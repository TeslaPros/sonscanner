# =========================================================================================
# SYSTEM ASSEMBLY ENTIRE FRAMEWORK INITIALIZATION
# =========================================================================================
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Global Window Runtime Configurations
$version = "3.3"
$announcementTitle = "TeslaPro Streamer Actief"
$announcementMessage = @"
Welkom bij de native TeslaPro Streaming App.

Deze applicatie draait nu volledig lokaal als een stand-alone Windows desktop applicatie (WPF). Er worden geen achtergrond-webservers, poorten of externe browsers gebruikt.

Functies:
• Core Graphics Capture Engine
  Projecteert uw primaire monitor direct in de hardware-versnelde interface.
• Low-Latency Rendering
  Geoptimaliseerd voor minimale CPU-belasting en soepele weergave.

Gebruik de knoppen aan de linkerkant om de live feed te beheren.
"@

# =========================================================================================
# PURE NATIVE WPF XAML INTERFACE DESIGN (Behoudt uw exacte look & feel)
# =========================================================================================
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Tesla Streamer"
    Width="1320"
    Height="830"
    MinWidth="1320"
    MinHeight="830"
    WindowStartupLocation="CenterScreen"
    ResizeMode="NoResize"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Segoe UI"
    Opacity="1">

    <Window.Resources>
        <LinearGradientBrush x:Key="WindowBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#05070B" Offset="0"/>
            <GradientStop Color="#09111B" Offset="0.46"/>
            <GradientStop Color="#071B27" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="SidebarBackground" StartPoint="0,0" EndPoint="0,1">
            <GradientStop Color="#0B1118" Offset="0"/>
            <GradientStop Color="#0D1520" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="PrimaryButtonBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#39E5FF" Offset="0"/>
            <GradientStop Color="#00A8D8" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="DangerButtonBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#3A2028" Offset="0"/>
            <GradientStop Color="#24151A" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="NeutralButtonBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#182332" Offset="0"/>
            <GradientStop Color="#141C27" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="CardBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#101824" Offset="0"/>
            <GradientStop Color="#0B1017" Offset="1"/>
        </LinearGradientBrush>

        <SolidColorBrush x:Key="BorderBrushSoft" Color="#1C2A3C"/>

        <Style x:Key="ActionButtonStyle" TargetType="Button">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Height" Value="56"/>
            <Setter Property="Margin" Value="0,0,0,14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Background" Value="{StaticResource NeutralButtonBrush}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Root" Background="{TemplateBinding Background}" CornerRadius="17" BorderBrush="#203040" BorderThickness="1">
                            <Border.Effect>
                                <DropShadowEffect BlurRadius="18" ShadowDepth="0" Opacity="0.22"/>
                            </Border.Effect>
                            <Grid Margin="16,0,16,0">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="12"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="36" Height="36" CornerRadius="11" Background="#18FFFFFF" BorderBrush="#24FFFFFF" BorderThickness="1" VerticalAlignment="Center">
                                    <TextBlock Text="{TemplateBinding Tag}" FontFamily="Segoe MDL2 Assets" FontSize="15" Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <ContentPresenter Grid.Column="2" VerticalAlignment="Center" RecognizesAccessKey="True"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Root" Property="Opacity" Value="0.97"/>
                                <Setter TargetName="Root" Property="BorderBrush" Value="#35D9FF"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Root" Property="Opacity" Value="0.82"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Root" Property="Opacity" Value="0.25"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SmallWindowButtonStyle" TargetType="Button">
            <Setter Property="Width" Value="34"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="Margin" Value="8,0,0,0"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="16"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Background" Value="#14FFFFFF"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="BtnBorder" Background="{TemplateBinding Background}" CornerRadius="10">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="BtnBorder" Property="Opacity" Value="0.90"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="BtnBorder" Property="Opacity" Value="0.72"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="CardBorderStyle" TargetType="Border">
            <Setter Property="CornerRadius" Value="22"/>
            <Setter Property="Padding" Value="22"/>
            <Setter Property="Background" Value="{StaticResource CardBackground}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrushSoft}"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>

        <Style x:Key="MiniStatStyle" TargetType="Border">
            <Setter Property="CornerRadius" Value="20"/>
            <Setter Property="Padding" Value="18"/>
            <Setter Property="Background" Value="{StaticResource CardBackground}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrushSoft}"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Border CornerRadius="24" Background="{StaticResource WindowBackground}" BorderBrush="#1D2938" BorderThickness="1">
            <Border.Effect>
                <DropShadowEffect BlurRadius="30" ShadowDepth="0" Opacity="0.45"/>
            </Border.Effect>

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="64"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Ellipse Width="560" Height="560" Fill="#1DDCFF" Opacity="0.06" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="-190,-180,0,0"/>
                <Ellipse Width="430" Height="430" Fill="#0E86FF" Opacity="0.05" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,-120,-130"/>

                <Border Grid.Row="0" Background="#0A0F17" CornerRadius="24,24,0,0" BorderBrush="#162232" BorderThickness="0,0,0,1">
                    <Grid Margin="18,0,18,0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Border Width="40" Height="40" CornerRadius="13" Background="#101A27" BorderBrush="#23435D" BorderThickness="1">
                                <TextBlock Text="T" FontSize="20" FontWeight="Bold" Foreground="#7BE9FF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <StackPanel Margin="12,0,0,0" VerticalAlignment="Center">
                                <TextBlock Text="Tesla Streamer" FontSize="18" FontWeight="SemiBold" Foreground="White"/>
                                <TextBlock Text="TeslaPro Native App Shell" FontSize="11" Foreground="#7E92A6" Margin="0,2,0,0"/>
                            </StackPanel>
                        </StackPanel>

                        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button x:Name="InfoButtonTop" Content="ⓘ" Style="{StaticResource SmallWindowButtonStyle}" Background="#163043"/>
                            <Button x:Name="MinButton" Content="—" Style="{StaticResource SmallWindowButtonStyle}"/>
                            <Button x:Name="CloseButton" Content="✕" Style="{StaticResource SmallWindowButtonStyle}" Background="#1F2330"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <Grid Grid.Row="1" Margin="20">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="300"/>
                        <ColumnDefinition Width="20"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <Border Grid.Column="0" Background="{StaticResource SidebarBackground}" CornerRadius="22" BorderBrush="#192537" BorderThickness="1" Padding="20">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="18"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel>
                                <TextBlock Text="Control Center" FontSize="24" FontWeight="SemiBold" Foreground="White"/>
                                <TextBlock Text="Start en bestuur uw hardware-versnelde schermopname lokaal vanuit deze shell." TextWrapping="Wrap" Margin="0,8,0,0" Foreground="#8EA2B6" FontSize="13"/>
                            </StackPanel>

                            <StackPanel Grid.Row="2">
                                <Button x:Name="StartButton" Tag="&#xE768;" Content="Start Screen Share" Style="{StaticResource ActionButtonStyle}" Background="{StaticResource PrimaryButtonBrush}"/>
                                <Button x:Name="StopButton" Tag="&#xE71A;" Content="Stop Screen Share" Style="{StaticResource ActionButtonStyle}" Background="{StaticResource DangerButtonBrush}" IsEnabled="False"/>
                                <Button x:Name="CopyTokenButton" Tag="&#xE8C8;" Content="Kopieer Connectie Token" Style="{StaticResource ActionButtonStyle}" Background="#182434"/>
                                <Button x:Name="SettingsButton" Tag="&#xE713;" Content="Systeem Instellingen" Style="{StaticResource ActionButtonStyle}" Background="#182434"/>
                                <Button x:Name="ExitButton" Tag="&#xE8BB;" Content="Applicatie Sluiten" Style="{StaticResource ActionButtonStyle}" Background="#141C28"/>
                            </StackPanel>

                            <Border Grid.Row="4" Background="#0B1017" CornerRadius="18" Padding="16" BorderBrush="#1B2837" BorderThickness="1">
                                <StackPanel>
                                    <TextBlock Text="Engine Modus" FontSize="12" Foreground="#7890A6"/>
                                    <TextBlock x:Name="LocationText" Margin="0,8,0,0" TextWrapping="Wrap" Foreground="White" FontSize="13" Text="Native Windows Graphics API"/>

                                    <Border Margin="0,14,0,0" CornerRadius="14" Background="#101722" Padding="12" BorderBrush="#203042" BorderThickness="1">
                                        <Grid>
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="Auto"/>
                                            </Grid.ColumnDefinitions>
                                            <StackPanel>
                                                <TextBlock Text="Shell Versie" Foreground="#7A92A8" FontSize="11"/>
                                                <TextBlock x:Name="VersionText" Text="Version 3.3" Foreground="#74E8FF" FontSize="16" FontWeight="Bold" Margin="0,4,0,0"/>
                                            </StackPanel>
                                            <Border Grid.Column="1" Width="110" Height="30" CornerRadius="15" Background="#122232" BorderBrush="#234760" BorderThickness="1" VerticalAlignment="Center">
                                                <TextBlock x:Name="StateChip" Text="IDLE" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#74E8FF" FontSize="12" FontWeight="Bold"/>
                                            </Border>
                                        </Grid>
                                    </Border>
                                </StackPanel>
                            </Border>
                        </Grid>
                    </Border>

                    <Grid Grid.Column="2">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="165"/>
                            <RowDefinition Height="18"/>
                            <RowDefinition Height="150"/>
                            <RowDefinition Height="18"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <Border Grid.Row="0" Style="{StaticResource CardBorderStyle}">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="290"/>
                                </Grid.ColumnDefinitions>

                                <StackPanel>
                                    <TextBlock x:Name="StatusText" Text="Ready" FontSize="30" FontWeight="SemiBold" Foreground="White"/>
                                    <TextBlock x:Name="SubStatusText" Text="Systeem stand-by. Kies een actie in het linkerpaneel om te starten." Margin="0,8,0,0" FontSize="14" Foreground="#9DB1C4"/>
                                    <Border Margin="0,18,0,0" CornerRadius="14" Background="#0B121B" Padding="12" BorderBrush="#1A293A" BorderThickness="1">
                                        <TextBlock Text="Een geavanceerde, ultra-snelle render engine zonder browser-overhead." Foreground="#84A1BA" TextWrapping="Wrap"/>
                                    </Border>
                                </StackPanel>

                                <Border Grid.Column="1" HorizontalAlignment="Right" Width="260" Height="110" CornerRadius="22" Background="#0B1119" BorderBrush="#1E3145" BorderThickness="1">
                                    <Grid Margin="16 Cla">
                                        <Grid.RowDefinitions>
                                            <RowDefinition Height="Auto"/>
                                            <RowDefinition Height="*"/>
                                        </Grid.RowDefinitions>
                                        <TextBlock Text="Stream Status" Foreground="#7990A5" FontSize="12"/>
                                        <StackPanel Grid.Row="1" VerticalAlignment="Center">
                                            <TextBlock x:Name="BigChipText" Text="IDLE" HorizontalAlignment="Center" Foreground="#74E8FF" FontSize="22" FontWeight="Bold"/>
                                            <TextBlock x:Name="FooterText" Text="Klaar voor opname" HorizontalAlignment="Center" Foreground="#8FA4B8" FontSize="12" Margin="0,6,0,0"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>
                            </Grid>
                        </Border>

                        <Grid Grid.Row="2">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="16"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="16"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <Border Grid.Column="0" Style="{StaticResource MiniStatStyle}">
                                <StackPanel>
                                    <TextBlock Text="Systeem Status" FontSize="12" Foreground="#7C93A8"/>
                                    <TextBlock x:Name="StepText" Text="STANDBY" FontSize="22" FontWeight="SemiBold" Foreground="White" Margin="0,8,0,0"/>
                                    <TextBlock Text="Huidige status van de core." Margin="0,6,0,0" Foreground="#8DA3B7" FontSize="12"/>
                                </StackPanel>
                            </Border>

                            <Border Grid.Column="2" Style="{StaticResource MiniStatStyle}">
                                <StackPanel>
                                    <TextBlock Text="Resolutie" FontSize="12" Foreground="#7C93A8"/>
                                    <TextBlock x:Name="ProgressLabel" Text="—" FontSize="22" FontWeight="SemiBold" Foreground="White" Margin="0,8,0,0"/>
                                    <TextBlock Text="Gedetecteerde monitor dimensie." Margin="0,6,0,0" Foreground="#8DA3B7" FontSize="12"/>
                                </StackPanel>
                            </Border>

                            <Border Grid.Column="4" Style="{StaticResource MiniStatStyle}">
                                <StackPanel>
                                    <TextBlock Text="Framerate Target" FontSize="12" Foreground="#7C93A8"/>
                                    <TextBlock x:Name="ToolCountText" Text="0 FPS" FontSize="22" FontWeight="SemiBold" Foreground="White" Margin="0,8,0,0"/>
                                    <TextBlock Text="Frames per seconde capture rate." Margin="0,6,0,0" Foreground="#8DA3B7" FontSize="12"/>
                                </StackPanel>
                            </Border>
                        </Grid>

                        <Border Grid.Row="4" Style="{StaticResource CardBorderStyle}">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="16"/>
                                    <RowDefinition Height="*"/>
                                </Grid.RowDefinitions>

                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <StackPanel>
                                        <TextBlock Text="Live Preview Window" FontSize="22" FontWeight="SemiBold" Foreground="White"/>
                                        <TextBlock Text="Hardware direct screen-capture frame feed" Foreground="#91A7BB" FontSize="12" Margin="0,6,0,0"/>
                                    </StackPanel>
                                    <Border Grid.Column="1" Width="140" Height="34" HorizontalAlignment="Right" VerticalAlignment="Top" CornerRadius="17" Background="#0B121B" BorderBrush="#203447" BorderThickness="1">
                                        <TextBlock x:Name="MiniStateText" Text="READY" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#74E8FF" FontWeight="Bold"/>
                                    </Border>
                                </Grid>

                                <Border Grid.Row="2" CornerRadius="18" Background="#091018" BorderBrush="#1A2B3C" BorderThickness="1" Padding="4" ClipToBounds="True">
                                    <Grid>
                                        <Image x:Name="LiveImage" Stretch="Uniform" Visibility="Collapsed"/>
                                        
                                        <StackPanel x:Name="EmptyStatePanel" VerticalAlignment="Center" HorizontalAlignment="Center">
                                            <TextBlock Text="" FontFamily="Segoe MDL2 Assets" FontSize="48" Foreground="#39E5FF" HorizontalAlignment="Center" Margin="0,0,0,16"/>
                                            <TextBlock Text="Geen actieve stream feed" FontSize="18" FontWeight="SemiBold" Foreground="White" HorizontalAlignment="Center"/>
                                            <TextBlock Text="Klik links op 'Start Screen Share' om de live opname te initialiseren." FontSize="13" Foreground="#8DA3B7" HorizontalAlignment="Center" Margin="0,6,0,0"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>
                            </Grid>
                        </Border>
                    </Grid>
                </Grid>
            </Grid>
        </Border>

        <Grid x:Name="InfoRoot" Visibility="Collapsed" Opacity="0" Background="#A0000000">
            <Border Width="620" Padding="24" CornerRadius="22" Background="#0D141D" BorderBrush="#203447" BorderThickness="1" HorizontalAlignment="Center" VerticalAlignment="Center">
                <Border.Effect>
                    <DropShadowEffect BlurRadius="30" ShadowDepth="0" Opacity="0.35"/>
                </Border.Effect>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="18"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="20"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Width="44" Height="44" CornerRadius="14" Background="#112130" BorderBrush="#28445C" BorderThickness="1">
                            <TextBlock Text="i" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="21" FontWeight="Bold" Foreground="#74E8FF"/>
                        </Border>
                        <StackPanel Grid.Column="1" Margin="14,0,0,0">
                            <TextBlock Text="Over Deze Applicatie" FontSize="22" FontWeight="SemiBold" Foreground="White"/>
                            <TextBlock Text="Tesla Launcher &amp; Streamer Informatie" Foreground="#8FA4B8" FontSize="12" Margin="0,4,0,0"/>
                        </StackPanel>
                        <Button x:Name="InfoCloseButton" Grid.Column="2" Content="✕" Width="34" Height="34" Style="{StaticResource SmallWindowButtonStyle}" Background="#1F2330"/>
                    </Grid>
                    <StackPanel Grid.Row="2">
                        <Border CornerRadius="16" Background="#0A1018" BorderBrush="#1C2E40" BorderThickness="1" Padding="16">
                            <TextBlock TextWrapping="Wrap" Foreground="#DCE7F2" FontSize="13">
