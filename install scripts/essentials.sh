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
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
code ~/.zshrc
#update plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions fzf-tab k)
#Download font https://github.com/powerline/fonts/raw/master/SourceCodePro/Source%20Code%20Pro%20for%20Powerline.otf
source ~/.zshrc

#bat - a better cat
sudo nala install bat

#Replacement for ls
sudo nala install eza

#zoxide - a better cd
sudo nala install zoxide

#tldr - replacement for man pages
sudo nala install tldr

########################## Browsers ##########################
# Install Tor Browser
sudo add-apt-repository ppa:micahflee/ppa
sudo nala install torbrowser-launcher

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update
sudo nala install brave-browser

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
#Use Extension Manager Clipboard History
#Trading View
sudo snap install tradingview
#Install proprietary Nvidia GPU Drivers
sudo apt install nvidia-driver-455

