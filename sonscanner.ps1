# FIX-V4 - parser zonder PowerShell-overloadresolutie
# =========================================================================================
# CONFIGURATIEBLOK (Example)
# =========================================================================================
$AppName         = "Example"
$WindowTitle     = "Example Application"
$MainTitle       = "Example Dashboard"
$Subtitle        = "Example Management & Control Interface"
$Description     = "Example system configuration, performance simulation, and global monitoring panel."
$StatusText      = "Example System Status: Operational"
$VersionText     = "Example v1.0.0"

# =========================================================================================
# ASSEMBLIES LADEN
# =========================================================================================
try {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase
    Add-Type -AssemblyName System.Xaml
    Add-Type -AssemblyName System.Xml
}
catch {
    [System.Windows.MessageBox]::Show("Example Fatal Error: Failed to load WPF assemblies.")
    Exit
}

# =========================================================================================
# INLINE XAML INTERFACE (Pure String Formulation)
# =========================================================================================
$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Example"
    Width="1240" Height="780"
    MinWidth="1100" MinHeight="700"
    WindowStartupLocation="CenterScreen"
    ResizeMode="NoResize"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Segoe UI">

    <Window.Resources>
        <LinearGradientBrush x:Key="MainBgGradient" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#020617" Offset="0.0"/>
            <GradientStop Color="#030712" Offset="0.5"/>
            <GradientStop Color="#0B132B" Offset="1.0"/>
        </LinearGradientBrush>

        <SolidColorBrush x:Key="PanelBgBrush" Color="#B3071126"/>
        <SolidColorBrush x:Key="SidebarBgBrush" Color="#030712"/>
        <SolidColorBrush x:Key="BorderSoftBrush" Color="#334155"/>
        <SolidColorBrush x:Key="BorderGlowBrush" Color="#2D60A5FA"/>
        
        <SolidColorBrush x:Key="ElectricBlueBrush" Color="#2563FF"/>
        <SolidColorBrush x:Key="CyanAccentBrush" Color="#22D3EE"/>
        <SolidColorBrush x:Key="TextPrimaryBrush" Color="#F8FAFC"/>
        <SolidColorBrush x:Key="TextSecondaryBrush" Color="#94A3B8"/>
        <SolidColorBrush x:Key="TextMutedBrush" Color="#64748B"/>

        <Style x:Key="PremiumButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="#2563EB"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimaryBrush}"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Height" Value="42"/>
            <Setter Property="Padding" Value="20,0,20,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderGlowBrush}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="BtnBorder" 
                                Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="10">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="BtnBorder" Property="Background" Value="#3B82F6"/>
                                <Setter TargetName="BtnBorder" Property="BorderBrush" Value="{StaticResource CyanAccentBrush}"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="BtnBorder" Property="Background" Value="#1D4ED8"/>
                                <Setter TargetName="BtnBorder" Property="Opacity" Value="0.9"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="BtnBorder" Property="Background" Value="#1E293B"/>
                                <Setter TargetName="BtnBorder" Property="BorderBrush" Value="Transparent"/>
                                <Setter Property="Foreground" Value="{StaticResource TextMutedBrush}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SecondaryButtonStyle" TargetType="Button" BasedOn="{StaticResource PremiumButtonStyle}">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderSoftBrush}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="BtnBorder" 
                                Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="10">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="BtnBorder" Property="Background" Value="#14FFFFFF"/>
                                <Setter TargetName="BtnBorder" Property="BorderBrush" Value="{StaticResource BorderSoftBrush}"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="BtnBorder" Property="Background" Value="#24FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="NavButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{StaticResource TextSecondaryBrush}"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="Height" Value="46"/>
            <Setter Property="Margin" Value="0,4,0,4"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="NavBorder" Background="{TemplateBinding Background}" CornerRadius="8" Padding="12,0,12,0">
                            <Grid>
                                <ContentPresenter VerticalAlignment="Center"/>
                                <Border x:Name="ActiveIndicator" HorizontalAlignment="Left" Width="3" Height="16" Background="{StaticResource CyanAccentBrush}" CornerRadius="1.5" Visibility="Collapsed"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="NavBorder" Property="Background" Value="#0F172A"/>
                                <Setter Property="Foreground" Value="{StaticResource TextPrimaryBrush}"/>
                            </Trigger>
                            <Trigger Property="Tag" Value="Active">
                                <Setter TargetName="NavBorder" Property="Background" Value="#1E293B"/>
                                <Setter Property="Foreground" Value="{StaticResource TextPrimaryBrush}"/>
                                <Setter TargetName="ActiveIndicator" Property="Visibility" Value="Visible"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ToolTip">
            <Setter Property="Background" Value="#0F172A"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderSoftBrush}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimaryBrush}"/>
            <Setter Property="Padding" Value="10,6,10,6"/>
            <Setter Property="ContentTemplate">
                <Setter.Value>
                    <DataTemplate>
                        <TextBlock Text="{Binding}" FontSize="12"/>
                    </DataTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border CornerRadius="16" Background="{StaticResource MainBgGradient}" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1.5" ClipToBounds="True">
        <Grid x:Name="MainGrid">
            
            <Canvas IsHitTestVisible="False" x:Name="BackgroundCanvas">
                <Ellipse Width="600" Height="600" Canvas.Left="-150" Canvas.Top="-150" Opacity="0.25">
                    <Ellipse.Fill>
                        <RadialGradientBrush>
                            <GradientStop Color="#1E40AF" Offset="0"/>
                            <GradientStop Color="#00000000" Offset="1"/>
                        </RadialGradientBrush>
                    </Ellipse.Fill>
                </Ellipse>
                
                <Ellipse Width="500" Height="500" Canvas.Left="840" Canvas.Top="380" Opacity="0.2">
                    <Ellipse.Fill>
                        <RadialGradientBrush>
                            <GradientStop Color="#0369A1" Offset="0"/>
                            <GradientStop Color="#00000000" Offset="1"/>
                        </RadialGradientBrush>
                    </Ellipse.Fill>
                </Ellipse>

                <Path StrokeThickness="2" Opacity="0.15" Data="M 0,400 C 300,200 600,600 1240,350">
                    <Path.Stroke>
                        <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                            <GradientStop Color="#22D3EE" Offset="0"/>
                            <GradientStop Color="#2563FF" Offset="0.5"/>
                            <GradientStop Color="#00000000" Offset="1"/>
                        </LinearGradientBrush>
                    </Path.Stroke>
                    <Path.RenderTransform>
                        <TranslateTransform x:Name="WaveTransform" X="0" Y="0"/>
                    </Path.RenderTransform>
                </Path>

                <Ellipse x:Name="Particle1" Width="8" Height="8" Fill="#22D3EE" Opacity="0.3" Canvas.Left="400" Canvas.Top="500"/>
                <Ellipse x:Name="Particle2" Width="14" Height="14" Fill="#2563FF" Opacity="0.2" Canvas.Left="800" Canvas.Top="200"/>
                <Ellipse x:Name="Particle3" Width="6" Height="6" Fill="#60A5FA" Opacity="0.4" Canvas.Left="200" Canvas.Top="150"/>
            </Canvas>

            <Canvas IsHitTestVisible="False">
                <Ellipse x:Name="CursorGlow" Width="320" Height="320" Opacity="0.12" IsHitTestVisible="False">
                    <Ellipse.Fill>
                        <RadialGradientBrush>
                            <GradientStop Color="#22D3EE" Offset="0"/>
                            <GradientStop Color="#00000000" Offset="0.7"/>
                        </RadialGradientBrush>
                    </Ellipse.Fill>
                </Ellipse>
            </Canvas>

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="48"/> <RowDefinition Height="*"/>   </Grid.RowDefinitions>

                <Border Grid.Row="0" x:Name="TitleBar" Background="#A6020617" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="0,0,0,1">
                    <Grid Margin="16,0,16,0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                            <Viewbox Width="18" Height="18" Margin="0,0,10,0">
                                <Path Data="M0,0 L10,0 L15,10 L5,10 Z M8,12 L20,12 L15,22 L3,22 Z" Fill="{StaticResource CyanAccentBrush}"/>
                            </Viewbox>
                            <TextBlock x:Name="TxtAppName" Text="Example" Foreground="{StaticResource TextPrimaryBrush}" FontSize="15" FontWeight="Bold"/>
                            <Border Margin="12,0,0,0" CornerRadius="6" Background="#1E293B" Padding="6,2,6,2" VerticalAlignment="Center">
                                <TextBlock x:Name="TxtTitleTag" Text="Example State" Foreground="{StaticResource CyanAccentBrush}" FontSize="10" FontWeight="SemiBold"/>
                            </Border>
                        </StackPanel>

                        <TextBlock Grid.Column="1"/>

                        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button x:Name="BtnMinimize" Content="—" Width="32" Height="32" Background="Transparent" Foreground="{StaticResource TextSecondaryBrush}" BorderThickness="0" Cursor="Hand" Margin="0,0,4,0"/>
                            <Button x:Name="BtnMaximize" Content="▢" Width="32" Height="32" Background="Transparent" Foreground="{StaticResource TextSecondaryBrush}" BorderThickness="0" Cursor="Hand" Margin="0,0,4,0"/>
                            <Button x:Name="BtnClose" Content="✕" Width="32" Height="32" Background="Transparent" Foreground="{StaticResource TextSecondaryBrush}" BorderThickness="0" Cursor="Hand"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <Grid Grid.Row="1">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="240"/> <ColumnDefinition Width="*"/>   </Grid.ColumnDefinitions>

                    <Border Grid.Column="0" Background="{StaticResource SidebarBgBrush}" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="0,0,1,0" Padding="16,24,16,16">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <TextBlock Grid.Row="0" Text="NAVIGATION" FontSize="11" FontWeight="Bold" Foreground="{StaticResource TextMutedBrush}" Margin="8,0,0,12"/>

                            <StackPanel Grid.Row="1">
                                <Button x:Name="NavBtn1" Style="{StaticResource NavButtonStyle}" Tag="Active">
                                    <StackPanel Orientation="Horizontal">
                                        <Path Data="M2,4 L20,4 L20,8 L20,18 L2,18 Z" Stroke="{Binding RelativeSource={RelativeSource AncestorType=Button}, Path=Foreground}" StrokeThickness="1.5" Width="14" Height="14" Stretch="Uniform" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                        <TextBlock Text="Example Hub" VerticalAlignment="Center"/>
                                    </StackPanel>
                                </Button>
                                <Button x:Name="NavBtn2" Style="{StaticResource NavButtonStyle}">
                                    <StackPanel Orientation="Horizontal">
                                        <Path Data="M2,18 L6,10 L12,14 L20,4" Stroke="{Binding RelativeSource={RelativeSource AncestorType=Button}, Path=Foreground}" StrokeThickness="1.5" Width="14" Height="14" Stretch="Uniform" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                        <TextBlock Text="Example Analytics" VerticalAlignment="Center"/>
                                    </StackPanel>
                                </Button>
                                <Button x:Name="NavBtn3" Style="{StaticResource NavButtonStyle}">
                                    <StackPanel Orientation="Horizontal">
                                        <Path Data="M12,2 A10,10 0 1 0 22,12" Stroke="{Binding RelativeSource={RelativeSource AncestorType=Button}, Path=Foreground}" StrokeThickness="1.5" Width="14" Height="14" Stretch="Uniform" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                        <TextBlock Text="Example Actions" VerticalAlignment="Center"/>
                                    </StackPanel>
                                </Button>
                            </StackPanel>

                            <StackPanel Grid.Row="2" Margin="4,0,4,8">
                                <Border Height="1" Background="{StaticResource BorderSoftBrush}" Margin="0,0,0,16"/>
                                <TextBlock x:Name="TxtSidebarFooter" Text="Example Console" FontSize="12" Foreground="{StaticResource TextSecondaryBrush}" FontWeight="SemiBold"/>
                                <TextBlock x:Name="TxtSidebarVersion" Text="Example Framework" FontSize="11" Foreground="{StaticResource TextMutedBrush}" Margin="0,2,0,0"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <Grid Grid.Column="1" Margin="24">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/> <RowDefinition Height="*"/>    <RowDefinition Height="64"/>   </Grid.RowDefinitions>

                        <Grid Grid.Row="0" Margin="0,0,0,20">
                            <StackPanel>
                                <TextBlock x:Name="TxtMainTitle" Text="Example Main Title" Foreground="{StaticResource TextPrimaryBrush}" FontSize="28" FontWeight="Bold"/>
                                <TextBlock x:Name="TxtSubtitle" Text="Example Summary Subtitle Description" Foreground="{StaticResource TextSecondaryBrush}" FontSize="14" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Grid>

                        <TabControl Grid.Row="1" x:Name="ViewTabControl" BorderThickness="0" Background="Transparent">
                            <TabControl.ItemContainerStyle>
                                <Style TargetType="TabItem">
                                    <Setter Property="Visibility" Value="Collapsed"/> </Style>
                            </TabControl.ItemContainerStyle>

                            <TabItem>
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="2*"/>
                                        <ColumnDefinition Width="1*"/>
                                    </Grid.ColumnDefinitions>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                    </Grid.RowDefinitions>

                                    <Border Grid.Column="0" Background="{StaticResource PanelBgBrush}" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1" CornerRadius="14" Padding="20" Margin="0,0,16,0">
                                        <Grid>
                                            <StackPanel>
                                                <TextBlock Text="Example Core Panel" Foreground="{StaticResource TextPrimaryBrush}" FontSize="18" FontWeight="Bold"/>
                                                <TextBlock Text="Example component dynamic layout display space." Foreground="{StaticResource TextMutedBrush}" FontSize="13" Margin="0,4,0,16"/>
                                                
                                                <Border Height="240" CornerRadius="10" Background="#050C1A" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1" Padding="16">
                                                    <Grid>
                                                        <Grid.RowDefinitions>
                                                            <RowDefinition Height="Auto"/>
                                                            <RowDefinition Height="*"/>
                                                        </Grid.RowDefinitions>
                                                        <StackPanel Orientation="Horizontal" Grid.Row="0">
                                                            <Ellipse Width="8" Height="8" Fill="#EF4444" Margin="0,0,6,0"/>
                                                            <Ellipse Width="8" Height="8" Fill="#F59E0B" Margin="0,0,6,0"/>
                                                            <Ellipse Width="8" Height="8" Fill="#10B981"/>
                                                        </StackPanel>
                                                        <TextBlock Grid.Row="1" Text="[Example Simulated Visual Space]" Foreground="{StaticResource TextMutedBrush}" HorizontalAlignment="Center" VerticalAlignment="Center" FontFamily="Consolas" FontSize="14"/>
                                                    </Grid>
                                                </Border>
                                            </StackPanel>
                                        </Grid>
                                    </Border>

                                    <StackPanel Grid.Column="1">
                                        <Border Background="{StaticResource PanelBgBrush}" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1" CornerRadius="14" Padding="16" Margin="0,0,0,16">
                                            <StackPanel>
                                                <TextBlock Text="Example Metric A" FontSize="12" FontWeight="Bold" Foreground="{StaticResource TextSecondaryBrush}"/>
                                                <TextBlock x:Name="TxtMetricValA" Text="Example 84.2%" FontSize="24" FontWeight="Bold" Foreground="{StaticResource CyanAccentBrush}" Margin="0,6,0,2"/>
                                                <TextBlock Text="Example secondary analytical text data info." FontSize="11" Foreground="{StaticResource TextMutedBrush}"/>
                                            </StackPanel>
                                        </Border>

                                        <Border Background="{StaticResource PanelBgBrush}" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1" CornerRadius="14" Padding="16">
                                            <StackPanel>
                                                <TextBlock Text="Example Metric B" FontSize="12" FontWeight="Bold" Foreground="{StaticResource TextSecondaryBrush}"/>
                                                <TextBlock x:Name="TxtMetricValB" Text="Example Active" FontSize="24" FontWeight="Bold" Foreground="{StaticResource TextPrimaryBrush}" Margin="0,6,0,2"/>
                                                <ProgressBar Minimum="0" Maximum="100" Value="65" Height="6" Background="#1E293B" Foreground="{StaticResource ElectricBlueBrush}" BorderThickness="0" Margin="0,6,0,0"/>
                                            </StackPanel>
                                        </Border>
                                    </StackPanel>
                                </Grid>
                            </TabItem>

                            <TabItem>
                                <Border Background="{StaticResource PanelBgBrush}" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1" CornerRadius="14" Padding="24">
                                    <StackPanel>
                                        <TextBlock Text="Example Analytics Workspace" Foreground="{StaticResource TextPrimaryBrush}" FontSize="20" FontWeight="Bold"/>
                                        <TextBlock Text="Example structural container intended for system telemetry data visual mapping." Foreground="{StaticResource TextSecondaryBrush}" FontSize="13" Margin="0,4,0,24"/>
                                        
                                        <Border Background="#091224" Padding="16" CornerRadius="8" Margin="0,0,0,10" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1">
                                            <Grid>
                                                <TextBlock Text="Example Operational Pipeline Vector" Foreground="{StaticResource TextPrimaryBrush}" FontWeight="SemiBold"/>
                                                <TextBlock Text="Example OK" Foreground="{StaticResource CyanAccentBrush}" HorizontalAlignment="Right"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#091224" Padding="16" CornerRadius="8" Margin="0,0,0,10" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1">
                                            <Grid>
                                                <TextBlock Text="Example Cluster Node Array Allocation" Foreground="{StaticResource TextPrimaryBrush}" FontWeight="SemiBold"/>
                                                <TextBlock Text="Example 100%" Foreground="{StaticResource CyanAccentBrush}" HorizontalAlignment="Right"/>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>
                            </TabItem>

                            <TabItem>
                                <Border Background="{StaticResource PanelBgBrush}" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1" CornerRadius="14" Padding="24">
                                    <StackPanel>
                                        <TextBlock Text="Example Trigger Actions &amp; Configurations" Foreground="{StaticResource TextPrimaryBrush}" FontSize="20" FontWeight="Bold"/>
                                        <TextBlock Text="Example parameters toggle configuration overview." Foreground="{StaticResource TextSecondaryBrush}" FontSize="13" Margin="0,4,0,24"/>
                                        
                                        <StackPanel Width="300" HorizontalAlignment="Left">
                                            <Grid Margin="0,0,0,16">
                                                <TextBlock Text="Example Feature Optimization" Foreground="{StaticResource TextPrimaryBrush}" VerticalAlignment="Center"/>
                                                <Border x:Name="ToggleSwitch1" HorizontalAlignment="Right" Width="44" Height="22" CornerRadius="11" Background="{StaticResource ElectricBlueBrush}" Padding="2" Cursor="Hand">
                                                    <Ellipse HorizontalAlignment="Right" Width="18" Height="18" Fill="White"/>
                                                </Border>
                                            </Grid>
                                            <Grid Margin="0,0,0,16">
                                                <TextBlock Text="Example Deep Memory Tracing" Foreground="{StaticResource TextPrimaryBrush}" VerticalAlignment="Center"/>
                                                <Border x:Name="ToggleSwitch2" HorizontalAlignment="Right" Width="44" Height="22" CornerRadius="11" Background="#334155" Padding="2" Cursor="Hand">
                                                    <Ellipse HorizontalAlignment="Left" Width="18" Height="18" Fill="White"/>
                                                </Border>
                                            </Grid>
                                        </StackPanel>
                                    </StackPanel>
                                </Border>
                            </TabItem>
                        </TabControl>

                        <Border Grid.Row="2" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="0,1,0,0" Margin="0,12,0,0">
                            <Grid Margin="0,12,0,0">
                                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                    <Ellipse Width="8" Height="8" Fill="#10B981" Margin="0,0,8,0">
                                        <Ellipse.Triggers>
                                            <EventTrigger RoutedEvent="Loaded">
                                                <BeginStoryboard>
                                                    <Storyboard RepeatBehavior="Forever" AutoReverse="True">
                                                        <DoubleAnimation Storyboard.TargetProperty="Opacity" From="0.3" To="1" Duration="0:0:0.8"/>
                                                    </Storyboard>
                                                </BeginStoryboard>
                                            </EventTrigger>
                                        </Ellipse.Triggers>
                                    </Ellipse>
                                    <TextBlock x:Name="TxtStatus" Text="Example Operational Status Text" Foreground="{StaticResource TextSecondaryBrush}" FontSize="13"/>
                                </StackPanel>

                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                    <Button x:Name="BtnOpenSettings" Content="Example Config Panel" Style="{StaticResource SecondaryButtonStyle}" Margin="0,0,12,0" ToolTip="Example Tooltip text trigger description helper string."/>
                                    <Button x:Name="BtnActionExecute" Content="Example Primary Action" Style="{StaticResource PremiumButtonStyle}" ToolTip="Example action initialization execution configuration."/>
                                </StackPanel>
                            </Grid>
                        </Border>
                    </Grid>
                </Grid>
            </Grid>

            <Grid x:Name="ModalOverlay" Visibility="Collapsed" Background="#C6020617">
                <Border Width="500" Height="340" Background="#0B132B" BorderBrush="{StaticResource CyanAccentBrush}" BorderThickness="1.5" CornerRadius="16" Padding="24" HorizontalAlignment="Center" VerticalAlignment="Center">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0">
                            <TextBlock Text="Example Modal Component Title" Foreground="{StaticResource TextPrimaryBrush}" FontSize="20" FontWeight="Bold"/>
                            <TextBlock Text="Example window detailed parameter explanation profile configuration details." Foreground="{StaticResource TextSecondaryBrush}" FontSize="12" Margin="0,4,0,0" TextWrapping="Wrap"/>
                        </StackPanel>

                        <StackPanel Grid.Row="1" VerticalAlignment="Center">
                            <TextBlock Text="Example Input Parameter Parameter Field Label:" Foreground="{StaticResource TextSecondaryBrush}" FontSize="12" Margin="0,0,0,6"/>
                            <TextBox x:Name="TxtBoxExampleInput" Text="Example default placeholder input setting string data" Background="#030712" Foreground="{StaticResource TextPrimaryBrush}" BorderBrush="{StaticResource BorderSoftBrush}" BorderThickness="1" Padding="10" FontSize="13"/>
                        </StackPanel>

                        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right">
                            <Button x:Name="BtnModalCancel" Content="Example Close" Style="{StaticResource SecondaryButtonStyle}" Margin="0,0,12,0"/>
                            <Button x:Name="BtnModalConfirm" Content="Example Save Settings" Style="{StaticResource PremiumButtonStyle}"/>
                        </StackPanel>
                    </Grid>
                </Border>
            </Grid>

            <Canvas IsHitTestVisible="False">
                <Border x:Name="ToastNotificationCard" Width="320" Height="74" Background="#1E293B" BorderBrush="{StaticResource ElectricBlueBrush}" BorderThickness="1" CornerRadius="10" Padding="16,12,16,12" Canvas.Left="1260" Canvas.Top="64" Opacity="0">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="24"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Path Grid.Column="0" Data="M12,2 A10,10 0 1 0 22,12" Stroke="{StaticResource CyanAccentBrush}" StrokeThickness="2" VerticalAlignment="Center" HorizontalAlignment="Left" Width="16" Height="16" Stretch="Uniform"/>
                        <StackPanel Grid.Column="1" Margin="10,0,0,0" VerticalAlignment="Center">
                            <TextBlock Text="Example Alert Notification" Foreground="{StaticResource TextPrimaryBrush}" FontWeight="SemiBold" FontSize="13"/>
                            <TextBlock Text="Example action triggered successfully text info." Foreground="{StaticResource TextSecondaryBrush}" FontSize="11" Margin="0,2,0,0" TextWrapping="NoWrap"/>
                        </StackPanel>
                    </Grid>
                </Border>
            </Canvas>

        </Grid>
    </Border>
