Function Get-XDUsers {
    Param
    (
        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [string] $Username,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'FullName')]
        [ValidateNotNull()]
        [string] $FullName
    )

    Begin {
        Try {           
            If (! (Get-PSSnapin Citrix.Broker* -ErrorAction SilentlyContinue) ) {
                Add-PSSnapin Citrix.Broker* -ErrorAction Stop
            }
        }
        Catch { 
            Write-Warning "Unable to load Citrix Broker Snapin...."
            Break
        }

    }

    
    
    PROCESS {
        $DesktopDetails = Get-BrokerMachine |
            Select-Object HostedMachineName, Uid,
            @{name = "UserNames"; Expression = { ($_.AssociatedUserNames | ForEach-Object { ($_ -split "\\")[1] } ) -join ";" } },
            @{name = "FullNames"; Expression = { ($_.AssociatedUserFullNames | ForEach-Object { ($_ ) -join ";" } ) } },
            @{Name = "Orphand"; Expression = { ($_.AssociatedUserNames | ForEach-Object { If ($_ -like "S-1-5-*") { $true } } ) } }
        If ($Username) { $DesktopDetails | Where-Object UserNames -like "*$Username*" }
        elseIf ($FullName) { $DesktopDetails | Where-Object FullNames -like "*$FullName*" }
        else { $DesktopDetails }

    }

    END {
        
    }
}