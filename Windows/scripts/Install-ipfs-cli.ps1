<#
    .SYNOPSIS
    Download the latest release windows 64 bit binary of the IPFS Kubo CLI.

    .DESCRIPTION
    The following script automates the download and extraction of the latest windows 64 bit version of the Kubo CLI. Additionally, the User system environment 
    Path variable is updated to invoke ipfs.exe tool. 
    
    .NOTES
	Version:        0.1
	Author:         Seth Docherty
	Creation Date:  09/28/2023
	
    - By default, the payload will be extracted to the IPFS folder under your User folder: C:\Users\<user name>\IPFS. 
    To override, change the param, destFolder, below.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> ./install-ipfs-cli.ps1

    .LINK
    Kubo CLI: https://github.com/ipfs/kubo
#>

###########
# FUNCTIONS
###########

<#
.SYNOPSIS
Downloads and extracts a payload from a given URL to a specified destination folder.

.PARAMETER downloadUrl
The URL of the payload to download.

.PARAMETER destFolder
The destination folder to extract the payload to.
#>
function DownloadAndExtractPayload {
    param(
        [string]$downloadUrl,
        [string]$destination_folder
    )

    Write-Host "Found the latest Windows 64 binary, Downloading payload....." -ForegroundColor Green
    $fileName = $downloadUrl.Split("/")[-1]
    Invoke-Webrequest -Uri $downloadUrl -OutFile "${env:temp}\$fileName" -Headers @{'Accept' = 'application/octet-stream' }

    Write-Host "Extracting payload to $destination_folder....." -ForegroundColor Green
    Expand-Archive -Path "${env:temp}\$fileName" -DestinationPath $destination_folder -Force

    # Delete the downloaded zip file after it's been extracted
    Remove-Item -Path "${env:temp}\$fileName" -Force
}


# Github parameters
$ownerName = "ipfs"
$repoName = "kubo"
$tag = "latest"
$binary_tag = "windows-amd64.zip"

# Content will be saved to User Folder be default.
$destFolder = "${env:USERPROFILE}\$ownerName"

Write-Host "Navigating to https://github.com/ipfs/kubo to download the latest Windows release....." -ForegroundColor Green

$json = Invoke-Webrequest -Uri "https://api.github.com/repos/$ownerName/$repoName/releases/$tag" -Headers @{'Accept' = 'application/json' } -UseBasicParsing
$release = $json.Content | ConvertFrom-Json

# NOTE: we only return the first asset that matches our binary tag
$asset = $release.assets | Where-Object { $_.browser_download_url -like "*$binary_tag" }

# Check if the specific binary tag were looking for returns anything
if ($null -eq $asset) {
    Write-Host "No assets were found that match the tag, $binary_tag."  -ForegroundColor Yellow
    Pause
    Exit
}

# Check if IPFS CLI is already installed
try {
    Get-Command ipfs -ErrorAction Stop > $null
    $aliasExists = $true
}
catch {
    $aliasExists = $false
}


if ($aliasExists) {
    # Run ipfs --version command and save version to variable
    # NOTE: running the command ipfs --version returns a string with the following format: "ipfs version <version number>" so we need to split the string and grab the 3rd element
    $ipfs_version = (ipfs --version | Out-String).Split(" ")[2].TrimEnd()
    if ($asset.name -like "*$ipfs_version*") {
        Write-Host "The latest version (Version $ipfs_version) of the IPFS CLI is already installed. You should already be able to invoke the `ipfs` command" -ForegroundColor Green
        Pause
        Exit
    }
    else {
        Write-Host "The latest version of the IPFS CLI is not installed. Lets fix that..." -ForegroundColor Yellow
        DownloadAndExtractPayload $asset.browser_download_url $destFolder
    }
}
else {
    Write-Host "IPFS appears to not be installed.  Lets fix that..." -ForegroundColor Yellow
    DownloadAndExtractPayload $asset.browser_download_url $destFolder
}
# Update User Environment Path Variable.
Write-Host "Checking if the IPFS CLI path exists in the USER Environment Path Variable......" -ForegroundColor Green

# Check if PowerShell profile has been created
if (!(Test-Path -Path $profile)) {
    Write-Host "No PowerShell profile exists. Creating one now....." -ForegroundColor Yellow
    New-Item -Path $profile -ItemType File
}

# Check if the IPFS CLI path exists in the PowerShell Profile $PROFILE
$path_check = Get-Content -Path $profile | Select-String -Pattern "$destFolder\$repoName".Replace("\", "\\")

# if path_check is null, then we need to add the path to the PowerShell Profile
if ($null -eq $path_check) {
    Write-Host "Kubo CLI path was not found. Adding it now to the PowerShell Profile....." -ForegroundColor Yellow
    Add-Content $PROFILE "`n[System.Environment]::SetEnvironmentVariable('PATH',`$Env:PATH+';;$destFolder\$repoName')"
    Add-Content $PROFILE "`n# Create aliases for frequently used commands"
    Add-Content $PROFILE "`nSet-Alias ipfs ipfs.exe"
}
else {
    Write-Host "Found the IPFS CLI path. You should already be able to invoke the `ipfs` command in PowerShell" -ForegroundColor Green
}
        
# Check if the IPFS CLI path exists in the User Environment Path Variable
$PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"
$kubo_cli_path = [Environment]::GetEnvironmentVariable($variableName, "User")
$path_check = $PathParts.Where{ $_ -eq "$destFolder\kubo" }

if ($PathParts -contains "$destFolder\kubo") {
    Write-Host "Found the IPFS CLI path. You should already be able to reference `ipfs` from the USER Environment PATH Variable." -ForegroundColor Green
}
else {
    Write-Host "Kubo CLI path was not found in USER Environment PATH Variable. Adding it now..." -ForegroundColor Yellow
    # Append new path to existing list of paths as not to overwrite
    $PathParts += "$destFolder\$repoName"
    $updatedPath = $PathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $updatedPath, "User")
}

Write-Host "Finished installing the IPFS CLI. After restarting your shell session You should already be able to invoke the `ipfs` command" -ForegroundColor Green

Pause
Exit