</Window>
'@

# =========================================================================================
# XAML PARSER ENGINE (Direct String Stream Deployment to prevent parsing corruption)
# =========================================================================================
try {
    # Gebruik reflection met de exacte Parse(String)-signature. Hierdoor hoeft
    # PowerShell zelf geen overload te kiezen en kan de bekende overload-fout
    # niet vanuit deze parsercode ontstaan.
    $parseMethod = [System.Windows.Markup.XamlReader].GetMethod(
        "Parse",
        [System.Reflection.BindingFlags]::Public -bor [System.Reflection.BindingFlags]::Static,
        $null,
        [Type[]]@([string]),
        $null
    )

    if ($null -eq $parseMethod) {
        throw "Parsermethode Parse(String) is niet beschikbaar in deze WPF-installatie."
    }

    $window = $parseMethod.Invoke($null, [object[]]@([string]$xaml))

    if ($null -eq $window) {
        throw "De XAML-parser retourneerde geen venster."
    }
}
catch {
    $rootError = $_.Exception
    while ($null -ne $rootError.InnerException) {
        $rootError = $rootError.InnerException
    }
    $details = $rootError.Message
    [System.Windows.MessageBox]::Show(
        "Example Critical Error [FIX-V4]: XAML kon niet worden opgebouwd.`n`n" + $details,
        "Example - FIX-V4",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    ) | Out-Null
    Exit 1
}

