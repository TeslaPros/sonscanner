#requires -Version 5.1

if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    Start-Process powershell.exe -ArgumentList @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath` Gaza")
    exit
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="RootWindow"
        Title="AstraTrace Premium"
        Width="1200" Height="780"
        MinWidth="1000" MinHeight="680"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        ResizeMode="CanResizeWithGrip"
        AllowsTransparency="True"
        Background="Transparent"
        FontFamily="Segoe UI Variable Text, Segoe UI, Arial"
        SnapsToDevicePixels="True"
        UseLayoutRounding="True">

    <Window.Resources>
        <!-- Modern Premium Obsidian Dark Theme Palette -->
        <Color x:Key="BgBase">#080A10</Color>
        <Color x:Key="BgSide">#0C0F1A</Color>
        <Color x:Key="BgTop">#0E1222</Color>
        <Color x:Key="CardBg">#131929</Color>
        <Color x:Key="CardHoverBg">#1A2238</Color>
        <Color x:Key="BorderColor">#222D4A</Color>
        <Color x:Key="BorderHoverColor">#344570</Color>
        <Color x:Key="TextPrimary">#F8FAFC</Color>
        <Color x:Key="TextSecondary">#94A3B8</Color>
        <Color x:Key="TextMuted">#64748B</Color>
        
        <!-- Premium Accents -->
        <Color x:Key="AccentCyan">#38BDF8</Color>
        <Color x:Key="AccentPurple">#A855F7</Color>
        <Color x:Key="AccentPink">#EC4899</Color>

        <SolidColorBrush x:Key="BgBaseBrush" Color="{StaticResource BgBase}"/>
        <SolidColorBrush x:Key="BgSideBrush" Color="{StaticResource BgSide}"/>
        <SolidColorBrush x:Key="CardBgBrush" Color="{StaticResource CardBg}"/>
        <SolidColorBrush x:Key="BorderBrush" Color="{StaticResource BorderColor}"/>
        <SolidColorBrush x:Key="TextPrimaryBrush" Color="{StaticResource TextPrimary}"/>
        <SolidColorBrush x:Key="TextSecondaryBrush" Color="{StaticResource TextSecondary}"/>
        <SolidColorBrush x:Key="TextMutedBrush" Color="{StaticResource TextMuted}"/>
        
        <LinearGradientBrush x:Key="PremiumGradient" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#38BDF8" Offset="0"/>
            <GradientStop Color="#818CF8" Offset="0.5"/>
            <GradientStop Color="#C084FC" Offset="1"/>
        </LinearGradientBrush>

        <DropShadowEffect x:Key="CardShadow" Color="#000000" BlurRadius="20" ShadowDepth="4" Opacity="0.4"/>
        <DropShadowEffect x:Key="GlowShadow" Color="#38BDF8" BlurRadius="15" ShadowDepth="0" Opacity="0.3"/>

        <!-- Window Controls Window Button Style -->
        <Style x:Key="WindowButton" TargetType="Button">
            <Setter Property="Width" Value="40"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Foreground" Value="{StaticResource TextSecondaryBrush}"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="BtnBorder" Background="{TemplateBinding Background}" CornerRadius="6" Margin="2">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="BtnBorder" Property="Background" Value="#222D4A"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Premium Navigation Button Style -->
        <Style x:Key="NavButton" TargetType="Button">
            <Setter Property="Height" Value="46"/>
            <Setter Property="Margin" Value="0,4,0,4"/>
            <Setter Property="Foreground" Value="{StaticResource TextSecondaryBrush}"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="NavBorder" Background="{TemplateBinding Background}" CornerRadius="10" Padding="16,0">
                            <Grid>
                                <Border x:Name="ActiveIndicator" Width="4" Height="18" HorizontalAlignment="Left" CornerRadius="2" Background="{StaticResource PremiumGradient}" Opacity="0"/>
                                <ContentPresenter Margin="12,0,0,0" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="NavBorder" Property="Background" Value="#151C33"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="Tag" Value="Active">
                                <Setter TargetName="NavBorder" Property="Background" Value="#1A233D"/>
                                <Setter TargetName="ActiveIndicator" Property="Opacity" Value="1"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Premium Modern Action Buttons -->
        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Height" Value="40"/>
            <Setter Property="Padding" Value="24,0"/>
            <Setter Property="Foreground" Value="#060814"/>
            <Setter Property="Background" Value="{StaticResource PremiumGradient}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="BtnShell" Background="{TemplateBinding Background}" CornerRadius="10" Effect="{StaticResource GlowShadow}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="BtnShell" Property="Opacity" Value="0.9"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SecondaryButton" TargetType="Button">
            <Setter Property="Height" Value="40"/>
            <Setter Property="Padding" Value="24,0"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimaryBrush}"/>
            <Setter Property="Background" Value="#161F33"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="BtnShell" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="10">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="BtnShell" Property="Background" Value="#202C47"/>
                                <Setter TargetName="BtnShell" Property="BorderBrush" Value="{StaticResource BorderHoverColor}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="PillButton" TargetType="Button">
            <Setter Property="Height" Value="32"/>
            <Setter Property="Padding" Value="16,0"/>
            <Setter Property="Margin" Value="0,0,8,0"/>
            <Setter Property="Foreground" Value="{StaticResource TextSecondaryBrush}"/>
            <Setter Property="Background" Value="#111625"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="PillShell" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="16">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="PillShell" Property="Background" Value="#1B233A"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="Tag" Value="Active">
                                <Setter TargetName="PillShell" Property="Background" Value="#222D4A"/>
                                <Setter TargetName="PillShell" Property="BorderBrush" Value="#38BDF8"/>
                                <Setter Property="Foreground" Value="#38BDF8"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="CardStyle" TargetType="Border">
            <Setter Property="Background" Value="{StaticResource CardBgBrush}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="14"/>
            <Setter Property="Padding" Value="20"/>
            <Setter Property="Margin" Value="0,0,16,16"/>
            <Setter Property="Effect" Value="{StaticResource CardShadow}"/>
        </Style>
    </Window.Resources>

    <!-- Main Window Frameless Outer Layer -->
    <Border CornerRadius="16" Background="{StaticResource BgBaseBrush}" BorderBrush="#2A3654" BorderThickness="1" Effect="{StaticResource CardShadow}">
        <Grid>
            <!-- Premium Glass Aura / Glow Background Effects -->
            <Canvas IsHitTestVisible="False" Opacity="0.06">
                <Ellipse x:Name="GlowOne" Width="600" Height="600" Canvas.Left="650" Canvas.Top="-250">
                    <Ellipse.Fill>
                        <RadialGradientBrush>
                            <GradientStop Color="{StaticResource AccentCyan}" Offset="0"/>
                            <GradientStop Color="Transparent" Offset="1"/>
                        </RadialGradientBrush>
                    </Ellipse.Fill>
                </Ellipse>
                <Ellipse x:Name="GlowTwo" Width="500" Height="500" Canvas.Left="-150" Canvas.Top="450">
                    <Ellipse.Fill>
                        <RadialGradientBrush>
                            <GradientStop Color="{StaticResource AccentPurple}" Offset="0"/>
                            <GradientStop Color="Transparent" Offset="1"/>
                        </RadialGradientBrush>
                    </Ellipse.Fill>
                </Ellipse>
            </Canvas>

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="60"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <!-- Modern Top Header Bar -->
                <Border Grid.Row="0" Background="#0C101F" BorderBrush="{StaticResource BorderBrush}" BorderThickness="0,0,0,1" CornerRadius="16,16,0,0">
                    <Grid Margin="20,0,16,0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="250"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        
                        <!-- Logo & Title -->
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Border Width="28" Height="28" CornerRadius="8" Background="{StaticResource PremiumGradient}">
                                <TextBlock Text="A" Foreground="#060814" FontWeight="Black" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <TextBlock Text="ASTRATRACE" Margin="12,0,0,0" Foreground="White" FontWeight="Bold" FontSize="12" LetterSpacing="2" VerticalAlignment="Center"/>
                            <Border Margin="10,0,0,0" Background="#1E1B4B" CornerRadius="6" Padding="6,2">
                                <TextBlock Text="PREMIUM" Foreground="#A78BFA" FontSize="9" FontWeight="Bold"/>
                            </Border>
                        </StackPanel>

                        <!-- Sleek Search Bar Emulator -->
                        <Border Grid.Column="1" Width="320" Height="34" HorizontalAlignment="Center" CornerRadius="8" Background="#111625" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1">
                            <Grid Margin="12,0">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition/></Grid.ColumnDefinitions>
                                <TextBlock Text=" Looking for something?" Foreground="{StaticResource TextMutedBrush}" FontSize="11" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>

                        <!-- Window Commands -->
                        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button x:Name="MinimizeButton" Style="{StaticResource WindowButton}" Content="—"/>
                            <Button x:Name="MaximizeButton" Style="{StaticResource WindowButton}" Content="▢"/>
                            <Button x:Name="CloseButton" Style="{StaticResource WindowButton}" Content="×"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <!-- Main Layout Container -->
                <Grid Grid.Row="1">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="240"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <!-- Left Sidebar Panels -->
                    <Border Grid.Column="0" Background="{StaticResource BgSideBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="0,0,1,0" CornerRadius="0,0,0,16">
                        <Grid Margin="16,20,16,20">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            
                            <!-- Navigation Links -->
                            <StackPanel Grid.Row="1">
                                <Button x:Name="NavOverview" Tag="Active" Style="{StaticResource NavButton}" Content="◈   Overview"/>
                                <Button x:Name="NavLibrary" Style="{StaticResource NavButton}" Content="▦   Library"/>
                                <Button x:Name="NavActivity" Style="{StaticResource NavButton}" Content="⌁   Activity"/>
                                <Button x:Name="NavSettings" Style="{StaticResource NavButton}" Content="⚙   Settings"/>
                            </StackPanel>

                            <!-- User Profile Card bottom sidebar -->
                            <StackPanel Grid.Row="2" VerticalAlignment="Bottom">
                                <Button Style="{StaticResource NavButton}" Content="?   Help &amp; Documentation" Margin="0,0,0,12"/>
                                <Border Background="#121826" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="12" Padding="12">
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition/></Grid.ColumnDefinitions>
                                        <Border Width="32" Height="32" CornerRadius="8" Background="{StaticResource PremiumGradient}">
                                            <TextBlock Text="M" Foreground="#060814" FontWeight="Bold" FontSize="13" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <StackPanel Grid.Column="1" Margin="12,0,0,0" VerticalAlignment="Center">
                                            <TextBlock Text="Michiel De Bauw" Foreground="White" FontSize="11" FontWeight="SemiBold"/>
                                            <TextBlock Text="Administrator" Foreground="{StaticResource TextMutedBrush}" FontSize="9" Margin="0,1,0,0"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- Core Workspace Dashboard Main View -->
                    <Grid Grid.Column="1" Margin="32,24,32,24">
                        
                        <!-- VIEW: Overview -->
                        <Grid x:Name="PageOverview">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="24"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="20"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            
                            <!-- Welcome and Action Header -->
                            <Grid Grid.Row="0">
                                <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Dashboard Overview" Foreground="White" FontSize="26" FontWeight="SemiBold" LetterSpacing="-0.5"/>
                                    <StackPanel Orientation="Horizontal" Margin="0,12,0,0">
                                        <Button Tag="Active" Style="{StaticResource PillButton}" Content="All Modules"/>
                                        <Button Style="{StaticResource PillButton}" Content="Active Actions"/>
                                        <Button Style="{StaticResource PillButton}" Content="Completed"/>
                                    </StackPanel>
                                </StackPanel>
                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Top">
                                    <Button Style="{StaticResource SecondaryButton}" Content="Configuration" Margin="0,0,12,0"/>
                                    <Button Style="{StaticResource PrimaryButton}" Content="Initialize Scanner"/>
                                </StackPanel>
                            </Grid>

                            <!-- Grid Cards Column Stats -->
                            <Grid Grid.Row="2">
                                <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition/><ColumnDefinition/></Grid.ColumnDefinitions>
                                
                                <Border Grid.Column="0" Style="{StaticResource CardStyle}">
                                    <StackPanel>
                                        <Border Width="36" Height="36" CornerRadius="10" Background="#142838" HorizontalAlignment="Left">
                                            <TextBlock Text="◈" Foreground="{StaticResource AccentCyan}" FontSize="16" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <TextBlock Text="Network Integrity" Foreground="White" FontSize="14" FontWeight="SemiBold" Margin="0,16,0,4"/>
                                        <TextBlock Text="All endpoints authenticated" Foreground="{StaticResource TextSecondaryBrush}" FontSize="11"/>
                                        <Rectangle Height="6" RadiusX="3" RadiusY="3" Fill="#1E293B" Margin="0,16,0,0"/>
                                    </StackPanel>
                                </Border>
                                
                                <Border Grid.Column="1" Style="{StaticResource CardStyle}">
                                    <StackPanel>
                                        <Border Width="36" Height="36" CornerRadius="10" Background="#261A3A" HorizontalAlignment="Left">
                                            <TextBlock Text="◇" Foreground="{StaticResource AccentPurple}" FontSize="16" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <TextBlock Text="Database Cache" Foreground="White" FontSize="14" FontWeight="SemiBold" Margin="0,16,0,4"/>
                                        <TextBlock Text="Optimal latency detected" Foreground="{StaticResource TextSecondaryBrush}" FontSize="11"/>
                                        <Rectangle Height="6" RadiusX="3" RadiusY="3" Fill="#1E293B" Margin="0,16,0,0"/>
                                    </StackPanel>
                                </Border>
                                
                                <Border Grid.Column="2" Style="{StaticResource CardStyle}" Margin="0,0,0,16">
                                    <StackPanel>
                                        <Border Width="36" Height="36" CornerRadius="10" Background="#2C1628" HorizontalAlignment="Left">
                                            <TextBlock Text="✓" Foreground="{StaticResource AccentPink}" FontSize="16" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <TextBlock Text="Security Directives" Foreground="White" FontSize="14" FontWeight="SemiBold" Margin="0,16,0,4"/>
                                        <TextBlock Text="Zero vulnerabilities active" Foreground="{StaticResource TextSecondaryBrush}" FontSize="11"/>
                                        <Rectangle Height="6" RadiusX="3" RadiusY="3" Fill="#1E293B" Margin="0,16,0,0"/>
                                    </StackPanel>
                                </Border>
                            </Grid>

                            <!-- Bottom Activity Feed / Components Container Table -->
                            <Border Grid.Row="4" Style="{StaticResource CardStyle}" Margin="0">
                                <Grid>
                                    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="16"/><RowDefinition/></Grid.RowDefinitions>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="System Infrastructure Components" Foreground="White" FontSize="14" FontWeight="SemiBold"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Style="{StaticResource PillButton}" Content="Filters"/>
                                            <Button Style="{StaticResource PillButton}" Content="Export Dataset"/>
                                        </StackPanel>
                                    </Grid>
                                    
                                    <UniformGrid Grid.Row="2" Columns="2" Rows="2">
                                        <Border Background="#0D1220" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Margin="0,0,12,12" Padding="14">
                                            <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                                <StackPanel VerticalAlignment="Center">
                                                    <TextBlock Text="Astra Core Engine Architecture" Foreground="White" FontSize="12" FontWeight="SemiBold"/>
                                                    <TextBlock Text="Status: Operational" Foreground="#10B981" FontSize="10" Margin="0,2,0,0"/>
                                                </StackPanel>
                                            <Button Grid.Column="1" Style="{StaticResource SecondaryButton}" Height="32" Padding="12,0" Content="Inspect"/></Grid>
                                        </Border>
                                        <Border Background="#0D1220" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Margin="0,0,0,12" Padding="14">
                                            <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                                <StackPanel VerticalAlignment="Center">
                                                    <TextBlock Text="Asynchronous Payload Listener" Foreground="White" FontSize="12" FontWeight="SemiBold"/>
                                                    <TextBlock Text="Status: Idle" Foreground="{StaticResource TextSecondaryBrush}" FontSize="10" Margin="0,2,0,0"/>
                                                </StackPanel>
                                            <Button Grid.Column="1" Style="{StaticResource SecondaryButton}" Height="32" Padding="12,0" Content="Inspect"/></Grid>
                                        </Border>
                                        <Border Background="#0D1220" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Margin="0,0,12,0" Padding="14">
                                            <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                                <StackPanel VerticalAlignment="Center">
                                                    <TextBlock Text="Cryptographic Token Valuator" Foreground="White" FontSize="12" FontWeight="SemiBold"/>
                                                    <TextBlock Text="Status: Operational" Foreground="#10B981" FontSize="10" Margin="0,2,0,0"/>
                                                </StackPanel>
                                            <Button Grid.Column="1" Style="{StaticResource SecondaryButton}" Height="32" Padding="12,0" Content="Inspect"/></Grid>
                                        </Border>
                                        <Border Background="#0D1220" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1" CornerRadius="10" Padding="14">
                                            <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                                <StackPanel VerticalAlignment="Center">
                                                    <TextBlock Text="Telemetry Dispatch Relay Pipeline" Foreground="White" FontSize="12" FontWeight="SemiBold"/>
                                                    <TextBlock Text="Status: Operational" Foreground="#10B981" FontSize="10" Margin="0,2,0,0"/>
                                                </StackPanel>
                                            <Button Grid.Column="1" Style="{StaticResource SecondaryButton}" Height="32" Padding="12,0" Content="Inspect"/></Grid>
                                        </Border>
                                    </UniformGrid>
                                </Grid>
                            </Border>
                        </Grid>

                        <!-- VIEW: Library -->
                        <Grid x:Name="PageLibrary" Visibility="Collapsed" Opacity="0">
                            <StackPanel>
                                <TextBlock Text="Content Library" Foreground="White" FontSize="26" FontWeight="SemiBold"/>
                                <TextBlock Text="Manage your pre-compiled custom script signatures and binaries from this workspace." Foreground="{StaticResource TextSecondaryBrush}" FontSize="12" Margin="0,4,0,20"/>
                                <WrapPanel>
                                    <Button Style="{StaticResource PrimaryButton}" Content="Import Elements" Margin="0,0,12,0"/>
                                    <Button Style="{StaticResource SecondaryButton}" Content="Synchronize Cloud"/>
                                </WrapPanel>
                            </StackPanel>
                        </Grid>

                        <!-- VIEW: Activity -->
                        <Grid x:Name="PageActivity" Visibility="Collapsed" Opacity="0">
                            <StackPanel>
                                <TextBlock Text="Live Activity Log" Foreground="White" FontSize="26" FontWeight="SemiBold"/>
                                <TextBlock Text="Real-time performance diagnostic auditing feed." Foreground="{StaticResource TextSecondaryBrush}" FontSize="12" Margin="0,4,0,20"/>
                                <Border Style="{StaticResource CardStyle}" Margin="0" Height="220" Background="#0C101E">
                                    <TextBlock Text="[INFO] 17:54:21 - AstraTrace Security Suite initialized successfully." Foreground="#A78BFA" FontFamily="Consolas" FontSize="11"/>
                                </Border>
                            </StackPanel>
                        </Grid>

                        <!-- VIEW: Settings -->
                        <Grid x:Name="PageSettings" Visibility="Collapsed" Opacity="0">
                            <StackPanel>
                                <TextBlock Text="Application Settings" Foreground="White" FontSize="26" FontWeight="SemiBold"/>
                                <TextBlock Text="Configure layout parameters, network proxies and credentials." Foreground="{StaticResource TextSecondaryBrush}" FontSize="12" Margin="0,4,0,20"/>
                                <Border Style="{StaticResource CardStyle}" Margin="0" Padding="20">
                                    <StackPanel>
                                        <TextBlock Text="UI Accent Profile Selection" Foreground="White" FontSize="14" FontWeight="SemiBold" Margin="0,0,0,12"/>
                                        <WrapPanel>
                                            <Button Tag="Active" Style="{StaticResource PillButton}" Content="Obsidian Cyan"/>
                                            <Button Style="{StaticResource PillButton}" Content="Cyber Orchid"/>
                                            <Button Style="{StaticResource PillButton}" Content="Aurora Teal"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>
                            </StackPanel>
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

# Map all XAML elements with x:Name cleanly to variables without crashing namespaces
$xaml.SelectNodes("//*[local-name()='Window']//*") | ForEach-Object {
    $nameAttr = $_.Attributes | Where-Object { $_.LocalName -eq 'Name' }
    if ($nameAttr) {
        Set-Variable -Name $nameAttr.Value -Value $window.FindName($nameAttr.Value) -Scope Script
    }
}

$pages = @($PageOverview, $PageLibrary, $PageActivity, $PageSettings)
$navs = @($NavOverview, $NavLibrary, $NavActivity, $NavSettings)

function Show-Page([System.Windows.FrameworkElement]$Page, [System.Windows.Controls.Button]$NavigationButton) {
    foreach ($item in $pages) {
        $item.Visibility = 'Collapsed'
        $item.Opacity = 0
    }
    foreach ($button in $navs) { $button.Tag = $null }

    if ($NavigationButton) { $NavigationButton.Tag = 'Active' }
    $Page.Visibility = 'Visible'

    # Fluent smooth page transitions fading animation
    $fade = New-Object Windows.Media.Animation.DoubleAnimation
    $fade.From = 0
    $fade.To = 1
    $fade.Duration = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(250))
    $fade.EasingFunction = New-Object Windows.Media.Animation.CubicEase -Property @{ EasingMode = 'EaseOut' }
    $Page.BeginAnimation([Windows.UIElement]::OpacityProperty, $fade)

    $slide = New-Object Windows.Media.Animation.ThicknessAnimation
    $slide.From = [Windows.Thickness]::new(0,12,0,0)
    $slide.To = [Windows.Thickness]::new(0)
    $slide.Duration = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(280))
    $slide.EasingFunction = New-Object Windows.Media.Animation.CubicEase -Property @{ EasingMode = 'EaseOut' }
    $Page.BeginAnimation([Windows.FrameworkElement]::MarginProperty, $slide)
}

# Bind events
$NavOverview.Add_Click({ Show-Page $PageOverview $NavOverview })
$NavLibrary.Add_Click({ Show-Page $PageLibrary $NavLibrary })
$NavActivity.Add_Click({ Show-Page $PageActivity $NavActivity })
$NavSettings.Add_Click({ Show-Page $PageSettings $NavSettings })

$CloseButton.Add_Click({ $window.Close() })
$MinimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$MaximizeButton.Add_Click({
    if ($window.WindowState -eq 'Maximized') { $window.WindowState = 'Normal' }
    else { $window.WindowState = 'Maximized' }
})

# Make frameless window smoothly draggable
$window.Add_MouseLeftButtonDown({
    if ($_.ChangedButton -eq 'Left' -and $_.OriginalSource -isnot [System.Windows.Controls.Button]) {
        try { $window.DragMove() } catch {}
    }
})

$window.Opacity = 0
$window.Add_ContentRendered({
    $fadeWindow = New-Object Windows.Media.Animation.DoubleAnimation
    $fadeWindow.From = 0
    $fadeWindow.To = 1
    $fadeWindow.Duration = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(400))
    $fadeWindow.EasingFunction = New-Object Windows.Media.Animation.CubicEase -Property @{ EasingMode = 'EaseOut' }
    $window.BeginAnimation([Windows.Window]::OpacityProperty, $fadeWindow)

    # Ambient Background Glass Aura Slow Movement Anims
    $moveOne = New-Object Windows.Media.Animation.DoubleAnimation
    $moveOne.From = -250
    $moveOne.To = -190
    $moveOne.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(10))
    $moveOne.AutoReverse = $true
    $moveOne.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $moveOne.EasingFunction = New-Object Windows.Media.Animation.SineEase -Property @{ EasingMode = 'EaseInOut' }
    $GlowOne.BeginAnimation([System.Windows.Controls.Canvas]::TopProperty, $moveOne)

    $moveTwo = New-Object Windows.Media.Animation.DoubleAnimation
    $moveTwo.From = 450
    $moveTwo.To = 390
    $moveTwo.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(12))
    $moveTwo.AutoReverse = $true
    $moveTwo.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $moveTwo.EasingFunction = New-Object Windows.Media.Animation.SineEase -Property @{ EasingMode = 'EaseInOut' }
    $GlowTwo.BeginAnimation([System.Windows.Controls.Canvas]::TopProperty, $moveTwo)
})

$window.ShowDialog() | Out-Null
