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
        Title="AstraTrace"
        Width="1180" Height="760"
        MinWidth="980" MinHeight="650"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        ResizeMode="CanResizeWithGrip"
        AllowsTransparency="True"
        Background="Transparent"
        FontFamily="Segoe UI Variable Display, Segoe UI"
        SnapsToDevicePixels="True"
        UseLayoutRounding="True">

    <Window.Resources>
        <Color x:Key="Bg0">#07090F</Color>
        <Color x:Key="Bg1">#0B0E17</Color>
        <Color x:Key="Surface0">#101521</Color>
        <Color x:Key="Surface1">#141B2A</Color>
        <Color x:Key="Stroke0">#253047</Color>
        <Color x:Key="Text0">#F4F7FF</Color>
        <Color x:Key="Text1">#8D9AB2</Color>
        <Color x:Key="Cyan">#53E7FF</Color>
        <Color x:Key="Violet">#8C6CFF</Color>

        <SolidColorBrush x:Key="SurfaceBrush" Color="{StaticResource Surface0}"/>
        <SolidColorBrush x:Key="SurfaceHoverBrush" Color="{StaticResource Surface1}"/>
        <SolidColorBrush x:Key="StrokeBrush" Color="{StaticResource Stroke0}"/>
        <SolidColorBrush x:Key="TextBrush" Color="{StaticResource Text0}"/>
        <SolidColorBrush x:Key="MutedBrush" Color="{StaticResource Text1}"/>
        <SolidColorBrush x:Key="CyanBrush" Color="{StaticResource Cyan}"/>
        <SolidColorBrush x:Key="VioletBrush" Color="{StaticResource Violet}"/>

        <LinearGradientBrush x:Key="AccentGradient" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#53E7FF" Offset="0"/>
            <GradientStop Color="#8C6CFF" Offset="1"/>
        </LinearGradientBrush>

        <DropShadowEffect x:Key="SoftShadow" Color="#000000" BlurRadius="26" ShadowDepth="8" Opacity="0.38"/>
        <DropShadowEffect x:Key="GlowShadow" Color="#53E7FF" BlurRadius="24" ShadowDepth="0" Opacity="0.24"/>

        <Style x:Key="WindowButton" TargetType="Button">
            <Setter Property="Width" Value="38"/>
            <Setter Property="Height" Value="32"/>
            <Setter Property="Margin" Value="4,0,0,0"/>
            <Setter Property="Foreground" Value="{StaticResource MutedBrush}"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Shell" Background="{TemplateBinding Background}" CornerRadius="8">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Shell" Property="Background" Value="#182033"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Shell" Property="Opacity" Value="0.72"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="NavButton" TargetType="Button">
            <Setter Property="Height" Value="48"/>
            <Setter Property="Margin" Value="0,0,0,8"/>
            <Setter Property="Padding" Value="15,0"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Foreground" Value="{StaticResource MutedBrush}"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="NavShell" Background="{TemplateBinding Background}" CornerRadius="12">
                            <Grid>
                                <Border x:Name="Indicator" Width="3" Height="22" CornerRadius="2"
                                        HorizontalAlignment="Left" VerticalAlignment="Center"
                                        Background="{StaticResource AccentGradient}" Opacity="0"/>
                                <ContentPresenter Margin="8,0,0,0" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="NavShell" Property="Background" Value="#131A29"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="Tag" Value="Active">
                                <Setter TargetName="NavShell" Property="Background" Value="#172033"/>
                                <Setter TargetName="Indicator" Property="Opacity" Value="1"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="NavShell" Property="Opacity" Value="0.78"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Height" Value="42"/>
            <Setter Property="Padding" Value="20,0"/>
            <Setter Property="Margin" Value="0,0,10,0"/>
            <Setter Property="Foreground" Value="#071017"/>
            <Setter Property="Background" Value="{StaticResource AccentGradient}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Shell" Background="{TemplateBinding Background}" CornerRadius="11"
                                Effect="{StaticResource GlowShadow}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Shell" Property="RenderTransformOrigin" Value="0.5,0.5"/>
                                <Setter TargetName="Shell" Property="RenderTransform">
                                    <Setter.Value><ScaleTransform ScaleX="1.025" ScaleY="1.025"/></Setter.Value>
                                </Setter>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Shell" Property="RenderTransform">
                                    <Setter.Value><ScaleTransform ScaleX="0.975" ScaleY="0.975"/></Setter.Value>
                                </Setter>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SecondaryButton" TargetType="Button">
            <Setter Property="Height" Value="42"/>
            <Setter Property="Padding" Value="20,0"/>
            <Setter Property="Margin" Value="0,0,10,0"/>
            <Setter Property="Foreground" Value="{StaticResource TextBrush}"/>
            <Setter Property="Background" Value="#121928"/>
            <Setter Property="BorderBrush" Value="{StaticResource StrokeBrush}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Shell" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="11">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Shell" Property="Background" Value="#192238"/>
                                <Setter TargetName="Shell" Property="BorderBrush" Value="#41516F"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Shell" Property="Opacity" Value="0.72"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="GhostButton" TargetType="Button" BasedOn="{StaticResource SecondaryButton}">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderBrush" Value="#2A354D"/>
        </Style>

        <Style x:Key="PillButton" TargetType="Button">
            <Setter Property="Height" Value="32"/>
            <Setter Property="Padding" Value="14,0"/>
            <Setter Property="Margin" Value="0,0,8,0"/>
            <Setter Property="Foreground" Value="{StaticResource MutedBrush}"/>
            <Setter Property="Background" Value="#111827"/>
            <Setter Property="BorderBrush" Value="#253149"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Pill" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="16">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Pill" Property="Background" Value="#19243A"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="Tag" Value="Active">
                                <Setter TargetName="Pill" Property="Background" Value="#21314A"/>
                                <Setter TargetName="Pill" Property="BorderBrush" Value="#53E7FF"/>
                                <Setter Property="Foreground" Value="#8DEEFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="CardStyle" TargetType="Border">
            <Setter Property="Background" Value="#101622"/>
            <Setter Property="BorderBrush" Value="#222D43"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="16"/>
            <Setter Property="Padding" Value="18"/>
            <Setter Property="Margin" Value="0,0,14,14"/>
        </Style>
    </Window.Resources>

    <Border CornerRadius="22" Background="#080B12" BorderBrush="#263149" BorderThickness="1" Effect="{StaticResource SoftShadow}">
        <Grid ClipToBounds="True">
            <Grid.Background>
                <RadialGradientBrush Center="0.78,0.1" GradientOrigin="0.78,0.1" RadiusX="0.8" RadiusY="0.8">
                    <GradientStop Color="#20204E73" Offset="0"/>
                    <GradientStop Color="#10162B48" Offset="0.38"/>
                    <GradientStop Color="#00070A10" Offset="1"/>
                </RadialGradientBrush>
            </Grid.Background>

            <Canvas IsHitTestVisible="False" ClipToBounds="True">
                <Ellipse x:Name="GlowOne" Width="420" Height="420" Canvas.Left="720" Canvas.Top="-240" Opacity="0.20">
                    <Ellipse.Fill>
                        <RadialGradientBrush>
                            <GradientStop Color="#8C6CFF" Offset="0"/>
                            <GradientStop Color="#008C6CFF" Offset="1"/>
                        </RadialGradientBrush>
                    </Ellipse.Fill>
                </Ellipse>
                <Ellipse x:Name="GlowTwo" Width="360" Height="360" Canvas.Left="-170" Canvas.Top="470" Opacity="0.16">
                    <Ellipse.Fill>
                        <RadialGradientBrush>
                            <GradientStop Color="#53E7FF" Offset="0"/>
                            <GradientStop Color="#0053E7FF" Offset="1"/>
                        </RadialGradientBrush>
                    </Ellipse.Fill>
                </Ellipse>
                <Rectangle Width="1600" Height="1" Canvas.Left="-150" Canvas.Top="215" Opacity="0.24">
                    <Rectangle.Fill>
                        <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                            <GradientStop Color="#0053E7FF" Offset="0"/>
                            <GradientStop Color="#5353E7FF" Offset="0.5"/>
                            <GradientStop Color="#0053E7FF" Offset="1"/>
                        </LinearGradientBrush>
                    </Rectangle.Fill>
                </Rectangle>
            </Canvas>

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="58"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="#B2090D16" BorderBrush="#1D2638" BorderThickness="0,0,0,1" CornerRadius="22,22,0,0">
                    <Grid Margin="18,0,14,0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="230"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Border Width="30" Height="30" CornerRadius="9" Background="{StaticResource AccentGradient}" Effect="{StaticResource GlowShadow}">
                                <TextBlock Text="A" Foreground="#071017" FontWeight="Black" FontSize="15" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <TextBlock Text="ASTRATRACE" Margin="11,0,0,0" Foreground="White" FontWeight="Bold" FontSize="12" VerticalAlignment="Center"/>
                        </StackPanel>
                        <Border Grid.Column="1" Width="250" Height="32" HorizontalAlignment="Center" CornerRadius="10" Background="#0D1320" BorderBrush="#202B40" BorderThickness="1">
                            <Grid Margin="12,0">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition/></Grid.ColumnDefinitions>
                                <TextBlock Text="⌕" Foreground="#6F7D95" FontSize="16" VerticalAlignment="Center"/>
                                <TextBlock Grid.Column="1" Text="Search" Foreground="#58677F" FontSize="11" Margin="10,0,0,0" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button x:Name="MinimizeButton" Style="{StaticResource WindowButton}" Content="—"/>
                            <Button x:Name="MaximizeButton" Style="{StaticResource WindowButton}" Content="□"/>
                            <Button x:Name="CloseButton" Style="{StaticResource WindowButton}" Content="×"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <Grid Grid.Row="1">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="228"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <Border Background="#94090D16" BorderBrush="#1D2638" BorderThickness="0,0,1,0" CornerRadius="0,0,0,22">
                        <Grid Margin="14,18,14,16">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <StackPanel>
                                <Button x:Name="NavOverview" Tag="Active" Style="{StaticResource NavButton}" Content="◈   Overview"/>
                                <Button x:Name="NavLibrary" Style="{StaticResource NavButton}" Content="▦   Library"/>
                                <Button x:Name="NavActivity" Style="{StaticResource NavButton}" Content="⌁   Activity"/>
                                <Button x:Name="NavSettings" Style="{StaticResource NavButton}" Content="⚙   Settings"/>
                            </StackPanel>
                            <StackPanel Grid.Row="2">
                                <Button Style="{StaticResource NavButton}" Content="?   Support"/>
                                <Border Background="#101725" BorderBrush="#243149" BorderThickness="1" CornerRadius="14" Padding="12">
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="34"/><ColumnDefinition/></Grid.ColumnDefinitions>
                                        <Border Width="30" Height="30" CornerRadius="10" Background="#1C2941">
                                            <TextBlock Text="J" Foreground="#7CEAFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <StackPanel Grid.Column="1" Margin="10,0,0,0" VerticalAlignment="Center">
                                            <TextBlock Text="Profile" Foreground="White" FontSize="11" FontWeight="SemiBold"/>
                                            <TextBlock Text="Premium" Foreground="#7F8DA7" FontSize="9" Margin="0,2,0,0"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <Grid Grid.Column="1" Margin="28,24,28,26">
                        <Grid x:Name="PageOverview">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="20"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="18"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <Grid>
                                <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Overview" Foreground="White" FontSize="29" FontWeight="SemiBold"/>
                                    <StackPanel Orientation="Horizontal" Margin="0,12,0,0">
                                        <Button Tag="Active" Style="{StaticResource PillButton}" Content="All"/>
                                        <Button Style="{StaticResource PillButton}" Content="Recent"/>
                                        <Button Style="{StaticResource PillButton}" Content="Pinned"/>
                                    </StackPanel>
                                </StackPanel>
                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Top">
                                    <Button Style="{StaticResource GhostButton}" Content="Secondary"/>
                                    <Button Style="{StaticResource PrimaryButton}" Content="Primary"/>
                                </StackPanel>
                            </Grid>

                            <Grid Grid.Row="2">
                                <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition/><ColumnDefinition/></Grid.ColumnDefinitions>
                                <Border Grid.Column="0" Style="{StaticResource CardStyle}">
                                    <StackPanel>
                                        <Border Width="38" Height="38" CornerRadius="11" Background="#172C38" HorizontalAlignment="Left">
                                            <TextBlock Text="◈" Foreground="#53E7FF" FontSize="17" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <TextBlock Text="Card One" Foreground="White" FontSize="15" FontWeight="SemiBold" Margin="0,20,0,0"/>
                                        <Rectangle Height="7" RadiusX="4" RadiusY="4" Fill="#253149" Margin="0,12,42,0"/>
                                        <Rectangle Height="7" RadiusX="4" RadiusY="4" Fill="#1D273A" Margin="0,8,78,0"/>
                                    </StackPanel>
                                </Border>
                                <Border Grid.Column="1" Style="{StaticResource CardStyle}">
                                    <StackPanel>
                                        <Border Width="38" Height="38" CornerRadius="11" Background="#251F42" HorizontalAlignment="Left">
                                            <TextBlock Text="◇" Foreground="#9C83FF" FontSize="17" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <TextBlock Text="Card Two" Foreground="White" FontSize="15" FontWeight="SemiBold" Margin="0,20,0,0"/>
                                        <Rectangle Height="7" RadiusX="4" RadiusY="4" Fill="#253149" Margin="0,12,42,0"/>
                                        <Rectangle Height="7" RadiusX="4" RadiusY="4" Fill="#1D273A" Margin="0,8,78,0"/>
                                    </StackPanel>
                                </Border>
                                <Border Grid.Column="2" Style="{StaticResource CardStyle}" Margin="0,0,0,14">
                                    <StackPanel>
                                        <Border Width="38" Height="38" CornerRadius="11" Background="#18312F" HorizontalAlignment="Left">
                                            <TextBlock Text="✓" Foreground="#72F2C5" FontSize="17" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <TextBlock Text="Card Three" Foreground="White" FontSize="15" FontWeight="SemiBold" Margin="0,20,0,0"/>
                                        <Rectangle Height="7" RadiusX="4" RadiusY="4" Fill="#253149" Margin="0,12,42,0"/>
                                        <Rectangle Height="7" RadiusX="4" RadiusY="4" Fill="#1D273A" Margin="0,8,78,0"/>
                                    </StackPanel>
                                </Border>
                            </Grid>

                            <Border Grid.Row="4" Style="{StaticResource CardStyle}" Margin="0">
                                <Grid>
                                    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="18"/><RowDefinition/></Grid.RowDefinitions>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Components" Foreground="White" FontSize="15" FontWeight="SemiBold"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Style="{StaticResource PillButton}" Content="Filter"/>
                                            <Button Style="{StaticResource PillButton}" Content="Sort"/>
                                        </StackPanel>
                                    </Grid>
                                    <UniformGrid Grid.Row="2" Columns="2" Rows="2">
                                        <Border Background="#0C121E" BorderBrush="#202B40" BorderThickness="1" CornerRadius="12" Margin="0,0,10,10" Padding="14">
                                            <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="Example row" Foreground="#DDE5F4" VerticalAlignment="Center"/><Button Grid.Column="1" Style="{StaticResource GhostButton}" Height="34" Content="Open"/></Grid>
                                        </Border>
                                        <Border Background="#0C121E" BorderBrush="#202B40" BorderThickness="1" CornerRadius="12" Margin="0,0,0,10" Padding="14">
                                            <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="Example row" Foreground="#DDE5F4" VerticalAlignment="Center"/><Button Grid.Column="1" Style="{StaticResource GhostButton}" Height="34" Content="Open"/></Grid>
                                        </Border>
                                        <Border Background="#0C121E" BorderBrush="#202B40" BorderThickness="1" CornerRadius="12" Margin="0,0,10,0" Padding="14">
                                            <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="Example row" Foreground="#DDE5F4" VerticalAlignment="Center"/><Button Grid.Column="1" Style="{StaticResource GhostButton}" Height="34" Content="Open"/></Grid>
                                        </Border>
                                        <Border Background="#0C121E" BorderBrush="#202B40" BorderThickness="1" CornerRadius="12" Padding="14">
                                            <Grid><Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="Example row" Foreground="#DDE5F4" VerticalAlignment="Center"/><Button Grid.Column="1" Style="{StaticResource GhostButton}" Height="34" Content="Open"/></Grid>
                                        </Border>
                                    </UniformGrid>
                                </Grid>
                            </Border>
                        </Grid>

                        <Grid x:Name="PageLibrary" Visibility="Collapsed" Opacity="0">
                            <StackPanel>
                                <TextBlock Text="Library" Foreground="White" FontSize="29" FontWeight="SemiBold"/>
                                <WrapPanel Margin="0,22,0,0">
                                    <Button Style="{StaticResource PrimaryButton}" Content="Primary"/>
                                    <Button Style="{StaticResource SecondaryButton}" Content="Secondary"/>
                                    <Button Style="{StaticResource GhostButton}" Content="Ghost"/>
                                    <Button Style="{StaticResource PillButton}" Content="Pill"/>
                                </WrapPanel>
                            </StackPanel>
                        </Grid>

                        <Grid x:Name="PageActivity" Visibility="Collapsed" Opacity="0">
                            <StackPanel>
                                <TextBlock Text="Activity" Foreground="White" FontSize="29" FontWeight="SemiBold"/>
                                <Border Style="{StaticResource CardStyle}" Margin="0,22,0,0" Height="180"/>
                            </StackPanel>
                        </Grid>

                        <Grid x:Name="PageSettings" Visibility="Collapsed" Opacity="0">
                            <StackPanel>
                                <TextBlock Text="Settings" Foreground="White" FontSize="29" FontWeight="SemiBold"/>
                                <WrapPanel Margin="0,22,0,0">
                                    <Button Tag="Active" Style="{StaticResource PillButton}" Content="Dark"/>
                                    <Button Style="{StaticResource PillButton}" Content="Cyan"/>
                                    <Button Style="{StaticResource PillButton}" Content="Violet"/>
                                </WrapPanel>
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

