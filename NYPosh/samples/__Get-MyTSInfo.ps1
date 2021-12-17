<#
.Synopsis
   Get the Home Path and Terminal Services (TS) home Path information
.DESCRIPTION
   Long description
.EXAMPLE
   Get-MyTSInfo -Username pbossman
.EXAMPLE
   Get-MyADuser -Lastname Boss* | Get-MyTSInfo
#>
function Get-MyTSInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        [Alias("SamaccountName")]
        [Alias("DistinguishedName")]
        [String[]] $UserName
    )

    Begin {
    }
    Process {

        Foreach ($user in $UserName) {
            Try {
                $ADUser = Get-ADUser -Identity "$user" -Properties HomeDrive, HomeDirectory, DistinguishedName -ErrorAction Stop

                Write-Verbose "User: [ $($ADUser.SamAccountName) ]" 
                
                $ADSIInfo = [ADSI] "LDAP://$($ADUser.DistinguishedName)"
                $TSDirectory = $ADSIInfo.psbase.InvokeGet("TerminalServicesHomeDirectory")
                $TSDriveLetter = $ADSIInfo.psbase.InvokeGet("TerminalServicesHomeDrive")
        
                [PSCustomObject] @{
                    'SAMAccountName'   = $ADUser.SamAccountName;
                    'name'             = $ADUser.Name;
                    'HomeDrive'        = $ADUser.HomeDrive;
                    'HomeDirectory'    = $ADUser.HomeDirectory;
                    'TS_HomeDrive'     = $TSDriveLetter;
                    'TS_HomeDirectory' = $TSDirectory;
                    'PathMatch'        = "$($ADUser.HomeDirectory -eq $TSDirectory)"
                }

            }
            Catch {
                Write-Warning "Unable to lookup $user"
            }
        }

    }
    End {
    }
}


Get-MyTSInfo -UserName 'phil','jason','bob'
'phil', 'jason', 'bob' | Get-MyTSInfo