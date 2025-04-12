<#
    .SYNOPSIS
    Automate the installation of Windows applications from one or more app manifests using the native package manager, WinGet. 

    .DESCRIPTION
    The following script automates the installation of applications that are specified by different themed app manifest JSON files.  Each manifest 
    contains a `winget` section that lists all the `PackageIdentifier` names of applications to be installed. 
    
    .NOTES
	Version:        0.2
	Author:         Seth Docherty
	Creation Date:  06/28/2023
	
    - The manifest files were created to be used with WingetUI, an intuitive GUI to install, update, uninstall and manage packages from the most common 
    package managers for windows, such as Winget, Scoop, Chocolatey, Pip and NPM. I purposely built this script to automate the installation of winget
    sourced applications found in the manifests.
 
    - If this repo has not been locally downloaded, the script will grab the RAW json from each manifest's githubusercontent URL.

    - If you are using a custom manifest file, please provide the full path to the file.

    .PARAMETER manifest
    Specify the manifests that you would like to install as a comma separated string or full path to the file.
    
    NOTE: If nothing is specified, the core.json is referenced

    .INPUTS 
    None. You cannot pipe objects to InstallManifests.ps1.

    .OUTPUTS
    None. InstallManifests.ps1 does not generate any output.  

    .EXAMPLE
    PS> .\InstallManifests.ps1
    Running without the `-manifest` parameter`:
    ---> installs apps found in core.json
    
    .EXAMPLE
    PS> .\InstallManifests.ps1 -manifest 'core, dev'
    Running with the `-manifest` parameter with the core and dev manifest tags`
    ---> installs apps found in core.json and dev.json

    .EXAMPLE
    PS> .\InstallManifests.ps1 -manifest '<all/full>'
    Running with the `-manifest` parameter with the `all` or `full` tags
    ---> installs apps found in all manifest JSON files.

    .EXAMPLE
    PS> .\InstallManifests.ps1 -manifest "path\to\custom\manifest.json"
    Running with the `-manifest` with the full path to a custom manifest file
    ---> installs apps found in the custom manifest JSON file.
    ---> NOTE: The custom manifest file must be a valid JSON file. See the manifest files in this repo for examples.

    .LINK
    dev.env Repo: https://github.com/SethDocherty/dev.env/tree/main
	More info on this script: https://github.com/SethDocherty/dev.env/tree/main/Windows/Apps/
    Winget Overview: https://learn.microsoft.com/en-us/windows/package-manager/
    WingetUI Repo: https://github.com/marticliment/WingetUI
#>

# Default Parameters
param (
    [string]$manifest = "core",
    [switch]$help
)

# Display help content if -help is passed
if ($help) {
    Get-Help -Full $MyInvocation.MyCommand.Path
    exit
}

# If additional manifest files are created, please add file name to this list
# "all" and "full" tags are used to install all manifests.
$validManifests = "all", "full", "core", "dev", "device_apps", "other"

Function get_apps_from_manifest([string[]]$file_names, [bool[]]$customFilePath) {
    # Define the predefined JSON object
    $schema_version = "https://aka.ms/winget-packages.schema.2.0.json"
    $predefinedJson = @{
        '$schema' = $schema_version
        "WinGetVersion" = "1.5.1572"
        'Sources' = @()
    }
    
    [System.Array]$manifestSources = @()
    [System.Array]$manifest_packages = @()

    # Check if a filepath was provided as a custom manifest file.
    # If so, set the manifest path to the custom file path and set the file_names to the valid manifest names.
    if ($customFilePath) {
        # check if the file is a json file.
        if ($file_names[0] -notlike "*.json") {
            Write-Host "The custom manifest file is not valid. Please pass in a json file." -ForegroundColor Red
            Write-Host "exiting..." -ForegroundColor Red
            exit 1
        }
        $manifest_Path = Split-Path -Path $file_names[0] -Parent
        $file_names[0] = [System.IO.Path]::GetFileNameWithoutExtension($file_names[0])
        Write-Host "Custom manifest file ($file_names) provided. Using: $manifest_Path" -ForegroundColor Green
    }
    else {

        # Get the current directory
        $currentDirectory = Get-Location
        # Set the manifest path to the default path and set the file_names to the valid manifest names.
        $manifest_Path = Join-Path -Path $currentDirectory -ChildPath "manifest"

        # Determine the file names to process based on the manifest input parameter from the user.
        if ("all", "full" -in $file_names) {
            $file_names = Get-ChildItem -Path $manifest_Path -Filter "*.json" | ForEach-Object { $_.Name -replace ".json$" }
        }
    }

    foreach ($file_name in $file_names) {
        Write-Host "Processing manifest file: $file_name at path $manifest_Path" -ForegroundColor Green
        $jsonFile = Join-Path -Path $manifest_Path -ChildPath "${file_name}.json"
        $jsonObject = Process-ManifestFile -filePath $jsonFile

        # Extract the desired section and store it to our array
        $manifest_packages += $jsonObject.winget.Sources[0].Packages
        $manifestSources += $jsonObject.winget.Sources
    }

    # Return the predefinedJson with all the packages to be installed
    # Install any apps that contain custom arguments and Pipe return object through filter to remove any non "PSCustomObject" types.
    $non_custom_apps = custom_app_install -input_apps $manifest_packages | Where-Object { $_ -is [System.Management.Automation.PSCustomObject] }
    
    # Update the "Packages" key in `manifestSources`
    $manifestSources[0].Packages = $non_custom_apps  
    $predefinedJson.Sources = $manifestSources # | ConvertTo-Json -Depth 10
    return $predefinedJson
}


