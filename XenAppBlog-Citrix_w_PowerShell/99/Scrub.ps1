function Scrub-Data {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject]
        $Object
    )
    
    begin {
    }
    
    process {
        Write-Verbose "Object Type: [$($Object.GetType())]" 
        if ($Object.GetType().Name -eq 'EventLogRecord' -or $Object.GetType().Name -eq 'PSObject') {
            Write-Verbose "WinEvent" 
            $editMachineName = $Object.MachineName
            $Object.PSobject.properties.remove("MachineName")
            $editMachineName = ($editMachineName -replace '.<<CORPDOMAIN>>.com', '.domain.local')
            $editMachineName = $editMachineName -replace '^[a-zA-Z]{5}', "___"
            $object | Add-Member -MemberType NoteProperty -Name MachineName -Value $editMachineName -Force
            $Object.Message = ($Object.Message -replace '<<CORPDOMAIN>>.com', 'domain.local')
            $Object.Message = ($Object.Message -replace 'martinarietta.com', 'domain.local')
            $Object.Message = ($Object.Message -replace '<<CORPDOMAIN>>\\', 'domain\\')
            $Object.Message = ($Object.Message -replace '10.100.', 'x.x.')
            $Object.Message = ($Object.Message -replace '192.168.', 'x.x.')
            $Object.Message = ($Object.Message -replace '(<<COMPUTERNAME>>)', '____OSSML2')
            $object
        }
        elseif ($Object.GetType().Name -eq 'string') {
            Write-Verbose "String" 
            #            $Object = $Object -replace '([A-Za-z0-9]{5})(?<name>[a-zA-Z0-9]+)(.<<CORPDOMAIN>>.com)','___${name}.domain.local'
            #            $Object = ($Object -replace '.<<CORPDOMAIN>>.com','.domain.local')
            #            $Object = $Object -replace '([A-Za-z0-9]{4})(?<name>[a-zA-Z0-9]+)(.<<CORPDOMAIN>>.com)','___${name}.domain.local'
            $object = $Object -replace '([A-Za-z0-9]{5})(?<name>[a-zA-Z0-9]+)(.<<CORPDOMAIN>>.com)', '___${name}.domain.local'
            $object = $Object -replace '(<<CORPDOMAIN>>)', 'domain'
            $object = $Object -replace '(<<ADMIN_USERNAME>>)', 'admADAcct'
            $object = $Object -replace '(<<REG_USERNAME>>)', 'ADAcct'
            $object = $Object -replace '(<<PC_NAME>>)', '____OSSML1'
            $object = $Object -replace '(<<CORP_SID_PREFIX>>)', '123456789-9999999999'
            $Object -replace '<<DEVICE_SID>>', '9999999999-123456789'
            $object
        } 
        elseif ($Object.GetType().Name -eq 'PSCustomObject' -or $Object.GetType().Name -eq 'ArrayList') {
            $props = $Object.psobject.Properties.name
            Write-Verbose "String" 
            $props | ForEach-Object {
            
                $Object.($_) = $Object.($_) -replace '([_A-Za-z0-9]{5})(?<name>[a-zA-Z0-9_]+)(.<<CORPDOMAIN>>.com)', '___${name}.domain.local'
                $Object.($_) = $Object.($_) -replace '(_[A-Za-z0-9]{4})(?<name>[a-zA-Z0-9_]+)(.<<CORPDOMAIN>>.com)', '___${name}.domain.local'
                $Object.($_) = $Object.($_) -replace '(_[A-Za-z0-9]{3})(?<name>[a-zA-Z0-9_]+)(.<<CORPDOMAIN>>.com)', '___${name}.domain.local'
                $Object.($_) = $Object.($_) -replace '(_[A-Za-z0-9]{2})(?<name>[a-zA-Z0-9_]+)(.<<CORPDOMAIN>>.com)', '___${name}.domain.local'
                $Object.($_) = $Object.($_) -replace '(_[A-Za-z0-9]{1})(?<name>[a-zA-Z0-9_]+)(.<<CORPDOMAIN>>.com)', '___${name}.domain.local'
                $Object.($_) = $Object.($_) -replace '.<<CORPDOMAIN>>.com', '.domain.local'
                $Object.($_) = $Object.($_) -replace '(<<CORPDOMAIN>>)', 'domain'
                $Object.($_) = $Object.($_) -replace '(<<ADMIN_USERNAME>>)', 'admADAcct'
                $Object.($_) = $Object.($_) -replace '(<<REG_USERNAME>>)', 'ADAcct'
                $Object.($_) = $Object.($_) -replace '(<<HOSTNAME>>)', '___pps'
                $Object.($_) = $Object.($_) -replace '(<<OTHER_HOSTNAME>>)', '___PN'
                $Object.($_) = $Object.($_) -replace '(<<PC_NAME>>)', '____OSSML1'
                $Object.($_) = $Object.($_) -replace '(<<COMPUTERNAME>>)', '____OSSML2'
                $Object.($_) = $Object.($_) -replace '(<<CORP_SID_PREFIX>>)', '123456789-9999999999'
                #$Object.($_) = $Object.($_) -replace '10.100.123', 'x.x.x'
                $Object.($_) = $Object.($_) -replace '10.100.[0-9][0-9][0-9]', 'x.x.x'
                $Object.($_) = $Object.($_) -replace '10.100.[0-9][0-9]', 'x.x.x'
                $Object.($_) = $Object.($_) -replace '10.100.[0-9]', 'x.x.x'
                $Object.($_) = $Object.($_) -replace '172.16.8', 'x.x.x'
                $Object.($_) = $Object.($_) -replace '<<OTHERNAME>>', '___est'
                $Object.($_) = $Object.($_) -replace '(<<HOST_PREFIX>>)', '_DEV_'
                $Object.($_) = $Object.($_) -replace '(<<HOST_SUFFIX>>)', '_DEV_'

                $Object.($_) = $Object.($_) -replace '(<<CORPDOMAIN>>)', 'domain'           
            }
            $object
        } 
        else {
            $Object
        }

    }
    
    end {
        
    }
}