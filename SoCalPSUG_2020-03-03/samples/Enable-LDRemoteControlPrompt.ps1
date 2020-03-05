<#
       .Synopsis
          Short description
       .DESCRIPTION
          Long description
       .EXAMPLE
          Example of how to use this cmdlet
       .EXAMPLE
          Another example of how to use this cmdlet
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
    }
    Process {
        If (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
            Try {
                $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computername ) 
                $regKey = $reg.OpenSubKey('SOFTWARE\Wow6432Node\Intel\LANDesk\WUSER32', $true) 
                If ($regKey) {
                    Write-Verbose "Current: [Permission Required] -> '$($regkey.GetValue('Permission Required'))'  " -Verbose
                    Write-Verbose "Set:  [Permission Required] -> '2'" -Verbose 
                    $regKey.SetValue("Permission Required", "2", [Microsoft.Win32.RegistryValueKind]::DWord)
                }
                $regKey = $reg.OpenSubKey('SOFTWARE\Intel\LANDesk\WUSER32', $true) 
                If ($regKey) {
                    Write-Verbose "Current: [Permission Required] -> '$($regkey.GetValue('Permission Required'))'  " -Verbose
                    Write-Verbose "Set:  [Permission Required] -> '2'" -Verbose 
                    $regKey.SetValue("Permission Required", "2", [Microsoft.Win32.RegistryValueKind]::DWord)
                }
                            
            }
            Catch {
                Write-Error "unable to update Registry"
            }

        }
        else {
            Write-Warning "Unable to Ping [ $computerName ]"
        }
    }
    End {
    }
}


