#requires -Version 5.1

if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    Start-Process powershell.exe -ArgumentList @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    exit
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="RootWindow"
        Title="AstraTrace Ultimate"
        Width="1250" Height="820"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent">

    <Window.Resources>
        <Color x:Key="CyanNeon">#00F5FF</Color>
        <Color x:Key="PurpleNeon">#9D00FF</Color>
        <LinearGradientBrush x:Key="MainGlow" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#00F5FF" Offset="0"/>
            <GradientStop Color="#9D00FF" Offset="1"/>
        </LinearGradientBrush>
        
        <DropShadowEffect x:Key="NeonGlow" Color="#00F5FF" BlurRadius="20" ShadowDepth="0" Opacity="0.6"/>
        <DropShadowEffect x:Key="SoftBlur" Color="Black" BlurRadius="40" ShadowDepth="10" Opacity="0.5"/>

        <Style x:Key="NavBtn" TargetType="Button">
            <Setter Property="Height" Value="50"/>
            <Setter Property="Margin" Value="0,5"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#888888"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Back" Background="{TemplateBinding Background}" CornerRadius="12" Padding="20,0">
                            <StackPanel Orientation="Horizontal">
                                <TextBlock x:Name="Icon" Text="●" Foreground="{TemplateBinding Foreground}" VerticalAlignment="Center" Margin="0,0,15,0"/>
                                <ContentPresenter VerticalAlignment="Center"/>
                            </StackPanel>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Back" Property="Background" Value="#1AFFFFFF"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="Tag" Value="Active">
                                <Setter TargetName="Back" Property="Background" Value="#2500F5FF"/>
                                <Setter Property="Foreground" Value="#00F5FF"/>
                                <Setter TargetName="Icon" Property="Foreground" Value="#00F5FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="PrimaryBtn" TargetType="Button">
            <Setter Property="Height" Value="45"/>
            <Setter Property="Padding" Value="30,0"/>
            <Setter Property="Background" Value="{StaticResource MainGlow}"/>
            <Setter Property="Foreground" Value="Black"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Body" Background="{TemplateBinding Background}" CornerRadius="12" Effect="{StaticResource NeonGlow}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Body" Property="Opacity" Value="0.85"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border x:Name="MainShell" CornerRadius="25" Background="#0A0A0F" BorderBrush="#1F1F2E" BorderThickness="1.5" Effect="{StaticResource SoftBlur}" Margin="20">
        <Grid>
            <Canvas IsHitTestVisible="False">
                <Ellipse x:Name="GlowOne" Width="500" Height="500" Canvas.Left="-150" Canvas.Top="-150" Opacity="0.08" Fill="#00F5FF">
                    <Ellipse.Effect><BlurEffect Radius="100"/></Ellipse.Effect>
                </Ellipse>
                <Ellipse x:Name="GlowTwo" Width="600" Height="600" Canvas.Right="-200" Canvas.Bottom="-200" Opacity="0.08" Fill="#9D00FF">
                    <Ellipse.Effect><BlurEffect Radius="100"/></Ellipse.Effect>
                </Ellipse>
            </Canvas>

            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="260"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border Background="#0D0D14" CornerRadius="25,0,0,25" BorderBrush="#1F1F2E" BorderThickness="0,0,1.5,0">
                    <Grid Margin="25,40">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <StackPanel>
                            <TextBlock Text="ASTRA" Foreground="White" FontSize="28" FontWeight="Black"/>
                            <TextBlock Text="ULTIMATE" Foreground="#00F5FF" FontSize="12" FontWeight="Bold" Margin="2,-5,0,30"/>
                            
                            <Button x:Name="NavDash" Tag="Active" Style="{StaticResource NavBtn}" Content="DASHBOARD"/>
                            <Button x:Name="NavScanner" Style="{StaticResource NavBtn}" Content="HYPER SCANNER"/>
                            <Button x:Name="NavLogs" Style="{StaticResource NavBtn}" Content="SYSTEM LOGS"/>
                        </StackPanel>

                        <StackPanel Grid.Row="2">
                            <Border Background="#161621" CornerRadius="15" Padding="15">
                                <StackPanel Orientation="Horizontal">
                                    <Border Width="35" Height="35" CornerRadius="10" Background="{StaticResource MainGlow}"/>
                                    <StackPanel Margin="12,0,0,0">
                                        <TextBlock Text="Operator" Foreground="White" FontSize="12" FontWeight="Bold"/>
                                        <TextBlock Text="Root Privilege" Foreground="#666666" FontSize="10"/>
                                    </StackPanel>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </Grid>
                </Border>

                <Grid Grid.Column="1" Margin="40">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Grid Grid.Row="0">
                        <StackPanel>
                            <TextBlock x:Name="PageTitle" Text="SYSTEM OVERVIEW" Foreground="White" FontSize="32" FontWeight="Black"/>
                            <TextBlock Text="Real-time predictive analysis engine active." Foreground="#555555" FontSize="13" Margin="2,5,0,0"/>
                        </StackPanel>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Top">
                            <Button x:Name="MinBtn" Content="—" Foreground="#444" Background="Transparent" BorderThickness="0" Cursor="Hand" Padding="10"/>
                            <Button x:Name="CloseBtn" Content="✕" Foreground="#444" Background="Transparent" BorderThickness="0" Cursor="Hand" Padding="10" Margin="10,0,0,0"/>
                        </StackPanel>
                    </Grid>

                    <Grid Grid.Row="1" Margin="0,40,0,0">
                        
                        <Grid x:Name="PageDash">
                            <UniformGrid Columns="2">
                                <Border Margin="0,0,15,15" Background="#0D0D14" CornerRadius="20" BorderBrush="#1F1F2E" BorderThickness="1.5">
                                    <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                        <TextBlock Text="842" Foreground="#00F5FF" FontSize="48" FontWeight="Black" HorizontalAlignment="Center"/>
                                        <TextBlock Text="THREADS ANALYZED" Foreground="#555555" FontSize="12" FontWeight="Bold"/>
                                    </StackPanel>
                                </Border>
                                <Border Margin="15,0,0,15" Background="#0D0D14" CornerRadius="20" BorderBrush="#1F1F2E" BorderThickness="1.5">
                                    <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                        <TextBlock Text="99.9%" Foreground="#9D00FF" FontSize="48" FontWeight="Black" HorizontalAlignment="Center"/>
                                        <TextBlock Text="INTEGRITY RATIO" Foreground="#555555" FontSize="12" FontWeight="Bold"/>
                                    </StackPanel>
                                </Border>
                            </UniformGrid>
                        </Grid>

                        <Grid x:Name="PageScanner" Visibility="Collapsed">
                            <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                <Border x:Name="ScanGlow" Width="220" Height="220" CornerRadius="110" Background="#0D0D14" BorderBrush="#00F5FF" BorderThickness="2" Margin="0,0,0,40">
                                    <Grid>
                                        <TextBlock x:Name="ScanPercent" Text="0%" Foreground="White" FontSize="42" FontWeight="Black" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        <Ellipse x:Name="Pulse" Margin="-5" Stroke="#00F5FF" StrokeThickness="1" Opacity="0"/>
                                    </Grid>
                                </Border>
                                <Button x:Name="BtnStartScan" Style="{StaticResource PrimaryBtn}" Content="INITIALIZE HYPER-SCAN" Width="280"/>
                                <ProgressBar x:Name="ProgBar" Height="4" Width="400" Background="#111" Foreground="{StaticResource MainGlow}" BorderThickness="0" Margin="0,30,0,0" Value="0" Opacity="0"/>
                            </StackPanel>
                        </Grid>

                        <Grid x:Name="PageLogs" Visibility="Collapsed">
                            <Border Background="#08080C" CornerRadius="15" BorderBrush="#1F1F2E" BorderThickness="1.5">
                                <ScrollViewer Margin="20">
                                    <TextBlock x:Name="TxtLogs" Text="[SYSTEM] Waiting for initialization..." Foreground="#00F5FF" FontFamily="Consolas" FontSize="12"/>
                                </ScrollViewer>
                            </Border>
                        </Grid>

                    </Grid>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Node tree evaluation mapping to standard PowerShell objects
