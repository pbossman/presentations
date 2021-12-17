## Parameter Options
# Mandatory
function Get-MyService {
    param (
        [Parameter(Mandatory=$true)]
        [String] $Name,
        [Parameter(Mandatory)]
        [String] $Status
    )
    
    Process{
        Get-Service -Name $name | Where-Object Status -eq $Status
    }
}

Get-MyService Workstation 


# Position 

function Get-MyService {
    param (
        [Parameter(Position=0)]
        [String] $Name,
        [Parameter(Position=1)]
        [String] $Status
    )
    
    Process{
        Get-Service -Name $name | Where-Object Status -eq $Status
    }
}

Get-MyService -Status Running -Name Workstation
Get-MyService Workstation Running

# HelpMessage
# ValueFromPipeline 


function Get-MyService {
    param (
        [Parameter(Mandatory,
            Position = 0,
            HelpMessage='Enter a ServiceName',
            ValueFromPipeline=$true)]
        [String] $Name,
        [Parameter(Position = 1)]
        [ValidateSet('Running','Stopped','JAson')]
        [String] $Status = 'Running'
    )
    
    Process {
        Get-Service -Name $name | Where-Object Status -eq $Status
    }
}

Get-MyService bits -Status Stopped

'bits', 'WinMgmt', 'WinRM' | Get-MyService 

'bits', 'WinMgmt', 'WinRM' | Get-MyService -Status 





# ValueFromPipelineByPropertyName 
# ValueFromRemainingArguments 
# ParameterSetName
# Alias 

 
#  [AllowEmptyCollection()]
 
# [ValidateCount(1,5)] 

# [ValidateLength(1,10)]
#   Length of a string


# [ValidatePattern("[0-9][0-9][0-9][0-9]")]
#   regex Match

# [ValidateRange(0,10)]
#   Match a number range
#   or 'Positive', 'Negative', 'NonNegative', 'NonPositive'

# [ValidateScript({$_ -ge (Get-Date)})]
#  Any Script you want.
#  matches if NOT $false or Throwing error


# [ValidateSet("Low", "Average", "High")]
#  Matches a set


# [ValidateNotNull()]
#  validated the parameter is NOT $null


# [ValidateNotNullOrEmpty()]
#  validates that the string in not $null or an empty string
 


