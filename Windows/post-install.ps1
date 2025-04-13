# This script is intended to be run after a fresh installation of Windows.
# It's expected that the necessary apps and tools have already been installed via the winget manifest installer.


# install the latest version of singularity: https://github.com/data-preservation-programs/singularity
go install github.com/data-preservation-programs/singularity@latest




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

# Final message
Write-Host "Post-installation setup complete! Please restart your system." -ForegroundColor Green