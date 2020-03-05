## other languages

# VBscript
# Function Functionname(parameter-list)
#       statement 1
#       statement 2
#       statement 3
#       .......
#       statement n
#     End Function


# RAW FORMAT
function [<scope:>]<name> [([type]$parameter1[, [type]$parameter2])] {
  param([type]$parameter1 [, [type]$parameter2])
  dynamicparam { <statement list> }
  begin { <statement list> }
  Get-process { <statement list> }
  end { <statement list> }
}




# simple function
function Get-ExplorerProcess { 
  Get-Process explorer
  Get-item C:\SoCal
}




Get-ExplorerProcess




function Get-myProcess ($name) {
  Get-Process $name
}

Get-myProcess


Get-myProcess code



function Get-myProcess ($name = 'explorer') {
  Get-Process $name
}



Get-myProcess



Get-myProcess code 



Get-myProcess code | export-csv .\out.csv
.\out.csv




'apple', 'code', 'dog' | Get-myProcess



Get-myProcess 'explorer', 'code' 

function Get-myProcess ($name = 'explorer') {
  Get-Process $name
}


Get-myProcess -name apple





function [<scope:>]<name> [([type]$parameter1[, [type]$parameter2])]
{
  param([type]$parameter1 [, [type]$parameter2])
  dynamicparam { <statement list> }
  begin { <statement list> }
  Get-process { <statement list> }
  end { <statement list> }
}