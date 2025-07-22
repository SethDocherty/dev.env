#!/bin/bash

# Check if .bash_aliases file exists, if not create it
if [ ! -f ~/.bash_aliases ]; then
    touch ~/.bash_aliases
fi

# Check if .profile file exists, if not create it
if [ ! -f ~/.profile ]; then
    touch ~/.profile
fi

# Check if ~/.local/bin is in PATH, if not add it
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
fi

# Install pyenv
curl https://pyenv.run | bash

# Install the following so that pyenv can build the binary for the python version you want to install
sudo apt update;sudo apt install build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

echo "" >> ~/.profile
echo "# pyenv settings" >> ~/.profile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init --path)"' >> ~/.bashrc

# Install poetry
curl -sSL https://install.python-poetry.org | python3 -

# Enable autocompletion for poetry
poetry completions bash >> ~/.bash_completion
echo "" >> ~/.profile
echo "# Poetry settings" >> ~/.profile
echo 'export PATH="~/.local/share/pypoetry/venv/bin/:$PATH"' >> ~/.profile

# Add alias commands
#alias gs="git status"

# Install mcfly
#  if the current user doesn't have permissions to edit /usr/local/bin, then use sudo sh -s
sudo curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly

# Add the following to your .bash_aliases file
echo "" >> ~/.bashrc
echo "# Mcfly settings" >> ~/.bashrc
echo "eval \"\$(mcfly init bash)\"" >> ~/.bashrc
echo "export MCFLY_FUZZY=2" >> ~/.bashrc
echo "export MCFLY_RESULTS=25" >> ~/.bashrc
echo "export MCFLY_INTERFACE_VIEW=BOTTOM" >> ~/.bashrc
echo "export MCFLY_RESULTS_SORT=LAST_RUN" >> ~/.bashrc
echo "export MCFLY_HISTORY_LIMIT=10000" >> ~/.bashrc

# Create .bash_history file if it doesn't exist in the user home directory
if [ ! -f ~/.bash_history ]; then
    touch ~/.bash_history
fi

# Install ohmyposh
sudo curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d "$HOME/.local/bin"
# binary is installed in ~/.local/bin/oh-my-posh so ensure that you add
# export POSH="$HOME/.local/bin/oh-my-posh" to your .bashrc file
# and then add eval "$($POSH init bash --config /mnt/c/Users/<user-name>/.config/profile/custom-theme.json)"
echo "" >> ~/.bashrc
echo "# OhMyPosh settings" >> ~/.bashrc
echo "export POSH=\"$HOME/.local/bin/oh-my-posh\"" >> ~/.bashrc
echo "# if you are using WSL, and want to use the custom theme, uncomment the" >> ~/.bashrc
echo "# following line and to set the username or modify the filepath if necessary" >> ~/.bashrc
echo "#eval \"\$(\$POSH init bash --config /mnt/c/Users/<enter-windows-username>/.config/profile/custom-theme.json)\"" >> ~/.bashrc

# Download and install Singularity
mkdir -p singularity
curl -L -O https://github.com/data-preservation-programs/singularity/releases/download/v0.6.0-RC2/singularity_0.6.0-RC2_linux_amd64.tar.gz
tar -xzf singularity_0.6.0-RC2_linux_amd64.tar.gz -C singularity
cd singularity
chmod +x singularity
mv singularity ~/.local/bin/

# delete the singularity directory and tarball
cd ..
rm -rf singularity
singularity_0.6.0-RC2_linux_amd64.tar.gz

# Install kubo
curl -sSL https://dist.ipfs.tech/kubo/v0.36.0/kubo_v0.36.0_linux-amd64.tar.gz | tar -xvz 
