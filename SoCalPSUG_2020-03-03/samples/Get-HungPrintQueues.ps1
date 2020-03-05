
Function Get-HungPrintQueues {
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter( Mandatory = $false )]
        [String[]] $ComputerName = "*",
        # Param1 help description
        [Parameter( Mandatory = $false )]
        [switch] $Parallel,
        # Param1 help description
        [Parameter( Mandatory = $false )]
        [switch] $DoAction,
        # Param1 help description
        [Parameter( Mandatory = $false )]
        [switch] $PassThru
    )

    BEGIN {
        Write-Verbose "Getting All Online XenApp servers...." 
        $XAServers = Get-XAZone | Get-XAServer -OnlineOnly 
    }

    PROCESS {

        If ($ComputerName) {
            foreach ($Computer in $ComputerName) {
                $XAServerNames = $XAServers | Where-Object ServerName -like $ComputerName | Sort-Object -Property ServerName
                If ($Parallel) {
                    $scriptBlock = {
                        Write-Verbose "   $($_.ServerName)" 
                        $ptrJobs = @(Get-WmiObject -ComputerName $_.ServerName -Class Win32_PrintJob -Verbose | 
                                Select-Object caption, document, jobid, jobstatus, owner, @{Name = "TimeSubmitted"; expression = { $_.ConvertToDateTime($_.timesubmitted) } })
                        If ($ptrJobs.Count -gt 0) {  
                            Write-Warning "Found ($($ptrJobs.Count)) Jobs on $($_.ServerName)" 
                            Write-host "Need to Run" -ForegroundColor Yellow
                            Write-Host "Restart-Service -InputObject (Get-Service -ComputerName $_ -Name Spooler) -Force -Verbose" -ForegroundColor Yellow
                            If ($DoAction) {
                                Restart-Service -InputObject (Get-Service -ComputerName $_.ServerName -Name Spooler) -Force 
                            }
                        }
                        If ($PassThru) {
                            Write-Output $ptrJobs
                        }
                    }
                    Invoke-Parallel -InputObject $XAServerNames -ScriptBlock $scriptBlock 
                }
                Else {
                    $XAServerNames | ForEach-Object {
                        Write-Verbose "   $($_.ServerName)" 
                        $ptrJobs = @(Get-WmiObject -ComputerName $_.ServerName -Class Win32_PrintJob -Verbose | 
                                Select-Object caption, document, jobid, jobstatus, owner, @{Name = "TimeSubmitted"; expression = { $_.ConvertToDateTime($_.timesubmitted) } })
                        If ($ptrJobs.Count -gt 0) {  
                            Write-Warning "Found ($($ptrJobs.Count)) Jobs on $($_.ServerName)" 
                            Write-host "Need to Run" -ForegroundColor Yellow
                            Write-Host "Restart-Service -InputObject (Get-Service -ComputerName $_ -Name Spooler) -Force -Verbose" -ForegroundColor Yellow
                            If ($DoAction) {
                                Restart-Service -InputObject (Get-Service -ComputerName $_.ServerName -Name Spooler) -Force 
                            }
                        }
                        If ($PassThru) {
                            Write-Output $ptrJobs
                        }
                    }
                } 
            }
        }
    }

    END { }
}