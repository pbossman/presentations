function Get-ProcessFunction {
    param(
        [String[]] $ProcName
    )
    
    begin {
    }
    
    process {
        Get-Process -Name $ProcName
    }
    
    end {
    }
}


Get-ProcessFunction 'code'

'code' | Get-ProcessFunction




function Get-ProcessFunction {
    param(
        [Parameter(Mandatory = $true,
            HelpMessage = "Enter one or more process names separated by commas.")]
        [String[]]  $ProcName
    )
    
    begin {
    }
    
    process {
        Get-Process -Name $ProcName
    }
    
    end {
    }
}


## Go to 3-Proc



## Switch 

