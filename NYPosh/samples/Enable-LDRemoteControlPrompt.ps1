<#
.Synopsis
    Enable LANDesk remote control user prompt
.DESCRIPTION
    This will turn on the "prompt user" for remote control access
.EXAMPLE
    Enable-LDRemoteControlPrompt -ComputerName PC02
.EXAMPLE
    "PC01","PC02" | Enable-LDRemoteControlPrompt 
#>
function Enable-LDRemoteControlPrompt {
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [String[]] $computerName


    )
       
    Begin {
        # Force Verbose for all cmdlets
        $HoldVerbose = $VerbosePreference
        $VerbosePreference = "Continue"
    }
    Process {
        If (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
            Try {
                $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computername ) 
                $regKey = $reg.OpenSubKey('SOFTWARE\Wow6432Node\Intel\LANDesk\WUSER32', $true) 
                If ($regKey) {
                    Write-Verbose "Current: [Permission Required] -> '$($regkey.GetValue('Permission Required'))'  " 
                    Write-Verbose "Set:  [Permission Required] -> '2'"  
                    $regKey.SetValue("Permission Required", "2", [Microsoft.Win32.RegistryValueKind]::DWord)
                }
                $regKey = $reg.OpenSubKey('SOFTWARE\Intel\LANDesk\WUSER32', $true) 
                If ($regKey) {
                    Write-Verbose "Current: [Permission Required] -> '$($regkey.GetValue('Permission Required'))'  " 
                    Write-Verbose "Set:  [Permission Required] -> '2'"  
                    $regKey.SetValue("Permission Required", "2", [Microsoft.Win32.RegistryValueKind]::DWord)
                }
                            
            }
            Catch {
                Write-Error "unable to update Registry on [$ComputerName]"
            }

        }
        else {
            Write-Warning "Unable to Ping [ $computerName ]"
        }
    }
    End {
        $VerbosePreference = $HoldVerbose
    }
}