# =========================================================================================
# INTERFACE ELEMENT VERWIJZINGEN (FindName Engine Mapping)
# =========================================================================================
$MainGrid            = $window.FindName("MainGrid")
$TitleBar            = $window.FindName("TitleBar")
$BackgroundCanvas    = $window.FindName("BackgroundCanvas")
$CursorGlow          = $window.FindName("CursorGlow")

# Window control elementen
$BtnMinimize         = $window.FindName("BtnMinimize")
$BtnMaximize         = $window.FindName("BtnMaximize")
$BtnClose            = $window.FindName("BtnClose")

# Tekst elementen configuratie bindings
$TxtAppName          = $window.FindName("TxtAppName")
$TxtTitleTag         = $window.FindName("TxtTitleTag")
$TxtMainTitle        = $window.FindName("TxtMainTitle")
$TxtSubtitle         = $window.FindName("TxtSubtitle")
$TxtStatus           = $window.FindName("TxtStatus")
$TxtSidebarFooter    = $window.FindName("TxtSidebarFooter")
$TxtSidebarVersion   = $window.FindName("TxtSidebarVersion")
$TxtMetricValA       = $window.FindName("TxtMetricValA")
$TxtMetricValB       = $window.FindName("TxtMetricValB")

# Navigatie / Tabs
$ViewTabControl      = $window.FindName("ViewTabControl")
$NavBtn1             = $window.FindName("NavBtn1")
$NavBtn2             = $window.FindName("NavBtn2")
$NavBtn3             = $window.FindName("NavBtn3")

