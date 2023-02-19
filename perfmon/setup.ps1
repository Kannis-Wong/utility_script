<#
    Basic script to run the monitoring, which the duration will be following the user input or the default time settings. 
    The output format will be blg and txt file locating in the working path .\log folder, which blg file can be read from the Windows Performance Monitor
    Binary builder: Invoke-PS2EXE -inputFile .\setup.ps1 -outputFile .\setup.exe -x64 -title "Sys_Performance_Monitoring" -description "This is the application for logging time to time CPU and GPU usage" -version "1.0.0" -noConfigFile -requireAdmin
#>
param (
    [Parameter(Mandatory=$false)]
    [int]$time
)

function createLogFolder{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$cPath,
        [Parameter(Mandatory=$true)]
        [string]$date
    )
    if(!(Test-Path -Path "$cPath\log")){
        $mute = New-Item -Path "$cPath" -Name log -ItemType Directory -Force -ErrorAction SilentlyContinue
        Remove-Variable -Name mute -Force -ErrorAction SilentlyContinue
    }
    if(!(Test-Path -Path "$cPath\log\$date")){
        $mute = New-Item -Path "$cPath\log" -Name $date -ItemType Directory -Force -ErrorAction SilentlyContinue
        Remove-Variable -Name mute 
    }
    $Global:finalLogPath = "$cPath\log\$date"
    return "$cPath\log "+"| $cPath\log\$date"
}

function write-log{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$caller
    )
    return $caller
}

function startMonitoring{
    [CmdletBinding()]
    param (
        $time = 60
    )
    $cLogName = "Perfmon_$(Get-Date -Format "yyyyMMddHHmmss")"
    write-log -caller "Starting the system performance monitoring...| the time is set to $time"
    $scriptBlock = {
        param(
            $cPath,
            $name
        )
        $counterList = @(
            "\Processor Information(_total)\% Processor Time",
            "\GPU Engine(*)\Utilization Percentage"
        )
        Get-Counter -Counter $counterList -Continuous -ErrorAction SilentlyContinue | Export-Counter -Path "$cPath\$name.blg" -Force -ErrorAction SilentlyContinue
    }
    $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
    $stopWatch.Start()
    $quiet = Start-Job -Name $cLogName -ScriptBlock $scriptBlock -ArgumentList $finalLogPath,$cLogName
    while($stopWatch.Elapsed.TotalSeconds -le $time){
        write-log -caller "Running System Performance Monitoring...Please wait until after $time ..."
        Start-Sleep -Seconds $time
    }
    $quiet = Stop-Job -Name $cLogName; Receive-Job -Name $cLogName; Remove-Job -Name $cLogName -Force;
    write-log -caller "Finish."
}

function main{
    param(
        $time
    )
    $currentPath = $(Get-Location).Path
    $date = $(Get-Date -Format "yyyyMMdd")
    if($currentPath){
        createLogfolder -cPath $currentPath -date $date
    }
    else{
        return "Fatal error: cannot get current directory."
    }
    if($time){
        startMonitoring -time $time
    }
    else{
        startMonitoring
    }
    Pause
}

if($time){
    main -time $time
}
else{
    main
}
