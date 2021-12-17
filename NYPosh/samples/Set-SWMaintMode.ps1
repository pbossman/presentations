<#
.Synopsis
   Add Solarwinds ADHOC Maintenance Schedule
.DESCRIPTION
   Adds an adhoc maintenance schedule for the supplied computername for a specifiec amount of time (default: 15 minutes)

   This function REQUIRES the SolarWinds Module [SwisPowerShell]
   To install:  Install-Module -Name SwisPowerShell -Scope CurrentUser

.PARAMETER ComputerName
    (Required) Unique computer name, FQDN or IP address.  Can also be an array of names if multiple machines need to be set.

.PARAMETER Minutes
    Number of minutes to put computers in maintenance, up to 240

.PARAMETER Hours
    Number of hours to put computers in maintenance, up to 72

.PARAMETER EndDate
    Specific date and time for maintenance period to end using 24 Hour notation (exmanple: 2015-08-05 16:11:43 )

.PARAMETER StartTime
    Specific date and time for maintenance periot to start using 24 Hour notation (exmanple: 2015-08-05 16:11:43 ) (default is now)

.PARAMETER SWServer
    Solarwinds server to use.  Default is the infrastucture solarwinds instance (RALOSWAPP01)

.PARAMETER Unmanage
    Switch to completely stop monitoring the server instead of simply preventing alerts from triggering.

.PARAMETER Passthru
    Switch to output results

.EXAMPLE
   Set-SWMaintMode -ComputerName Server01

   Mutes alerts from the server for the DEFAULT ( 15 ) Mintes
.EXAMPLE
   Set-SWMaintMode -ComputerName Server01 -Minutes 30

   Mutes alerts from the server for 30 Mintes
      
.EXAMPLE
   Set-SWMaintMode -ComputerName Server01 -Hours 4

   Mutes alerts from the server for 4 Hours
      
.EXAMPLE
   Set-SWMaintMode -ComputerName Server01 -EndTime "2015-08-05 16:11:43"

   Mutes alerts from the server and will end at 8/5/2015 @ 4:11:43 PM
      
.EXAMPLE
    Set-SWMAintMode -Computername Server01 -Hours 4 -Unmanage

    Unmanages the server (will stop alerts AND stop collecting performance data) for 4 hours

.EXAMPLE
    "Server01","Server02" | Set-SWMAintMode -Hours 4 -Unmanage

    Unmanages the server (will stop alerts AND stop collecting performance data) for 4 hours

.NOTES
    Adapted from set-argentmaintmode 10/16/2018
    