# Acties & Modals
$BtnOpenSettings     = $window.FindName("BtnOpenSettings")
$BtnActionExecute    = $window.FindName("BtnActionExecute")
$ModalOverlay        = $window.FindName("ModalOverlay")
$BtnModalCancel      = $window.FindName("BtnModalCancel")
$BtnModalConfirm     = $window.FindName("BtnModalConfirm")
$ToggleSwitch1       = $window.FindName("ToggleSwitch1")
$ToggleSwitch2       = $window.FindName("ToggleSwitch2")
$ToastNotificationCard = $window.FindName("ToastNotificationCard")

# =========================================================================================
# WAARDEN INJECTEREN VANUIT CONFIGURATIEBLOK
# =========================================================================================
$TxtAppName.Text        = $AppName
$window.Title           = $WindowTitle
$TxtTitleTag.Text       = "$AppName State"
$TxtMainTitle.Text      = $MainTitle
$TxtSubtitle.Text       = $Description
$TxtStatus.Text         = $StatusText
$TxtSidebarFooter.Text  = "$AppName System"
$TxtSidebarVersion.Text = $VersionText
$TxtMetricValA.Text     = "Example 91.4%"
$TxtMetricValB.Text     = "Example Active"

# =========================================================================================
# WINDOW NATIVE MANAGEMENT BEHAVIOR (Drag, Minimize, Maximize Toggle, Close)
# =========================================================================================
$TitleBar.Add_MouseLeftButtonDown({
    try { $window.DragMove() } catch {}
})

