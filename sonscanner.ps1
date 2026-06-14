#requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Ensure required assemblies are loaded
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml

# Son Scanner is a transparent, local system review utility.
# It does not upload information, read credentials, or execute remote code.

$script:Results = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
$script:CurrentMode = 'Presence'
$script:ScanRunning = $false
$script:CancelRequested = $false
$script:ScanStarted = $null
$script:CompletedChecks = 0
$script:TotalChecks = 0

function New-ScanResult {
    param(
        [Parameter(Mandatory)][string]$Mode,
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$CheckName,
        [ValidateSet('Clean','Information','Warning','Detected','Error')][string]$Status = 'Information',
        [Parameter(Mandatory)][string]$Description,
        [string]$Details = ''
    )

    [pscustomobject]@{
        Timestamp   = Get-Date
        Mode        = $Mode
        Category    = $Category
        Status      = $Status
        CheckName   = $CheckName
        Description = $Description
        Details     = $Details
    }
}

function Test-OperatingSystem {
    param([string]$Mode)
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        New-ScanResult -Mode $Mode -Category 'System' -CheckName 'Operating system' -Status 'Information' `
            -Description 'Windows information was collected successfully.' `
            -Details ("{0}, build {1}, {2}-bit" -f $os.Caption, $os.BuildNumber, $os.OSArchitecture)
    }
    catch {
        New-ScanResult -Mode $Mode -Category 'System' -CheckName 'Operating system' -Status 'Error' `
            -Description 'Windows information could not be collected.' -Details $_.Exception.Message
    }
}

function Test-PowerShellEnvironment {
    param([string]$Mode)
    $status = if ($PSVersionTable.PSVersion.Major -ge 5) { 'Clean' } else { 'Warning' }
    New-ScanResult -Mode $Mode -Category 'Runtime' -CheckName 'PowerShell environment' -Status $status `
        -Description 'The local PowerShell runtime was reviewed.' `
        -Details ("PowerShell {0}; edition {1}" -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition)
}

function Test-AdministratorContext {
    param([string]$Mode)
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    New-ScanResult -Mode $Mode -Category 'Permissions' -CheckName 'Permission context' -Status 'Information' `
        -Description 'The current permission level was identified.' `
        -Details $(if ($isAdmin) { 'Running with administrator permissions.' } else { 'Running with standard user permissions.' })
}

function Test-SystemDriveSpace {
    param([string]$Mode)
    try {
        $driveName = [IO.Path]::GetPathRoot($env:SystemRoot).TrimEnd('\')
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$driveName'"
        $freeGb = [math]::Round($disk.FreeSpace / 1GB, 1)
        $totalGb = [math]::Round($disk.Size / 1GB, 1)
        $percent = if ($disk.Size) { [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1) } else { 0 }
        $status = if ($percent -lt 10) { 'Warning' } else { 'Clean' }
        New-ScanResult -Mode $Mode -Category 'Storage' -CheckName 'System drive space' -Status $status `
            -Description 'Available space on the Windows system drive was checked.' `
            -Details ("{0} GB free of {1} GB ({2}%)." -f $freeGb, $totalGb, $percent)
    }
    catch {
        New-ScanResult -Mode $Mode -Category 'Storage' -CheckName 'System drive space' -Status 'Error' `
            -Description 'System drive space could not be checked.' -Details $_.Exception.Message
    }
}

function Test-RunningProcessSummary {
    param([string]$Mode)
    try {
        $processes = @(Get-Process -ErrorAction SilentlyContinue)
        $highMemory = @($processes | Where-Object WorkingSet64 -gt 1GB)
        New-ScanResult -Mode $Mode -Category 'Processes' -CheckName 'Running process summary' -Status 'Information' `
            -Description 'A non-invasive summary of running processes was created.' `
            -Details ("{0} processes running; {1} currently use more than 1 GB of memory." -f $processes.Count, $highMemory.Count)
    }
    catch {
        New-ScanResult -Mode $Mode -Category 'Processes' -CheckName 'Running process summary' -Status 'Error' `
            -Description 'Running processes could not be summarized.' -Details $_.Exception.Message
    }
}

function Test-RecentApplicationCrashes {
    param([string]$Mode)
    try {
        $start = (Get-Date).AddDays(-7)
        $events = @(Get-WinEvent -FilterHashtable @{ LogName='Application'; Level=2; StartTime=$start } -MaxEvents 100 -ErrorAction Stop |
            Where-Object { $_.ProviderName -in @('Application Error','Windows Error Reporting') })
        $status = if ($events.Count -gt 10) { 'Warning' } else { 'Information' }
        New-ScanResult -Mode $Mode -Category 'Diagnostics' -CheckName 'Recent application crashes' -Status $status `
            -Description 'Recent Windows application crash events were counted.' `
            -Details ("{0} relevant error events were found in the last seven days." -f $events.Count)
    }
    catch {
        New-ScanResult -Mode $Mode -Category 'Diagnostics' -CheckName 'Recent application crashes' -Status 'Information' `
            -Description 'The Application event log was unavailable or access was limited.' -Details $_.Exception.Message
    }
}