$xaml.SelectNodes("//*[local-name()='Window']//*") | ForEach-Object {
    $nameAttr = $_.Attributes | Where-Object { $_.LocalName -eq 'Name' }
    if ($nameAttr) { Set-Variable -Name $nameAttr.Value -Value $window.FindName($nameAttr.Value) -Scope Script }
}

# --- WINDOW NAVIGATION SCHEDULER & STATE MANAGEMENT ---
$pages = @($PageDash, $PageScanner, $PageLogs)
$btns = @($NavDash, $NavScanner, $NavLogs)

function Switch-Page($Page, $Btn, $Title) {
    foreach($p in $pages){ $p.Visibility = 'Collapsed' }
    foreach($b in $btns){ $b.Tag = '' }
    $Page.Visibility = 'Visible'
    $Btn.Tag = 'Active'
    $PageTitle.Text = $Title
}

$NavDash.Add_Click({ Switch-Page $PageDash $NavDash "SYSTEM OVERVIEW" })
$NavScanner.Add_Click({ Switch-Page $PageScanner $NavScanner "HYPER SCANNER" })
$NavLogs.Add_Click({ Switch-Page $PageLogs $NavLogs "ENCRYPTED LOGS" })

# INTERACTIVE SCAN ACTION SEQUENCER
$BtnStartScan.Add_Click({
    $BtnStartScan.IsEnabled = $false
    $ProgBar.Opacity = 1
    $TxtLogs.Text += "`n[ACTION] Scanner initialized by Operator..."
    
    # Core Animation Pipeline Configuration
    $pulseAnim = New-Object Windows.Media.Animation.DoubleAnimation
    $pulseAnim.From = 0; $pulseAnim.To = 1; $pulseAnim.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(1))
    $pulseAnim.AutoReverse = $true; $pulseAnim.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $Pulse.BeginAnimation([Windows.UIElement]::OpacityProperty, $pulseAnim)

    # Dynamic Value Step Generator Logic
    1..100 | ForEach-Object {
        Start-Sleep -Milliseconds (Get-Random -Min 15 -Max 70)
        $val = $_
        $window.Dispatcher.Invoke({
            $ProgBar.Value = $val
            $ScanPercent.Text = "$val%"
            if($val % 10 -eq 0){ $TxtLogs.Text += "`n[INFO] Decrypting database cluster 0x0$val... SUCCESS" }
        })
    }
    
    $TxtLogs.Text += "`n[SUCCESS] Vulnerability scan completed. System integrity at 100%."
    $BtnStartScan.IsEnabled = $true
})

# Native OS Control Integrations
$window.Add_MouseLeftButtonDown({ if($_.LeftButton -eq 'Pressed'){ $window.DragMove() } })
$CloseBtn.Add_Click({ $window.Close() })
$MinBtn.Add_Click({ $window.WindowState = 'Minimized' })

# Active Background Ambient Flow Animators
$window.Add_ContentRendered({
    $moveOne = New-Object Windows.Media.Animation.DoubleAnimation
    $moveOne.From = -150; $moveOne.To = -90; $moveOne.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(8))
    $moveOne.AutoReverse = $true; $moveOne.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $GlowOne.BeginAnimation([System.Windows.Controls.Canvas]::TopProperty, $moveOne)

    $moveTwo = New-Object Windows.Media.Animation.DoubleAnimation
    $moveTwo.From = 450; $moveTwo.To = 390; $moveTwo.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(10))
    $moveTwo.AutoReverse = $true; $moveTwo.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $GlowTwo.BeginAnimation([System.Windows.Controls.Canvas]::TopProperty, $moveTwo)
})

$window.ShowDialog() | Out-Null