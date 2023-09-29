Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, WindowsFormsIntegration
$DebugPreference = "Continue"
$VerbosePreference = "Continue"
$element = @{} #init hashtable for our GUI elements.
$ErrFields = @{}
[xml]$xaml = @"
<Window x:Class="GUI_Sample_Progress_Bar.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:GUI_Sample_Progress_Bar"
        mc:Ignorable="d"
        Title="PC Config" Height="229.074" Width="356.338">
    <Grid>
        <CheckBox x:Name="chkChangeTZ" Content="Set Timezone" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="chkRunDCU" Content="Run DCU" HorizontalAlignment="Left" Margin="10,30,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="chkGpUpdate" Content="Run GPUpdate" HorizontalAlignment="Left" Margin="10,50,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="chkConfigThing1" Content="Config thing 1" HorizontalAlignment="Left" Margin="233,10,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="chkConfigThing3" Content="Config thing 3" HorizontalAlignment="Left" Margin="233,50,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="chkConfigThing2" Content="Config thing 2" HorizontalAlignment="Left" Margin="233,30,0,0" VerticalAlignment="Top"/>
        <ProgressBar x:Name="progressbar" HorizontalAlignment="Left" Height="10" Margin="10,169,0,0" VerticalAlignment="Top" Width="328"/>
        <Label x:Name="lblProgress" Content="Not Started" HorizontalAlignment="Left" Margin="10,138,0,0" VerticalAlignment="Top"/>
        <Button x:Name="btnConfigure" Content="Configure" HorizontalAlignment="Left" Margin="129,101,0,0" VerticalAlignment="Top" Width="75"/>
    </Grid>
</Window>
"@ #Source for WPF XAML
$AttributesToRemove = @(
    'x:Class',
    'mc:Ignorable'
) #attributes that need to be removed from the source XAML

foreach ($Attribute in $AttributesToRemove) {
    if ($xaml.Window.GetAttribute($Attribute)) {
        $xaml.Window.REmoveAttribute($Attribute)
    }
} #remove unnecessary attributes that cause errors when loading with powershell.

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)
[xml]$xaml = $xaml
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object {
    #find all of the form controls and create variables for them based on their name.
    #$element.<elementName>
    $element.Add($_.Name, $Window.FindName($_.Name))
}

#RunSpace Code for Config Items
$code = {
    function Write-HostDebug {
        #Helper function to write back to the host debug output
        param(
            # The message to send.
            [Parameter(Mandatory)]
            [string]
            $debugMessage
        )
    
        if ($sharedData.DebugPreference) {
            $sharedData.host.UI.WriteDebugLine($debugMessage)
        }
    }
    
    function Write-VerboseDebug {
        # Helper function to write back to the host verbose output
        param(
            # The message to send
            [Parameter(Mandatory)]
            [string]
            $verboseMessage
        )
    
        if ($sharedData.VerbosePreference) {
            $sharedData.host.UI.WriteVerboseLine($verboseMessage)
        }
    }
    Write-HostDebug "In the runspace."
    #This is our runspace code.  To referece our elements we use the $sharedData variable.
    #let's change our lblprogress from "Not Started" to "Process started..."
    #https://docs.microsoft.com/en-us/dotnet/api/system.windows.threading.dispatcher.invoke?view=net-5.0
    $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.lblProgress.Content = 'Process Started...' }, 'Normal')
    #change the "Configure" button to not enabled so people don't keep pressing it...
    $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.btnConfigure.isEnabled = $false }, 'Normal')
    if ($sharedData.chkrunDCU) {
        Write-HostDebug "runDCU is checked."
        #mimic a process using start-sleep...
        $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.progressbar.Value = '1' }, 'Normal')
        Start-Sleep -Seconds 5
        #process is done, let's set our progress bar... Going with simple math - we have 6 checkboxes so 1/6 = 16.66%...
        $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.progressbar.Value = '16.66' }, 'Normal')
        
    }

    if ($sharedData.chkConfigThing1) {
        Write-HostDebug "chkConfigThing1 is checked."
        #or we can change our progress bar to indeterminate so it continues to animate and not have to worry about math..
        $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.progressbar.IsIndeterminate = $true }, 'Normal')
        Start-Sleep -Seconds 5
    }



    Start-Sleep -Seconds 5
    #bring back our button, set the lblProgress and progressbar, we're done..
    $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.btnConfigure.isEnabled = $true }, 'Normal')
    $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.lblProgress.Content = 'Done' }, 'Normal')
    $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.progressbar.IsIndeterminate = $false }, 'Normal')
    $sharedData.Window.Dispatcher.Invoke([action] { $sharedData.progressbar.Value = '100' }, 'Normal')
}
#==>RunSpace Code for Config Items

#Build the runspace - set options
$newRunspace = [runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = 'STA' #https://docs.microsoft.com/en-us/dotnet/api/system.threading.apartmentstate?view=net-5.0
$newRunspace.ThreadOptions = 'ReuseThread' #https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.runspaces.psthreadoptions?view=powershellsdk-1.1.0
$newRunspace.Open()
$newRunspace.Name = 'Process-Config-Options'
#==>Build the runspace - set options

#share info between runspaces
$sharedData = [hashtable]::Synchronized(@{}) # https://docs.microsoft.com/en-us/dotnet/api/system.collections.hashtable.synchronized?view=net-5.0
$sharedData.Runspace = $newRunspace
$sharedData.host = $Host #https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-5.1
$sharedData.Window = $Window
$sharedData.progressbar = $element.progressbar
$sharedData.lblProgress = $element.lblProgress
$sharedData.btnConfigure = $element.btnConfigure
$sharedData.DebugPreference = $DebugPreference
$sharedData.VerbosePreference = $VerbosePreference
#==>share info between runspaces

#add shared data to runspace
$newRunspace.SessionStateProxy.SetVariable("sharedData", $sharedData)
#==>add shared data to runspace

#Create the run space
$newPowershell = [powershell]::Create().AddScript($code)
$newPowerShell.Runspace = $newRunspace
#==>Create the run space

function Write-HostDebug {
    #Helper function to write back to the host debug output
    param(
        # The message to send.
        [Parameter(Mandatory)]
        [string]
        $debugMessage
    )

    if ($DebugPreference) {
        $host.UI.WriteDebugLine($debugMessage)
    }
}

function Write-VerboseDebug {
    # Helper function to write back to the host verbose output
    param(
        # The message to send
        [Parameter(Mandatory)]
        [string]
        $verboseMessage
    )

    if ($VerbosePreference) {
        $host.UI.WriteVerboseLine($verboseMessage)
    }
}

$element.btnConfigure.Add_Click( {
        #Button clicked - check status of our checkboxes and invoke the runspace code in $code.
        $sharedData.chkChangeTz = $element.chkChangeTZ.isChecked
        $sharedData.chkRunDCU = $element.chkRunDCU.isChecked
        $sharedData.chkGpUpdate = $element.chkGpUpdate.isChecked
        $sharedData.chkConfigThing1 = $element.chkConfigThing1.isChecked
        $sharedData.chkConfigThing2 = $element.chkConfigThing2.isChecked
        $sharedData.chkConfigThing3 = $element.chkConfigThing3.isChecked
        $asyncObject = $newPowershell.BeginInvoke()
    })

$Window.Add_Closed( {
        #Clear the runspace if the GUI window is closed.
        if ($asyncObject) {
            $newPowershell.EndInvoke($asyncObject)
        }
        if ($newPowerShell.Runspace) {
            $newPowershell.Runspace.Dispose()
        }
    })

$Window.Activate()
$Window.ShowDialog() | Out-Null