$script:isMaximized = $false
$script:oldLeft = 0
$script:oldTop = 0

$ToggleMaximize = {
    if ($script:isMaximized) {
        $window.Width = 1240
        $window.Height = 780
        $window.Left = $script:oldLeft
        $window.Top = $script:oldTop
        $script:isMaximized = $false
    } else {
        $script:oldLeft = $window.Left
        $script:oldTop = $window.Top
        $screen = [System.Windows.SystemParameters]::WorkArea
        $window.Left = $screen.Left
        $window.Top = $screen.Top
        $window.Width = $screen.Width
        $window.Height = $screen.Height
        $script:isMaximized = $true
    }
}

$TitleBar.Add_MouseDoubleClick({
    $ToggleMaximize.Invoke()
})

$BtnMinimize.Add_Click({
    $window.WindowState = [System.Windows.WindowState]::Minimized
})

$BtnMaximize.Add_Click({
    $ToggleMaximize.Invoke()
})

$BtnClose.Add_Click({
    $script:AnimationTimer.Stop()
    $window.Close()
})

# =========================================================================================
# INTERACTIEVE BACKGROUND GLOW & MOUSE TRACKING SYSTEM
# =========================================================================================
$MainGrid.Add_MouseMove({
    param($sender, $e)
    $pos = $e.GetPosition($MainGrid)
    [System.Windows.Controls.Canvas]::SetLeft($CursorGlow, ($pos.X - 160))
    [System.Windows.Controls.Canvas]::SetTop($CursorGlow, ($pos.Y - 160))
})

