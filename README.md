# personal-script

Personal Arch Linux (COSMIC / KDE Plasma / Hyprland) and macOS setup automation.

Every OS/desktop gets **one TUI install script**. Each presents a checkbox
menu (via [`gum`](https://github.com/charmbracelet/gum), falling back to
plain `y/n` prompts if `gum` isn't installed) of installable components. Only
the script's own desktop setup (plus, on Arch, disk utility support) is
pre-selected — everything else is opt-in, so running the KDE script only
installs KDE Plasma unless you ask for more.

## Structure

```
shared/           # Single source of truth for everything cross-platform
  lib/             # log.sh, prompt.sh (checkbox menu), backup.sh, sudo.sh, packages.sh
  config/          # zsh, Starship, Ghostty, fastfetch, git templates
  ide/             # Java code-style XMLs (Eclipse, IntelliJ)
  packages/        # Package lists that are identical on pacman and Homebrew
  install-*.sh     # dotfiles, git, oh-my-zsh, mise, starship, lazyvim installers

arch/              # Arch Linux
  lib/pacman.sh     # pacman / paru (AUR) / flatpak wrappers
  packages/         # Arch-specific package/AUR/flatpak lists (see below)
  components/       # terminal, dev-tools, postgres, apps, disk-utility,
                     # power-profiles, sddm-numlock
  ARCH_INSTALL.md   # base Arch install (disk partitioning, bootloader, BTRFS) —
                     # reference only, deliberately NOT a script (see below)
  hyprland/         # Hyprland desktop: install.sh, setup.sh, security.sh,
                     # config/ (hypr, waybar, rofi, swaync, uwsm), scripts/
                     # (keybind helpers), themes/
  cosmic/           # COSMIC desktop: install.sh, setup.sh
  kde/              # KDE Plasma desktop: install.sh, setup.sh

macos/             # macOS
  lib/brew.sh       # Homebrew wrapper (+ Xcode CLT / Homebrew bootstrap)
  packages/         # macOS-specific formula/cask lists
  components/       # terminal, dev-tools, postgres, apps
  install.sh
```

### Package lists

Every package/app/cask name lives as plain text under a `packages/`
directory — one name per line, blank lines and full-line `#` comments
ignored — instead of inline in a script, so the actual install list is easy
to scan and edit without reading bash:

- `shared/packages/` — names identical on both pacman and Homebrew (most of
  the terminal CLI tool list, mise's Java/Node/Gradle versions).
- `arch/packages/*.txt` — Arch/AUR/flatpak-specific lists, one file per
  component (`terminal-extra.txt`, `hyprland-base.txt`, `kde-media.txt`, ...).
- `macos/packages/*.txt` — Homebrew formula/cask lists.

`shared/lib/packages.sh`'s `read_package_list <file>` loads one of these
into the array `PACKAGE_LIST` for a component script to pass straight to
`install_pkg`/`install_aur`/`install_cask`.

## Usage

```bash
# Arch — pick your desktop:
./arch/hyprland/install.sh
./arch/cosmic/install.sh
./arch/kde/install.sh

# macOS:
./macos/install.sh
```

Each script asks for `sudo` once up front (cached for the run). On Arch,
`paru` (the AUR helper) is always bootstrapped unconditionally right after —
every component may need an AUR package, so it isn't gated behind any menu
selection. It's built from the **source** `paru` AUR package rather than
`paru-bin`/`paru-bin-debug`, whose prebuilt binaries have proven unreliable
here; that costs a few minutes of Rust compile time on a fresh machine.
The script then asks which components to install. Every step is
safe to re-run: config files are only touched if their content actually
changed (and the *first* differing file is backed up to `<name>.backup` —
later re-runs won't clobber that backup with our own previously-installed
copy), and system changes like the wallpaper cron entry or the login
manager's NumLock config are written idempotently.

### Components (per script)

- **Terminal environment** — zsh + Oh My Zsh (+ 4 plugins), Starship prompt,
  modern CLI tools (ripgrep, fd, bat, eza, zoxide, fzf, btop, ...), Ghostty
  (the terminal emulator the shared `config/ghostty` dotfile configures —
  a pacman package on Arch, a cask on macOS), Neovim + LazyVim, mise,
  JetBrains Mono Nerd Font.
- **Dev tools** — Docker + mise-managed Java/Node/Gradle.
- **PostgreSQL** *(optional, off by default)* — a local dev Postgres
  instance with a throwaway `dev`/`dev` role and database.
- **GUI apps** — VS Code, IntelliJ IDEA (Arch only, via AUR's
  `intellij-idea-ultimate-edition` — JetBrains merged Community/Ultimate
  into one unified download in the 2025.3 release, so this is the correct
  package now; unlicensed it behaves as Community used to, with an optional
  paid upgrade), Brave, Obsidian, DBeaver, etc. (OpenCode and Claude Code
  too, on Arch — both AUR, neither in Homebrew as of this writing).
- **Git/SSH configuration** — identity, aliases, global excludes/commit
  template, and an ed25519 SSH key for GitHub (skips key generation if one
  already exists).
- **Disk utility** *(Arch only, on by default)* — GNOME Disks plus FAT32
  (`dosfstools`) and NTFS (`ntfs-3g`) support.
- **Power profiles** *(Arch only, on by default)* — `power-profiles-daemon`,
  enabled as a service, so the desktop's Performance / Balanced / Power
  Saver switcher (and `powerprofilesctl`) works. Warns instead of acting if
  `tlp` is enabled, since the two conflict and picking between them is a
  real choice.
- **Desktop setup** *(on by default)* — see below.

### Hyprland desktop setup

Compositor + Wayland utilities (waybar, rofi, swaync, hypridle/hyprlock,
hyprpolkitagent, uwsm, ...), SDDM + NumLock, gnome-keyring, the GNOME app
suite Hyprland doesn't bundle on its own (Nautilus, Loupe, Amberol, Showtime,
Papers, codecs, thumbnailers), and the wallpaper-shuffler cron job. Also
copies the tracked `hyprland/config/` tree into `~/.config`, the keybind
helper scripts into `~/scripts`, and the Bibata cursor theme into
`~/.local/share/icons`.

**Wallpapers are not tracked in this repo** — as multi-MB binaries they
dwarfed every script and config in it put together. The setup only creates
an empty `~/Pictures/Wallpapers`; drop your own images there and the
shuffler cron job (every 30 min) picks them up. With the directory empty the
shuffler simply exits without changing anything.

An optional **Security hardening** component adds `ufw` (default-deny
incoming) and enables the AppArmor service.

Two steps are deliberately **not** automated because they edit boot-critical
system files (an initramfs regen or a wrong bootloader line can leave the
system unbootable) — the script prints exact instructions instead:

- NumLock *before disk decryption*: add `numlock` to `HOOKS` in
  `/etc/mkinitcpio.conf`, then `sudo mkinitcpio -P`.
- AppArmor *enforcement* (the service alone doesn't enforce anything): add
  `apparmor=1 security=apparmor` to `GRUB_CMDLINE_LINUX_DEFAULT` in
  `/etc/default/grub`, then `sudo grub-mkconfig -o /boot/grub/grub.cfg`.
- Keyring auto-unlock at login needs a `pam_gnome_keyring.so` line added to
  `/etc/pam.d/login` — also printed by the script rather than sed'd in,
  since a bad PAM edit can lock you out of login.

### COSMIC desktop setup

`xdg-desktop-portal-gtk` (so GTK apps render correctly under COSMIC) and the
cosmic-greeter NumLock config. COSMIC bundles its own file manager and media
apps, so there's no GNOME-app-suite step here.

### KDE Plasma desktop setup

Base Plasma packages (`plasma-desktop`, Dolphin, Konsole, etc.), Elisa
(music) and Haruna (video) since neither ships with `plasma-desktop`,
Dolphin thumbnailer plugins (`ffmpegthumbs`, `kdegraphics-thumbnailers`,
`kimageformats`), and NumLock in two places:

- **Login screen** — KDE here uses **Plasma Login Manager**
  (`plasma-login-manager` package, `plasmalogin` service), *not* classic
  SDDM — see the ["Plasma Login Manager" section of the Arch
  Wiki](https://wiki.archlinux.org/title/Activating_numlock_on_bootup#Plasma_Login_Manager).
  Its NumLock setting lives in
  `/var/lib/plasmalogin/.config/kdedefaults/kcminputrc` (owned by the
  `plasmalogin` system user), not `/etc/sddm.conf.d`. If `sddm.service` is
  enabled from a previous run, it's disabled first so the two login
  managers don't fight over the display. This is a different mechanism from
  Hyprland's, which does use classic SDDM (`arch/components/sddm-numlock.sh`).
- **Plasma session** — set via `kwriteconfig6`/`kwriteconfig5`, so it merges
  into `~/.config/kcminputrc` instead of overwriting it.

## Design notes

- **No spinners around package managers.** `gum spin` (or any wrapper that
  hides a subprocess's output) is never used around `pacman`/`paru`/`brew`
  calls — those can need a `sudo` password or hit a rare interactive
  confirmation, and burying that under a spinner is how install scripts
  silently hang. `sudo` is cached up front instead
  (`shared/lib/sudo.sh`), and package managers always run with their output
  visible and their `--noconfirm`/non-interactive flags set explicitly.
- **`shared/lib/prompt.sh`'s `checkbox_menu`** returns its selection via the
  global array `MENU_RESULT` (not a `declare -n` nameref) so the same code
  runs on both Arch's bash and macOS's stock bash 3.2. It must be called as
  a bare statement, never through a pipe or subshell — bash runs the
  right-hand side of a pipe in a subshell, and `MENU_RESULT` would be set
  there and lost when the subshell exits.
- **`arch/ARCH_INSTALL.md`** (disk partitioning, BTRFS subvolumes + Snapper,
  bootloader) stays a plain doc, not a script — it runs before there's even
  a filesystem to check out this repo onto, and it's the kind of thing you
  want to read, not blindly pipe into a shell.