function Test-StartupEntrySummary {
    param([string]$Mode)
    try {
        $entries = @(Get-CimInstance Win32_StartupCommand -ErrorAction Stop)
        New-ScanResult -Mode $Mode -Category 'Startup' -CheckName 'Startup entry summary' -Status 'Information' `
            -Description 'Visible Windows startup entries were counted.' `
            -Details ("{0} startup entries are registered." -f $entries.Count)
    }
    catch {
        New-ScanResult -Mode $Mode -Category 'Startup' -CheckName 'Startup entry summary' -Status 'Error' `
            -Description 'Startup entries could not be reviewed.' -Details $_.Exception.Message
    }
}

function Test-TemporaryExecutableSummary {
    param([string]$Mode)
    try {
        $cutoff = (Get-Date).AddDays(-7)
        $extensions = @('.exe','.dll','.ps1','.bat','.cmd','.vbs','.js')
        $files = @(Get-ChildItem -LiteralPath $env:TEMP -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -ge $cutoff -and $extensions -contains $_.Extension.ToLowerInvariant() } |
            Select-Object -First 500)
        $status = if ($files.Count -ge 100) { 'Warning' } else { 'Information' }
        New-ScanResult -Mode $Mode -Category 'Temporary files' -CheckName 'Recent executable-type temporary files' -Status $status `
            -Description 'Recent executable-type files in the current user temporary directory were counted.' `
            -Details ("{0} matching files were found; the review was limited to 500 items." -f $files.Count)
    }
    catch {
        New-ScanResult -Mode $Mode -Category 'Temporary files' -CheckName 'Recent executable-type temporary files' -Status 'Error' `
            -Description 'The temporary directory could not be reviewed.' -Details $_.Exception.Message
    }
}

function Test-DefenderStatus {
    param([string]$Mode)
    try {
        $status = Get-MpComputerStatus -ErrorAction Stop
        $healthy = $status.AntivirusEnabled -and $status.RealTimeProtectionEnabled
        New-ScanResult -Mode $Mode -Category 'Security' -CheckName 'Microsoft Defender status' `
            -Status $(if ($healthy) { 'Clean' } else { 'Warning' }) `
            -Description 'The visible Microsoft Defender protection state was checked.' `
            -Details ("Antivirus enabled: {0}; real-time protection: {1}." -f $status.AntivirusEnabled, $status.RealTimeProtectionEnabled)
    }
    catch {
        New-ScanResult -Mode $Mode -Category 'Security' -CheckName 'Microsoft Defender status' -Status 'Information' `
            -Description 'Microsoft Defender status was unavailable. Another security product may be installed.' -Details $_.Exception.Message
    }
}

function Get-ScanDefinitions {
    @(
        [pscustomobject]@{ Name='Operating system'; Function='Test-OperatingSystem'; Modes=@('Presence','Basic SS','Normal SS','Full SS') }
        [pscustomobject]@{ Name='PowerShell environment'; Function='Test-PowerShellEnvironment'; Modes=@('Presence','Basic SS','Normal SS','Full SS') }
        [pscustomobject]@{ Name='Permission context'; Function='Test-AdministratorContext'; Modes=@('Basic SS','Normal SS','Full SS') }
        [pscustomobject]@{ Name='System drive space'; Function='Test-SystemDriveSpace'; Modes=@('Basic SS','Normal SS','Full SS') }
        [pscustomobject]@{ Name='Running process summary'; Function='Test-RunningProcessSummary'; Modes=@('Normal SS','Full SS') }
        [pscustomobject]@{ Name='Microsoft Defender status'; Function='Test-DefenderStatus'; Modes=@('Normal SS','Full SS') }
        [pscustomobject]@{ Name='Recent application crashes'; Function='Test-RecentApplicationCrashes'; Modes=@('Full SS') }
        [pscustomobject]@{ Name='Startup entry summary'; Function='Test-StartupEntrySummary'; Modes=@('Full SS') }
        [pscustomobject]@{ Name='Recent executable-type temporary files'; Function='Test-TemporaryExecutableSummary'; Modes=@('Full SS') }
    )
}

