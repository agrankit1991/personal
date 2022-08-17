#Update
sudo apt update && sudo apt upgrade

#Essentials
sudo snap install vlc
sudo apt install make
sudo apt install vim
sudo apt install zsh
#Install proprietary Nvidia GPU Drivers
sudo apt install nvidia-driver-455
#Install Tor Browser
sudo add-apt-repository ppa:micahflee/ppa
sudo apt install torbrowser-launcher

#Git and Github setup
sudo apt install git
git config --global user.email "ankitagrawal1991@gmail.com"
git config --global user.name "Ankit Agrawal"
ssh-keygen
cat ~/.ssh/id_rsa.pub
# Setup token for repo, needed for 2FA https://github.com/settings/tokens
# https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token
# command for storing git credentials locally in plain text
git config --global credential.helper store
#gitignore
touch ~/.gitignore
git config --global core.excludesfile ~/.gitignore

#JDK8
sudo apt install openjdk-8-jdk

#VS Code
sudo apt install software-properties-common apt-transport-https wget
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt install code

#Intellij Community
sudo snap install intellij-idea-community --classic

#Postman
sudo snap install postman

#Obsidian
# Download snap file https://obsidian.md/download
sudo snap install '/home/agrankit/Downloads/obsidian_0.15.9_amd64.snap' --dangerous

#Trading View
sudo snap install tradingview

#Dbeaver
sudo snap install dbeaver-ce

#Unrar - To extract rar files
sudo apt-get install unrar
#Command: unrar x <file_path>

#MySql Server and Workbench: https://phoenixnap.com/kb/install-mysql-ubuntu-20-04
sudo apt install mysql-server
sudo mysql_secure_installation
sudo snap install mysql-workbench-community
# Store password for application downloaded from snap
sudo snap connect mysql-workbench-community:password-manager-service :password-manager-service
# Allow mysql workbench to connect to root user with password
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '<password>';
#oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
code ~/.zshrc
#update plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions k)
source ~/.zshrc
#Download font https://github.com/powerline/fonts/raw/master/SourceCodePro/Source%20Code%20Pro%20for%20Powerline.otf
