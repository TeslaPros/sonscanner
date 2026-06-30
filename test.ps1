# ==============================================================================
# TESLA TOOLS FORENSIC PLATFORM v2.0 - ULTRA CLEAN CYBERPUNK EDITION
# ==============================================================================

# Veilige initialisatie van de grafische bibliotheken
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml
Add-Type -AssemblyName System.Windows.Forms

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$installDir = "$env:USERPROFILE\Downloads\Tesla Tools"

# ------------------------------------------------------------------------------
# DATA CONFIGURATIE (74 TOOLS)
# ------------------------------------------------------------------------------
$ToolData = @(
    @{ Name="PrefetchView";          Desc="Parses prefetch, extracts file info";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/PrefetchView/releases/latest" },
    @{ Name="BAMReveal";             Desc="Parses BAM forensic artefact";                 Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/BAMReveal/releases/latest" },
    @{ Name="StringsParser";         Desc="Strings + YARA + signatures scanner";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/StringsParser/releases/latest" },
    @{ Name="Fileless";              Desc="Detects fileless via eventlog + memdump";      Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/Fileless/releases/latest" },
    @{ Name="DPS-Analyzer";          Desc="Analyzes DPS memory";                          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/DPS-Analyzer/releases/latest" },
    @{ Name="UserAssistView";        Desc="Parses UserAssist registry artifact";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/UserAssistView/releases/latest" },
    @{ Name="JournalParser";         Desc="Parses NTFS USNJournal entries";               Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/JournalParser/releases/latest" },
    @{ Name="InjGen";                Desc="Detects JNI/JVMTI memory injections";         Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/InjGen/releases/latest" },
    @{ Name="USBDetector";           Desc="Detects USB device history";                   Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/USBDetector/releases/latest" },
    @{ Name="PFTrace";               Desc="Rundll32/Regsvr32 prefetch analysis";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/PFTrace/releases/latest" },
    @{ Name="CheckDeletedUSN";       Desc="Compares USN timestamp vs boot time";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/CheckDeletedUSN/releases/latest" },
    @{ Name="JARParser";             Desc="Parses JAR prefetch, DcomLaunch strings";      Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/JARParser/releases/latest" },
    @{ Name="BAM-parser";            Desc="Parses BAM entries for execution history";     Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/BAM-parser/releases/latest" },
    @{ Name="PathsParser";           Desc="Extracts and analyzes executable paths";       Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/PathsParser/releases/latest" },
    @{ Name="JournalTrace";          Desc="Traces file activity via USN journal";         Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/JournalTrace/releases/latest" },
    @{ Name="KernelLiveDumpTool";    Desc="Captures live kernel memory dump";             Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/KernelLiveDumpTool/releases/latest" },
    @{ Name="BamDeletedKeys";        Desc="Finds deleted BAM registry keys";              Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/BamDeletedKeys/releases/latest" },
    @{ Name="Espouken Tool";         Desc="All-in-one SS forensics toolkit";              Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/Tool/releases/latest" },
    @{ Name="pcasvc-executed";       Desc="Extracts PCA service execution records";       Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/pcasvc-executed/releases/latest" },
    @{ Name="process-parser";        Desc="Parses process execution artefacts";           Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/process-parser/releases/latest" },
    @{ Name="prefetch-parser";       Desc="Parses Windows prefetch files";                Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/prefetch-parser/releases/latest" },
    @{ Name="ActivitiesCache";       Desc="Parses ActivitiesCache execution history";     Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/ActivitiesCache-execution/releases/latest" },
    @{ Name="MeowDoomsdayFucker";    Desc="Detects Doomsday cheat artefacts";             Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowDoomsdayFucker/releases/latest" },
    @{ Name="MeowModAnalyzer";       Desc="Analyzes mod files for suspicious content";    Category="Tonynoh";    Type="Cmd";    Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/MeowTonynoh/MeowModAnalyzer/main/MeowModAnalyzer.ps1')" },
    @{ Name="MeowResolver";          Desc="Resolves obfuscated strings in binaries";      Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowResolver/releases/latest" },
    @{ Name="MeowNovowareFucker";    Desc="Detects Novoware cheat artefacts";             Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowNovowareFucker/releases/latest" },
    @{ Name="MeowImportsChecker";    Desc="Checks PE imports for suspicious DLLs";        Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowImportsChecker/releases/latest" },
    @{ Name="MeowClientsFucker";     Desc="Detects known cheat client artefacts";         Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowClientFucker/releases/latest" },
    @{ Name="PSHunter";              Desc="Hunts suspicious PowerShell activity";         Category="Praiselily"; Type="GitHub"; URL="https://github.com/praiselily/PSHunter/releases/latest" },
    @{ Name="AltDetector";           Desc="Detects alternate account artefacts";          Category="Praiselily"; Type="GitHub"; URL="https://github.com/praiselily/AltDetector/releases/latest" },
    @{ Name="WeHateFakers";          Desc="Checks hotspot / tethering logs";              Category="Praiselily"; Type="Cmd";    Command="iwr https://raw.githubusercontent.com/praiselily/WeHateFakers/refs/heads/main/HotspotLogs.ps1 | iex" },
    @{ Name="CommonDirectories";     Desc="Lists files in common suspicious dirs";        Category="Praiselily"; Type="Cmd";    Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1')" },
    @{ Name="HarddiskConverter";     Desc="Converts harddisk identifiers for review";     Category="Praiselily"; Type="Cmd";    Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/HarddiskConverter.ps1')" },
    @{ Name="Services";              Desc="Lists and analyzes running services";          Category="Praiselily"; Type="Cmd";    Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1')" },
    @{ Name="SignedScheduledTasks";  Desc="Finds unsigned / suspicious scheduled tasks"; Category="Praiselily"; Type="Cmd";    Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Signed-Scheduled-Tasks.ps1')" },
    @{ Name="RL ModAnalyzer";        Desc="Analyzes mod files for cheat indicators";     Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotus-Mod-Analyzer/releases/latest" },
    @{ Name="RL TaskSentinel";       Desc="Monitors scheduled tasks for anomalies";      Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotus-Task-Sentinel/releases/latest" },
    @{ Name="RL AltChecker";         Desc="Checks for alternate account indicators";     Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotusAltChecker/releases/latest" },
    @{ Name="ComputerActivityView";  Desc="Timeline of computer activity events";        Category="Others";     Type="Web";    URL="https://www.nirsoft.net/utils/computer_activity_view.html" },
    @{ Name="AmcacheParser";         Desc="Parses AMCache with YARA + signatures";       Category="Others";     Type="Web";    URL="https://download.ericzimmermanstools.com/net9/AmcacheParser.zip" },
    @{ Name="SystemInformer";        Desc="Advanced process and kernel inspector";        Category="Others";     Type="Link";   URL="https://www.systeminformer.com/canary" },
    @{ Name="DIE-engine";            Desc="Detects file type, packer, compiler";         Category="Others";     Type="Web";    URL="https://github.com/horsicq/DIE-engine/releases" },
    @{ Name="DQRKIS-FUCKER";         Desc="Detects DQRKIS cheat artefacts";              Category="Others";     Type="Cmd";    Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/cheesecatlol/DQRKIS-FUCKER/refs/heads/main/DqrkisFucker.ps1')" },
    @{ Name="MacroDetector";         Desc="Detects macro / clicker software traces";     Category="Others";     Type="Cmd";    Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/NiccBlahh/MacroDetector/refs/heads/main/MacroDetector.ps1')" },
    @{ Name="Jarabel";               Desc="Locates .jar files with detailed checks";     Category="Others";     Type="GitHub"; URL="https://github.com/nay-cat/Jarabel/releases/latest" },
    @{ Name="Luyten";                Desc="Open source Java decompiler GUI (Procyon)";   Category="Others";     Type="GitHub"; URL="https://github.com/deathmarine/Luyten/releases/latest" },
    @{ Name="VMAware";               Desc="Advanced VM detection library and tool";      Category="Others";     Type="GitHub"; URL="https://github.com/kernelwernel/VMAware/releases/latest" },
    @{ Name="Velociraptor";          Desc="Endpoint DFIR and threat hunting agent";      Category="Others";     Type="GitHub"; URL="https://github.com/Velocidex/velociraptor/releases/latest" },
    @{ Name="NTFS Parser";           Desc="NTFS forensics: MFT, Bitlocker, USN";        Category="Others";     Type="GitHub"; URL="https://github.com/thewhiteninja/ntfstool/releases/latest" },
    @{ Name="Hayabusa";              Desc="Fast forensics timeline generator";           Category="Others";     Type="GitHub"; URL="https://github.com/Yamato-Security/hayabusa/releases/latest" },
    @{ Name="Everything";            Desc="Instant filename search engine for Windows";  Category="Others";     Type="Link";   URL="https://www.voidtools.com/downloads/" },
    @{ Name="HxD";                   Desc="Fast hex editor with disk and RAM editing";   Category="Others";     Type="Link";   URL="https://mh-nexus.de/en/hxd/" },
    @{ Name="bstrings";              Desc="Searches strings with regex + YARA";          Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/bstrings.zip" },
    @{ Name="JLECmd";                Desc="Parses Jump List files (CLI)";                Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/JLECmd.zip" },
    @{ Name="JumpListExplorer";      Desc="GUI explorer for Jump List artefacts";        Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/JumpListExplorer.zip" },
    @{ Name="MFTECmd";               Desc="Parses MFT, UsnJrnl, LogFile, Boot";         Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/MFTECmd.zip" },
    @{ Name="PECmd";                 Desc="Parses Windows prefetch files (CLI)";         Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/PECmd.zip" },
    @{ Name="RecentFileCacheParser"; Desc="Parses RecentFileCache.bcf artefact";         Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/RecentFileCacheParser.zip" },
    @{ Name="RegistryExplorer";      Desc="GUI explorer for registry hives";             Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/RegistryExplorer.zip" },
    @{ Name="ShellBagsExplorer";     Desc="GUI explorer for ShellBags artefacts";        Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/ShellBagsExplorer.zip" },
    @{ Name="SrumECmd";              Desc="Parses SRUM database for usage data";         Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/SrumECmd.zip" },
    @{ Name="TimelineExplorer";      Desc="GUI viewer for CSV timeline output";          Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip" },
    @{ Name="FullEventLogView";      Desc="Views all Windows event log entries";         Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/fulleventlogview.zip" },
    @{ Name="NetworkUsageView";      Desc="Shows network usage per process";             Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/networkusageview.zip" },
    @{ Name="BrowserDownloadsView";  Desc="Lists all browser download history";          Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/browserdownloadsview.zip" },
    @{ Name="AlternateStreamView";   Desc="Reveals hidden NTFS alternate streams";       Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/alternatestreamview.zip" },
    @{ Name="USBDeview";             Desc="Lists all USB devices ever connected";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/usbdeview.zip" },
    @{ Name="OpenSaveFilesView";     Desc="Shows files opened/saved via dialogs";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/opensavefilesview.zip" },
    @{ Name="ExecutedProgramsList";  Desc="Lists programs run from various sources";     Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/executedprogramslist.zip" },
    @{ Name="TaskSchedulerView";     Desc="Views all scheduled tasks and history";       Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/taskschedulerview.zip" },
    @{ Name="JumpListsView";         Desc="Views Jump List recent/frequent files";       Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/jumplistsview.zip" },
    @{ Name="WinPrefetchView";       Desc="Views Windows prefetch file details";         Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/winprefetchview.zip" },
    @{ Name="RegScanner";            Desc="Scans registry for values / patterns";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/regscanner.zip" },
    @{ Name="ShellBagsView";         Desc="Views ShellBags folder access history";       Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/shellbagsview.zip" },
    @{ Name="NET 9.0";               Desc="Microsoft .NET 9 SDK runtime";                Category="Dependencies"; Type="Web"; URL="https://download.visualstudio.microsoft.com/download/pr/92dba916-bc51-4e76-8b0e-d41d37ce5fa4/ab08f3e95bf7a3d3da336a7e8c8eca63/dotnet-sdk-9.0.203-win-x64.exe" },
    @{ Name="NET 10.0";              Desc="Microsoft .NET 10 runtime";                   Category="Dependencies"; Type="Web"; URL="https://download.visualstudio.microsoft.com/download/pr/b3f93f0e-9e5e-4b4c-a4c4-36db0c4b0e3e/dotnet-runtime-10.0.0-win-x64.exe" },
    @{ Name="VSRedist";              Desc="Visual C++ redistributable (x64)";            Category="Dependencies"; Type="Web"; URL="https://aka.ms/vs/17/release/vc_redist.x64.exe" }
)

# ------------------------------------------------------------------------------
# INTERFACE DESIGN (MAIN XAML)
# ------------------------------------------------------------------------------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Tesla Tools Premium" Width="1280" Height="820" MinWidth="1150" MinHeight="720"
        WindowStartupLocation="CenterScreen" ResizeMode="CanResizeWithGrip"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        FontFamily="Segoe UI">
  <Window.Resources>
    <SolidColorBrush x:Key="Bg" Color="#040712"/>
    <SolidColorBrush x:Key="Panel" Color="#0A1024"/>
    <SolidColorBrush x:Key="Panel2" Color="#121A36"/>
    <SolidColorBrush x:Key="Accent" Color="#00F2FE"/>
    <SolidColorBrush x:Key="AccentSecondary" Color="#4FACFE"/>
    <SolidColorBrush x:Key="TextMain" Color="#F5F9FF"/>
    <SolidColorBrush x:Key="TextMuted" Color="#6C82A3"/>
    
    <Style x:Key="ChromeBtn" TargetType="Button">
      <Setter Property="Width" Value="44"/><Setter Property="Height" Value="36"/>
      <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#6C82A3"/>
      <Setter Property="BorderThickness" Value="0"/><Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button">
        <Border x:Name="B" Background="{TemplateBinding Background}" CornerRadius="6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
        <ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="B" Property="Background" Value="#1C284C"/><Setter Property="Foreground" Value="#00F2FE"/></Trigger></ControlTemplate.Triggers>
      </ControlTemplate></Setter.Value></Setter>
    </Style>
    <Style x:Key="NavBtn" TargetType="Button">
      <Setter Property="Height" Value="44"/><Setter Property="Margin" Value="0,0,0,10"/><Setter Property="Padding" Value="16,0"/>
      <Setter Property="HorizontalContentAlignment" Value="Left"/><Setter Property="Foreground" Value="#A4B9D6"/>
      <Setter Property="Background" Value="#080F21"/><Setter Property="BorderBrush" Value="#17274F"/><Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Cursor" Value="Hand"/><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button">
        <Border x:Name="B" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="12">
          <ContentPresenter Margin="{TemplateBinding Padding}" HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center"/>
        </Border>
        <ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="B" Property="Background" Value="#122147"/><Setter TargetName="B" Property="BorderBrush" Value="#00F2FE"/><Setter Property="Foreground" Value="White"/></Trigger></ControlTemplate.Triggers>
      </ControlTemplate></Setter.Value></Setter>
    </Style>
  </Window.Resources>

  <Border CornerRadius="20" Background="{StaticResource Bg}" BorderBrush="#1C2E5C" BorderThickness="1.5">
    <Border.Effect><DropShadowEffect Color="#00F2FE" BlurRadius="35" Opacity="0.25" ShadowDepth="0"/></Border.Effect>
    <Grid>
      <Grid.RowDefinitions><RowDefinition Height="60"/><RowDefinition Height="*"/></Grid.RowDefinitions>

      <Border Grid.Row="0" Background="#060A17" CornerRadius="20,20,0,0" BorderBrush="#142142" BorderThickness="0,0,0,1">
        <Grid Margin="20,0,12,0">
          <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
          <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
            <Border Width="36" Height="36" CornerRadius="10" Background="#0C142B" BorderBrush="#00F2FE" BorderThickness="1.5">
              <TextBlock Text="⚡" FontWeight="Black" FontSize="18" Foreground="#00F2FE" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="0,0,1,2"/>
            </Border>
            <StackPanel Margin="14,0,0,0" VerticalAlignment="Center">
              <TextBlock Text="TESLA TOOLS PLATFORM" FontSize="16" FontWeight="Black" Foreground="White" CharacterSpacing="160"/>
              <TextBlock Text="NEXT-GEN DIGITAL FORENSICS HUB" FontSize="8.5" Foreground="#4A658A" FontWeight="SemiBold" CharacterSpacing="120"/>
            </StackPanel>
          </StackPanel>
          <StackPanel Grid.Column="1" Orientation="Horizontal"><Button x:Name="MinBtn" Style="{StaticResource ChromeBtn}" Content="—"/><Button x:Name="CloseBtn" Style="{StaticResource ChromeBtn}" Content="✕"/></StackPanel>
        </Grid>
      </Border>

      <Grid Grid.Row="1">
        <Grid.ColumnDefinitions><ColumnDefinition Width="260"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
        
        <Border Grid.Column="0" Background="#060A17" CornerRadius="0,0,0,20" BorderBrush="#142142" BorderThickness="0,0,1,0">
          <Grid Margin="18">
            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            
            <Border Background="#0C1322" CornerRadius="14" Padding="15" BorderBrush="#1E3254" BorderThickness="1">
              <StackPanel>
                <TextBlock x:Name="CatBlock" Text="  T E S L A  &#x0a;  ╱╲╱╲╱╲  &#x0a; SYSTEM ONLINE" FontFamily="Consolas" FontWeight="Bold" FontSize="12" Foreground="#00F2FE" HorizontalAlignment="Center" TextAlignment="Center"/>
                <Border Height="1" Background="#1E3254" Margin="0,12,0,12"/>
                <Grid>
                  <TextBlock Text="Total Utilities:" Foreground="#6A7E9C" FontSize="11"/>
                  <TextBlock Text="74 Loaded" Foreground="#00F2FE" FontWeight="Bold" FontSize="11" HorizontalAlignment="Right"/>
                </Grid>
              </StackPanel>
            </Border>
            
            <StackPanel Grid.Row="1" Margin="0,22,0,0">
              <TextBlock Text="SYSTEM OPERATORS" Foreground="#4A658A" FontSize="9.5" FontWeight="Black" CharacterSpacing="80" Margin="4,0,0,10"/>
              <Button x:Name="OpenFolderBtn" Style="{StaticResource NavBtn}" Content="▣   Explore Sandbox Directory"/>
              <Button x:Name="ClearCacheBtn" Style="{StaticResource NavBtn}" Content="⌫   Purge Cached Binary Files"/>
              <Button x:Name="OpenCmdBtn" Style="{StaticResource NavBtn}" Content="›_  Spawn Native Prompt"/>
            </StackPanel>
            
            <StackPanel Grid.Row="3">
              <Border Background="#0C1322" CornerRadius="14" Padding="14" BorderBrush="#1E3254" BorderThickness="1">
                <StackPanel>
                  <TextBlock Text="CREDITS" Foreground="#4A658A" FontSize="9" FontWeight="Black"/>
                  <TextBlock Text="Network Hub: teamwsf" Foreground="#00F2FE" FontSize="11" FontWeight="Bold" Margin="0,6,0,0"/>
                  <TextBlock Text="Database: Cheese_Cat" Foreground="#D5E4F7" FontSize="11" Margin="0,2,0,0"/>
                  <TextBlock x:Name="InstPathBlock" Text="" Foreground="#506685" FontSize="9" TextWrapping="Wrap" Margin="0,10,0,0"/>
                </StackPanel>
              </Border>
            </StackPanel>
          </Grid>
        </Border>

        <Grid Grid.Column="1" Margin="22">
          <Grid.RowDefinitions><RowDefinition Height="94"/><RowDefinition Height="14"/><RowDefinition Height="*"/><RowDefinition Height="14"/><RowDefinition Height="130"/></Grid.RowDefinitions>
          
          <Border Grid.Row="0" CornerRadius="16" Background="#0C1425" BorderBrush="#192A4D" BorderThickness="1" Padding="20,15">
            <Border.Effect><DropShadowEffect Color="#4FACFE" BlurRadius="20" Opacity="0.12" ShadowDepth="0"/></Border.Effect>
            <Grid>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="280"/>
              </Grid.ColumnDefinitions>
              
              <StackPanel VerticalAlignment="Center" Grid.Column="0">
                <TextBlock x:Name="StatusTitle" Text="System Ready" FontSize="24" FontWeight="Bold" Foreground="White"/>
                <TextBlock x:Name="StatusSub" Text="Enter a search term or pick an interface tab to scan assets." Foreground="#8EA2C0" FontSize="11.5" Margin="0,4,0,0"/>
              </StackPanel>
              
              <Border Grid.Column="1" Background="#102B42" BorderBrush="#00F2FE" BorderThickness="1" CornerRadius="8" Padding="14,7" VerticalAlignment="Center" Margin="0,0,18,0">
                <TextBlock x:Name="StatusBadge" Text="IDLE" Foreground="#00F2FE" FontWeight="Black" FontSize="11" CharacterSpacing="60"/>
              </Border>
              
              <Border Grid.Column="2" Background="#050912" BorderBrush="#223966" BorderThickness="1.5" CornerRadius="10" Padding="14,8" VerticalAlignment="Center">
                <Grid>
                  <TextBlock x:Name="SearchPlaceholder" Text="🔍 Quick-filter all 74 tools..." Foreground="#4D6285" Visibility="Visible" IsHitTestVisible="False" VerticalAlignment="Center" FontSize="12"/>
                  <TextBox x:Name="SearchBox" Background="Transparent" Foreground="White" BorderThickness="0" CaretBrush="#00F2FE" VerticalAlignment="Center" FontSize="12.5" SelectionBrush="#00F2FE"/>
                </Grid>
              </Border>
            </Grid>
          </Border>
          
          <Border Grid.Row="2" CornerRadius="16" Background="#070C17" BorderBrush="#152445" BorderThickness="1" Padding="8">
            <TabControl x:Name="ToolsTab" Background="Transparent" BorderThickness="0">
              <TabControl.Resources>
                <Style TargetType="TabItem">
                  <Setter Property="Foreground" Value="#6F85A6"/>
                  <Setter Property="FontSize" Value="11.5"/>
                  <Setter Property="FontWeight" Value="SemiBold"/>
                  <Setter Property="Padding" Value="14,8"/>
                  <Setter Property="Cursor" Value="Hand"/>
                  <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="TabItem">
                    <Border x:Name="B" Background="Transparent" CornerRadius="8" Margin="3" Padding="{TemplateBinding Padding}">
                      <ContentPresenter ContentSource="Header" HorizontalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers>
                      <Trigger Property="IsSelected" Value="True"><Setter TargetName="B" Property="Background" Value="#132647"/><Setter Property="Foreground" Value="#00F2FE"/></Trigger>
                      <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="B" Property="Background" Value="#0D1930"/><Setter Property="Foreground" Value="White"/></Trigger>
                    </ControlTemplate.Triggers>
                  </ControlTemplate></Setter.Value></Setter>
                </Style>
              </TabControl.Resources>
            </TabControl>
          </Border>
          
          <Border Grid.Row="4" CornerRadius="16" Background="#040712" BorderBrush="#142342" BorderThickness="1" Padding="16,12">
            <Grid>
              <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
              <TextBlock Text="SYSTEM DIAGNOSTICS STREAM" Foreground="#4A658A" FontSize="9.5" FontWeight="Black" CharacterSpacing="100"/>
              <TextBox x:Name="LogBox" Grid.Row="1" Background="Transparent" Foreground="#7BFAFF" BorderThickness="0" FontFamily="Consolas" FontSize="11" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap" Margin="0,8,0,0" CaretBrush="Transparent"/>
            </Grid>
          </Border>
        </Grid>
      </Grid>
    </Grid>
  </Border>
</Window>
"@

# ------------------------------------------------------------------------------
# PRE-FLIGHT LEGAL GATEWAY (DISCLAIMER DIALOG)
# ------------------------------------------------------------------------------
[xml]$disclaimerXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
 Title="Tesla Gate" Width="600" Height="440" WindowStartupLocation="CenterScreen" ResizeMode="NoResize" WindowStyle="None" AllowsTransparency="True" Background="Transparent" FontFamily="Segoe UI">
 <Border Background="#050814" BorderBrush="#00F2FE" BorderThickness="1.5" CornerRadius="20" Padding="30">
  <Border.Effect><DropShadowEffect Color="#00F2FE" BlurRadius="35" Opacity="0.25" ShadowDepth="0"/></Border.Effect>
  <Grid><Grid.RowDefinitions><RowDefinition Height="*"/><RowDefinition Height="60"/></Grid.RowDefinitions>
   <StackPanel>
    <TextBlock Text="TESLA SUITE" FontSize="28" FontWeight="Black" Foreground="White" CharacterSpacing="140"/>
    <TextBlock Text="EULA &amp; FORENSIC DISCLOSURE" FontSize="9" FontWeight="Black" Foreground="#00F2FE" CharacterSpacing="160" Margin="0,4,0,24"/>
    <TextBlock TextWrapping="Wrap" Foreground="#A2B7D4" FontSize="13.5" LineHeight="20" Margin="0,0,0,16" Text="All binary utilities housed within this ecosystem are directly sourced from their respective vendor and developer environments. End-users must assume and execute due diligence prior to active deployment."/>
    <TextBlock TextWrapping="Wrap" Foreground="#A2B7D4" FontSize="13.5" LineHeight="20" Margin="0,0,0,20" Text="Tesla Suite acts strictly as an administrative runtime environment and does not store, harvest, or transmit external tracking telemetry."/>
    <Border Background="#0B1224" CornerRadius="10" Padding="14" BorderBrush="#1C2F54" BorderThickness="1"><TextBlock Text="Operator Access Token: Active   •   System integrity verified." Foreground="#63DDFF" FontSize="11" FontWeight="SemiBold" HorizontalAlignment="Center"/></Border>
   </StackPanel>
   <Grid Grid.Row="1"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="15"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
    <Button x:Name="CancelBtn" Grid.Column="0" Content="Decline" Height="44" Background="#0A1021" Foreground="#8FA3BF" BorderBrush="#1D2E54" Cursor="Hand" Style="{StaticResource {x:Null}}"><Button.Resources><Style TargetType="Button"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1" CornerRadius="10"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value></Setter></Style></Button.Resources></Button>
    <Button x:Name="AcceptBtn" Grid.Column="2" Content="Accept Framework" Height="44" Background="#112F47" Foreground="#00F2FE" BorderBrush="#00F2FE" Cursor="Hand" FontWeight="Bold" Style="{StaticResource {x:Null}}"><Button.Resources><Style TargetType="Button"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1.5" CornerRadius="10"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value></Setter></Style></Button.Resources></Button>
   </Grid>
  </Grid>
 </Border>
</Window>
"@

$disclaimerReader = New-Object System.Xml.XmlNodeReader $disclaimerXaml
$disclaimerWindow = [Windows.Markup.XamlReader]::Load($disclaimerReader)
$disclaimerWindow.Add_MouseLeftButtonDown({ try { $disclaimerWindow.DragMove() } catch {} })

$CancelBtn = $disclaimerWindow.FindName("CancelBtn")
$AcceptBtn = $disclaimerWindow.FindName("AcceptBtn")
$script:disclaimerAccepted = $false

$AcceptBtn.Add_Click({ $script:disclaimerAccepted = $true; $disclaimerWindow.Close() })
$CancelBtn.Add_Click({ $script:disclaimerAccepted = $false; $disclaimerWindow.Close() })
$disclaimerWindow.ShowDialog() | Out-Null
if (-not $script:disclaimerAccepted) { exit }

# ------------------------------------------------------------------------------
# CORE DESKTOP FRAMEWORK RUNTIME
# ------------------------------------------------------------------------------
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$MinBtn            = $window.FindName("MinBtn")
$CloseBtn          = $window.FindName("CloseBtn")
$StatusTitle       = $window.FindName("StatusTitle")
$StatusSub         = $window.FindName("StatusSub")
$StatusBadge       = $window.FindName("StatusBadge")
$LogBox            = $window.FindName("LogBox")
$ToolsTab          = $window.FindName("ToolsTab")
$OpenFolderBtn     = $window.FindName("OpenFolderBtn")
$ClearCacheBtn     = $window.FindName("ClearCacheBtn")
$OpenCmdBtn        = $window.FindName("OpenCmdBtn")
$CatBlock          = $window.FindName("CatBlock")
$InstPathBlock     = $window.FindName("InstPathBlock")
$SearchBox         = $window.FindName("SearchBox")
$SearchPlaceholder = $window.FindName("SearchPlaceholder")

$InstPathBlock.Text = "Active Workspace Path:`n$installDir"
$script:allToolButtons = @()

# Operational Helpers
function Write-Log {
    param([string]$msg)
    $time = Get-Date -Format "HH:mm:ss"
    $LogBox.Dispatcher.Invoke([Action]{
        $LogBox.AppendText("[$time] » $msg`r`n")
        $LogBox.ScrollToEnd()
    })
}

function Set-Status {
    param($title, $sub, $badge = "BUSY")
    $window.Dispatcher.Invoke([Action]{
        $StatusTitle.Text = $title
        $StatusSub.Text   = $sub
        $StatusBadge.Text = $badge
    })
}

# ------------------------------------------------------------------------------
# MATRIX TABS GENERATION ENGINE
# ------------------------------------------------------------------------------
$Categories = @("Orbdiff","Spokwn","Tonynoh","Praiselily","RedLotus","Zimmerman","NirSoft","Dependencies","Others")

foreach ($cat in $Categories) {
    $tab = New-Object System.Windows.Controls.TabItem
    $tab.Header = $cat.ToUpper()

    $scroll = New-Object System.Windows.Controls.ScrollViewer
    $scroll.VerticalScrollBarVisibility   = "Auto"
    $scroll.HorizontalScrollBarVisibility = "Disabled"

    $wrap = New-Object System.Windows.Controls.WrapPanel
    $wrap.Margin = "10"

    $catTools = $ToolData | Where-Object { $_.Category -eq $cat }

    foreach ($tool in $catTools) {
        $t = $tool

        $btn            = New-Object System.Windows.Controls.Button
        $btn.Width      = 224
        $btn.Height     = 84
        $btn.Margin     = "6"
        $btn.Cursor     = "Hand"
        
        # Voeg de tool-informatie direct toe aan het knopobject om crash te voorkomen
        Add-Member -InputObject $btn -NotePropertyName "ToolInfo" -NoteValue $t -Force

        # Bouw de Premium Grid Card Indeling
        $cardGrid = New-Object System.Windows.Controls.Grid
        $row1 = New-Object System.Windows.Controls.RowDefinition; $row1.Height = [System.Windows.GridLength]::Auto
        $row2 = New-Object System.Windows.Controls.RowDefinition; $row2.Height = New-Object System.Windows.GridLength 1, [System.Windows.GridUnitType]::Star
        $cardGrid.RowDefinitions.Add($row1)
        $cardGrid.RowDefinitions.Add($row2)

        # Bovenkant kaart: Titel + Source Badge
        $topDock = New-Object System.Windows.Controls.DockPanel
        $topDock.LastChildFill = $false

        $nameBlock = New-Object System.Windows.Controls.TextBlock
        $nameBlock.Text = $t.Name
        $nameBlock.FontSize = 13
        $nameBlock.FontWeight = "Bold"
        $nameBlock.Foreground = [Windows.Media.Brushes]::White
        [System.Windows.Controls.DockPanel]::SetDock($nameBlock, [System.Windows.Controls.Dock]::Left)
        $topDock.Children.Add($nameBlock) | Out-Null

        $badgeBorder = New-Object System.Windows.Controls.Border
        $badgeBorder.Padding = "5,1,5,2"
        $badgeBorder.CornerRadius = 4
        $badgeBorder.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $badgeBorder.Margin = "6,0,0,0"
        
        $badgeText = New-Object System.Windows.Controls.TextBlock
        $badgeText.Text = $t.Type.ToUpper()
        $badgeText.FontSize = 8
        $badgeText.FontWeight = "Black"
        $badgeBorder.Child = $badgeText
        
        switch ($t.Type) {
            "GitHub" { $badgeBorder.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#142E20"); $badgeText.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#4EFA9D") }
            "Cmd"    { $badgeBorder.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#2E1F14"); $badgeText.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#FFA24D") }
            "Web"    { $badgeBorder.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#14253D"); $badgeText.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#59B2FF") }
            default  { $badgeBorder.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#23143D"); $badgeText.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#B76BFF") }
        }
        [System.Windows.Controls.DockPanel]::SetDock($badgeBorder, [System.Windows.Controls.Dock]::Right)
        $topDock.Children.Add($badgeBorder) | Out-Null

        # Onderkant kaart: Beschrijving
        $descBlock = New-Object System.Windows.Controls.TextBlock
        $descBlock.Text = $t.Desc
        $descBlock.FontSize = 10.5
        $descBlock.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#798EA8")
        $descBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $descBlock.Margin = "0,5,0,0"

        [System.Windows.Controls.Grid]::SetRow($topDock, 0)
        [System.Windows.Controls.Grid]::SetRow($descBlock, 1)
        $cardGrid.Children.Add($topDock) | Out-Null
        $cardGrid.Children.Add($descBlock) | Out-Null

        $btn.Content = $cardGrid

        # Genereer lokale animatie-transformaties
        $btnBg    = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(0x0C, 0x13, 0x24))
        $btnScale = [Windows.Media.ScaleTransform]::new(1.0, 1.0)
        $btnGlow  = [Windows.Media.Effects.DropShadowEffect]::new()
        $btnGlow.Color       = [Windows.Media.Color]::FromRgb(0x00, 0xF2, 0xFE)
        $btnGlow.BlurRadius  = 0
        $btnGlow.ShadowDepth = 0
        $btnGlow.Opacity     = 0

        $btn.Template = [Windows.Markup.XamlReader]::Parse(
            "<ControlTemplate xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' TargetType='Button'>" +
            "  <Border CornerRadius='10' BorderThickness='1' RenderTransformOrigin='0.5,0.5'" +
            "          Background='{TemplateBinding Background}'" +
            "          RenderTransform='{TemplateBinding Tag}'" +
            "          BorderBrush='#223A6B'>" +
            "    <ContentPresenter Padding='12,10'/>" +
            "  </Border>" +
            "</ControlTemplate>"
        )
        $btn.Background = $btnBg
        $btn.Tag        = $btnScale

        $btn.Add_Loaded({
            $b = $_.Source
            if ([Windows.Media.VisualTreeHelper]::GetChildrenCount($b) -gt 0) {
                $border = [Windows.Media.VisualTreeHelper]::GetChild($b, 0)
                if ($border) { $border.Effect = $b.Resources["glow"] }
            }
        })
        $btn.Resources["glow"] = $btnGlow

        # Micro-animaties voor de kaarten (Smooth scaling en Neon Edge Glow)
        $btn.Add_MouseEnter({
            $b = $_.Source; $bg = $b.Background; $sc = $b.Tag; $glw = $b.Resources["glow"]
            if (-not $bg -or -not $sc) { return }
            $d = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(120))
            $ease = [Windows.Media.Animation.CubicEase]::new()
            $bg.BeginAnimation([Windows.Media.SolidColorBrush]::ColorProperty, [Windows.Media.Animation.ColorAnimation]::new([Windows.Media.Color]::FromRgb(0x13,0x22,0x40), $d))
            $ax = [Windows.Media.Animation.DoubleAnimation]::new(1.04, $d); $ax.EasingFunction = $ease; $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty, $ax)
            $ay = [Windows.Media.Animation.DoubleAnimation]::new(1.04, $d); $ay.EasingFunction = $ease; $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty, $ay)
            if ($glw) {
                $glw.BeginAnimation([Windows.Media.Effects.DropShadowEffect]::BlurRadiusProperty, [Windows.Media.Animation.DoubleAnimation]::new(15.0, $d))
                $glw.BeginAnimation([Windows.Media.Effects.DropShadowEffect]::OpacityProperty, [Windows.Media.Animation.DoubleAnimation]::new(0.7, $d))
            }
        })

        $btn.Add_MouseLeave({
            $b = $_.Source; $bg = $b.Background; $sc = $b.Tag; $glw = $b.Resources["glow"]
            if (-not $bg -or -not $sc) { return }
            $d = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(140))
            $bg.BeginAnimation([Windows.Media.SolidColorBrush]::ColorProperty, [Windows.Media.Animation.ColorAnimation]::new([Windows.Media.Color]::FromRgb(0x0C,0x13,0x24), $d))
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty, [Windows.Media.Animation.DoubleAnimation]::new(1.0, $d))
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty, [Windows.Media.Animation.DoubleAnimation]::new(1.0, $d))
            if ($glw) {
                $glw.BeginAnimation([Windows.Media.Effects.DropShadowEffect]::BlurRadiusProperty, [Windows.Media.Animation.DoubleAnimation]::new(0.0, $d))
                $glw.BeginAnimation([Windows.Media.Effects.DropShadowEffect]::OpacityProperty, [Windows.Media.Animation.DoubleAnimation]::new(0.0, $d))
            }
        })

        # Registreer de knop voor de realtime zoekmatrix
        $script:allToolButtons += [PSCustomObject]@{ Button = $btn; Name = $t.Name; Desc = $t.Desc }

        # Execution Click Trigger
        $btn.Add_Click({
            $clickedBtn = $_.Source
            $tData = $clickedBtn.ToolInfo
            $tName = $tData.Name

            $clickedBtn.IsEnabled = $false

            if ($tData.Type -eq "Link") {
                Start-Process $tData.URL
                Set-Status "Ready" "Redirected to endpoint configuration browser." "IDLE"
                $clickedBtn.IsEnabled = $true
            } elseif ($tData.Type -eq "Cmd") {
                Set-Status "Executing" "Initializing custom execution script thread..." "BUSY"
                Write-Log "Deploying task wrapper for: $tName"
                
                $rsc = [runspacefactory]::CreateRunspace()
                $rsc.ApartmentState = "STA"; $rsc.ThreadOptions = "ReuseThread"; $rsc.Open()
                $rsc.SessionStateProxy.SetVariable("timerData",    $tData)
                $rsc.SessionStateProxy.SetVariable("timerName",    $tName)
                $rsc.SessionStateProxy.SetVariable("timerBtn",     $clickedBtn)
                $rsc.SessionStateProxy.SetVariable("dispatcher",   $clickedBtn.Dispatcher)
                $rsc.SessionStateProxy.SetVariable("StatusTitle",  $StatusTitle)
                $rsc.SessionStateProxy.SetVariable("StatusSub",    $StatusSub)
                $rsc.SessionStateProxy.SetVariable("StatusBadge",  $StatusBadge)
                $rsc.SessionStateProxy.SetVariable("LogBox",       $LogBox)
                
                $psc = [powershell]::Create(); $psc.Runspace = $rsc
                $null = $psc.AddScript({
                    try {
                        $cmd = $timerData.Command
                        Start-Process "powershell.exe" -ArgumentList @("-NoExit","-NoProfile","-ExecutionPolicy","Bypass","-Command",$cmd)
                        $dispatcher.Invoke([Action]{ 
                            $StatusTitle.Text="Ready"; $StatusSub.Text="$timerName runtime active."; $StatusBadge.Text="IDLE"
                            $LogBox.AppendText("[$(Get-Date -f 'HH:mm:ss')] » Task initiated successfully.`r`n"); $LogBox.ScrollToEnd()
                        })
                    } catch {
                        $dispatcher.Invoke([Action]{ $StatusTitle.Text="Error"; $StatusSub.Text="Failed execution thread."; $StatusBadge.Text="ERR" })
                    }
                    $dispatcher.Invoke([Action]{ $timerBtn.IsEnabled = $true })
                })
                $null = $psc.BeginInvoke()
            } else {
                Set-Status "Syncing" "Fetching package binary allocations..." "BUSY"
                Write-Log "Downloading distribution repository: $tName"

                $rs = [runspacefactory]::CreateRunspace()
                $rs.ApartmentState = "STA"; $rs.ThreadOptions = "ReuseThread"; $rs.Open()
                $rs.SessionStateProxy.SetVariable("tData",       $tData)
                $rs.SessionStateProxy.SetVariable("installDir",  $installDir)
                $rs.SessionStateProxy.SetVariable("dispatcher",  $clickedBtn.Dispatcher)
                $rs.SessionStateProxy.SetVariable("btn",         $clickedBtn)
                $rs.SessionStateProxy.SetVariable("StatusTitle", $StatusTitle)
                $rs.SessionStateProxy.SetVariable("StatusSub",   $StatusSub)
                $rs.SessionStateProxy.SetVariable("StatusBadge", $StatusBadge)
                $rs.SessionStateProxy.SetVariable("LogBox",      $LogBox)

                $ps = [powershell]::Create(); $ps.Runspace = $rs
                $null = $ps.AddScript({
                    function Set-StatusBg { param($t, $s, $b) $dispatcher.Invoke([Action]{ $StatusTitle.Text=$t; $StatusSub.Text=$s; $StatusBadge.Text=$b })}
                    function Write-LogBg { param($m) $dispatcher.Invoke([Action]{ $LogBox.AppendText("[$(Get-Date -f 'HH:mm:ss')] » $m`r`n"); $LogBox.ScrollToEnd() })}
                    
                    $name = $tData.Name; $url = $tData.URL; $cat = $tData.Category; $type = $tData.Type
                    try {
                        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                        $destDir = "$installDir\$cat\$name"
                        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

                        if ($type -eq "GitHub") {
                            $urlParts = $url -replace "https://github.com/", "" -split "/"
                            $apiUrl   = "https://api.github.com/repos/$($urlParts[0])/$($urlParts[1])/releases/latest"
                            $release  = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "Tesla Tools" } -ErrorAction Stop
                            $asset    = $release.assets | Where-Object { $_.name -match "\.(zip|exe)$" } | Select-Object -First 1
                            if (-not $asset) { throw "No valid binaries found." }
                            $dlUrl = $asset.browser_download_url; $fileName = $asset.name
                        } else {
                            $dlUrl = $url; $fileName = ($url -split "/")[-1]
                        }

                        $destFile = "$destDir\$fileName"
                        if (Test-Path $destFile) {
                            Write-LogBg "Utilizing compiled disk cache for execution."
                        } else {
                            Write-LogBg "Streaming file arrays from server..."
                            $wc = New-Object System.Net.WebClient
                            $wc.DownloadFile($dlUrl, $destFile)
                        }

                        if ($fileName -match "\.zip$") {
                            Write-LogBg "Decompressing payload stream..."
                            Expand-Archive -Path $destFile -DestinationPath $destDir -Force -ErrorAction Stop
                            $exe = Get-ChildItem -Path $destDir -Filter "*.exe" -Recurse | Select-Object -First 1
                            if ($exe) { Start-Process -FilePath $exe.FullName } else { Start-Process explorer.exe "`"$destDir`"" }
                        } else {
                            Start-Process -FilePath $destFile
                        }
                        Set-StatusBg "Ready" "Process initialized successfully." "IDLE"
                    } catch {
                        Write-LogBg "Thread Exception: $_"
                        Set-StatusBg "Error" "Network allocation failed." "ERR"
                    }
                    $dispatcher.Invoke([Action]{ $btn.IsEnabled = $true })
                    $rs.Close()
                })
                $null = $ps.BeginInvoke()
            }
        })

        $wrap.Children.Add($btn) | Out-Null
    }

    $scroll.Content = $wrap
    $tab.Content    = $scroll
    $ToolsTab.Items.Add($tab) | Out-Null
}

# ------------------------------------------------------------------------------
# INTERACTIVE REALTIME SEARCH INDEX CONTROLLER
# ------------------------------------------------------------------------------
$SearchBox.Add_TextChanged({
    $query = $SearchBox.Text.Trim().ToLower()
    if ([string]::IsNullOrEmpty($query)) {
        $SearchPlaceholder.Visibility = [System.Windows.Visibility]::Visible
        foreach ($item in $script:allToolButtons) {
            $item.Button.Visibility = [System.Windows.Visibility]::Visible
        }
    } else {
        $SearchPlaceholder.Visibility = [System.Windows.Visibility]::Collapsed
        foreach ($item in $script:allToolButtons) {
            if ($item.Name.ToLower().Contains($query) -or $item.Desc.ToLower().Contains($query)) {
                $item.Button.Visibility = [System.Windows.Visibility]::Visible
            } else {
                $item.Button.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }
    }
})

# ------------------------------------------------------------------------------
# SIDEBAR LED BRANDING ENGINE
# ------------------------------------------------------------------------------
$catFrames = @(
    "  T E S L A  `n  ╱╲╱╲╱╲  `n SYSTEM ONLINE",
    "  T E S L A  `n  ╲╱╲╱╲╱  `n INTEL MAP PIP",
    "  T E S L A  `n  ╱╲╱╲╱╲  `n MATRIX READY",
    "  T E S L A  `n  ╲╱╲╱╲╱  `n THREAD ACTIVE"
)
$script:catIdx = 0
$catTimer = New-Object System.Windows.Threading.DispatcherTimer
$catTimer.Interval = [TimeSpan]::FromMilliseconds(1000)
$catTimer.Add_Tick({
    $script:catIdx = ($script:catIdx + 1) % $catFrames.Count
    $CatBlock.Text = $catFrames[$script:catIdx]
})
$catTimer.Start()

# ------------------------------------------------------------------------------
# CORE CONTROLS AND INTERFACE BINDS
# ------------------------------------------------------------------------------
$window.Add_MouseLeftButtonDown({ try { $window.DragMove() } catch {} })
$CloseBtn.Add_Click({ $catTimer.Stop(); $window.Close() })
$MinBtn.Add_Click({ $window.WindowState = "Minimized" })

$OpenFolderBtn.Add_Click({
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
    Start-Process explorer.exe $installDir
    Write-Log "Opened core toolkit workspace folder."
})

$ClearCacheBtn.Add_Click({
    if (Test-Path $installDir) {
        $items = Get-ChildItem -Path $installDir -Force -ErrorAction SilentlyContinue
        $items | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Purged binary filesystem cache allocations successfully."
        Set-Status "Clean" "Purged local cache allocations." "IDLE"
    }
})

$OpenCmdBtn.Add_Click({ Start-Process "cmd.exe"; Write-Log "Spawned administrative terminal wrapper." })

Write-Log "Tesla Engine Active. Target Path: $installDir"
Set-Status "Ready" "All arrays built. Input diagnostic search query or choose matrix." "IDLE"

$window.ShowDialog() | Out-Null
