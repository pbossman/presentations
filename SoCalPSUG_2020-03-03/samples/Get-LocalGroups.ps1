<#
        .Synopsis
            Gets membership information of local groups in remote computer
        .Description
            This script by default queries the membership details of local administrators group on remote computers.
			It has a provision to query any local group in remote server, not just administrators group.
        .Parameter ComputerName
            Computer Name(s) which you want to query for local group information
		.Parameter LocalGroupName
			Name of the local group which you want to query for membership information. It queries 'Administrators' group when
			this parameter is not specified
		.Parameter OutputDir
			Name of the folder where you want to place the output file. It creates the output file in c:\temp folder
			this parameter is not used.
        .Example
            Get-LocalGroupMembers.ps1 -ComputerName srvmem1, srvmem2
            Queries the local administrators group membership and writes the details to c:\temp\localGroupMembers.CSV
        .Example
			Get-LocalGroupMembers.ps1 -ComputerName (get-content c:\temp\servers.txt)
		.Example
			Get-LocalGroupMembers.ps1 -ComputerName srvmem1, srvmem2
        .Notes
			Author : Sitaram Pamarthi
			WebSite: http://techibee.com
            Modified By: Phil Bossman - 1-13-2015
#>
Function Get-LocalGroups {
	[CmdletBinding()]
	Param(
		[Parameter(	ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		[Alias("Name", "IPAddress", "IPv4Address")]
		[string[]]
		$ComputerName = $env:ComputerName,
		[Parameter()]
		[Alias("Group")]
		[string]
		$LocalGroupName = "Administrators"
	)
	Begin {
	}
	Process {
		ForEach ($Computer in $ComputerName) {
			Write-Verbose "Working on $Computer"
			If (!(Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
				Write-Warning "$Computer is offline. Proceeding with next computer"
				Continue
			}
			else {
				Write-Verbose "Working on $computer"
				try {
					$group = [ADSI]"WinNT://$Computer/$LocalGroupName"
					$members = @($group.Invoke("Members"))
					Write-Verbose "Successfully queries the members of $computer"
					if (!$members) {
						Write-Warning "No members found in the group"
						continue
					}
				}
				catch {
					Write-Warning "Failed to query the members of $computer"
					Continue
				}
				foreach ($member in $members) {
					try {
						$MemberName = $member.GetType().Invokemember("Name", "GetProperty", $null, $member, $null)
						$MemberType = $member.GetType().Invokemember("Class", "GetProperty", $null, $member, $null)
						$MemberPath = $member.GetType().Invokemember("ADSPath", "GetProperty", $null, $member, $null)
						$MemberDomain = $null
						if ($MemberPath -match "^Winnt\:\/\/(?<domainName>\S+)\/(?<CompName>\S+)\/") {
							if ($MemberType -eq "User") {
								$MemberType = "LocalUser"
							}
							elseif ($MemberType -eq "Group") {
								$MemberType = "LocalGroup"
							}
							$MemberDomain = $matches["CompName"]
						}
						elseif ($MemberPath -match "^WinNT\:\/\/(?<domainname>\S+)/") {
							if ($MemberType -eq "User") {
								$MemberType = "DomainUser"
							}
							elseif ($MemberType -eq "Group") {
								$MemberType = "DomainGroup"
							}
							$MemberDomain = $matches["domainname"]
						}
						else {
							$MemberType = "Unknown"
							$MemberDomain = "Unknown"
						}
						# Output Custom Object into Pipeline
						[PSCustomObject]@{
							'ComputerName'   = $Computer;
							'LocaLGroupName' = $LocalGroupName;
							'Name'           = $MemberName;
							'Type'           = $MemberType;
							'Domain'         = $MemberDomain
						}

					}
					catch {
						Write-Warning "failed to query details of a member. Details $_"
					}
				}
			}
		}
	}
	End { }
}