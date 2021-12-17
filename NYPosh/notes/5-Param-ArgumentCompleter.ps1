## ArgumentCompleter 

function Get-filesByExt {
    Param(
        [Parameter(Mandatory)]
        
        [String[]]  $fileExt,

        [Parameter(Mandatory)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                if ($fakeBoundParameters.ContainsKey('FileExt')) {
                    Get-ChildItem -filter "*.$($fakeBoundParameters.FileExt)" | Where-Object {
                        $_ -like "$wordToComplete*"
                    }
                }
            })]
        [String[]]  $FileName
    )
    
    begin {
    }
    
    process {
        Get-ChildItem $fileName
    }
    
    end {
    }
}
