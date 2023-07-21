<#
    .SYNOPSIS
    Downloads and installs pyenv-win and poetry to help manage your python development environment.

    .DESCRIPTION
    The following script automates the download, installation and configuration of your system environment variables for pyenv-win and poetry
    
    .NOTES
	Version:        0.1
	Author:         Seth Docherty
	Creation Date:  12/08/2022
	
    - Depending on your machines `Execution Policy`, you may run into issues downloading necessary files through the Invoke-WebRequest command. I try handling this
    but I cannot guarantee it will work 100% of the time.
    
    - The pyenv-win installation file is downloaded to to ${env:APPDATA} and is deleted after installation.

    - If you are running Windows 10 1905 or newer, you might need to disable the built-in Python launcher via Start > "Manage App Execution Aliases" and turning off 
    the "App Installer" aliases for Python. I try handling this by deleting the python.exe Microsoft Store shortcut I cannot guarantee it will work 100% of the time.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> setup_python_development_env.ps1

    .LINK
    Pyenv-Win Site: https://pyenv-win.github.io/pyenv-win/
	Poetry Site: https://python-poetry.org/
#>

$default_install_version = "3.9.13"
$install_version = ''
$Poetry_exe = "${env:APPDATA}\Python\Scripts"

### Splash Screen Messages
$msg_header = @'
  __          __  _                          _                                                            
  \ \        / / | |                        | |                                                           
   \ \  /\  / /__| | ___ ___  _ __ ___   ___| |                                                           
    \ \/  \/ / _ \ |/ __/ _ \| '_ ` _ \ / _ \ |                                                           
     \  /\  /  __/ | (_| (_) | | | | | |  __/_|                                                           
      \/  \/ \___|_|\___\___/|_| |_| |_|\___(_)                                                           
-------------------------------------------------                                                                                                                                                                                                                                                                                        
'@

$msg_pyenv_install = @'
 _____           _        _ _ _                _____                                       _             
|_   _|         | |      | | (_)              |  __ \                                     (_)            
  | |  _ __  ___| |_ __ _| | |_ _ __   __ _   | |__) |   _  ___ _ ____   __________      ___ _ __        
  | | | '_ \/ __| __/ _` | | | | '_ \ / _` |  |  ___/ | | |/ _ \ '_ \ \ / /______\ \ /\ / / | '_ \       
 _| |_| | | \__ \ || (_| | | | | | | | (_| |  | |   | |_| |  __/ | | \ V /        \ V  V /| | | | |_ _ _ 
|_____|_| |_|___/\__\__,_|_|_|_|_| |_|\__, |  |_|    \__, |\___|_| |_|\_/          \_/\_/ |_|_| |_(_|_|_)
                                       __/ |          __/ |                                              
                                      |___/          |___/                                               

'@

$msg_poetry_install = @'
 _____           _        _ _ _                _____           _                                         
|_   _|         | |      | | (_)              |  __ \         | |                                        
  | |  _ __  ___| |_ __ _| | |_ _ __   __ _   | |__) |__   ___| |_ _ __ _   _                            
  | | | '_ \/ __| __/ _` | | | | '_ \ / _` |  |  ___/ _ \ / _ \ __| '__| | | |                           
 _| |_| | | \__ \ || (_| | | | | | | | (_| |  | |  | (_) |  __/ |_| |  | |_| |_ _ _                      
|_____|_| |_|___/\__\__,_|_|_|_|_| |_|\__, |  |_|   \___/ \___|\__|_|   \__, (_|_|_)                     
                                       __/ |                             __/ |                           
                                      |___/                             |___/                            

'@

$msg_overview = @"
This script prepares your python environment by automating the download, installation and configuration of your system environment with pyenv-win and poetry.

Following the installation of the tools you will find details about about your python development environment.

"@

$msg_finish = @'
 ______ _       _     _              _ _ 
|  ____(_)     (_)   | |            | | |
| |__   _ _ __  _ ___| |__   ___  __| | |
|  __| | | '_ \| / __| '_ \ / _ \/ _` | |
| |    | | | | | \__ \ | | |  __/ (_| |_|
|_|    |_|_| |_|_|___/_| |_|\___|\__,_(_)

'@

#-----------------------------------


Function Install_pyenv() {
    $PyEnvDir = "${env:USERPROFILE}\.pyenv"
    if (Test-Path $PyEnvDir) {
        Write-Host "pyenv-win has already been installed to your system.  Checking for updates....."  -ForegroundColor Green
        powershell.exe -File "$PyEnvDir\pyenv-win\install-pyenv-win.ps1"
    }
    else {
		
        # Check Execution Policy to ensure user can download and install script.
        $policy = Get-ExecutionPolicy
        if ($policy -ne "RemoteSigned") {
            Write-Warning -Message 'Set-ExecutionPolicy is not set to RemoteSigned. If you are getting any UnauthorizedAccess error, start 
		a new PowerShell session with the "Run as administrator" option to run the following command and then re-run script.'

            Write-Host "    ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`r`n" -ForegroundColor Green
            Write-Output "For more info, please refer to this following link: https://github.com/pyenv-win/pyenv-win/issues/332"
            Write-Host "To save you time, let's try to run the command now to keep things moving"
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
        }
        # Download installation script from pyenv-win repo
        Write-Host "Installing pyenv since it does not exist on your system."  -ForegroundColor Green
        Invoke-WebRequest -UseBasicParsing  -ErrorAction Stop -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "${env:APPDATA}/install-pyenv-win.ps1"; & "${env:APPDATA}/install-pyenv-win.ps1"
        Remove-Item -Path "${env:APPDATA}/install-pyenv-win.ps1"
        refresh_env
    }
}


Function install_python_version([string]$python_version) {
    $get_version_list = pyenv install --list
    if ($get_version_list -like "*$($python_version)*") {
        Write-Host "Installing $($python_version)....." -ForegroundColor Green
        pyenv install $python_version
        pyenv rehash
    }
    else {
        Write-Error -Message "The installer for version $($python_version) was not found. See all available versions by running the command 'pyenv install --list'." -ErrorAction Stop -Category InvalidData
    }
}


Function refresh_env() {
    Write-Host "Refreshing session with latest environment variables."
    $Env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

<#
    -----------------------------------
    MAIN: Script Processing Starts Here
    -----------------------------------
#>
# Remove culprit python.exe files which are shortcut commands to install python from the Microsoft Store.
# See this link for more info: https://stackoverflow.com/questions/58754860/cmd-opens-windows-store-when-i-type-python
Remove-Item $env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\python*.exe

# Run install_pyenv function
Write-Host $msg_header -ForegroundColor Green
Write-Host $msg_overview -ForegroundColor White
Write-Host $msg_pyenv_install -ForegroundColor Green
Install_pyenv

# Get input from user. This is optional
Write-Host -NoNewLine "Enter Python version to install otherwise press enter to skip (Default version is $($default_install_version)): " -ForegroundColor Green
$input_python_version = Read-host
if ($input_python_version -eq '' -or
$input_python_version -eq $false ) {
    $install_version = $default_install_version
}
else {
    $install_version = $input_python_version
}

# Check for Python versions and install
$get_pyenv_versions = pyenv versions
if ($null -eq $get_pyenv_versions) { 
    Write-Host "First time installing python through pyenv-win." -ForegroundColor Magenta
    install_python_version($install_version)
    Write-Host "Setting $install_version as the global python version" -ForegroundColor Magenta
    pyenv global $install_version
}
elseif ($get_pyenv_versions -notlike "*$($install_version)*" ) {
    install_python_version($install_version)
}
else {
    Write-Host "$($install_version) is already installed. Skipping installation" -ForegroundColor Yellow
}

# Install Poetry
Write-Host $msg_poetry_install -ForegroundColor Green
(Invoke-WebRequest -ErrorAction Stop -Uri https://install.python-poetry.org -UseBasicParsing).Content  | python - 

# Remove existing paths, so we don't add duplicates
Write-Host "Don't worry, were going to ensure that the `poetry` command has been added to your 'PATH' environment variable settings." -ForegroundColor Cyan
$PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"
$path_check = $PathParts.Where{ $_ -eq $Poetry_exe }
if ($path_check.count -eq 0) {
    $PathParts += $Poetry_exe
    $NewPath = $PathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "User")      
}
refresh_env

# Print some helpful details for the user
Write-Host "Finished installing pyenv-win and Poetry. Your python development environment is now ready." -ForegroundColor Green
Write-Host "`r`n     Details about the global python interpreter:" -BackgroundColor Blue
Write-Host "Global Python interpreter is set to $(pyenv global)
Full path to python.exe: $(pyenv which python)" -ForegroundColor Cyan
Write-Host "`r`nThe versions of python currently installed:
$(pyenv versions)" -ForegroundColor Cyan
Write-Host "`r`n     Learn more about the pyenv-win CLI by running the 'pyenv help' command." -BackgroundColor Blue
pyenv help | Write-Host -ForegroundColor Cyan
Write-Host "`r`n     Details about your Poetry Installation:" -BackgroundColor Blue
poetry about | Write-Host -ForegroundColor Cyan
Write-Host "`r`nPoetry settings can be configured via the CLI with the 'poetry config' command or manually via the config.toml file found at $("${env:APPDATA}\pypoetry"))
Here's a list of the current configuration:`r`n" -ForegroundColor Cyan
poetry config --list | Write-Host -ForegroundColor Cyan
Write-Host "`r`n     Learn more about the poetry CLI by running the 'poetry list' command." -BackgroundColor Blue
poetry list | Write-Host -ForegroundColor Cyan
pause