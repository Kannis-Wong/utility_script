# Invoke-PS2EXE -inputFile .\mumbleControl.ps1 -outputFile .\SessionControl.exe -x64 -iconFile .\SBLOGO.ico -title SandboxVR_Mumble_Control_Panel -company SandboxVR -version 1.0.0 -requireAdmin -noConfigFile -noConsole

[xml]$Global:xmlWPF = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SandboxVR Mumble Control Panel - v1.0.0" Height="155" Width="990" ResizeMode="NoResize" >
    <Grid>
       <GroupBox HorizontalAlignment="Left" Height="103" Header="Room selection" Margin="10,10,0,0" VerticalAlignment="Top" Width="802"/>
        <Button Name="Mum1" Content="Room1" HorizontalAlignment="Left" Height="47" Margin="21,0,0,0" VerticalAlignment="Center" Width="120" FontSize="16"/>
        <Button Name="Mum2" Content="Room2" HorizontalAlignment="Left" Height="47" Margin="153,0,0,0" VerticalAlignment="Center" Width="120" FontSize="16"/>
        <Button Name="Mum3" Content="Room3" HorizontalAlignment="Left" Height="47" Margin="285,0,0,0" VerticalAlignment="Center" Width="120" FontSize="16"/>
        <Button Name="Mum4" Content="Room4" HorizontalAlignment="Left" Height="47" Margin="417,0,0,0" VerticalAlignment="Center" Width="120" FontSize="16"/>
        <Button Name="Mum5" Content="Room5" HorizontalAlignment="Left" Height="47" Margin="549,0,0,0" VerticalAlignment="Center" Width="120" FontSize="16"/>
        <Button Name="Mum6" Content="Room6" HorizontalAlignment="Left" Height="47" Margin="681,0,0,0" VerticalAlignment="Center" Width="120" FontSize="16"/>

        <GroupBox HorizontalAlignment="Left" Height="103" Header="Shutdown Mumble" Margin="826,10,0,0" VerticalAlignment="Top" Width="148"/>
        <Button Name="Shut" Content="Shutdown" HorizontalAlignment="Left" Height="47" Margin="840,0,0,0" VerticalAlignment="Center" Width="120" FontSize="16"/>
    </Grid>
</Window>
"@
Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
$Global:xamGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))
$xmlWPF.SelectNodes("//*[@Name]") | %{
Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global -Force
}

function cLog{
    if(!$(Test-Path -Path "C:\log")){
        $mute = New-Item -Path "C:\"  -Name log -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
    $Global:name = "Mumble_Control_Log_" + $(Get-Date -Format "yyyyMMdd_HHmmss")
    $mute = New-Item -Path "C:\log" -Name "$name.txt" -ItemType File -Force
}

function wLog{
    param(
        $str
    )
    $str | Out-File -FilePath "C:\log\$Global:name.txt" -Encoding utf8 -Append -Force
}

function keepUnmute{
    Start-Process -FilePath "$Global:mumblePath\mumble.exe" -ArgumentList "rpc unmute"
}

function init_{
    # suppose the path of 1.4.287 is below #
    if($(Test-Path "C:\Program Files\Mumble\client")){
        $Global:mumblePath = "C:\Program Files\Mumble\client"
    }
    else{
        $log = "Cannot find the mumble application in this computer. Exit"
        wLog -str $log
        exit
    }
    $Global:GUItimer = New-Object System.Windows.Forms.Timer
    $Global:GUItimer.Interval = 500
    $Global:GUItimer.add_tick({keepUnmute})
    #Invoke-WebRequest -Uri https://dl.mumble.info/latest/stable/client-windows-x64 -UseBasicParsing -Method Get -OutFile 
}

function startMumble{
    param(
        $roomNo
    )
    $str = Start-Process -FilePath "$Global:mumblePath\mumble.exe" -ArgumentList "-m mumble://10.$roomNo.1.1?version=1.3.0"
    wLog -str "Entered Room $roomNo Mumble | $(Get-Date -Format "yyyyMMdd_HHmmss")"
}

function killMumble{
    $process = Get-Process | where ProcessName -Match "mumble"
    $str = "Trying to kill Mumble..."
    wLog -str $str
    if($process){
        $mute = Stop-Process -InputObject $process -Force -ErrorAction SilentlyContinue
        $str = "Successfully killed mumble!"
        wLog -str $str
    }
    else{
        $str = "No mumble is required to be killed."
        wLog -str $str
    }
}

function main{
    cLog
    $logContent = "$($($host | select Name).Name) | Starting Mumble control panel..."
    wLog -str $logContent
    init_
    $Global:GUItimer.start()
    $Global:xamGUI.ShowDialog() | Out-Null
    pause
}

$Mum1.add_Click({
    killMumble
    startMumble -roomNo 1
})

$Mum2.add_Click({
    killMumble
    startMumble -roomNo 2
})

$Mum3.add_Click({
    killMumble
    startMumble -roomNo 3
})

$Mum4.add_Click({
    killMumble
    startMumble -roomNo 4
})

$Mum5.add_Click({
    killMumble
    startMumble -roomNo 5
})

$Mum6.add_Click({
    killMumble
    startMumble -roomNo 6
})

$Shut.add_Click({
    killMumble
})

main
