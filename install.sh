#!/usr/bin/env bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
# It also installs the system programming essentials for myself
# It installs all the packages I need for my development environment
############################

# shellcheck source=SCRIPTDIR/scripts/latest-git-release.sh
source scripts/latest-git-release.sh

# shellcheck source=/dev/null

GREEN='\e[32m'
NC='\e[0m'

# Setup Dotfiles
echo -e "\n${GREEN}Creating symlinks for dotfiles...${NC}"
cp -rsTvf ~/dotfiles/dot ~/

# Check if curl is installed, if not install it
type -p curl >/dev/null || sudo apt install curl -y

# Check if xargs is installed, if not install it
type -p xargs >/dev/null || sudo apt install xargs -y

# Install apt packages
echo -e "\n${GREEN}Setting Up APT Packages...${NC}"
xargs sudo apt install -y < lists/apt-packages.txt

# Install onefetch https://github.com/o2sh/onefetch
sudo add-apt-repository ppa:o2sh/onefetch
sudo apt-get update
sudo apt install onefetch

# Install or update nvm
./scripts/install-nvm.sh
source ~/.bashrc

# Install docker and docker-compose
# ? This will require a reboot for the user to be added to the docker group
./scripts/install-docker.sh

# Install rbenv and latest ruby
if ! command -v rbenv &> /dev/null
then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  mkdir -p "$(rbenv root)"/plugins
  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
  git clone https://github.com/rbenv/rbenv-vars.git "$(rbenv root)"/plugins/rbenv-vars
  rbenv install 3.3.3 --verbose
  rbenv global 3.3.3
  gem install rails bundler prettier_print syntax_tree syntax_tree-haml syntax_tree-rbs rainbow
fi

# Install Deno
if ! command -v deno &>/dev/null; then
  echo -e "\n${GREEN}Installing Deno...${NC}"
  curl -fsSL https://deno.land/install.sh | sh &&
    export DENO_INSTALL="$HOME/.deno" &&
    export PATH="$DENO_INSTALL/bin:$PATH"
fi

# install gh cli
if ! command -v gh &>/dev/null; then
  echo -e "\n${GREEN}Installing GitHub CLI...${NC}"
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo apt update &&
    sudo apt install gh -y &&
    gh extension install mislav/gh-license
fi

# install vs code
if ! command -v code &>/dev/null; then
  echo -e "\n${GREEN}Installing VS Code...${NC}"
  sudo apt-get install wget gpg &&
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg &&
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &&
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &&
    rm -f packages.microsoft.gpg &&
    sudo apt install apt-transport-https &&
    sudo apt update &&
    sudo apt install code
fi

# install remmina
if ! command -v remmina &>/dev/null; then
  echo -e "\n${GREEN}Installing Remmina...${NC}"
  sudo apt-add-repository ppa:remmina-ppa-team/remmina-next &&
    sudo apt update &&
    sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret
fi

# install obs studio
if ! command -v obs &>/dev/null; then
  echo -e "\n${GREEN}Installing OBS Studio...${NC}"
  sudo add-apt-repository ppa:obsproject/obs-studio
  sudo apt update
  sudo apt install ffmpeg obs-studio
fi

# install postman
if ! command -v postman &>/dev/null; then
  echo -e "\n${GREEN}Installing Postman...${NC}"
  curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh &&
    source ~/.bashrc
fi

# install anydesk
if ! command -v anydesk &>/dev/null; then
  echo
  read -p "Do you want to install AnyDesk (y/n)? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${GREEN}Installing AnyDesk...${NC}"
    curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
    echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
    sudo apt -qq update
    sudo apt -qq install -y anydesk
  fi
fi

# install mongodb server
if ! command -v mongod &>/dev/null; then
	echo -e "\n${GREEN}Installing MongoDB Server...${NC}"
	wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add - &&
		echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list &&
		sudo apt -qq update &&
		sudo apt -qq install -y mongodb-org &&
		sudo systemctl daemon-reload &&
		sudo systemctl start mongod
fi

# install mongodb compass
if ! command -v mongodb-compass &>/dev/null; then
  echo -e "\n${GREEN}Installing MongoDB Compass...${NC}"
  repo="mongodb-js/compass" &&
    tag="$(latest_git_release "$repo")" &&
    version="${tag:1}" &&
    wget -q --show-progress "https://github.com/${repo}/releases/download/${tag}/mongodb-compass_${version}_amd64.deb" -O compass.deb &&
    sudo apt -qq install -y ./compass.deb &&
    rm ./compass.deb
fi

# install vivaldi
if ! command -v vivaldi-stable &>/dev/null; then
  echo -e "\n${GREEN}Installing Vivaldi...${NC}"
  wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg &&
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi-browser.gpg] https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list &&
    sudo apt update &&
    sudo apt install vivaldi-stable
fi

# install slack
if ! command -v slack &>/dev/null; then
  echo -e "\n${GREEN}Installing Slack...${NC}"
  version="$(curl --silent https://slack.com/downloads/linux --stderr - | grep -Po -m 1 "(?<=Version )[0-9.]*")" &&
    wget -q --show-progress "https://downloads.slack-edge.com/releases/linux/${version}/prod/x64/slack-desktop-${version}-amd64.deb" -O slack.deb &&
    sudo apt -qq install -y ./slack.deb &&
    rm ./slack.deb
fi

# install proton vpn cli
if ! command -v protonvpn-cli &>/dev/null; then
  echo -e "\n${GREEN}Installing Proton VPN CLI...${NC}"
  wget -q --show-progress https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb -O proton_repo.deb &&
    sudo apt install ./proton_repo.deb &&
    rm ./proton_repo.deb &&
    sudo apt update &&
    sudo apt install protonvpn-cli
fi

# install foliate
if ! command -v com.github.johnfactotum.Foliate &>/dev/null; then
  echo -e "\n${GREEN}Installing Foliate...${NC}"
  repo="johnfactotum/foliate" &&
    tag="$(latest_git_release "$repo")" &&
    version="${tag:1}" &&
    wget -q --show-progress "https://github.com/${repo}/releases/download/${tag}/com.github.johnfactotum.foliate_${version}_all.deb" -O foliate.deb &&
    sudo apt -qq install -y ./foliate.deb &&
    rm ./foliate.deb
fi

echo
read -p "Do you want to install Turso CLI (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  curl -sSfL https://get.tur.so/install.sh | bash
fi

echo
read -p "Do you want to install FlyCTL CLI (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  curl -L https://fly.io/install.sh | sh
fi

## TODO Add JetBrains Toolbox installation
### TODO Install Android Studio
### TODO Install DataGrip
### TODO Install Gradle

# Setup Configs for theming and other stuff
scripts/setup-config.sh

# Setup Fonts
scripts/install-fonts.sh

# Install Completions
scripts/install-completions.sh

# Move assets i.e wallpapers, icons, etc
scripts/move-assets.sh

source ~/.bashrc
