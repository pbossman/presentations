Funtion Get-XDUsers {
    [CmdletBinding(DefaultParameterSetName = 'UserName')]
    Param(
        [Parameter(Mandatory = $false,
            ParameterSetName = 'UserName')]
        [ValidateNotNull()]
        [string] $Username,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'FullName')]
        [ValidateNotNull()]
        [string] $FullName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [string] $HostedMachineName = "*",

        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [string] $DDCServer = "DDC.local",

        [Parameter(Mandatory = $false)]
        [ValidateRange(200, 999)]
        [int] $MaxRecordCount = 250 
    )

    BEGIN {
        Try {
            If (! (Get-Command -Name Get-BrokerSite -ErrorAction SilentlyContinue) ) {
                Add-PSSnapin Citrix.Broker* -ErrorAction Stop
            }
        }
        Catch { 
            Write-Warning "Unable to load Citrix Broker Snapin...."
            Break
        }

    }

    PROCESS {
        $DesktopDetails = Get-BrokerMachine -HostedMachineName $HostedMachineName -MaxRecordCount $MaxRecordCount -AdminAddress $DDCServer |
            Select-Object HostedMachineName, Uid,
                @{name = "UserNames"; Expression = { ($_.AssociatedUserNames | ForEach-Object { ($_ -split "\\")[1] } ) -join ";" } },
                @{name = "FullNames"; Expression = { ($_.AssociatedUserFullNames | ForEach-Object { ($_ ) -join ";" } ) } },
                @{Name = "Orphand"; Expression = { ($_.AssociatedUserNames | ForEach-Object { If ($_ -like "S-1-5-*") { $true } } ) } }

        If ($Username) {
            $DesktopDetails | Where-Object UserNames -Like "*$Username*" 
        }
        elseIf ($FullName) { 
            $DesktopDetails | Where-Object FullNames -Like "*$FullName*" 
        }
        else { 
            $DesktopDetails 
        }

        }

    END {
        
        }

    }