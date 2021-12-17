
Function Get-HungPrintQueues {
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Name of computer(s) to gather data on
        [Parameter( Mandatory = $false )]
        [String[]] $ComputerName = "*",
        # process computers in parallel
        [Parameter( Mandatory = $false )]
        [switch] $Parallel,
        # -Force operation
        [Parameter( Mandatory = $false )]
        [switch] $DoAction,
        # return an object for each computer
        [Parameter( Mandatory = $false )]
        [switch] $PassThru
    )

    BEGIN {
        Write-Verbose "Getting All Online XenApp servers...." 
        $XAServers = Get-XASite | Get-XAServer -OnlineOnly 
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