function Convert-ResultsToHtml {
    param([object[]]$InputResults, [string]$Mode, [timespan]$Duration)
    $rows = foreach ($item in $InputResults) {
        $statusClass = [System.Net.WebUtility]::HtmlEncode($item.Status.ToLowerInvariant())
        '<tr><td>{0}</td><td>{1}</td><td><span class="badge {2}">{3}</span></td><td>{4}</td><td>{5}</td><td>{6}</td></tr>' -f `
            [System.Net.WebUtility]::HtmlEncode($item.Timestamp.ToString('yyyy-MM-dd HH:mm:ss')),
            [System.Net.WebUtility]::HtmlEncode($item.Category), $statusClass,
            [System.Net.WebUtility]::HtmlEncode($item.Status),
            [System.Net.WebUtility]::HtmlEncode($item.CheckName),
            [System.Net.WebUtility]::HtmlEncode($item.Description),
            [System.Net.WebUtility]::HtmlEncode($item.Details)
    }
    @"
<!doctype html><html><head><meta charset="utf-8"><title>Son Scanner Report</title>
<style>body{font-family:Segoe UI,Arial;background:#0b1020;color:#e8edf7;margin:0;padding:32px}.wrap{max-width:1200px;margin:auto}.card{background:#121a2c;border:1px solid #26324a;border-radius:16px;padding:24px;margin-bottom:20px}h1{margin:0 0 8px}.muted{color:#98a5ba}table{width:100%;border-collapse:collapse;background:#121a2c}th,td{text-align:left;padding:12px;border-bottom:1px solid #26324a;vertical-align:top}th{color:#98a5ba}.badge{padding:4px 9px;border-radius:999px;font-weight:600}.clean{background:#153b33;color:#62e6b5}.information{background:#173454;color:#7cc7ff}.warning{background:#4a3715;color:#ffd166}.detected,.error{background:#4a1d2b;color:#ff8ba0}</style></head>
<body><div class="wrap"><div class="card"><h1>Son Scanner Report</h1><div class="muted">Mode: $Mode · Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') · Computer: $env:COMPUTERNAME · Duration: $([math]::Round($Duration.TotalSeconds,1)) seconds</div></div>
<div class="card"><table><thead><tr><th>Time</th><th>Category</th><th>Status</th><th>Check</th><th>Description</th><th>Details</th></tr></thead><tbody>$($rows -join [Environment]::NewLine)</tbody></table></div></div></body></html>
"@
}

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Son Scanner" Width="1240" Height="790" MinWidth="980" MinHeight="650"
        WindowStyle="None" ResizeMode="CanResize" Background="Transparent"
        AllowsTransparency="True" Opacity="0" FontFamily="Segoe UI">
    <Window.Resources>
        <SolidColorBrush x:Key="WindowBackground" Color="#080D18"/>
        <SolidColorBrush x:Key="SidebarBackground" Color="#0C1322"/>
        <SolidColorBrush x:Key="CardBackground" Color="#111A2B"/>
        <SolidColorBrush x:Key="CardHover" Color="#162238"/>
        <SolidColorBrush x:Key="BorderBrush" Color="#26344E"/>
        <SolidColorBrush x:Key="Primary" Color="#7C6CF2"/>
        <SolidColorBrush x:Key="PrimaryHover" Color="#9184FF"/>
        <SolidColorBrush x:Key="Accent" Color="#45D5B4"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#F4F7FC"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#93A1B8"/>

        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#0B1220"/><Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/><Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="11,8"/><Setter Property="CaretBrush" Value="White"/>
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="#0B1220"/><Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/><Setter Property="Padding" Value="8,5"/>
        </Style>
        <Style x:Key="NavButton" TargetType="Button">
            <Setter Property="Foreground" Value="{StaticResource TextSecondary}"/><Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/><Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Padding" Value="16,11"/><Setter Property="Margin" Value="8,2"/><Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="Bg" Background="{TemplateBinding Background}" CornerRadius="9"><ContentPresenter VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Bg" Property="Background" Value="#18243A"/><Setter Property="Foreground" Value="White"/></Trigger><Trigger Property="IsPressed" Value="True"><Setter TargetName="Bg" Property="Opacity" Value="0.72"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.4"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
        </Style>
        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Background" Value="{StaticResource Primary}"/><Setter Property="Foreground" Value="White"/><Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="16,9"/><Setter Property="Margin" Value="0,0,8,8"/><Setter Property="FontWeight" Value="SemiBold"/><Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="Bg" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Bg" Property="Background" Value="{StaticResource PrimaryHover}"/></Trigger><Trigger Property="IsPressed" Value="True"><Setter TargetName="Bg" Property="RenderTransform"><Setter.Value><ScaleTransform ScaleX="0.97" ScaleY="0.97"/></Setter.Value></Setter></Trigger><Trigger Property="IsEnabled" Value="False"><Setter TargetName="Bg" Property="Opacity" Value="0.38"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
        </Style>
        <Style x:Key="SecondaryButton" TargetType="Button" BasedOn="{StaticResource PrimaryButton}">
            <Setter Property="Background" Value="#19253A"/><Setter Property="Foreground" Value="#DCE4F2"/>
        </Style>
        <Style x:Key="WindowButton" TargetType="Button">
            <Setter Property="Width" Value="44"/><Setter Property="Height" Value="34"/><Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#AAB5C8"/><Setter Property="BorderThickness" Value="0"/><Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="Bg" Background="{TemplateBinding Background}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Bg" Property="Background" Value="#22304A"/><Setter Property="Foreground" Value="White"/></Trigger><Trigger Property="IsPressed" Value="True"><Setter TargetName="Bg" Property="Opacity" Value="0.6"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
        </Style>
    </Window.Resources>

    <Border Background="{StaticResource WindowBackground}" BorderBrush="#34425E" BorderThickness="1" CornerRadius="14">
        <Border.Effect><DropShadowEffect Color="#000000" BlurRadius="30" ShadowDepth="5" Opacity="0.55"/></Border.Effect>
        <Grid>
            <Grid.RowDefinitions><RowDefinition Height="46"/><RowDefinition Height="*"/></Grid.RowDefinitions>
            <Grid x:Name="TitleBar" Background="#0A101D">
                <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <StackPanel Orientation="Horizontal" Margin="18,0" VerticalAlignment="Center">
                    <Border Width="24" Height="24" CornerRadius="7" Background="{StaticResource Primary}"><TextBlock Text="S" Foreground="White" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
                    <TextBlock Text="Son Scanner" Foreground="White" FontWeight="SemiBold" Margin="10,0,0,0" VerticalAlignment="Center"/>
                    <TextBlock Text="  2.0" Foreground="{StaticResource TextSecondary}" VerticalAlignment="Center"/>
                </StackPanel>
                <StackPanel Grid.Column="1" Orientation="Horizontal"><Button x:Name="MinimizeButton" Content="—" Style="{StaticResource WindowButton}" ToolTip="Minimize"/><Button x:Name="MaximizeButton" Content="□" Style="{StaticResource WindowButton}" ToolTip="Maximize or restore"/><Button x:Name="CloseButton" Content="×" Style="{StaticResource WindowButton}" ToolTip="Close"/></StackPanel>
            </Grid>

            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions><ColumnDefinition Width="224"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                <Border Background="{StaticResource SidebarBackground}" CornerRadius="0,0,0,14">
                    <DockPanel LastChildFill="True">
                        <StackPanel DockPanel.Dock="Top" Margin="0,18,0,0">
                            <TextBlock Text="WORKSPACE" Foreground="#61708A" FontSize="10" FontWeight="Bold" Margin="23,0,0,8"/>
                            <Button x:Name="DashboardNav" Content="⌂   Dashboard" Style="{StaticResource NavButton}" ToolTip="Open dashboard"/>
                            <Button x:Name="PresenceNav" Content="◌   Presence" Style="{StaticResource NavButton}" ToolTip="Open Presence mode"/>
                            <Button x:Name="BasicNav" Content="◇   Basic SS" Style="{StaticResource NavButton}" ToolTip="Open Basic SS mode"/>
                            <Button x:Name="NormalNav" Content="◈   Normal SS" Style="{StaticResource NavButton}" ToolTip="Open Normal SS mode"/>
                            <Button x:Name="FullNav" Content="◆   Full SS" Style="{StaticResource NavButton}" ToolTip="Open Full SS mode"/>
                            <Separator Margin="20,10" Background="#253149"/>
                            <Button x:Name="ResultsNav" Content="▤   Results" Style="{StaticResource NavButton}" ToolTip="Open results"/>
                            <Button x:Name="SettingsNav" Content="⚙   Settings" Style="{StaticResource NavButton}" ToolTip="Open settings"/>
                            <Button x:Name="AboutNav" Content="ⓘ   About" Style="{StaticResource NavButton}" ToolTip="Open information"/>
                        </StackPanel>
                        <Border DockPanel.Dock="Bottom" Margin="14" Padding="13" CornerRadius="10" Background="#121D31">
                            <StackPanel><TextBlock Text="STATUS" Foreground="#61708A" FontSize="10" FontWeight="Bold"/><StackPanel Orientation="Horizontal" Margin="0,7,0,0"><Ellipse Width="8" Height="8" Fill="{StaticResource Accent}" Margin="0,0,8,0"/><TextBlock x:Name="SidebarStatusText" Text="Ready" Foreground="White"/></StackPanel></StackPanel>
                        </Border>
                    </DockPanel>
                </Border>

                <Grid Grid.Column="1" Margin="28,22,28,20">
                    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                    <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><StackPanel><TextBlock x:Name="PageTitle" Text="Dashboard" Foreground="White" FontSize="28" FontWeight="SemiBold"/><TextBlock x:Name="PageSubtitle" Text="Transparent local system checks." Foreground="{StaticResource TextSecondary}" Margin="0,4,0,0"/></StackPanel><Border Grid.Column="1" Background="#16283A" CornerRadius="999" Padding="13,7" VerticalAlignment="Center"><TextBlock x:Name="HeaderBadge" Text="READY" Foreground="{StaticResource Accent}" FontWeight="Bold" FontSize="11"/></Border></Grid>

                    <Grid Grid.Row="1" Margin="0,20,0,14">
                        <Grid x:Name="DashboardPage">
                            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                            <UniformGrid Rows="1" Columns="4">
                                <Border Background="{StaticResource CardBackground}" CornerRadius="14" Margin="4" Padding="18"><StackPanel><TextBlock Text="Completed checks" Foreground="{StaticResource TextSecondary}"/><TextBlock x:Name="CompletedValue" Text="0" Foreground="White" FontSize="30" FontWeight="Bold"/></StackPanel></Border>
                                <Border Background="{StaticResource CardBackground}" CornerRadius="14" Margin="4" Padding="18"><StackPanel><TextBlock Text="Warnings" Foreground="{StaticResource TextSecondary}"/><TextBlock x:Name="WarningsValue" Text="0" Foreground="#FFD166" FontSize="30" FontWeight="Bold"/></StackPanel></Border>
                                <Border Background="{StaticResource CardBackground}" CornerRadius="14" Margin="4" Padding="18"><StackPanel><TextBlock Text="Detected" Foreground="{StaticResource TextSecondary}"/><TextBlock x:Name="DetectedValue" Text="0" Foreground="#FF879A" FontSize="30" FontWeight="Bold"/></StackPanel></Border>
                                <Border Background="{StaticResource CardBackground}" CornerRadius="14" Margin="4" Padding="18"><StackPanel><TextBlock Text="Last scan" Foreground="{StaticResource TextSecondary}"/><TextBlock x:Name="LastScanValue" Text="Never" Foreground="White" FontSize="16" FontWeight="SemiBold" Margin="0,8,0,0"/></StackPanel></Border>
                            </UniformGrid>
                            <Grid Grid.Row="1" Margin="4,14,4,0"><Grid.ColumnDefinitions><ColumnDefinition Width="2*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <Border Background="{StaticResource CardBackground}" CornerRadius="14" Padding="22" Margin="0,0,10,0"><StackPanel><TextBlock Text="Quick start" Foreground="White" FontSize="19" FontWeight="SemiBold"/><TextBlock Text="Choose a review level. Every check is visible and remains on this computer." Foreground="{StaticResource TextSecondary}" Margin="0,6,0,16" TextWrapping="Wrap"/><WrapPanel><Button x:Name="QuickPresence" Content="Start Presence" Style="{StaticResource PrimaryButton}" ToolTip="Run lightweight checks"/><Button x:Name="QuickBasic" Content="Start Basic SS" Style="{StaticResource SecondaryButton}" ToolTip="Run basic checks"/><Button x:Name="QuickNormal" Content="Start Normal SS" Style="{StaticResource SecondaryButton}" ToolTip="Run balanced checks"/><Button x:Name="QuickFull" Content="Start Full SS" Style="{StaticResource SecondaryButton}" ToolTip="Run all checks"/></WrapPanel><ProgressBar x:Name="DashboardProgress" Height="10" Margin="0,22,0,9" Minimum="0" Maximum="100" Foreground="{StaticResource Primary}" Background="#080E19"/><TextBlock x:Name="CurrentTaskText" Text="No scan is running." Foreground="{StaticResource TextSecondary}"/></StackPanel></Border>
                                <Border Grid.Column="1" Background="{StaticResource CardBackground}" CornerRadius="14" Padding="22"><StackPanel><TextBlock Text="System summary" Foreground="White" FontSize="19" FontWeight="SemiBold"/><TextBlock x:Name="SystemSummaryText" Foreground="{StaticResource TextSecondary}" Margin="0,13,0,0" TextWrapping="Wrap" LineHeight="23"/></StackPanel></Border>
                            </Grid>
                        </Grid>

                        <Grid x:Name="ModePage" Visibility="Collapsed"><Border Background="{StaticResource CardBackground}" CornerRadius="14" Padding="28"><StackPanel><TextBlock x:Name="ModeTitle" Text="Presence" Foreground="White" FontSize="26" FontWeight="SemiBold"/><TextBlock x:Name="ModeDescription" Foreground="{StaticResource TextSecondary}" TextWrapping="Wrap" Margin="0,9,0,12"/><TextBlock x:Name="ModeIntensity" Foreground="{StaticResource Accent}" FontWeight="SemiBold"/><ProgressBar x:Name="ModeProgress" Height="12" Margin="0,25,0,9" Minimum="0" Maximum="100" Foreground="{StaticResource Primary}" Background="#080E19"/><TextBlock x:Name="ModeTaskText" Text="Ready." Foreground="{StaticResource TextSecondary}"/><WrapPanel Margin="0,20,0,0"><Button x:Name="StartScanButton" Content="Start Scan" Style="{StaticResource PrimaryButton}" ToolTip="Start this scan mode"/><Button x:Name="StopScanButton" Content="Stop Scan" Style="{StaticResource SecondaryButton}" IsEnabled="False" ToolTip="Cancel before the next check"/><Button x:Name="ReturnDashboardButton" Content="Return to Dashboard" Style="{StaticResource SecondaryButton}" ToolTip="Return to dashboard"/></WrapPanel></StackPanel></Border></Grid>

                        <Grid x:Name="ResultsPage" Visibility="Collapsed"><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions><WrapPanel><TextBox x:Name="ResultSearchBox" Width="245" Margin="0,0,8,8" ToolTip="Search results"/><ComboBox x:Name="SeverityFilter" Width="145" Margin="0,0,8,8" ToolTip="Filter by status"><ComboBoxItem Content="All" IsSelected="True"/><ComboBoxItem Content="Clean"/><ComboBoxItem Content="Information"/><ComboBoxItem Content="Warning"/><ComboBoxItem Content="Detected"/><ComboBoxItem Content="Error"/></ComboBox><Button x:Name="RefreshResultsButton" Content="Refresh" Style="{StaticResource SecondaryButton}" ToolTip="Refresh filters"/><Button x:Name="ClearResultsButton" Content="Clear Results" Style="{StaticResource SecondaryButton}" ToolTip="Clear all results"/><Button x:Name="CopyResultsButton" Content="Copy Results" Style="{StaticResource SecondaryButton}" ToolTip="Copy visible results"/><Button x:Name="ExportResultsButton" Content="Export Results" Style="{StaticResource PrimaryButton}" ToolTip="Export visible results"/></WrapPanel><DataGrid x:Name="ResultsGrid" Grid.Row="1" Margin="0,10,0,0" AutoGenerateColumns="False" IsReadOnly="True" Background="#0B1220" Foreground="White" BorderBrush="{StaticResource BorderBrush}" GridLinesVisibility="Horizontal" RowBackground="#10192A" AlternatingRowBackground="#131E32"><DataGrid.Columns><DataGridTextColumn Header="Time" Binding="{Binding Timestamp, StringFormat=HH:mm:ss}" Width="82"/><DataGridTextColumn Header="Mode" Binding="{Binding Mode}" Width="90"/><DataGridTextColumn Header="Category" Binding="{Binding Category}" Width="110"/><DataGridTextColumn Header="Status" Binding="{Binding Status}" Width="100"/><DataGridTextColumn Header="Check" Binding="{Binding CheckName}" Width="185"/><DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="*"/><DataGridTextColumn Header="Details" Binding="{Binding Details}" Width="270"/></DataGrid.Columns></DataGrid></Grid>

                        <Grid x:Name="SettingsPage" Visibility="Collapsed"><Border Background="{StaticResource CardBackground}" CornerRadius="14" Padding="28"><StackPanel Width="590" HorizontalAlignment="Left"><TextBlock Text="Session settings" Foreground="White" FontSize="21" FontWeight="SemiBold"/><TextBlock Text="Settings are kept only while this window is open. No configuration file is created." Foreground="{StaticResource TextSecondary}" TextWrapping="Wrap" Margin="0,6,0,18"/><TextBlock Text="Default scan mode" Foreground="{StaticResource TextSecondary}" Margin="0,0,0,6"/><ComboBox x:Name="DefaultModeCombo"><ComboBoxItem Content="Presence" IsSelected="True"/><ComboBoxItem Content="Basic SS"/><ComboBoxItem Content="Normal SS"/><ComboBoxItem Content="Full SS"/></ComboBox><CheckBox x:Name="ConfirmFullCheck" Content="Confirm before Full SS" IsChecked="True" Foreground="White" Margin="0,16,0,0"/><CheckBox x:Name="AnimationsCheck" Content="Enable window animation" IsChecked="True" Foreground="White" Margin="0,9,0,0"/><WrapPanel Margin="0,21,0,0"><Button x:Name="SaveSettingsButton" Content="Apply Settings" Style="{StaticResource PrimaryButton}" ToolTip="Apply settings for this session"/><Button x:Name="ResetSettingsButton" Content="Reset Settings" Style="{StaticResource SecondaryButton}" ToolTip="Restore session defaults"/></WrapPanel></StackPanel></Border></Grid>

                        <Grid x:Name="AboutPage" Visibility="Collapsed"><Border Background="{StaticResource CardBackground}" CornerRadius="14" Padding="30"><StackPanel><TextBlock Text="Son Scanner" Foreground="White" FontSize="30" FontWeight="Bold"/><TextBlock Text="Single-file edition · Version 2.0" Foreground="{StaticResource Accent}" Margin="0,5,0,20"/><TextBlock Foreground="{StaticResource TextSecondary}" TextWrapping="Wrap" FontSize="14" LineHeight="23" Text="A transparent local system review utility. It performs visible checks for system information, permissions, storage, running-process counts, Windows security status, startup-entry counts, recent application crashes, and temporary executable-type files. It does not read passwords, browser data, cookies, authentication tokens, private messages, or account secrets. It does not upload information, contact external services, execute downloaded code, or create activity log files."/></StackPanel></Border></Grid>
                    </Grid>

                    <Border Grid.Row="2" Background="#0C1423" CornerRadius="10" Padding="12,8"><Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock x:Name="FooterStatus" Text="Ready" Foreground="{StaticResource TextSecondary}"/><TextBlock Grid.Column="1" x:Name="FooterCounters" Text="0 checks · 0 warnings · 0 detected" Foreground="{StaticResource TextSecondary}"/></Grid></Border>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

function Get-Control([string]$Name) { $Window.FindName($Name) }

$ResultsGrid = Get-Control 'ResultsGrid'
$ResultsGrid.ItemsSource = $script:Results

$script:ConfirmBeforeFull = $true
$script:AnimationsEnabled = $true

function Show-Page([string]$PageName, [string]$Title, [string]$Subtitle) {
    foreach ($page in 'DashboardPage','ModePage','ResultsPage','SettingsPage','AboutPage') {
        (Get-Control $page).Visibility = 'Collapsed'
    }
    (Get-Control $PageName).Visibility = 'Visible'
    (Get-Control 'PageTitle').Text = $Title
    (Get-Control 'PageSubtitle').Text = $Subtitle
}

function Set-Mode([string]$Mode) {
    $script:CurrentMode = $Mode
    $details = switch ($Mode) {
        'Presence'  { @('A lightweight environment and runtime overview.', 'Estimated intensity: Very low') }
        'Basic SS'  { @('A quick local system and storage review.', 'Estimated intensity: Low') }
        'Normal SS' { @('A balanced review including process and security summaries.', 'Estimated intensity: Medium') }
        'Full SS'   { @('All approved local checks, including diagnostics and startup summaries.', 'Estimated intensity: Medium') }
    }
    Show-Page 'ModePage' $Mode $details[0]
    (Get-Control 'ModeTitle').Text = $Mode
    (Get-Control 'ModeDescription').Text = $details[0]
    (Get-Control 'ModeIntensity').Text = $details[1]
}

function Update-Counters {
    $warnings = @($script:Results | Where-Object Status -eq 'Warning').Count
    $detected = @($script:Results | Where-Object Status -eq 'Detected').Count
    (Get-Control 'CompletedValue').Text = [string]$script:Results.Count
    (Get-Control 'WarningsValue').Text = [string]$warnings
    (Get-Control 'DetectedValue').Text = [string]$detected
    (Get-Control 'FooterCounters').Text = '{0} checks · {1} warnings · {2} detected' -f $script:Results.Count, $warnings, $detected
}

function Refresh-ResultsView {
    $search = (Get-Control 'ResultSearchBox').Text.Trim()
    $selected = (Get-Control 'SeverityFilter').SelectedItem
    $severity = if ($selected) { [string]$selected.Content } else { 'All' }
    $filtered = @($script:Results | Where-Object {
        ($severity -eq 'All' -or $_.Status -eq $severity) -and
        ([string]::IsNullOrWhiteSpace($search) -or (($_ | Out-String) -match [regex]::Escape($search)))
    })
    $ResultsGrid.ItemsSource = $filtered
}

function Set-ScanningUi([bool]$Running) {
    $script:ScanRunning = $Running
    (Get-Control 'StartScanButton').IsEnabled = -not $Running
    (Get-Control 'StopScanButton').IsEnabled = $Running
    (Get-Control 'SidebarStatusText').Text = if ($Running) { 'Scanning' } else { 'Ready' }
    (Get-Control 'HeaderBadge').Text = if ($Running) { 'SCANNING' } else { 'READY' }
    (Get-Control 'FooterStatus').Text = if ($Running) { 'Scan in progress' } else { 'Ready' }
}

function Start-Scan([string]$Mode) {
    if ($script:ScanRunning) { return }
    if ($Mode -eq 'Full SS' -and $script:ConfirmBeforeFull) {
        $choice = [System.Windows.MessageBox]::Show('Full SS runs every approved local check. Continue?', 'Son Scanner', 'YesNo', 'Warning')
        if ($choice -ne 'Yes') { return }
    }

    $definitions = @(Get-ScanDefinitions | Where-Object Modes -contains $Mode)
    $queue = [System.Collections.Queue]::new()
    foreach ($definition in $definitions) { $queue.Enqueue($definition) }

    $script:CancelRequested = $false
    $script:ScanStarted = Get-Date
    $script:CompletedChecks = 0
    $script:TotalChecks = $definitions.Count
    (Get-Control 'ModeProgress').Value = 0
    (Get-Control 'DashboardProgress').Value = 0
    Set-ScanningUi $true

    $timer = [Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(100)
    $timer.Add_Tick({
        if ($script:CancelRequested) {
            $timer.Stop()
            Set-ScanningUi $false
            (Get-Control 'ModeTaskText').Text = 'Scan cancelled.'
            (Get-Control 'CurrentTaskText').Text = 'Scan cancelled.'
            return
        }

        if ($queue.Count -eq 0) {
            $timer.Stop()
            Set-ScanningUi $false
            (Get-Control 'ModeProgress').Value = 100
            (Get-Control 'DashboardProgress').Value = 100
            (Get-Control 'ModeTaskText').Text = 'Scan completed.'
            (Get-Control 'CurrentTaskText').Text = 'Scan completed.'
            (Get-Control 'LastScanValue').Text = (Get-Date).ToString('g')
            Update-Counters
            return
        }

        $definition = $queue.Dequeue()
        (Get-Control 'ModeTaskText').Text = "Running: $($definition.Name)"
        (Get-Control 'CurrentTaskText').Text = "Running: $($definition.Name)"
        try {
            $result = & $definition.Function -Mode $Mode
            $script:Results.Add($result)
        }
        catch {
            $script:Results.Add((New-ScanResult -Mode $Mode -Category 'Runtime' -CheckName $definition.Name -Status 'Error' -Description 'The check failed.' -Details $_.Exception.Message))
        }

        $script:CompletedChecks++
        $percentage = [math]::Round(($script:CompletedChecks / [math]::Max(1, $script:TotalChecks)) * 100)
        (Get-Control 'ModeProgress').Value = $percentage
        (Get-Control 'DashboardProgress').Value = $percentage
        Update-Counters
    })
    $timer.Start()
}

# Custom title bar.
(Get-Control 'TitleBar').Add_MouseLeftButtonDown({
    if ($_.ClickCount -eq 2) {
        $Window.WindowState = if ($Window.WindowState -eq 'Maximized') { 'Normal' } else { 'Maximized' }
    }
    else { $Window.DragMove() }
})
(Get-Control 'MinimizeButton').Add_Click({ $Window.WindowState = 'Minimized' })
(Get-Control 'MaximizeButton').Add_Click({ $Window.WindowState = if ($Window.WindowState -eq 'Maximized') { 'Normal' } else { 'Maximized' } })
(Get-Control 'CloseButton').Add_Click({ $Window.Close() })

# Navigation.
(Get-Control 'DashboardNav').Add_Click({ Show-Page 'DashboardPage' 'Dashboard' 'Transparent local system checks.' })
(Get-Control 'PresenceNav').Add_Click({ Set-Mode 'Presence' })
(Get-Control 'BasicNav').Add_Click({ Set-Mode 'Basic SS' })
(Get-Control 'NormalNav').Add_Click({ Set-Mode 'Normal SS' })
(Get-Control 'FullNav').Add_Click({ Set-Mode 'Full SS' })
(Get-Control 'ResultsNav').Add_Click({ Show-Page 'ResultsPage' 'Results' 'Search, filter, copy, and export current findings.'; Refresh-ResultsView })
(Get-Control 'SettingsNav').Add_Click({ Show-Page 'SettingsPage' 'Settings' 'Session-only preferences; no configuration file is created.' })
(Get-Control 'AboutNav').Add_Click({ Show-Page 'AboutPage' 'About' 'Safety and transparency information.' })
(Get-Control 'ReturnDashboardButton').Add_Click({ Show-Page 'DashboardPage' 'Dashboard' 'Transparent local system checks.' })

# Scan actions.
(Get-Control 'QuickPresence').Add_Click({ Set-Mode 'Presence'; Start-Scan 'Presence' })
(Get-Control 'QuickBasic').Add_Click({ Set-Mode 'Basic SS'; Start-Scan 'Basic SS' })
(Get-Control 'QuickNormal').Add_Click({ Set-Mode 'Normal SS'; Start-Scan 'Normal SS' })
(Get-Control 'QuickFull').Add_Click({ Set-Mode 'Full SS'; Start-Scan 'Full SS' })
(Get-Control 'StartScanButton').Add_Click({ Start-Scan $script:CurrentMode })
(Get-Control 'StopScanButton').Add_Click({ $script:CancelRequested = $true })

# Result actions.
(Get-Control 'ResultSearchBox').Add_TextChanged({ Refresh-ResultsView })
(Get-Control 'SeverityFilter').Add_SelectionChanged({ Refresh-ResultsView })
(Get-Control 'RefreshResultsButton').Add_Click({ Refresh-ResultsView })
(Get-Control 'ClearResultsButton').Add_Click({
    $script:Results.Clear()
    $ResultsGrid.ItemsSource = $script:Results
    Update-Counters
})
(Get-Control 'CopyResultsButton').Add_Click({
    try {
        $visible = @($ResultsGrid.ItemsSource)
        $text = ($visible | ForEach-Object { '[{0}] {1}: {2} {3}' -f $_.Status, $_.CheckName, $_.Description, $_.Details }) -join [Environment]::NewLine
        if ([string]::IsNullOrWhiteSpace($text)) { $text = 'No results.' }
        [Windows.Clipboard]::SetText($text)
    }
    catch { [System.Windows.MessageBox]::Show($_.Exception.Message, 'Copy failed', 'OK', 'Error') | Out-Null }
})
(Get-Control 'ExportResultsButton').Add_Click({
    try {
        $visible = @($ResultsGrid.ItemsSource)
        if ($visible.Count -eq 0) { [System.Windows.MessageBox]::Show('There are no visible results to export.', 'Son Scanner', 'OK', 'Information') | Out-Null; return }
        $dialog = [Microsoft.Win32.SaveFileDialog]::new()
        $dialog.Title = 'Export Son Scanner results'
        $dialog.Filter = 'HTML report (*.html)|*.html|JSON (*.json)|*.json|CSV (*.csv)|*.csv|Text (*.txt)|*.txt'
        $dialog.FileName = 'SonScanner_{0}' -f (Get-Date -Format 'yyyyMMdd_HHmmss')
        if ($dialog.ShowDialog() -ne $true) { return }
        $extension = [IO.Path]::GetExtension($dialog.FileName).ToLowerInvariant()
        switch ($extension) {
            '.html' { Convert-ResultsToHtml -InputResults $visible -Mode $script:CurrentMode -Duration ((Get-Date) - $script:ScanStarted) | Set-Content -LiteralPath $dialog.FileName -Encoding UTF8 }
            '.json' { $visible | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $dialog.FileName -Encoding UTF8 }
            '.csv'  { $visible | Export-Csv -LiteralPath $dialog.FileName -NoTypeInformation -Encoding UTF8 }
            '.txt'  { $visible | ForEach-Object { '[{0:u}] [{1}] [{2}] {3}: {4} — {5}' -f $_.Timestamp, $_.Mode, $_.Status, $_.CheckName, $_.Description, $_.Details } | Set-Content -LiteralPath $dialog.FileName -Encoding UTF8 }
            default { throw 'Unsupported export format.' }
        }
        [System.Windows.MessageBox]::Show('The results were exported successfully.', 'Son Scanner', 'OK', 'Information') | Out-Null
    }
    catch { [System.Windows.MessageBox]::Show($_.Exception.Message, 'Export failed', 'OK', 'Error') | Out-Null }
})

# Session-only settings.
(Get-Control 'SaveSettingsButton').Add_Click({
    $selected = (Get-Control 'DefaultModeCombo').SelectedItem
    if ($selected) { $script:CurrentMode = [string]$selected.Content }
    $script:ConfirmBeforeFull = [bool](Get-Control 'ConfirmFullCheck').IsChecked
    $script:AnimationsEnabled = [bool](Get-Control 'AnimationsCheck').IsChecked
    [System.Windows.MessageBox]::Show('Session settings were applied. No settings file was created.', 'Son Scanner', 'OK', 'Information') | Out-Null
})
(Get-Control 'ResetSettingsButton').Add_Click({
    (Get-Control 'DefaultModeCombo').SelectedIndex = 0
    (Get-Control 'ConfirmFullCheck').IsChecked = $true
    (Get-Control 'AnimationsCheck').IsChecked = $true
    $script:CurrentMode = 'Presence'
    $script:ConfirmBeforeFull = $true
    $script:AnimationsEnabled = $true
})

# Initial system summary.
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem
    (Get-Control 'SystemSummaryText').Text = "Computer: $env:COMPUTERNAME`nWindows: $($os.Caption)`nBuild: $($os.BuildNumber)`nMemory: $([math]::Round($computer.TotalPhysicalMemory / 1GB, 1)) GB`nPowerShell: $($PSVersionTable.PSVersion)"
}
catch {
    (Get-Control 'SystemSummaryText').Text = "Computer: $env:COMPUTERNAME`nPowerShell: $($PSVersionTable.PSVersion)`nDetailed system information is unavailable."
}

$Window.Add_ContentRendered({
    if ($script:AnimationsEnabled) {
        $animation = [Windows.Media.Animation.DoubleAnimation]::new(0, 1, [TimeSpan]::FromMilliseconds(320))
        $Window.BeginAnimation([Windows.Window]::OpacityProperty, $animation)
    }
    else { $Window.Opacity = 1 }
})

# Force running within an STA thread boundary wrapper to avoid freezing if invoked contextually
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    Write-Warning "Re-launching application inside required STA thread mode..."
    Powershell -NoProfile -ExecutionPolicy Bypass -Command {
        $code = Get-Content -Path $MyInvocation.MyCommand.Definition -Raw
        Invoke-Expression $code
    }
} else {
    $Window.ShowDialog() | Out-Null
}