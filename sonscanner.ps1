#requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
<!doctype html><html><head><meta charset="utf-8"><title>Son Scanner Cyber-Report</title>
<style>body{font-family:Segoe UI,Arial;background:#060913;color:#e8edf7;margin:0;padding:32px}.wrap{max-width:1200px;margin:auto}.card{background:#0e1322;border:1px solid #1f2d4a;border-radius:16px;padding:24px;margin-bottom:20px;box-shadow: 0 4px 20px rgba(0,0,0,0.3)}h1{margin:0 0 8px;color:#00f0ff}h1{text-shadow: 0 0 10px rgba(0,240,255,0.3)}.muted{color:#7687a1}table{width:100%;border-collapse:collapse;background:#0e1322}th,td{text-align:left;padding:12px;border-bottom:1px solid #1f2d4a;vertical-align:top}th{color:#7687a1}.badge{padding:4px 12px;border-radius:6px;font-weight:600;text-transform:uppercase;font-size:11px}.clean{background:#10382b;color:#00ffaa;border:1px solid #00ffaa}.information{background:#102b4d;color:#00bfff;border:1px solid #00bfff}.warning{background:#3d2e10;color:#ffaa00;border:1px solid #ffaa00}.detected,.error{background:#3d1420;color:#ff0055;border:1px solid #ff0055}</style></head>
<body><div class="wrap"><div class="card"><h1>Son Scanner Report</h1><div class="muted">Mode: $Mode · Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') · Computer: $env:COMPUTERNAME · Duration: $([math]::Round($Duration.TotalSeconds,1)) seconds</div></div>
<div class="card"><table><thead><tr><th>Time</th><th>Category</th><th>Status</th><th>Check</th><th>Description</th><th>Details</th></tr></thead><tbody>$($rows -join [Environment]::NewLine)</tbody></table></div></div></body></html>
"@
}

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Son Scanner Pro" Width="1280" Height="820" MinWidth="1020" MinHeight="680"
        WindowStyle="None" ResizeMode="CanResize" Background="Transparent"
        AllowsTransparency="True" Opacity="0" FontFamily="Segoe UI">
    <Window.Resources>
        <SolidColorBrush x:Key="WindowBackground" Color="#05070F"/>
        <SolidColorBrush x:Key="SidebarBackground" Color="#090D1A"/>
        <SolidColorBrush x:Key="CardBackground" Color="#0E1426"/>
        <SolidColorBrush x:Key="CardHover" Color="#151E38"/>
        <SolidColorBrush x:Key="BorderBrush" Color="#1F2D4A"/>
        <SolidColorBrush x:Key="Primary" Color="#00F0FF"/>
        <SolidColorBrush x:Key="PrimaryHover" Color="#80F7FF"/>
        <SolidColorBrush x:Key="AccentPurple" Color="#9D4EDD"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#F4F7FC"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#7687A1"/>

        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#070A14"/><Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/><Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,10"/><Setter Property="CaretBrush" Value="{StaticResource Primary}"/>
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="#070A14"/><Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/><Setter Property="Padding" Value="10,6"/>
        </Style>
        
        <Style x:Key="NavButton" TargetType="Button">
            <Setter Property="Foreground" Value="{StaticResource TextSecondary}"/><Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/><Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Padding" Value="20,14"/><Setter Property="Margin" Value="10,3"/><Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Template"><Setter.Value>
                <ControlTemplate TargetType="Button">
                    <Border x:Name="Bg" Background="{TemplateBinding Background}" CornerRadius="8" BorderThickness="2,0,0,0" BorderBrush="Transparent">
                        <ContentPresenter VerticalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter TargetName="Bg" Property="Background" Value="#121B30"/>
                            <Setter TargetName="Bg" Property="BorderBrush" Value="{StaticResource Primary}"/>
                            <Setter Property="Foreground" Value="White"/>
                        </Trigger>
                        <Trigger Property="IsPressed" Value="True"><Setter TargetName="Bg" Property="Opacity" Value="0.7"/></Trigger>
                    </ControlTemplate.Triggers>
                </ControlTemplate>
            </Setter.Value></Setter>
        </Style>

        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Background" Value="#102538"/><Setter Property="Foreground" Value="{StaticResource Primary}"/><Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="{StaticResource Primary}"/><Setter Property="Padding" Value="20,12"/><Setter Property="Margin" Value="0,0,10,10"/>
            <Setter Property="FontWeight" Value="Bold"/><Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template"><Setter.Value>
                <ControlTemplate TargetType="Button">
                    <Border x:Name="Bg" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter TargetName="Bg" Property="Background" Value="{StaticResource Primary}"/>
                            <Setter Property="Foreground" Value="#05070F"/>
                        </Trigger>
                        <Trigger Property="IsPressed" Value="True">
                            <Setter TargetName="Bg" Property="RenderTransform"><Setter.Value><ScaleTransform ScaleX="0.96" ScaleY="0.96"/></Setter.Value></Setter>
                        </Trigger>
                        <Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.25"/></Trigger>
                    </ControlTemplate.Triggers>
                </ControlTemplate>
            </Setter.Value></Setter>
        </Style>

        <Style x:Key="SecondaryButton" TargetType="Button" BasedOn="{StaticResource PrimaryButton}">
            <Setter Property="Background" Value="#18132B"/><Setter Property="Foreground" Value="#D4BFFF"/><Setter Property="BorderBrush" Value="{StaticResource AccentPurple}"/>
            <Setter Property="Template"><Setter.Value>
                <ControlTemplate TargetType="Button">
                    <Border x:Name="Bg" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter TargetName="Bg" Property="Background" Value="{StaticResource AccentPurple}"/>
                            <Setter Property="Foreground" Value="White"/>
                        </Trigger>
                    </ControlTemplate.Triggers>
                </ControlTemplate>
            </Setter.Value></Setter>
        </Style>

        <Style x:Key="WindowButton" TargetType="Button">
            <Setter Property="Width" Value="46"/><Setter Property="Height" Value="36"/><Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#7687A1"/><Setter Property="BorderThickness" Value="0"/><Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template"><Setter.Value>
                <ControlTemplate TargetType="Button">
                    <Border x:Name="Bg" Background="{TemplateBinding Background}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
                    <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Bg" Property="Background" Value="#1F2D4A"/><Setter Property="Foreground" Value="White"/></Trigger>
                    </ControlTemplate.Triggers>
                </ControlTemplate>
            </Setter.Value></Setter>
        </Style>
    </Window.Resources>

    <Border Background="{StaticResource WindowBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1.5" CornerRadius="16">
        <Border.Effect><DropShadowEffect Color="#000" BlurRadius="40" ShadowDepth="0" Opacity="0.85"/></Border.Effect>
        <Grid>
            <Grid.RowDefinitions><RowDefinition Height="50"/><RowDefinition Height="*"/></Grid.RowDefinitions>
            
            <Grid x:Name="TitleBar" Background="#070B14">
                <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <StackPanel Orientation="Horizontal" Margin="20,0" VerticalAlignment="Center">
                    <Border Width="26" Height="26" CornerRadius="6" Background="{StaticResource Primary}">
                        <TextBlock Text="S" Foreground="#05070F" FontWeight="Black" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="14"/>
                    </Border>
                    <TextBlock Text="SON SCANNER" Foreground="White" FontWeight="Black" LetterSpacing="2" Margin="12,0,0,0" VerticalAlignment="Center" FontSize="13"/>
                    <TextBlock Text="PRO EDITION" Foreground="{StaticResource AccentPurple}" FontWeight="Bold" FontSize="10" Margin="10,0,0,0" VerticalAlignment="Center" Background="#1B122C" Padding="6,2" CornerRadius="4"/>
                </StackPanel>
                <StackPanel Grid.Column="1" Orientation="Horizontal">
                    <Button x:Name="MinimizeButton" Content="—" Style="{StaticResource WindowButton}"/>
                    <Button x:Name="MaximizeButton" Content="▢" Style="{StaticResource WindowButton}"/>
                    <Button x:Name="CloseButton" Content="×" Style="{StaticResource WindowButton}" Foreground="#FF4560"/>
                </StackPanel>
            </Grid>

            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions><ColumnDefinition Width="240"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                
                <Border Background="{StaticResource SidebarBackground}" CornerRadius="0,0,0,16" BorderBrush="{StaticResource BorderBrush}" BorderThickness="0,0,1,0">
                    <DockPanel LastChildFill="True">
                        <StackPanel DockPanel.Dock="Top" Margin="0,24,0,0">
                            <TextBlock Text="SYSTEM NAVIGATION" Foreground="#47566E" FontSize="10" FontWeight="Black" LetterSpacing="1" Margin="24,0,0,12"/>
                            <Button x:Name="DashboardNav" Content="⌂   Dashboard" Style="{StaticResource NavButton}"/>
                            <Button x:Name="PresenceNav" Content="◌   Presence Mode" Style="{StaticResource NavButton}"/>
                            <Button x:Name="BasicNav" Content="◇   Basic SS" Style="{StaticResource NavButton}"/>
                            <Button x:Name="NormalNav" Content="◈   Normal SS" Style="{StaticResource NavButton}"/>
                            <Button x:Name="FullNav" Content="◆   Full SS" Style="{StaticResource NavButton}"/>
                            <Separator Margin="24,14" Background="{StaticResource BorderBrush}"/>
                            <TextBlock Text="DATA &amp; CONFIG" Foreground="#47566E" FontSize="10" FontWeight="Black" LetterSpacing="1" Margin="24,0,0,12"/>
                            <Button x:Name="ResultsNav" Content="▤   Scan Metrics" Style="{StaticResource NavButton}"/>
                            <Button x:Name="SettingsNav" Content="⚙   Preferences" Style="{StaticResource NavButton}"/>
                            <Button x:Name="AboutNav" Content="ⓘ   Engine Info" Style="{StaticResource NavButton}"/>
                        </StackPanel>
                        
                        <Border DockPanel.Dock="Bottom" Margin="16" Padding="16" CornerRadius="10" Background="#0C1224" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="CORE SCANNER ENGINE" Foreground="#47566E" FontSize="9" FontWeight="Black" LetterSpacing="0.5"/>
                                <StackPanel Orientation="Horizontal" Margin="0,10,0,0">
                                    <Ellipse x:Name="StatusPulseLight" Width="10" Height="10" Fill="#00F0FF" Margin="0,0,10,0">
                                        <Ellipse.Triggers>
                                            <EventTrigger RoutedEvent="Loaded">
                                                <BeginStoryboard>
                                                    <Storyboard RepeatBehavior="Forever">
                                                        <DoubleAnimation Storyboard.TargetProperty="Opacity" From="1" To="0.3" Duration="0:0:1" AutoReverse="True"/>
                                                    </Storyboard>
                                                </BeginStoryboard>
                                            </EventTrigger>
                                        </Ellipse.Triggers>
                                    </Ellipse>
                                    <TextBlock x:Name="SidebarStatusText" Text="SYSTEM READY" Foreground="White" FontWeight="Bold" FontSize="11" LetterSpacing="0.5"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>
                    </DockPanel>
                </Border>

                <Grid Grid.Column="1" Margin="32,26,32,24">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    
                    <Grid>
                        <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                        <StackPanel>
                            <TextBlock x:Name="PageTitle" Text="Dashboard" Foreground="White" FontSize="32" FontWeight="Black" LetterSpacing="-0.5"/>
                            <TextBlock x:Name="PageSubtitle" Text="Transparent local system infrastructure metrics." Foreground="{StaticResource TextSecondary}" Margin="0,6,0,0" FontSize="14"/>
                        </StackPanel>
                        <Border Grid.Column="1" Background="#102538" BorderBrush="{StaticResource Primary}" BorderThickness="1" CornerRadius="20" Padding="16,8" VerticalAlignment="Center">
                            <TextBlock x:Name="HeaderBadge" Text="ENGINE OK" Foreground="{StaticResource Primary}" FontWeight="Black" FontSize="11" LetterSpacing="1"/>
                        </Border>
                    </Grid>

                    <Grid Grid.Row="1" Margin="0,24,0,16">
                        
                        <Grid x:Name="DashboardPage">
                            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                            <UniformGrid Rows="1" Columns="4">
                                <Border Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="12" Margin="5" Padding="20">
                                    <StackPanel><TextBlock Text="COMPLETED CHECKS" Foreground="{StaticResource TextSecondary}" FontSize="11" FontWeight="Bold" LetterSpacing="1"/><TextBlock x:Name="CompletedValue" Text="0" Foreground="White" FontSize="36" FontWeight="Black" Margin="0,8,0,0"/></StackPanel>
                                </Border>
                                <Border Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="12" Margin="5" Padding="20">
                                    <StackPanel><TextBlock Text="SYSTEM WARNINGS" Foreground="{StaticResource TextSecondary}" FontSize="11" FontWeight="Bold" LetterSpacing="1"/><TextBlock x:Name="WarningsValue" Text="0" Foreground="#FFB000" FontSize="36" FontWeight="Black" Margin="0,8,0,0"/></StackPanel>
                                </Border>
                                <Border Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="12" Margin="5" Padding="20">
                                    <StackPanel><TextBlock Text="THREATS DETECTED" Foreground="{StaticResource TextSecondary}" FontSize="11" FontWeight="Bold" LetterSpacing="1"/><TextBlock x:Name="DetectedValue" Text="0" Foreground="#FF4560" FontSize="36" FontWeight="Black" Margin="0,8,0,0"/></StackPanel>
                                </Border>
                                <Border Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="12" Margin="5" Padding="20">
                                    <StackPanel><TextBlock Text="LAST OPERATIONAL RUN" Foreground="{StaticResource TextSecondary}" FontSize="11" FontWeight="Bold" LetterSpacing="1"/><TextBlock x:Name="LastScanValue" Text="NEVER SCANNED" Foreground="{StaticResource Primary}" FontSize="15" FontWeight="Bold" Margin="0,22,0,0"/></StackPanel>
                                </Border>
                            </UniformGrid>
                            
                            <Grid Grid.Row="1" Margin="5,16,5,0">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="1.6*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <Border Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="14" Padding="26" Margin="0,0,12,0">
                                    <StackPanel>
                                        <TextBlock Text="Execute System Analysis Vectors" Foreground="White" FontSize="22" FontWeight="Black" LetterSpacing="-0.5"/>
                                        <TextBlock Text="Initialize localized diagnostics. All operational operations execute purely non-invasively on the device core architecture." Foreground="{StaticResource TextSecondary}" Margin="0,8,0,24" TextWrapping="Wrap" FontSize="13" LineHeight="19"/>
                                        <WrapPanel>
                                            <Button x:Name="QuickPresence" Content="DEPLOY PRESENCE" Style="{StaticResource PrimaryButton}"/>
                                            <Button x:Name="QuickBasic" Content="LAUNCH BASIC SS" Style="{StaticResource SecondaryButton}"/>
                                            <Button x:Name="QuickNormal" Content="RUN NORMAL SS" Style="{StaticResource SecondaryButton}"/>
                                            <Button x:Name="QuickFull" Content="ENGAGE FULL SS" Style="{StaticResource SecondaryButton}"/>
                                        </WrapPanel>
                                        
                                        <Grid Margin="0,28,0,10">
                                            <ProgressBar x:Name="DashboardProgress" Height="8" Minimum="0" Maximum="100" Foreground="{StaticResource Primary}" Background="#060914" BorderThickness="0"/>
                                            <Border BorderBrush="#2000F0FF" BorderThickness="1" CornerRadius="4" Margin="-1"/>
                                        </Grid>
                                        <TextBlock x:Name="CurrentTaskText" Text="Matrix Core Idle." Foreground="{StaticResource TextSecondary}" FontSize="12" FontStyle="Italic"/>
                                    </StackPanel>
                                </Border>
                                
                                <Border Grid.Column="1" Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="14" Padding="26">
                                    <StackPanel>
                                        <TextBlock Text="Hardware Snapshot" Foreground="White" FontSize="22" FontWeight="Black" LetterSpacing="-0.5"/>
                                        <Border Height="1" Background="{StaticResource BorderBrush}" Margin="0,12,0,16"/>
                                        <TextBlock x:Name="SystemSummaryText" Foreground="#A0B2CC" FontSize="13" TextWrapping="Wrap" LineHeight="26" FontFamily="Consolas"/>
                                    </StackPanel>
                                </Border>
                            </Grid>
                        </Grid>

                        <Grid x:Name="ModePage" Visibility="Collapsed">
                            <Border Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="14" Padding="32">
                                <StackPanel>
                                    <TextBlock x:Name="ModeTitle" Text="Presence Mode" Foreground="White" FontSize="28" FontWeight="Black"/>
                                    <TextBlock x:Name="ModeDescription" Foreground="{StaticResource TextSecondary}" TextWrapping="Wrap" Margin="0,10,0,14" FontSize="14" LineHeight="20"/>
                                    <TextBlock x:Name="ModeIntensity" Foreground="{StaticResource Primary}" FontWeight="Bold" FontSize="12" LetterSpacing="1"/>
                                    
                                    <Grid Margin="0,32,0,12">
                                        <ProgressBar x:Name="ModeProgress" Height="10" Minimum="0" Maximum="100" Foreground="{StaticResource Primary}" Background="#060914" BorderThickness="0"/>
                                    </Grid>
                                    <TextBlock x:Name="ModeTaskText" Text="Vector Engine Ready." Foreground="{StaticResource TextSecondary}" FontSize="12" FontStyle="Italic"/>
                                    
                                    <WrapPanel Margin="0,32,0,0">
                                        <Button x:Name="StartScanButton" Content="INITIALIZE VECTOR ANALYSIS" Style="{StaticResource PrimaryButton}" Width="240"/>
                                        <Button x:Name="StopScanButton" Content="TERMINATE ENGINE" Style="{StaticResource SecondaryButton}" IsEnabled="False"/>
                                        <Button x:Name="ReturnDashboardButton" Content="RETURN TO NEXUS" Style="{StaticResource SecondaryButton}"/>
                                    </WrapPanel>
                                </StackPanel>
                            </Border>
                        </Grid>

                        <Grid x:Name="ResultsPage" Visibility="Collapsed">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            
                            <WrapPanel Margin="0,0,0,14">
                                <TextBox x:Name="ResultSearchBox" Width="260" Margin="0,0,10,10" GotFocus="this" Tag="Search Logs..."/>
                                <ComboBox x:Name="SeverityFilter" Width="160" Margin="0,0,10,10">
                                    <ComboBoxItem Content="All Matrix Records" IsSelected="True"/>
                                    <ComboBoxItem Content="Clean"/>
                                    <ComboBoxItem Content="Information"/>
                                    <ComboBoxItem Content="Warning"/>
                                    <ComboBoxItem Content="Detected"/>
                                    <ComboBoxItem Content="Error"/>
                                </ComboBox>
                                <Button x:Name="RefreshResultsButton" Content="REFRESH VIEWS" Style="{StaticResource SecondaryButton}"/>
                                <Button x:Name="ClearResultsButton" Content="PURGE DATABASE" Style="{StaticResource SecondaryButton}"/>
                                <Button x:Name="CopyResultsButton" Content="COPY MATRIX BUFFER" Style="{StaticResource SecondaryButton}"/>
                                <Button x:Name="ExportResultsButton" Content="EXPORT CYBER-REPORT" Style="{StaticResource PrimaryButton}"/>
                            </WrapPanel>
                            
                            <DataGrid x:Name="ResultsGrid" Grid.Row="1" AutoGenerateColumns="False" IsReadOnly="True" 
                                      Background="#060914" Foreground="#E0E6ED" BorderBrush="{StaticResource BorderBrush}" 
                                      GridLinesVisibility="Horizontal" HorizontalGridLinesBrush="#101F2D4A" RowBackground="#0E1426" 
                                      AlternatingRowBackground="#121A30" RowHeight="38" HeadersVisibility="Column">
                                <DataGrid.Resources>
                                    <Style TargetType="DataGridColumnHeader">
                                        <Setter Property="Background" Value="#0A0F1D"/>
                                        <Setter Property="Foreground" Value="{StaticResource TextSecondary}"/>
                                        <Setter Property="FontWeight" Value="Bold"/>
                                        <Setter Property="Padding" Value="12,10"/>
                                        <Setter Property="BorderThickness" Value="0,0,0,1"/>
                                        <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/>
                                    </Style>
                                    <Style TargetType="DataGridCell">
                                        <Setter Property="Padding" Value="10,0"/>
                                        <Setter Property="Template">
                                            <Setter.Value>
                                                <ControlTemplate TargetType="DataGridCell">
                                                    <Border Padding="{TemplateBinding Padding}" Background="{TemplateBinding Background}">
                                                        <ContentPresenter VerticalAlignment="Center"/>
                                                    </Border>
                                                </ControlTemplate>
                                            </Setter.Value>
                                        </Setter>
                                        <Style.Triggers>
                                            <Trigger Property="IsSelected" Value="True">
                                                <Setter Property="Background" Value="#1A263F"/>
                                                <Setter Property="Foreground" Value="{StaticResource Primary}"/>
                                            </Trigger>
                                        </Style.Triggers>
                                    </Style>
                                </DataGrid.Resources>
                                <DataGrid.Columns>
                                    <DataGridTextColumn Header="TIME" Binding="{Binding Timestamp, StringFormat=HH:mm:ss}" Width="90"/>
                                    <DataGridTextColumn Header="VECTOR MODE" Binding="{Binding Mode}" Width="110"/>
                                    <DataGridTextColumn Header="CATEGORY" Binding="{Binding Category}" Width="110"/>
                                    <DataGridTextColumn Header="STATUS" Binding="{Binding Status}" Width="100"/>
                                    <DataGridTextColumn Header="TARGET FIELD" Binding="{Binding CheckName}" Width="195"/>
                                    <DataGridTextColumn Header="CORE SUMMARY DESCRIPTION" Binding="{Binding Description}" Width="*"/>
                                    <DataGridTextColumn Header="METRIC DIAGNOSTIC DETAILS" Binding="{Binding Details}" Width="280"/>
                                </DataGrid.Columns>
                            </DataGrid>
                        </Grid>

                        <Grid x:Name="SettingsPage" Visibility="Collapsed">
                            <Border Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="14" Padding="32">
                                <StackPanel Width="600" HorizontalAlignment="Left">
                                    <TextBlock Text="Volatile Session Parameters" Foreground="White" FontSize="22" FontWeight="Black" LetterSpacing="-0.5"/>
                                    <TextBlock Text="Configuration records exist purely inside transient active runtime process boundaries. Zero layout metadata commits onto physical disk layers." Foreground="{StaticResource TextSecondary}" TextWrapping="Wrap" Margin="0,6,0,24" FontSize="13" LineHeight="18"/>
                                    
                                    <TextBlock Text="DEFAULT ENGINE VECTOR VECTOR LEVEL" Foreground="{StaticResource TextSecondary}" Margin="0,0,0,8" FontSize="11" FontWeight="Bold" LetterSpacing="0.5"/>
                                    <ComboBox x:Name="DefaultModeCombo" Margin="0,0,0,20">
                                        <ComboBoxItem Content="Presence Mode" IsSelected="True"/>
                                        <ComboBoxItem Content="Basic SS"/>
                                        <ComboBoxItem Content="Normal SS"/>
                                        <ComboBoxItem Content="Full SS"/>
                                    </ComboBox>
                                    
                                    <CheckBox x:Name="ConfirmFullCheck" Content="Require Explicit Authorization Prompt Prior to Full SS Array Execution" IsChecked="True" Foreground="White" Margin="0,0,0,12"/>
                                    <CheckBox x:Name="AnimationsCheck" Content="Render Complex Kinematics Windows Transposition Animations" IsChecked="True" Foreground="White" Margin="0,0,0,28"/>
                                    
                                    <WrapPanel>
                                        <Button x:Name="SaveSettingsButton" Content="COMMIT RUNTIME PREFERENCES" Style="{StaticResource PrimaryButton}"/>
                                        <Button x:Name="ResetSettingsButton" Content="RESTORE CORE DEFAULTS" Style="{StaticResource SecondaryButton}"/>
                                    </WrapPanel>
                                </StackPanel>
                            </Border>
                        </Grid>

                        <Grid x:Name="AboutPage" Visibility="Collapsed">
                            <Border Background="{StaticResource CardBackground}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="14" Padding="36">
                                <StackPanel>
                                    <TextBlock Text="SON SCANNER COGNITIVE ENGINE" Foreground="White" FontSize="32" FontWeight="Black" LetterSpacing="-0.5"/>
                                    <TextBlock Text="CORE MODULE v2.0 // DEPLOYED SECURE SINGLE-FILE DISPATCH" Foreground="{StaticResource Primary}" Margin="0,6,0,24" FontSize="12" FontWeight="Bold" LetterSpacing="1"/>
                                    <Border Height="1" Background="{StaticResource BorderBrush}" Margin="0,0,0,24"/>
                                    <TextBlock Foreground="#A0B2CC" TextWrapping="Wrap" FontSize="14" LineHeight="26" 
                                               Text="A fully transparent localized system infrastructure analytics framework. Executes isolated, non-elevated diagnostics against operating system descriptors, process maps, security configurations, memory pools, startup registers, and temporal volatile cache scopes. The binary explicitly operates with zero egress communication conduits: no password extraction routines, cloud synchronization components, account verification bypass maps, or automated registry manipulation hooks exist within this system framework code structure."/>
                                </StackPanel>
                            </Border>
                        </Grid>
                    </Grid>

                    <Border Grid.Row="2" Background="#070A14" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="8" Padding="16,12">
                        <Grid>
                            <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                            <TextBlock x:Name="FooterStatus" Text="MATRIX SYSTEM OPERATIONAL" Foreground="{StaticResource TextSecondary}" FontSize="11" FontWeight="Bold" LetterSpacing="0.5"/>
                            <TextBlock Grid.Column="1" x:Name="FooterCounters" Text="0 ANALYSIS CHECKS COMPLETED · 0 ALERTS" Foreground="{StaticResource Primary}" FontSize="11" FontWeight="Bold" LetterSpacing="0.5"/>
                        </Grid>
                    </Border>
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
    (Get-Control 'FooterCounters').Text = '{0} CHECKS COMPLETED · {1} WARNINGS · {2} THREATS DETECTED' -f $script:Results.Count, $warnings, $detected
}