#>
function Set-SWMaintMode {
    [CmdLetBinding(DefaultParameterSetName = 'Minutes')]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String[]] $ComputerName,

        [Parameter(ParameterSetName = 'Minutes')]
        [ValidateScript( {
                If ([int]$_ -ge 1 -and [int]$_ -le 240) {
                    $True
                }
                else {
                Write-verbose "Enter a number of minutes up to 240 minutes (4 hours)" 
                    Throw "Enter a number of minutes up to 240 minutes (4 hours)"
                }
            })]
        [int] $Minutes = 15,

        # Specify number of hours
        [Parameter(ParameterSetName = 'Hours')]
        [ValidateScript( {
                If ([int]$_ -ge 1 -and [int]$_ -le 72) {
                    $True
                }
                else {
                    Write-verbose "Enter a number of hours up to 72 hours" 
                    Throw "Invalid Data"
                }
            })]
        [int] $Hours,

        # Specify an exact end time
        [Parameter(ParameterSetName = 'EndDate')]
        [ValidateScript( {
                If ($_ -match "^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})?$") {
                    $True
                }
                else {
                    Write-verbose "Enter a valid datetime: [YYYY-MM-DD HH:MM:SS] using 24 Hour notation (exmanple: 2015-08-05 16:11:43 )"
                    Throw "Invalid Data"
                }
            })]
        [string] $EndTime,

        # Specify an exact end time
        [Parameter()]
        [ValidateScript( {
                If ($_ -match "^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})?$") {
                    $True
                }
                else {
                    Write-verbose "Enter a valid datetime: [YYYY-MM-DD HH:MM:SS] using 24 Hour notation (exmanple: 2015-08-05 16:11:43 )"
                    Throw "Invalid Data"
                }
            })]
        [string] $StartTime,
        [Parameter()]
        [string] $swserver = "$env:SolarWindsSvr",
        [Parameter()]
        [switch] $Unmanage,
        [Parameter()]
        [switch] $Passthru
    )




    Begin {
        <# Credssp not needed for SolarWinds
        If ((Get-Item  WSMan:\localhost\Client\Auth\CredSSP).value -eq $false) {
            Write-Warning "CredSSP Not enabled.... Enabling"
            Enable-WSManCredSSP -Role Client -DelegateComputer *.domain.local -Force
        }#>

        If (-not (Get-Module -Name SwisPowerShell)) {
            Write-Warning "This function REQUIRES the SolarWinds PowerShell Module"
            Write-Warning "Run:  Install-Module -Name SwisPowerShell -Scope CurrentUser"
            break
        }

        $now = Get-Date

        If ( $StartTime ) {
            Try {
                Write-Verbose "Evaluating Starttime"
                $Start = Get-Date -Date $StartTime
                if ( (New-TimeSpan -Start $now -End $Start).Ticks -lt 0 ) {
                    Throw "Date [ $StartTime ] must be in the future"
                }
            }
            catch {
                Write-Error $Error[0].Exception.Message
                Break
            }
        }
        else {
            Write-Verbose "Setting startTime to NOW!"
            $start = Get-date
            $startTime = $start.ToString("yyyy-MM-dd HH:mm:ss")
        }

        If ($Hours -and (-not $EndTime)) {
            Write-Verbose "Adding $hours hours to Start" 
            $endtime = $start.AddHours($hours).ToString("yyyy-MM-dd HH:mm:ss")
        } 

        If ($Minutes -and (-not $EndTime) -and (-not $Hours)) {
            Write-Verbose "Adding $Minutes minutes to Start"
            $endtime = $start.AddMinutes($Minutes).ToString("yyyy-MM-dd HH:mm:ss")
        } 


        Write-Verbose "Starttfffime: $starttime" 
        Write-Verbose "EndTime:   $EndTime"

        # Not clear on why this isn't a parameter?
        IF (-not $script:SolarwindsCred) {
            $script:SolarwindsCred = (Get-Credential -Message "Enter Admin Credentials" )
        }

    }
    Process {
        Try {
            # import module is not already imported
            If (-not (Get-Command -Name Connevct-Swis -ErrorAction SilentlyContinue)) {
                import-module SwisPowerShell
            }
            # Connect to swis
            $swis = Connect-Swis -Credential $script:SolarwindsCred -Hostname $swserver
            $begin = (Get-Date -Date $StartTime).ToUniversalTime()
            $end = (Get-Date -Date $EndTime).ToUniversalTime()
            Foreach ($Computer in $ComputerName) {
                Write-Verbose "Processing $Computer" -Verbose
                # Finding computer
                $query = @"
select uri,nodeid,caption,ipaddress from orion.nodes
where unmanaged = 0 and
(caption = '$Computer' or dns = '$Computer' or ipaddress = '$Computer')
"@
                $node = get-swisdata -SwisConnection $swis -Query $query
                if ($node.count -le 0) {
                    Write-Debug "ISSUE: Did NOT find any entries for $Computer"
                    $result = "NotFound"
                    Write-Warning "##ERROR## -- $Computer NOT FOUND!"
                }
                elseif ($node.count -gt 1) {
                    Write-Debug "ISSUE: found multiple entires for $Computer"
                    $result = "TooManyResults"
                    Write-warning "Too many results, $($node.count) $Computer entries." 
                }
                else {

                    Write-Debug "SUCCESS: Only found 1 entry for $Computer found"
                    write-verbose "$($node.nodeid) $($node.uri)"
                    if ($unmanage) {
                        write-verbose "Unmanaging node"
                        $netObjectID = "N:{0}" -f ($node.nodeid)
                        $ReturnValue = Invoke-SwisVerb -SwisConnection $swis -EntityName Orion.Nodes -verb Unmanage -arguments @($netObjectID, $begin, $end, $false)
                        If ($ReturnValue.nil -eq $true) {
                            $result = "UnManaged"
                        }
                        else {
                            #unknown:  Why the REST call did not return True?
                            $result = "ERROR"
                        }
                    }
                    else {
                        write-verbose "Muting node $Computer"
                        $ReturnValue = Invoke-SwisVerb -SwisConnection $swis -EntityName Orion.AlertSuppression -verb SuppressAlerts -Arguments @(, $node.uri, $begin, $end)
                        If ($ReturnValue.nil -eq $true) {
                            $result = "Muted"
                        }
                        else {
                            #unknown:  Why the REST call did not return True?
                            $result = "ERROR"
                        }
                    }
                }
                if ($PassThru) {
                    # Write output object to pipeline to 
                    [pscustomobject]@{
                        ComputerName = $Computer
                        Result       = $result
                        Begin        = $begin
                        End          = $end
                    }
                
                }
            }
            $Swis.Close()
        }
        Catch {
            $script:SolarwindsCred = $null
            Write-Warning $Error[0].Exception.Message
        }
    }
    End {
    }
}

New-Alias -Name MaintMode -Value Set-SWMaintMode -Force
New-Alias -Name MM -Value Set-SWMaintMode -Force