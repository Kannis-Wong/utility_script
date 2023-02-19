# Invoke-PS2EXE -inputFile .\guiSkeleton.ps1 -outputFile .\gui.exe -x64 -title GUI_Control_Panel -company Kannis_Wong -version 1.0.0 -requireAdmin -noConfigFile -noConsole

[xml]$Global:xmlWPF = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="GUI Sample Control Panel - v1.0.0" Height="720" Width="1280" ResizeMode="NoResize" >
    <Grid>
    <GroupBox HorizontalAlignment="Left" Height="103" Header="Selection Zone One" Margin="10,10,0,0" VerticalAlignment="Top" Width="700" />
    <Button Name="B1" Content="Testing" HorizontalAlignment="Left" Height="50" Margin="20,40,0,0" VerticalAlignment="Top" Width="100" Background="LightSkyBlue"/>
    <Button Name="B2" Content="Merging" HorizontalAlignment="Left" Height="50" Margin="125,40,0,0" VerticalAlignment="Top" Width="100" Background="LightBlue"/>
    <Button Name="B3" Content="Monitoring" HorizontalAlignment="Left" Height="50" Margin="230,40,0,0" VerticalAlignment="Top" Width="100" Background="Azure"/>
    <Button Name="B4" Content="Checking" HorizontalAlignment="Left" Height="50" Margin="335,40,0,0" VerticalAlignment="Top" Width="100" Background="FloralWhite"/>
    <Button Name="B5" Content="Programming" HorizontalAlignment="Left" Height="50" Margin="440,40,0,0" VerticalAlignment="Top" Width="100" Background="Bisque"/>
    <Button Name="B6" Content="Deploying" HorizontalAlignment="Left" Height="50" Margin="545,40,0,0" VerticalAlignment="Top" Width="100" Background="Wheat"/>

    <GroupBox HorizontalAlignment="Left" Height="104" Header="Selection Zone Two" Margin="10,118,0,0" VerticalAlignment="Top" Width="700"/>
    <CheckBox Name="C1" Content="CheckBox" HorizontalAlignment="Left" Height="16" Margin="28,141,0,0" VerticalAlignment="Top" Width="100"/>
    <CheckBox Name="C2" Content="CheckBox" HorizontalAlignment="Left" Height="16" Margin="28,162,0,0" VerticalAlignment="Top" Width="100"/>
    <CheckBox Name="C3" Content="CheckBox" HorizontalAlignment="Left" Height="16" Margin="28,183,0,0" VerticalAlignment="Top" Width="100"/>
    <CheckBox Name="C4" Content="CheckBox" HorizontalAlignment="Left" Height="16" Margin="150,141,0,0" VerticalAlignment="Top" Width="100"/>
    <CheckBox Name="C5" Content="CheckBox" HorizontalAlignment="Left" Height="16" Margin="150,162,0,0" VerticalAlignment="Top" Width="100"/>
    <CheckBox Name="C6" Content="CheckBox" HorizontalAlignment="Left" Height="16" Margin="150,183,0,0" VerticalAlignment="Top" Width="100"/>
    <Button Name="BLog" Content="Logging" HorizontalAlignment="Left" Height="50" Margin="255,145,0,0" VerticalAlignment="Top" Width="100" Background="LightGreen"/>
    <Label Name="Llog" Content="Logging" HorizontalAlignment="Left" Height="50" Margin="360,145,0,0" VerticalAlignment="Top" Width="285"/>

    <GroupBox HorizontalAlignment="Left" Height="103" Header="Selection Zone Three" Margin="10,227,0,0" VerticalAlignment="Top" Width="700"/>
    <ComboBox Name="ComList1" HorizontalAlignment="Left" Height="35" Margin="20,262,0,0" VerticalAlignment="Top" Width="150"/>
    <ComboBox Name="ComList2" HorizontalAlignment="Left" Height="35" Margin="180,262,0,0" VerticalAlignment="Top" Width="150"/>

    <GroupBox HorizontalAlignment="Left" Height="103" Header="Selection Zone Four" Margin="10,335,0,0" VerticalAlignment="Top" Width="700"/>
    <TextBox Name="TextLogBox" HorizontalAlignment="Left" Height="428" Margin="715,10,0,0" TextWrapping="Wrap" Text="Logging" VerticalAlignment="Top" Width="540" IsReadOnly="True" VerticalScrollBarVisibility="Visible" TextAlignment="Left"/>
    </Grid>
</Window>
"@
Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
$Global:xamGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))
$xmlWPF.SelectNodes("//*[@Name]") | %{
Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global -Force
}

function init_{
    
}

function main{
    $Global:xamGUI.ShowDialog() | Out-Null
}

main