function Refresh-ResultsView {
    $search = (Get-Control 'ResultSearchBox').Text.Trim()
    $selected = (Get-Control 'SeverityFilter').SelectedItem
    $severity = if ($selected) { [string]$selected.Content } else { 'All Matrix Records' }
    if ($severity -match 'All') { $severity = 'All' }
    
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
    
    $light = Get-Control 'StatusPulseLight'
    if ($Running) {
        (Get-Control 'SidebarStatusText').Text = 'ANALYZING MATRIX...'
        (Get-Control 'HeaderBadge').Text = 'PROCESSING DIAGNOSTICS'
        (Get-Control 'FooterStatus').Text = 'VECTOR ENGINE SCAN RUNNING'
        if ($light) { $light.Fill = [Windows.Media.Brushes]::Red }
    } else {
        (Get-Control 'SidebarStatusText').Text = 'SYSTEM READY'
        (Get-Control 'HeaderBadge').Text = 'ENGINE OK'
        (Get-Control 'FooterStatus').Text = 'MATRIX SYSTEM OPERATIONAL'
        if ($light) { $light.Fill = [Windows.Media.BrushConverter]::::New().ConvertFromString("#00F0FF") }
    }
}

function Start-Scan([string]$Mode) {
    if ($script:ScanRunning) { return }
    if ($Mode -eq 'Full SS' -and $script:ConfirmBeforeFull) {
        $choice = [System.Windows.MessageBox]::Show('Full SS runs every approved local check. Continue?', 'Son Scanner Engine Execution', 'YesNo', 'Warning')
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
    $timer.Interval = [TimeSpan]::FromMilliseconds(120) # Vloeiendere vertraging voor visueel genot
    $timer.Add_Tick({
        if ($script:CancelRequested) {
            $timer.Stop()
            Set-ScanningUi $false
            (Get-Control 'ModeTaskText').Text = 'Engine processing aborted by user.'
            (Get-Control 'CurrentTaskText').Text = 'Engine processing aborted by user.'
            return
        }

        if ($queue.Count -eq 0) {
            $timer.Stop()
            Set-ScanningUi $false
            (Get-Control 'ModeProgress').Value = 100
            (Get-Control 'DashboardProgress').Value = 100
            (Get-Control 'ModeTaskText').Text = 'Operational check diagnostics complete.'
            (Get-Control 'CurrentTaskText').Text = 'Operational check diagnostics complete.'
            (Get-Control 'LastScanValue').Text = (Get-Date).ToString('HH:mm:ss (yyyy-MM-dd)')
            Update-Counters
            return
        }

        $definition = $queue.Dequeue()
        (Get-Control 'ModeTaskText').Text = "Invoking Vector: $($definition.Name)"
        (Get-Control 'CurrentTaskText').Text = "Invoking Vector: $($definition.Name)"
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

# Custom Window Navigation Triggers
(Get-Control 'TitleBar').Add_MouseLeftButtonDown({
    if ($_.ClickCount -eq 2) {
        $Window.WindowState = if ($Window.WindowState -eq 'Maximized') { 'Normal' } else { 'Maximized' }
    }
    else { $Window.DragMove() }
})
(Get-Control 'MinimizeButton').Add_Click({ $Window.WindowState = 'Minimized' })
(Get-Control 'MaximizeButton').Add_Click({ $Window.WindowState = if ($Window.WindowState -eq 'Maximized') { 'Normal' } else { 'Maximized' } })
(Get-Control 'CloseButton').Add_Click({ $Window.Close() })

# Primary Navigation Switching Hooks
(Get-Control 'DashboardNav').Add_Click({ Show-Page 'DashboardPage' 'Dashboard' 'Transparent local system infrastructure metrics.' })
(Get-Control 'PresenceNav').Add_Click({ Set-Mode 'Presence' })
(Get-Control 'BasicNav').Add_Click({ Set-Mode 'Basic SS' })
(Get-Control 'NormalNav').Add_Click({ Set-Mode 'Normal SS' })
(Get-Control 'FullNav').Add_Click({ Set-Mode 'Full SS' })
(Get-Control 'ResultsNav').Add_Click({ Show-Page 'ResultsPage' 'Scan Metrics' 'Search, sort, filter, and extract diagnostic matrix logs.'; Refresh-ResultsView })
(Get-Control 'SettingsNav').Add_Click({ Show-Page 'SettingsPage' 'Preferences' 'Volatile active thread configurations; zero write-to-disk states.' })
(Get-Control 'AboutNav').Add_Click({ Show-Page 'AboutPage' 'Engine Information' 'Localized integrity validation specifications.' })
(Get-Control 'ReturnDashboardButton').Add_Click({ Show-Page 'DashboardPage' 'Dashboard' 'Transparent local system infrastructure metrics.' })

# Engine Fast Fire Execution Links
(Get-Control 'QuickPresence').Add_Click({ Set-Mode 'Presence'; Start-Scan 'Presence' })
(Get-Control 'QuickBasic').Add_Click({ Set-Mode 'Basic SS'; Start-Scan 'Basic SS' })
(Get-Control 'QuickNormal').Add_Click({ Set-Mode 'Normal SS'; Start-Scan 'Normal SS' })
(Get-Control 'QuickFull').Add_Click({ Set-Mode 'Full SS'; Start-Scan 'Full SS' })
(Get-Control 'StartScanButton').Add_Click({ Start-Scan $script:CurrentMode })
(Get-Control 'StopScanButton').Add_Click({ $script:CancelRequested = $true })

# Live Search Datagrid Events 
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
        if ([string]::IsNullOrWhiteSpace($text)) { $text = 'No matrix records.' }
        [Windows.Clipboard]::SetText($text)
    }
    catch { [System.Windows.MessageBox]::Show($_.Exception.Message, 'Buffer Write Failed', 'OK', 'Error') | Out-Null }
})
(Get-Control 'ExportResultsButton').Add_Click({
    try {
        $visible = @($ResultsGrid.ItemsSource)
        if ($visible.Count -eq 0) { [System.Windows.MessageBox]::Show('Zero matrix items available to export.', 'Son Scanner Matrix', 'OK', 'Information') | Out-Null; return }
        $dialog = [Microsoft.Win32.SaveFileDialog]::new()
        $dialog.Title = 'Export System Analysis Report Logs'
        $dialog.Filter = 'Cyber HTML Log (*.html)|*.html|JSON Metrics (*.json)|*.json|Structured CSV (*.csv)|*.csv|Flat Text Log (*.txt)|*.txt'
        $dialog.FileName = 'SonScanner_Matrix_{0}' -f (Get-Date -Format 'yyyyMMdd_HHmmss')
        if ($dialog.ShowDialog() -ne $true) { return }
        $extension = [IO.Path]::GetExtension($dialog.FileName).ToLowerInvariant()
        switch ($extension) {
            '.html' { Convert-ResultsToHtml -InputResults $visible -Mode $script:CurrentMode -Duration ((Get-Date) - $script:ScanStarted) | Set-Content -LiteralPath $dialog.FileName -Encoding UTF8 }
            '.json' { $visible | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $dialog.FileName -Encoding UTF8 }
            '.csv'  { $visible | Export-Csv -LiteralPath $dialog.FileName -NoTypeInformation -Encoding UTF8 }
            '.txt'  { $visible | ForEach-Object { '[{0:u}] [{1}] [{2}] {3}: {4} — {5}' -f $_.Timestamp, $_.Mode, $_.Status, $_.CheckName, $_.Description, $_.Details } | Set-Content -LiteralPath $dialog.FileName -Encoding UTF8 }
            default { throw 'Unsupported output stream target type.' }
        }
        [System.Windows.MessageBox]::Show('The diagnostic matrix export completed seamlessly.', 'Son Scanner Export', 'OK', 'Information') | Out-Null
    }
    catch { [System.Windows.MessageBox]::Show($_.Exception.Message, 'Export Pipeline Blocked', 'OK', 'Error') | Out-Null }
})

# Preferences Handler 
(Get-Control 'SaveSettingsButton').Add_Click({
    $selected = (Get-Control 'DefaultModeCombo').SelectedItem
    if ($selected) { $script:CurrentMode = [string]$selected.Content }
    $script:ConfirmBeforeFull = [bool](Get-Control 'ConfirmFullCheck').IsChecked
    $script:AnimationsEnabled = [bool](Get-Control 'AnimationsCheck').IsChecked
    [System.Windows.MessageBox]::Show('Transients settings loaded dynamically into runtime memory stacks.', 'Son Scanner Framework', 'OK', 'Information') | Out-Null
})
(Get-Control 'ResetSettingsButton').Add_Click({
    (Get-Control 'DefaultModeCombo').SelectedIndex = 0
    (Get-Control 'ConfirmFullCheck').IsChecked = $true
    (Get-Control 'AnimationsCheck').IsChecked = $true
    $script:CurrentMode = 'Presence'
    $script:ConfirmBeforeFull = $true
    $script:AnimationsEnabled = $true
})

# System Information Bootstrap Init
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem
    (Get-Control 'SystemSummaryText').Text = "HOST IDENTIFIER: $env:COMPUTERNAME`nOS ARCHITECTURE: $($os.Caption)`nBUILD KERNEL:    $($os.BuildNumber)`nPHYSICAL MEMORY: $([math]::Round($computer.TotalPhysicalMemory / 1GB, 1)) GB RAM`nSHELL ENGINE:    PowerShell $($PSVersionTable.PSVersion)"
}
catch {
    (Get-Control 'SystemSummaryText').Text = "HOST IDENTIFIER: $env:COMPUTERNAME`nSHELL ENGINE:    PowerShell $($PSVersionTable.PSVersion)`n[!] Diagnostics framework locked out from kernel info reads."
}

# Advanced DoubleAnimation Window Initialization
$Window.Add_ContentRendered({
    if ($script:AnimationsEnabled) {
        $fadeIn = [Windows.Media.Animation.DoubleAnimation]::new(0, 1, [TimeSpan]::FromMilliseconds(450))
        $Window.BeginAnimation([Windows.Window]::OpacityProperty, $fadeIn)
    }
    else { $Window.Opacity = 1 }
})

$Window.ShowDialog() | Out-Null