# =========================================================================================
# DYNAMIC SELECTION & NAVIGATION MANAGEMENT
# =========================================================================================
$ClearNavSelection = {
    $NavBtn1.Tag = ""
    $NavBtn2.Tag = ""
    $NavBtn3.Tag = ""
}

$NavBtn1.Add_Click({
    & $ClearNavSelection
    $NavBtn1.Tag = "Active"
    $ViewTabControl.SelectedIndex = 0
    $TxtMainTitle.Text = "Example Main Hub"
})

$NavBtn2.Add_Click({
    & $ClearNavSelection
    $NavBtn2.Tag = "Active"
    $ViewTabControl.SelectedIndex = 1
    $TxtMainTitle.Text = "Example Analytics Space"
})

$NavBtn3.Add_Click({
    & $ClearNavSelection
    $NavBtn3.Tag = "Active"
    $ViewTabControl.SelectedIndex = 2
    $TxtMainTitle.Text = "Example Management Options"
})

# =========================================================================================
# INTERACTIEVE TOGGLE SWITCH ANIMATIE EMULATIE
# =========================================================================================
$script:stateToggle1 = $true
$ToggleSwitch1.Add_MouseLeftButtonDown({
    if ($script:stateToggle1) {
        $ToggleSwitch1.Background = [System.Windows.Media.Brushes]::Gray
        ($ToggleSwitch1.Child).HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
        $script:stateToggle1 = $false
    } else {
        $ToggleSwitch1.Background = $window.Resources["ElectricBlueBrush"]
        ($ToggleSwitch1.Child).HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
        $script:stateToggle1 = $true
    }
})

