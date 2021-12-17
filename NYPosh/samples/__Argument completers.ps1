Register-ArgumentCompleter -CommandName Get-BrokerApplication -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (Get-BrokerApplication).Name | Where-Object {
        $_ -like "$wordToComplete*"
    } | ForEach-Object {
        "'$_'"
    }
}

Register-ArgumentCompleter -CommandName Get-BrokerApplication -ParameterName BrowserName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (Get-BrokerApplication).BrowserName | Where-Object {
        $_ -like "$wordToComplete*"
    } | ForEach-Object {
        "'$_'"
    }
}

Register-ArgumentCompleter -CommandName Get-BrokerApplication -ParameterName PublishedName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (Get-BrokerApplication).PublishedName | Where-Object {
        $_ -like "$wordToComplete*"
    } | ForEach-Object {
        "'$_'"
    }
}

Register-ArgumentCompleter -CommandName Get-BrokerApplication -ParameterName AllAssociatedDesktopGroupUUIDs -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $BrowserNameFilter = $fakeBoundParameters.BrowserName

    $PublishedNameFilter = $fakeBoundParameters.PublishedName


    Get-BrokerApplication -BrowserName "*$BrowserNameFilter*" -PublishedName "*$PublishedNameFilter*" | Where-Object {
        $_.AllAssociatedDesktopGroupUUIDs -like "$wordToComplete*"
    } | ForEach-Object {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList "'$($_.UserFullName)'",
        $_.UserFullName,
        "ParameterValue",
        $_.UserFullName
    }
}
Register-ArgumentCompleter -CommandName Get-BrokerDesktop -ParameterName DNSName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (Get-BrokerDesktop).DNSName | Where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
        "$_"
    }
}

Register-ArgumentCompleter -CommandName Get-BrokerMachine -ParameterName MachineName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (Get-BrokerMachine).Machinename | Where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
        "'$_'"
    }
}

Register-ArgumentCompleter -CommandName Get-BrokerMachine -ParameterName PublishedApplication -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $MachineNameFilter = $fakeBoundParameters.Machinename

    (Get-BrokerMachine -MachineName "$MachineNameFilter").PublishedApplications | Where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
        "'$_'"
    }
}

Register-ArgumentCompleter -CommandName Get-BrokerSession -ParameterName UserName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (Get-BrokerSession).Username | Select-Object -Unique | Where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
        "$_"
    }
}

Register-ArgumentCompleter -CommandName Get-BrokerSession -ParameterName UserFullName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    Get-BrokerSession -UserFullName "*$wordToComplete*" -MaxRecordCount 999 | Select-Object -Property UserFullName -Unique | ForEach-Object {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList "'$($_.UserFullName)'",
        $_.UserFullName,
        "ParameterValue",
        $_.UserFullName
    }
}
