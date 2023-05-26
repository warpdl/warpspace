# setup script
# This script is used to setup the workspace for WarpDL.
# 
# Requires: git, powershell 5.0 or higher
#Requires -Version 5.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OrgUrl = 'https://github.com/warpdl',
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$WarpLibPath = 'warplib',
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$WarpCorePath = 'warp'
)

# This function gets called whenever the specified directory by user already
# exists, so we ask them what to do exactly.
function Show-ExistingSetupOptions {
    Write-Host "Select an option from the following:" -ForegroundColor "Green"
    Write-Host "1 - Setup a new one with some other name"
    Write-Host "2 - Delete existing and setup a new one"
    Write-Host "3 - Git pull in the existing directory"
    Write-Host "4 - Exit program"
    Write-Host "Default: 3" -ForegroundColor "Gray"

    return (Read-Host "Enter your option")
}

# This function will clone a certain repository from the specified URL to the
# specified path.
function Invoke-GitClone {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [Parameter(Mandatory = $false)]
        [string]$Path
    )

    Write-Verbose "Cloning from '$Url' to '$Path'..."
    & git clone $Url $Path --progress 2>&1
}

# This function will simply run git pull command (in the current pwd).
# It does not accept any input parameters, nor does it care about the output.
function Invoke-GitPull {
    Write-Verbose "Running git pull"
    & git pull 2>&1
}

# This function just simply calls Invoke-GitClone inside of its body.
# The only difference is that RepoPath parameter here is mandatory, so if
# user doesn't specify it, it will prompt them to enter its value.
function Invoke-AskAndClone {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepoPath,
        [Parameter(Mandatory = $true)]
        [string]$RepoUrl
    )

    return Invoke-GitClone -Url $RepoUrl -Path $RepoPath
}

# This function should be called when the target directory that has been chosen
# by user already exists. It will ask them what to do exactly.
function Get-DirExistSelectOption {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DirPath
    )

    $dirName = Split-Path -Path $DirPath -Leaf
    $local:repo = "$OrgUrl/$dirName"
    Write-Host "Directory $DirPath already exists!"
    switch ((Show-ExistingSetupOptions)) {
        1 {
            Invoke-AskAndClone -RepoPath (Read-Host "Enter alternative name") -RepoUrl $local:repo
        }
        2 {
            Write-Verbose "Deleting previous $DirPath directory..."
            Remove-Item -Path $DirPath -Force -Recurse
            Invoke-GitClone -Url $local:repo -Path $DirPath
        }
        {[string]::IsNullOrEmpty($_) -or $_ -eq 3} {
            $local:originalPWD = $PWD
            Set-Location -Path $DirPath
            Invoke-GitPull
            Set-Location -Path $local:originalPWD
        }
        4 {
            Write-Host "Exiting!"
            exit 0
        }

        Default {}
    }
}

# This function invokes the setup steps necessary for a certain repository.
function Invoke-SetupRepo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DirPath,
        [Parameter(Mandatory = $true)]
        [string]$SetupName
    )
    
    Write-Verbose "Setting up $SetupName"
    if ([System.IO.Directory]::Exists($DirPath)) {
        Get-DirExistSelectOption -DirPath $DirPath
    }
    else {
        Invoke-GitClone -Url "$OrgUrl/$(Split-Path -Path $DirPath -Leaf)" -Path $DirPath
    }
}

Write-Host "WarpDL Workspace Utility" -ForegroundColor Green
Start-Sleep -Milliseconds 600

Invoke-SetupRepo -SetupName "WarpLib" -DirPath $WarpLibPath
Start-Sleep -Milliseconds 600

Invoke-SetupRepo -SetupName "Warp Core" -DirPath $WarpCorePath
Start-Sleep -Milliseconds 600

Write-Verbose "Downloaded all the required repositories!"

Write-Verbose "Creating a go workspace..."
& go work init 2>&1

Write-Verbose "Adding all the required repositories to workspace..."
& go work use $WarpCorePath $WarpLibPath 2>&1

Write-Verbose "Successfully setup workspace!"
