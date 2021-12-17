function Get-ProcessFunction {
    param(
        [String[]] $ProcName
    )
    
    begin {
        ## runs once
        ## before the first item in Pipeline
    }
    
    process {
        ## runs for each item in the pipeline
        ## current item is $_ or $PSItem
    }
    
    end {
        ## runs after all items have been processed
        ## the pipeline is empty
    }
}


