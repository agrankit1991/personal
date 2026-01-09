
# File Manager Thumbnail Requirements (Arch Linux)

This document explains which packages are required to enable file previews
(thumbnails) in **GNOME Files (Nautilus)** and **Thunar**, and what each package
is responsible for.

---

## GNOME Files (Nautilus)

GNOME Files uses **GNOME’s thumbnailing infrastructure**. Most functionality
comes from shared GNOME libraries and services.

### Required Components

| Package | Purpose | File Types |
|-------|--------|-----------|
| `nautilus` | GNOME file manager | All |
| `gnome-desktop` | GNOME thumbnail framework | Images, videos |
| `ffmpegthumbnailer` | Video frame extraction | mp4, mkv, webm |
| `poppler-glib` | PDF rendering | PDF |
| `libgsf` | Office document parsing | docx, xlsx, pptx, odf |
| `freetype2` | Font rendering | Fonts, PDFs, SVG |
| `gvfs` | Virtual filesystem support | MTP, trash, network |

### Notes
- Nautilus **does not use tumbler**
- Thumbnails are cached in `~/.cache/thumbnails/`
- Works automatically under Wayland and X11

### Install Commands

```bash
sudo pacman -S nautilus gnome-desktop ffmpegthumbnailer poppler-glib libgsf freetype2 gvfs
````

---

## Thunar (Xfce / Hyprland)

Thunar does **not** generate thumbnails by itself. It relies on an external
thumbnailing service called **tumbler**.

### Required Components

| Package             | Purpose                    | File Types          |
| ------------------- | -------------------------- | ------------------- |
| `thunar`            | Xfce file manager          | All                 |
| `tumbler`           | Thumbnail service (D-Bus)  | All                 |
| `ffmpegthumbnailer` | Video thumbnails           | mp4, mkv, webm      |
| `poppler-glib`      | PDF thumbnails             | PDF                 |
| `libgsf`            | Office document thumbnails | docx, xlsx, pptx    |
| `freetype2`         | Font rendering             | Fonts, PDFs         |
| `gvfs`              | Filesystem integration     | MTP, trash, network |

### Optional / KDE-only

| Package        | Purpose               | Notes               |
| -------------- | --------------------- | ------------------- |
| `ffmpegthumbs` | KDE video thumbnailer | Not used by tumbler |

### Notes

* Thunar communicates with `tumbler` via D-Bus
* Without `tumbler`, **no thumbnails will appear**
* Thumbnail plugins live in `/usr/share/tumbler-1/plugins/`

### Install Commands

```bash
sudo pacman -S thunar tumbler ffmpegthumbnailer poppler-glib libgsf freetype2 gvfs
```

---

## Troubleshooting

### Restart thumbnail service (Thunar only)

```bash
pkill tumblerd
```

### Restart Thunar

```bash
pkill thunar && thunar &
```

### Verify tumbler plugins

```bash
ls /usr/share/tumbler-1/plugins/
```

---

## Summary

| File Manager | Thumbnail Backend       |
| ------------ | ----------------------- |
| GNOME Files  | GNOME desktop libraries |
| Thunar       | tumbler + plugins       |

No system reboot is required after installation — restarting the file manager
or logging out/in is sufficient.

```