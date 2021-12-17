## switch parameter


function Get-Process_w_Switch {
    param(
        [Parameter(Mandatory = $true,
            HelpMessage = "Enter one or more process names separated by commas.")]
        [String[]]  $ProcName,
        [Parameter()]
        [Switch]
        $NameOnly
    )
    
    begin {
    }
    
    process {
        $processes = Get-Process -Name $ProcName
        if ($NameOnly) {
            $processes | select -ExpandProperty Name
        } else {
            $processes
        }

    }
    
    end {
    }
}

Get-Process_w_Switch code -NameOnly
Get-Process_w_Switch code 


function Get-Process_w_Bool {
    param(
        [Parameter(Mandatory = $true,
            HelpMessage = "Enter one or more process names separated by commas.")]
        [String[]]  $ProcName,
        [Parameter()]
        [Bool]
        $NameOnly
    )
    
    begin {
    }
    
    process {
        $processes = Get-Process -Name $ProcName
        if ($NameOnly) {
            $processes | select -ExpandProperty Name
        } else {
            $processes
        }

    }
    
    end {
    }
}

Get-Process_w_Bool explorer -NameOnly:$true
Get-Process_w_Bool explorer -NameOnly $true
Get-Process_w_Bool explorer -NameOnly
