# Overview

This section contains an assortment of tools and guides to aid in streamlining the process of installing and setting up applications within my Windows environment.

## Table of contents

[Automate the Installation of a Fresh Install](#automate-the-installation-of-a-fresh-install)

## Automate the Installation of a Fresh Install

Getting up and running with a fresh Windows reinstall or even setting up a VM for testing is a tedious and time consuming process when it comes to installing applications. Instead of the typical *"What applications did I have installed?"* conundrum, I've built JSON formatted manifests to track the applications I use. These manifests make it easier to automate the tedious installation process with the help of [Winget](https://github.com/microsoft/winget-cli), the Windows package manager.  The overall goal of the [**InstallManifests**](InstallManifests.ps1) PowerShell script is to avoid the process of manually reinstalling applications with a system that can quickly replicate my ideal suite of applications on a new machine.

### Running the Script

1. Clone **dev.env** repo down to your local machine if it hasn't already.
2. Open PowerShell and change the Current Working Directory (CWD) to the ***Apps*** folder.

   > **:eyes: ProTip**: You can open PowerShell directly from the *Apps* folder in File Explorer by typing *PowerShell* in the address bar or `Shift + Right Click` in File Explorer.
   >

3. Running the following command installs applications from `core.json` by default.

```PowerShell
.\InstallManifests.ps1
```

To install a specific manifest, use the `-manifest` parameter and the name of the manifest file.

```PowerShell
.\InstallManifests.ps1 -manifest 'dev'
```

Install apps found in two or more manifests by passing in a comma separated string.

```PowerShell
.\InstallManifests.ps1 -manifest 'core, dev'
```

Install apps found in all manifests by passing in the tags *all* or *full.*

```PowerShell
.\InstallManifests.ps1 -manifest 'all'
```

Additional details can be found by running:

```PowerShell
Get-Help ".\InstallManifests.ps1" -full
```

### Manifest Details

The manifests themselves are just trimmed down JSON exports from [WingetUI](https://github.com/marticliment/WingetUI) that contain applications installed on my local machine. Manifests can easily be organized into thematic flavors by modifying the **Packages** array within the Winget section of the exported JSON file. The *Packages* array is composed of one or more key/value structures where [PackageIdentifier](https://github.com/microsoft/winget-cli/blob/9200b51529978b3ae031edd5ca6d585625381eb5/schemas/JSON/packages/packages.schema.2.0.json#L76C19-L76C19) contains the unique ID used by the Windows Package Manager to identify an application. Optional properties such as **Version** can be added to specify the exact version to install and **customArgs** which uses the `--override` option to pass a string that's passed directly to the installer.

```json
{
  "Packages":[
    {
      "PackageIdentifier": "Microsoft.VisualStudioCode",
      "Version": "1.80.0",
      "customArgs": "/SILENT /mergetasks=\"!runcode,addcontextmenufiles,addcontextmenufolders\""
    }
  ]
}
```

> **Note**: While the **customArgs** property is not apart of the standard [winget schema](https://learn.microsoft.com/en-us/windows/package-manager/winget/import#json-schema), the script will automatically process any applications that contain this property. This provides the flexibility to customize the installation of an application with the  `--override` option.

For more info on the `--override` option, check out the following resources: [1](https://github.com/microsoft/winget-cli/discussions/1798), [2](https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2019#use-winget-to-install-or-modify-visual-studio), [3](https://www.techwatching.dev/posts/winget-override), [4](https://www.devjev.nl/posts/2022/getting-along-with-winget-advanced-installation/), [5](https://winaero.com/install-a-winget-app-with-custom-arguments-and-command-line-switches/), [6](https://learn.microsoft.com/en-us/windows/package-manager/package/manifest?tabs=minschema%2Cversion-example#installer-switches)

> **Note**: While **WingetUI** can import and install the application manifests, it currently does not have the ability to parse additional properties such as **Version** and pass in custom commands to the `--override` option. **WingetUI** comes into play as it wraps an easy to use GUI around the Winget package manager (and others such as Scoop, Chocolatey, and more) to easily download, install, update and uninstall software.
