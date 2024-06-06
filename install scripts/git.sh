#Git and Github setup
sudo nala install git
git config --global user.email "ankitagrawal1991@gmail.com"
git config --global user.name "Ankit Agrawal"
git config --global column.ui auto
git config --global branch.sort -committerdate
ssh-keygen
cat ~/.ssh/id_rsa.pub
# Setup token for repo, needed for 2FA https://github.com/settings/tokens
# https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token
# command for storing git credentials locally in plain text
git config --global credential.helper store
#gitignore - run it after dotfile is present
git config --global core.excludesfile ~/.gitignore