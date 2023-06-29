# Overview

This section contains an assortment of tools and guides to aid in streamlining the process of installing and setting up applications within my Windows environment.

## Table of contents

[Automate the installation](#automate-the-installation)

## Automate the installation

Getting up and running with a fresh Windows reinstall or even setting up a VM for testing is a tedious and time consuming process when it comes to installing applications. Instead of the typical "Now what did I have installed?" conundrum and remembering everything that you previously were using (It's hard enough to keep up with all the eclectic apps I use), I've built JSON formatted manifests to keep things straight.  Additionally, these manifests make it easier to automate the tedious installation process with the help of [Winget](https://github.com/microsoft/winget-cli), the Windows package manager.  [WingetUI](https://github.com/marticliment/WingetUI) comes into play as it wraps an easy to use GUI around the Winget package manager (and others such as Scoop, Chocolatey, and more) to easily download, install, update and uninstall software.

The manifests themselves are just trimmed down exports from WingetUI of applications installed on my machine. I've done the manual labor of organizing into thematic flavors:

- **Core**
- **Dev**
- **Device Applications**
- **Other**

Since they are JSON formatted, I can easily extract the list of applications from the Winget section and automate the install with Winget.  While I could do this through WingetUI by importing the manifests, I personally want to use the flexibility of Winget's CLI features (*and in less clicks FTW*). The overall goal of the [**InstallManifests**](InstallManifests.ps1) PowerShell script is to avoid the process of manually reinstalling applications with a system that can quickly replicate my ideal suite of applications on a new machine.

### Running the Script

Assuming this repo has been pulled down, navigate to the ***Apps*** folder using PowerShell*.*

Running  `.\InstallManifests.ps1` will install applications from `core.json`.

To install a specific manifest, use the `-manifest` parameter and the name of the manifest file.

- Install apps found in `core.json` and `dev.json`: `.\InstallManifests.ps1 -manifest 'core, dev'`
- Install apps found in all manifests: `.\InstallManifests.ps1 -manifest '<all/full>'`

Additional details can be found by running `Get-Help ".\InstallManifests.ps1" -full`
