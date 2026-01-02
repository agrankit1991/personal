sudo pacman -S cronie
sudo systemctl enable --now cronie

crontab -e
*/30 * * * * ~/scripts/helper-wallpaper-shuffler

systemctl status cronie