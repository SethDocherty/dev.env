<#
    .SYNOPSIS
    Automate the installation of Windows applications from one or more app manifests using the native package manager, WinGet. 

    .DESCRIPTION
    The following script automates the installation of applications that are specified by different themed app manifest JSON files.  Each manifest 
    contains a `winget` section that lists all the `PackageIdentifier` names of applications to be installed. 
    
    .NOTES
	Version:        0.1
	Author:         Seth Docherty
	Creation Date:  06/28/2023
	
    - The manifest files were created to be used with WingetUI, an intuitive GUI to install, update, uninstall and manage packages from the most common 
    package managers for windows, such as Winget, Scoop, Chocolatey, Pip and NPM. I purposely built this script to automate the installation of winget
    sourced applications found in the manifests.
 
    - If this repo has not been locally downloaded, the script will grab the RAW json from each manifest's githubusercontent URL.

    .PARAMETER manifest
    Specify the manifests that you would like to install as a comma separated string. 
    
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

    .LINK
    dev.env Repo: https://github.com/SethDocherty/dev.env/tree/main
	More info on this script: https://github.com/SethDocherty/dev.env/tree/main/Windows/Apps/
    Winget Overview: https://learn.microsoft.com/en-us/windows/package-manager/
    WingetUI Repo: https://github.com/marticliment/WingetUI
#>

# Default Parameters
param (
    [string]$manifest = "core"
)

# If additional manifest files are created, please add file name to this list
# "all" and "full" tags are used to install all manifests.
$validManifests = "all", "full", "core", "dev", "device_apps", "other"

Function get_apps_from_manifest([string[]]$file_names) {
    # Define the predefined JSON object
    $schema_version = "https://aka.ms/winget-packages.schema.2.0.json"
    $predefinedJson = @{
        '$schema' = $schema_version
        "CreationDate" = "2023-06-26 14:54:28.455066"
        "WinGetVersion" = "1.5.1572"
        'Sources' = @()
    }
    
    [System.Array]$manifestSources = @()
    [System.Array]$manifest_packages = @()

    # Get the current directory
    $currentDirectory = Get-Location

    # Building out the manifest folder path.
    $manifest_Path = Join-Path -Path $currentDirectory -ChildPath "manifest"

    # Determine the file names to process based on the manifest input parameter from the user.
    if ("all", "full" -in $file_names) {
        $file_names = Get-ChildItem -Path $manifest_Path -Filter "*.json" | ForEach-Object { $_.Name -replace ".json$" }
    }

    foreach ($file_name in $file_names) {
        # Read in the JSON file in the manifest folder
        $jsonFile = Join-Path -Path $manifest_Path -ChildPath "${file_name}.json"

        if (Test-Path $jsonFile) {
            $jsonContent = Get-Content -Raw -Path $jsonFile
            # Convert JSON content to a PowerShell object
            $jsonObject = $jsonContent | ConvertFrom-Json
        }
        else {
            Write-Host "Unable to find the app manifest for $file_name.  Grabbing content from github repo....."  -ForegroundColor DarkYellow
            # Define the URL of the JSON file
            $jsonUrl = "https://raw.githubusercontent.com/SethDocherty/dev.env/main/Windows/Apps/manifest/$file_name.json"
            $jsonObject = Invoke-RestMethod -Uri $jsonUrl
        }
        # Extract the desired section and store it to our array
        $manifest_packages += $jsonObject.winget.Sources[0].Packages
    
        # Add the extracted section to the "Sources" array
        # $predefinedJson.Sources += $packages
        # $manifest_packages += $packages
    }

    # Add SourceDetails Key/Value. Using last one in to populate e.g. using SourceDetails from last file referenced.
    $manifestSources.SourceDetails = $jsonObject.winget.Sources.SourceDetails

    # Return the predefinedJson with all the packages to be installed
    # Install any apps that contain custom arguments
    $tmp = custom_app_install -input_apps $manifest_packages
    $predefinedJson.Sources = $manifestSources# | ConvertTo-Json -Depth 10
    return $predefinedJson
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
$selectedManifests = $manifest.Split(',').ToLower().Trim() | Where-Object { $_ -ne '' }
$invalidManifests = $selectedManifests | Where-Object { $_ -notin $validManifests }

if ($invalidManifests) {
    Write-Host "Invalid manifest values specified: $invalidManifests" -ForegroundColor Red
    Write-Host "`r`nValid names are: `r`n        $validManifests `r`nPlease check manifest names and try again." -ForegroundColor Red
    return
}

# Call the get_apps_from_manifest function with the selected file names
$app_listing = get_apps_from_manifest -file_names $selectedManifests
Write-Host "Preparing to Install $($app_listing.Sources[0].Packages.count) Packages....." -ForegroundColor Green

# Convert the hashtable object to JSON
$app_listing = $app_listing | ConvertTo-Json -Depth 10

# Temporary json file that contains only winget apps
# NOTE: File is saved to `C:\Users\<user name>\AppData\Local\Temp`
$winget_apps = "${env:temp}\winget_apps.json"

# Save the extracted section to the temporary file
$app_listing | Out-File -FilePath $winget_apps -Encoding UTF8

# Install apps
winget import --import-file $winget_apps

# Delete the temporary file once done
Remove-Item -Path $winget_apps -Force
