# push script
# This script file is supposed to do git add, commit and push operations
# in the specified locations.
# 
# Requires: git, powershell 5.0 or higher
#Requires -Version 5.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
    [string]$Message = $null,
    [Parameter(Mandatory = $false)]
    [string[]]$Target = @("warpdl", "warplib")
)

function Invoke-GitOperation {
    & git add .
    if (![string]::IsNullOrEmpty($Message)) {
        
        & git commit -am $Message
    }
    else {
        & git commit
    }
    
    & git push
}

if ($Target.Count -ne 0) {
    $script:originalPWD = $PWD
    for ($i = 0; $i -lt $Target.Count; $i++) {
        try {
            $Target[$i] = Resolve-Path -Path $Target[$i] -ErrorAction "Stop"
        }
        catch {
            Write-Output "Couldn't resolve location '$($Target[$i])'"
            $Target[$i] = ''
            continue
        }
    }

    foreach ($currentTargetPath in $Target) {
        Set-Location -Path $currentTargetPath > $null
        Invoke-GitOperation
    }

    Set-Location -Path $script:originalPWD > $null
}
else {
    # just do it here
    Invoke-GitOperation
}