Deze streamer app is volledig native gebouwd in WPF door TeslaPro.

Er wordt direct via GDI+ gecaptured zonder omwegen. Mocht u vragen hebben of mee willen ontwikkelen aan de optimalisatie van dit platform, neem dan contact op via Discord:
@teamwsf

Het distribueren of aanpassen van deze binary/codebase vereist expliciete toestemming.
                            </TextBlock>
                        </Border>
                    </StackPanel>
                    <StackPanel Grid.Row="4" Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button x:Name="InfoOkButton" Tag="&#xE73E;" Content="Sluiten" Style="{StaticResource ActionButtonStyle}" Background="{StaticResource PrimaryButtonBrush}" Width="140" Margin="0"/>
                    </StackPanel>
                </Grid>
            </Border>
        </Grid>

        <Grid x:Name="PopupRoot" Visibility="Collapsed" Opacity="0" Background="#A0000000">
            <Border Width="520" Padding="22" CornerRadius="22" Background="#0D141D" BorderBrush="#203447" BorderThickness="1" HorizontalAlignment="Center" VerticalAlignment="Center">
                <Border.Effect>
                    <DropShadowEffect BlurRadius="30" ShadowDepth="0" Opacity="0.35"/>
                </Border.Effect>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="16"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="20"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Width="44" Height="44" CornerRadius="14" Background="#112130" BorderBrush="#28445C" BorderThickness="1">
                            <TextBlock x:Name="PopupIconText" Text="i" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="20" FontWeight="Bold" Foreground="#74E8FF"/>
                        </Border>
                        <StackPanel Grid.Column="1" Margin="14,0,0,0">
                            <TextBlock x:Name="PopupTitleText" Text="Melding" FontSize="22" FontWeight="SemiBold" Foreground="White"/>
                            <TextBlock x:Name="PopupSubtitleText" Text="Tesla Streamer Core" Foreground="#8FA4B8" FontSize="12" Margin="0,4,0,0"/>
                        </StackPanel>
                        <Button x:Name="PopupCloseButton" Grid.Column="2" Content="✕" Width="34" Height="34" Style="{StaticResource SmallWindowButtonStyle}" Background="#1F2330"/>
                    </Grid>
                    <Border Grid.Row="2" CornerRadius="16" Background="#0A1018" BorderBrush="#1C2E40" BorderThickness="1" Padding="16">
                        <TextBlock x:Name="PopupMessageText" TextWrapping="Wrap" Foreground="#DCE7F2" FontSize="13" Text="Message content here."/>
                    </Border>
                    <StackPanel Grid.Row="4" Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button x:Name="PopupOkButton" Tag="&#xE73E;" Content="OK" Style="{StaticResource ActionButtonStyle}" Background="{StaticResource PrimaryButtonBrush}" Width="130" Margin="0"/>
                    </StackPanel>
                </Grid>
            </Border>
        </Grid>
    </Grid>