function Process-ManifestFile {
    param (
        [string]$filePath
    )

    # Read in the JSON file in the manifest folder
    if (Test-Path $filePath) {
        $jsonContent = Get-Content -Raw -Path $filePath
        # Convert JSON content to a PowerShell object
        $jsonObject = $jsonContent | ConvertFrom-Json
    }
    else {
        $fileName = Split-Path -Leaf $filePath -replace ".json$", ""
        Write-Host "Unable to find the app manifest for $fileName. Grabbing content from GitHub repo..." -ForegroundColor DarkYellow
        # Define the URL of the JSON file
        $jsonUrl = "https://raw.githubusercontent.com/SethDocherty/dev.env/main/Windows/Apps/manifest/$fileName.json"
        $jsonObject = Invoke-RestMethod -Uri $jsonUrl
    }

    # Return the JSON object
    return $jsonObject
}


function custom_app_install {
    param (
        [Parameter(Mandatory=$true)]
        [array]$input_apps 
    )

    $remaining_apps = @()

    foreach ($package in $input_apps) {
        # Find package with customArgs keys
        $custom_install = $package | Where-Object { $null -ne $_.customArgs}
        
        if ($custom_install) {
            # Run custom installation command using "customArgs" value
            $customArgs = $custom_install.customArgs
            Write-Host "Running custom installation for package: $($custom_install.PackageIdentifier)" -ForegroundColor Cyan
    
            # Run the custom installation command using winget
            winget install --id $custom_install.PackageIdentifier --exact --accept-source-agreements --disable-interactivity --accept-source-agreements --override $customArgs
            # winget install --id $custom_install.PackageIdentifier $customArgs

        }
        else {
            # Package doesn't have customArgs, add it to the remaining apps list
            $remaining_apps += $package
        }
    }
    # $remaining_apps.SourceDetails = $sourceDetails
    return $remaining_apps
}


<#
    -----------------------------------
    MAIN: Script Processing Starts Here
    -----------------------------------
#>

# Validate the input manifest values
# Treat input values as case-insensitive, trim any leading or trailing spaces and remove any empty strings.

$customFilePathFlag = $false
if (Test-Path $manifest) {
    Write-Host "Looks like you passed in a custom manifest files. Let's give it a try..." -ForegroundColor Green
    $customFilePathFlag = $true
    $selectedManifests = $manifest
}

if (-not $customFilePathFlag) {
    $selectedManifests = $manifest.Split(',').ToLower().Trim() | Where-Object { $_ -ne '' }
    $invalidManifests = $selectedManifests | Where-Object { $_ -notin $validManifests }

    if ($invalidManifests) {
        Write-Host "Invalid manifest values specified: $invalidManifests" -ForegroundColor Red
        Write-Host "`r`nValid names are: `r`n        $validManifests `r`nPlease check manifest names and try again." -ForegroundColor Red
        Write-Host "`nIf you are trying to use a custom manifest file, please provide the full path to the file." -ForegroundColor Red
        return
    }
}

# Call the get_apps_from_manifest function with the selected file names
$app_listing = get_apps_from_manifest -file_names $selectedManifests -customFilePath $customFilePathFlag
Write-Host "Preparing to Install $($app_listing.Sources[0].Packages.count) Packages....." -ForegroundColor Green

# Convert the hashtable object to JSON
$app_listing = $app_listing | ConvertTo-Json -Depth 10

# Temporary json file that contains only winget apps
# NOTE: File is saved to `C:\Users\<user name>\AppData\Local\Temp`
$winget_apps = "${env:temp}\winget_apps.json"

# Save the extracted section to the temporary file
$app_listing | Out-File -FilePath $winget_apps -Encoding UTF8

# Install apps
winget import --import-file $winget_apps --verbose --ignore-unavailable

# Delete the temporary file once done
Remove-Item -Path $winget_apps -Force

# Wait for user action to exit script and close console window.
# Note, if script is executed from an already open console, window does not close.
Write-Host "Press any key to close the window..."

while (-not [System.Console]::KeyAvailable) {
    Start-Sleep -Milliseconds 100
}

# Clear any queued key presses
while ([System.Console]::KeyAvailable) {
    $null = [System.Console]::ReadKey($true)
}
