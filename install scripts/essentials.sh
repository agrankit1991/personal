# Update
sudo apt update && sudo apt upgrade
sudo apt install nala
########################## Essentials ##########################
sudo nala install vlc make vim zsh unrar

########################## Terminal Improvements ##########################
#oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
code ~/.zshrc
#update plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions fzf-tab k)
#Download font https://github.com/powerline/fonts/raw/master/SourceCodePro/Source%20Code%20Pro%20for%20Powerline.otf
source ~/.zshrc

########################## Browsers ##########################
# Install Tor Browser
sudo add-apt-repository ppa:micahflee/ppa
sudo nala install torbrowser-launcher

########################## Languages ##########################
# Java
sudo add-apt-repository ppa:openjdk-r/ppa
#JDK21 and JDK8
sudo nala install openjdk-21-jdk openjdk-8-jdk

# Python
sudo nala install python3
# Install pip (Python package installer)
sudo nala install python3-pip
# Install Jupyter notebook using pip
pip3 install jupyter
# Restart OS to initialize notebook then run jupyter notebook in a directory

########################## Editors ##########################
#VS Code
sudo nala install code

#Intellij Community (seems like only available in snap)
sudo snap install intellij-idea-community --classic

########################## Database tools ##########################
#Dbeaver
sudo snap install dbeaver-ce

########################## Notes ##########################
#Obsidian
# Download snap file https://obsidian.md/download --classic is needed because it has to access notes from outside
sudo snap install obsidian --classic

########################## Others ##########################
#Postman
sudo snap install postman
#Trading View
sudo snap install tradingview
#Install proprietary Nvidia GPU Drivers
sudo apt install nvidia-driver-455

