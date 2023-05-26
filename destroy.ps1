# destroy script
# This script file is used to destroy the workspace and other files
# made by push script.
# 
# Requires: git, powershell 5.0 or higher
#Requires -Version 5.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
    [string]$BasePath = '.'
)

if ([string]::IsNullOrEmpty($BasePath)) {
    $BasePath = '.'
}

$BasePath = $BasePath.TrimEnd('\')
Remove-Item -Path "$BasePath\warplib" -Recurse -Force -ErrorAction "SilentlyContinue"
Remove-Item -Path "$BasePath\warp" -Recurse -Force -ErrorAction "SilentlyContinue"
Remove-Item -Path "$BasePath\go.work" -Recurse -Force -ErrorAction "SilentlyContinue"

Write-Output "Destroyed WarpDL Workspace!"
