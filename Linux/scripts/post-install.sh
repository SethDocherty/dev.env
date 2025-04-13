#!/bin/bash

# Check if .bash_aliases file exists, if not create it
if [ ! -f ~/.bash_aliases ]; then
    touch ~/.bash_aliases
fi
# Check if ~/.local/bin is in PATH, if not add it
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_aliases
fi

# Install pyenv
curl https://pyenv.run | bash

# Install the following so that pyenv can build the binary for the python version you want to install
sudo apt update;sudo apt install build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

echo "" >> ~/.bash_aliases
echo "# pyenv settings" >> ~/.bash_aliases
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_aliases
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_aliases
echo 'eval "$(pyenv init --path)"' >> ~/.bash_aliases

# Install poetry
curl -sSL https://install.python-poetry.org | python3 -

# Enable autocompletion for poetry
poetry completions bash >> ~/.bash_completion
echo "" >> ~/.bash_aliases
echo "# Poetry settings" >> ~/.bash_aliases
echo 'export PATH="~/.local/share/pypoetry/venv/bin/:$PATH"' >> ~/.bash_aliases

# Install mcfly
#  if the current user doesn't have permissions to edit /usr/local/bin, then use sudo sh -s
sudo curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly

# Add the following to your .bash_aliases file
echo "" >> ~/.bash_aliases
echo "# Mcfly settings" >> ~/.bash_aliases
echo "eval \"\$(mcfly init bash)\"" >> ~/.bash_aliases
echo "export MCFLY_FUZZY=2" >> ~/.bash_aliases
echo "export MCFLY_RESULTS=25" >> ~/.bash_aliases
echo "export MCFLY_INTERFACE_VIEW=BOTTOM" >> ~/.bash_aliases
echo "export MCFLY_RESULTS_SORT=LAST_RUN" >> ~/.bash_aliases
echo "export MCFLY_HISTORY_LIMIT=10000" >> ~/.bash_aliases

# Create .bash_history file if it doesn't exist in the user home directory
if [ ! -f ~/.bash_history ]; then
    touch ~/.bash_history
fi


# Install ohmyposh
sudo curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d "$HOME/.local/bin"
# binary is installed in ~/.local/bin/oh-my-posh so ensure that you add
# export POSH="$HOME/.local/bin/oh-my-posh" to your .bash_aliases file
# and then add eval "$($POSH init bash --config /mnt/c/Users/<user-name>/.config/profile/custom-theme.json)"
echo "" >> ~/.bash_aliases
echo "# OhMyPosh settings" >> ~/.bash_aliases
echo "export POSH=\"$HOME/.local/bin/oh-my-posh\"" >> ~/.bash_aliases
echo "# if you are using WSL, and want to use the custom theme, uncomment the" >> ~/.bash_aliases
echo "# following line and to set the username or modify the filepath if necessary" >> ~/.bash_aliases
echo "#eval \"\$(\$POSH init bash --config /mnt/c/Users/<enter-windows-username>/.config/profile/custom-theme.json)\"" >> ~/.bash_aliases


# Download and install singularity
mkdir -p singularity
curl -L -O https://github.com/data-preservation-programs/singularity/releases/download/v0.5.14/singularity_0.5.14_linux_amd64.tar.gz
tar -xzf singularity_0.5.14_linux_amd64.tar.gz -C singularity
cd singularity
chmod +x singularity
mv singularity ~/.local/bin/

# delete the singularity directory and tarball
cd ..
rm -rf singularity
rm singularity_0.5.13_linux_amd64.tar.gz


# Install kubo
curl -sSL https://dist.ipfs.tech/kubo/v0.28.0/kubo_v0.28.0_linux-amd64.tar.gz | tar -xvz 