# =========================================================================================
# MODAL LOGICA DIALOG FUNCTIONALITEIT
# =========================================================================================
$BtnOpenSettings.Add_Click({
    $ModalOverlay.Visibility = [System.Windows.Visibility]::Visible
})

$BtnModalCancel.Add_Click({
    $ModalOverlay.Visibility = [System.Windows.Visibility]::Collapsed
})

$BtnModalConfirm.Add_Click({
    $ModalOverlay.Visibility = [System.Windows.Visibility]::Collapsed
    [System.Windows.MessageBox]::Show("Example System Confirmation: Action Data Saved locally ($($window.FindName("TxtBoxExampleInput").Text)).")
})

# Sluit modal via Escape-toets af
$window.Add_KeyDown({
    param($sender, $e)
    if ($e.Key -eq "Escape" -and $ModalOverlay.Visibility -eq [System.Windows.Visibility]::Visible) {
        $ModalOverlay.Visibility = [System.Windows.Visibility]::Collapsed
        $e.Handled = $true
    }
})

# =========================================================================================
# TOAST NOTIFICATION REALTIME TRANSITIE LOGICA (WPF Storyboard)
# =========================================================================================
$ShowToastNotification = {
    $slideAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $slideAnim.From = 1260
    $slideAnim.To = 896
    $slideAnim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(400))
    $slideAnim.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    
    $fadeAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $fadeAnim.From = 0.0
    $fadeAnim.To = 1.0
    $fadeAnim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(300))

    $ToastNotificationCard.BeginAnimation([System.Windows.Controls.Canvas]::LeftProperty, $slideAnim)
    $ToastNotificationCard.BeginAnimation([System.Windows.Controls.Border]::OpacityProperty, $fadeAnim)

    # Automatische Fade-Out Sequentie na vertraging
    $closeTimer = New-Object System.Windows.Threading.DispatcherTimer
    $closeTimer.Interval = [TimeSpan]::FromMilliseconds(3000)
    $closeTimer.Add_Tick({
        $slideOut = New-Object System.Windows.Media.Animation.DoubleAnimation
        $slideOut.To = 1260
        $slideOut.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(400))
        
        $fadeOut = New-Object System.Windows.Media.Animation.DoubleAnimation
        $fadeOut.To = 0.0
        $fadeOut.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(300))

        $ToastNotificationCard.BeginAnimation([System.Windows.Controls.Canvas]::LeftProperty, $slideOut)
        $ToastNotificationCard.BeginAnimation([System.Windows.Controls.Border]::OpacityProperty, $fadeOut)
        
        $closeTimer.Stop()
    })
    $closeTimer.Start()
}

