# This script is intended to be run after a fresh installation of Windows.
# It's expected that the necessary apps and tools have already been installed via the winget manifest installer.

# installing PowerShell modules
Install-Module PSReadLine -AllowPrerelease -Force
# Install-Module WslInterop -Force # Integrate Linux commands into Windows
Install-Module -Name Posh-Git -Force -AllowPrerelease -Scope CurrentUser

# Check if the following PowerShell modules are installed and install them if not and then import them
$modules = @("Terminal-Icons", "PSReadLine", "posh-git", "poshy-wrap-golang", "WslInterop")
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -Scope AllUsers
    }
    Import-Module -Name $module
}

# Install Mcfly for PowerShell
# In order to install McFly, you will need to have Rust installed on your system.
# which will require to install Visual Studo build tools: https://visualstudio.microsoft.com/visual-cpp-build-tools/
# See this link for install required components: https://rust-lang.github.io/rustup/installation/windows-msvc.html#installing-only-the-required-components-optional
# Once rust is installed you can run the following:
# git clone https://github.com/cantino/mcfly
# cd mcfly
# cargo install --path .

# Add McFly to your PowerShell profile 
Add-Content -Path $profilePath -Value "Invoke-Expression -Command $(mcfly init powershell | out-string)"

# Configure Git
if (-not (Test-Path "$HOME\.gitconfig")) {
    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"
    git config --global core.editor "code --wait"
}

# Set up Windows Subsystem for Linux (WSL)
wsl --install

# Install additional tools via WSL
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl sudo apt update && sudo apt install -y build-essential curl wget zsh
}

# Set up PowerShell profile
$profilePath = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force
}
Add-Content -Path $profilePath -Value "# Custom PowerShell profile settings"
Add-Content -Path $profilePath -Value "Set-Alias ll Get-ChildItem"

# install the latest version of singularity: https://github.com/data-preservation-programs/singularity
go install github.com/data-preservation-programs/singularity@latest


# Final message
Write-Host "Post-installation setup complete! Please restart your system." -ForegroundColor Green