</Window>
"@

# =========================================================================================
# OBJECT BINDING MAPPER SYSTEM
# =========================================================================================
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Sidebar Action Knop Mappings
$StartButton      = $window.FindName("StartButton")
$StopButton       = $window.FindName("StopButton")
$CopyTokenButton  = $window.FindName("CopyTokenButton")
$SettingsButton   = $window.FindName("SettingsButton")
$ExitButton         = $window.FindName("ExitButton")
$CloseButton        = $window.FindName("CloseButton")
$MinButton          = $window.FindName("MinButton")
$InfoButtonTop      = $window.FindName("InfoButtonTop")

# Real-time UI Display Mappings
$StatusText         = $window.FindName("StatusText")
$SubStatusText      = $window.FindName("SubStatusText")
$StateChip          = $window.FindName("StateChip")
$BigChipText        = $window.FindName("BigChipText")
$MiniStateText      = $window.FindName("MiniStateText")
$FooterText         = $window.FindName("FooterText")
$StepText           = $window.FindName("StepText")
$ProgressLabel      = $window.FindName("ProgressLabel")
$ToolCountText      = $window.FindName("ToolCountText")
$LocationText       = $window.FindName("LocationText")
$VersionText        = $window.FindName("VersionText")

# Direct Live Capture Element Mappings
$LiveImage          = $window.FindName("LiveImage")
$EmptyStatePanel    = $window.FindName("EmptyStatePanel")

# Overlays / Overlay dialog Popups
$InfoRoot           = $window.FindName("InfoRoot")
$InfoCloseButton    = $window.FindName("InfoCloseButton")
$InfoOkButton       = $window.FindName("InfoOkButton")

$PopupRoot          = $window.FindName("PopupRoot")
$PopupCloseButton   = $window.FindName("PopupCloseButton")
$PopupOkButton      = $window.FindName("PopupOkButton")
$PopupTitleText     = $window.FindName("PopupTitleText")
$PopupSubtitleText  = $window.FindName("PopupSubtitleText")
$PopupMessageText   = $window.FindName("PopupMessageText")
$PopupIconText      = $window.FindName("PopupIconText")

# Init static parameters
$VersionText.Text  = "Version $version"

# =========================================================================================
# CORE UTILITIES & FLOATING ANIMATION LOGIC ENGINE
# =========================================================================================
function Refresh-Ui {
    $window.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
}

function Show-Fade