# VERANDERING: Namespace-vrije verwerking om de SelectNodes crash te omzeilen
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

    $NavigationButton.Tag = 'Active'
    $Page.Visibility = 'Visible'

    $fade = New-Object Windows.Media.Animation.DoubleAnimation
    $fade.From = 0
    $fade.To = 1
    $fade.Duration = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(220))
    $fade.EasingFunction = New-Object Windows.Media.Animation.CubicEase -Property @{ EasingMode = 'EaseOut' }
    $Page.BeginAnimation([Windows.UIElement]::OpacityProperty, $fade)

    $slide = New-Object Windows.Media.Animation.ThicknessAnimation
    $slide.From = [Windows.Thickness]::new(14,0,0,0)
    $slide.To = [Windows.Thickness]::new(0)
    $slide.Duration = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(250))
    $slide.EasingFunction = New-Object Windows.Media.Animation.CubicEase -Property @{ EasingMode = 'EaseOut' }
    $Page.BeginAnimation([Windows.FrameworkElement]::MarginProperty, $slide)
}

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
    $fadeWindow.Duration = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(360))
    $fadeWindow.EasingFunction = New-Object Windows.Media.Animation.CubicEase -Property @{ EasingMode = 'EaseOut' }
    $window.BeginAnimation([Windows.Window]::OpacityProperty, $fadeWindow)

    $moveOne = New-Object Windows.Media.Animation.DoubleAnimation
    $moveOne.From = -240
    $moveOne.To = -160
    $moveOne.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(7))
    $moveOne.AutoReverse = $true
    $moveOne.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $moveOne.EasingFunction = New-Object Windows.Media.Animation.SineEase -Property @{ EasingMode = 'EaseInOut' }
    $GlowOne.BeginAnimation([System.Windows.Controls.Canvas]::TopProperty, $moveOne)

    $moveTwo = New-Object Windows.Media.Animation.DoubleAnimation
    $moveTwo.From = 470
    $moveTwo.To = 400
    $moveTwo.Duration = [Windows.Duration]::new([TimeSpan]::FromSeconds(8))
    $moveTwo.AutoReverse = $true
    $moveTwo.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $moveTwo.EasingFunction = New-Object Windows.Media.Animation.SineEase -Property @{ EasingMode = 'EaseInOut' }
    $GlowTwo.BeginAnimation([System.Windows.Controls.Canvas]::TopProperty, $moveTwo)
})

$window.ShowDialog() | Out-Null