```bash
sudo pacman -S nautilus # File Manager
sudo pacman -S showtime # Video Player
sudo pacman -S loupe # Image Viewer
sudo pacman -S sushi # Image Quick Preview
sudo pacman -S amberol # Music player
sudo pacman -S papers # PDF Viewer
sudo pacman -S gnome-calendar # Calendar
sudo pacman -S gnome-calculator # Modern, adaptive calculator with advanced mode -- does not work
sudo pacman -S gnome-clocks # World clock, alarm, timer, stopwatch—all in one sleek app
sudo pacman -S gnome-font-viewer # Preview/manage fonts
yay -S mission-center # System Monitor

# Codecs
sudo pacman -S ffmpeg gstreamer
sudo pacman -S gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav # gst-libav (bridges FFmpeg codecs to GStreamer)
sudo pacman -S ffmpegthumbs # Enables video thumbnails in Nautilus (pairs with built-in thumbnailers).

# Set default apps
xdg-mime default org.gnome.Nautilus.desktop inode/directory
xdg-mime default org.gnome.Loupe.desktop image/png image/jpeg image/gif image/webp image/svg+xml
xdg-mime default org.gnome.Showtime.desktop video/mp4 video/mkv video/webm video/x-matroska
xdg-mime default org.gnome.Amberol.desktop audio/mpeg audio/flac audio/ogg
xdg-mime default org.gnome.Papers.desktop application/pdf

# Fonts
xdg-mime default org.gnome.font-viewer.desktop application/x-font-ttf
xdg-mime default org.gnome.font-viewer.desktop application/x-font-otf
xdg-mime default org.gnome.font-viewer.desktop application/font-sfnt
xdg-mime default org.gnome.font-viewer.desktop font/ttf font/otf

# Calendar
xdg-mime default org.gnome.Calendar.desktop text/calendar

# defaults for VS code
xdg-mime default code.desktop text/plain
xdg-mime default code.desktop text/markdown text/x-markdown
xdg-mime default code.desktop text/x-java-source text/x-java
xdg-mime default code.desktop text/x-c text/x-c++ text/x-python text/x-javascript application/json application/xml
xdg-mime default code.desktop text/x-script text/x-shellscript
```


# Install Flatpak and Bazaar 
sudo pacman -S flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub io.github.kolunmi.Bazaar