$BtnActionExecute.Add_Click({
    & $ShowToastNotification
})

# =========================================================================================
# PERFORMANT DISPATCHER ACHTERGROND ANIMATIE TIMING MECHANISME
# =========================================================================================
$script:waveOffset = 0.0
$script:particleY = 0.0
$script:particleDirection = 1.0

$WaveTransform = $window.FindName("WaveTransform")
$Particle1 = $window.FindName("Particle1")
$Particle2 = $window.FindName("Particle2")

$script:AnimationTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:AnimationTimer.Interval = [TimeSpan]::FromMilliseconds(30)
$script:AnimationTimer.Add_Tick({
    # Langzame vloeibare golfbeweging transformatie offset
    $script:waveOffset += 0.4
    if ($script:waveOffset -gt 1240) { $script:waveOffset = 0 }
    $WaveTransform.X = $script:waveOffset
    
    # Subtiele zwevende ambient particle floating effecten
    $script:particleY += (0.15 * $script:particleDirection)
    if ([System.Math]::Abs($script:particleY) -gt 20) {
        $script:particleDirection *= -1.0
    }
    
    [System.Windows.Controls.Canvas]::SetTop($Particle1, (500 + $script:particleY))
    [System.Windows.Controls.Canvas]::SetTop($Particle2, (200 - $script:particleY))
})
$script:AnimationTimer.Start()

# =========================================================================================
# APP INITIALISATIE RUN EXECUTION
# =========================================================================================
$window.Dispatcher.Invoke([Action]{
    # Trigger vloeiend intreden effect van venster bij laden
    $window.Opacity = 0
    $fadeInWindow = New-Object System.Windows.Media.Animation.DoubleAnimation
    $fadeInWindow.From = 0.0
    $fadeInWindow.To = 1.0
    $fadeInWindow.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(350))
    $window.BeginAnimation([System.Windows.Window]::OpacityProperty, $fadeInWindow)
})

# Toon de volledig functionele UI interface modal-loze loop runtime
$window.ShowDialog() | Out-Null