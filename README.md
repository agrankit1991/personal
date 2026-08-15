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
  cosmic/           # COSMIC desktop: install.sh, setup.sh, capture-config.sh,
                     # config/ (tracked COSMIC settings, fuzzel, systemd unit),
                     # scripts/ (clipboard-history picker)
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
safe to re-run: config files are only touched if they aren't already in
place (and the *first* pre-existing file is backed up to `<name>.backup` —
later re-runs won't clobber that backup with something we installed
ourselves), and system changes like the wallpaper cron entry or the login
manager's NumLock config are written idempotently.

### Config files are symlinked

Configs are **symlinked** out of this repo rather than copied into place, so
editing one here takes effect immediately with no re-run of the installer,
and a change made on a whim is already tracked instead of waiting to be
copied back by hand. `shared/lib/backup.sh` has both flavours —
`link_file`/`link_dir` and `install_file`/`install_dir` — and everything uses
the linking pair except where noted below.

Two consequences worth knowing:

- The links hold **absolute paths**, so the repo is expected to stay where it
  was first cloned. Move it and every link dangles at once.
- The repo is **live**. A `git checkout` of an older commit, a rebase, or a
  `git clean` changes your running config the moment it touches the file —
  which for something like `hypr/` means a half-finished edit is in effect as
  soon as you save it.

Two things are still copied. **COSMIC's config dirs** (`arch/cosmic/`) are
rewritten continuously by the desktop itself; linking them would keep the
repo permanently dirty with churn and leave `capture-config.sh` — the script
that pulls UI changes back in — copying files onto themselves. The
**cliphist systemd unit** is copied because `systemctl enable` reads a
symlinked unit file as an alias of its target rather than as the unit itself.

The editor settings (`shared/config/{zed,vscode}/settings.jsonc`) *are*
linked, which is a deliberate trade: Zed and VS Code write these files back
when you change a setting in their UI, so linking means the change lands in
the repo instead of being lost on the next install — but the editor, not you,
owns the formatting of whatever it rewrites. Check `git diff` before
committing rather than assuming the comment blocks came through intact.

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
links the tracked `hyprland/config/` tree into `~/.config`, the keybind
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
apps, so there's no GNOME-app-suite step here. `network-manager-applet` is
removed rather than installed — COSMIC has its own network applet, so the
GTK one only adds a duplicate tray icon.

**Universal copy/paste.** SUPER+C and SUPER+V copy and paste everywhere, the
way Omarchy does it on Hyprland. COSMIC's shortcut actions can only spawn a
command or drive a window — there is no "send a keystroke" action — so the
remap happens below the compositor in `keyd` (`/etc/keyd/default.conf`).
They map to Ctrl+Insert and Shift+Insert, the legacy combos that GTK, Qt,
Electron and terminals all honour, so one binding covers every app without
per-window special-casing.

Two details there are load-bearing. `[meta:M]` keeps SUPER working for
everything *not* explicitly bound, which is what leaves SUPER+W, SUPER+E and
the rest of the COSMIC shortcuts alive. The `[meta+shift]` composite layer
hands SUPER+SHIFT+V back to the compositor — without it the plain `v`
binding still fires with Shift merely passed through, and COSMIC never sees
the combo at all. Composite layers must be declared *after* the layers they
are built from.

**Clipboard history** on SUPER+SHIFT+V: `cliphist` records every clipboard
change via a systemd *user* service, and a `fuzzel` picker
(`/usr/local/bin/clipboard-history`) selects from it. COSMIC has no
clipboard manager of its own, and its one community applet is panel-click
only — no keybinding is possible — hence this pair instead. Ghostty needs
the matching `shift+insert=paste_from_clipboard` override in
`shared/config/ghostty/config`; its default binds that to
`paste_from_selection`, which pastes the mouse-highlight rather than what
SUPER+C copied.

**External monitor brightness.** COSMIC's settings daemon has spoken DDC/CI
since 1.0.14, so the brightness keys need no script — only `/dev/i2c-*`
nodes the session can reach. `ddcutil` is installed for the
`modules-load.d` and udev snippets it ships, which provide exactly that;
`ddcutil detect` is also how to diagnose a monitor with DDC/CI switched off
in its own OSD menu. Desktops have no `/sys/class/backlight`, so the
brightness bindings do nothing at all until this is in place.

#### Tracked COSMIC settings — read this before re-running the installer

The theme, panel, dock, pinned dock apps and keyboard shortcuts are tracked
in `cosmic/config/cosmic/`, one directory per COSMIC config ID, listed in
`cosmic/config/cosmic-ids.txt`.

**These are installed wholesale.** Anything tweaked afterwards in COSMIC
Settings is silently overwritten the next time `setup.sh` runs. That is a
real trap across ~60 theme files alone, so the loop is two-way:

```
tweak in COSMIC Settings  →  ./arch/cosmic/capture-config.sh  →  git diff  →  commit
```

`capture-config.sh` copies the live settings back out of `~/.config/cosmic`
into the repo. Both directions read `cosmic-ids.txt`, so they cannot drift,
and tracking something new is one line in that file plus a re-capture — no
code change. Capture *replaces* rather than merges, so a setting removed in
the UI also disappears from the repo instead of lingering as a stale tracked
file; the cost is that hand-edits under `config/cosmic/` are overwritten by
the next capture, so treat the UI as the source of truth for these.

For the theme, both `CosmicTheme.Dark.Builder` and the derived
`CosmicTheme.Dark` are tracked — the Builder is what COSMIC generates from,
but shipping the derived output means a fresh machine looks right
immediately instead of waiting for a regeneration.

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
