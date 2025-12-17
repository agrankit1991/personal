## Set Arch Logo in Login Screen
```bash
sudo cp ./logo.png /usr/share/plymouth/themes/omarchy/
sudo plymouth-set-default-theme omarchy
sudo limine-mkinitcpio
reboot
```