# Dotfiles managed with GNU Stow

This repository uses GNU Stow and a Makefile to manage your dotfiles.

Overview

- `./.config/*/` are treated as config packages and will be stowed into `$(HOME)/.config` (usually `~/.config`).
- `./system/*/` are treated as system packages and will be stowed into `/` (so a package containing files for `/etc` should be under `system/etc/...`).

Makefile targets

- `make stow` — stow both config and system packages
- `make stow-config` — stow packages from `./.config` into `~/.config`
- `make stow-system` — stow packages from `./system` into `/` (may use `sudo`)
- `make restow` / `make restow-config` / `make restow-system` — restow packages
- `make delete` / `make delete-config` / `make delete-system` — delete symlinks created by stow
- `make dry-run` / `make dry-run-config` / `make dry-run-system` — show what would happen without making changes
- `make help` — print a short usage summary

Variables you can set

- `STOW` — stow binary (default: `stow`)
- `SUDO` — command used to run privileged stow (default: `sudo`). Set `SUDO=` to avoid sudo.
- `VERBOSITY` — stow verbosity level (0-4, default: `1`)
- `PKG` — operate on a single package name instead of auto-detected packages
- `HOME_DIR` — target home directory (default: `$(HOME)`). Useful for testing.

Examples (fish shell)

List detected packages:

```fish
# config packages
ls -d .config/*/ 2>/dev/null || echo "(no config packages)"
# system packages
ls -d system/*/ 2>/dev/null || echo "(no system packages)"
```

Stow everything (config -> ~/.config, system -> /):

```fish
make stow
```

Stow only the `nvim` config package into your local ~/.config:

```fish
make stow-config PKG=nvim
```

Dry-run system packages without sudo (safe preview):

```fish
make dry-run-system SUDO=
```

Delete links for a single config package:

```fish
make delete-config PKG=somepkg
```

Restow both sets (useful after moving or updating packages):

```fish
make restow
```

Notes and safety

- `stow-system` uses `$(SUDO)` by default because packages under `system/` may write to `/etc` or other root-owned locations. Set `SUDO=` to run without sudo (for testing) or to avoid prompting.
- The Makefile expects each package to be a directory directly under `.config/` or `system/` (for example `.config/nvim/` or `system/etc/nginx/`). Place files inside those package directories laid out as they should appear relative to the target.
- If you want system packages to target `/etc` specifically, you can either place them under `system/etc/...` (recommended) or edit the Makefile to change `--target=/` to `--target=/etc`.

Troubleshooting

- "No such file or directory" from `stow`: make sure the package directory exists and is named correctly (trailing slash not required when passing `PKG`).
- If stow seems to create files instead of symlinks, double-check the `stow` version and options; the Makefile passes the `--dir` and `--target` explicitly.

Installing GNU Stow

- Arch / Manjaro:

```fish
sudo pacman -S stow
```

- Debian / Ubuntu:

```fish
sudo apt update; sudo apt install stow
```

- macOS (Homebrew):

```fish
brew install stow
```

Further ideas

- Add a `bootstrap` target that installs `stow` automatically for your platform.
- Add a `list` target to print detected packages in a friendly format.

If you want either of those added, or prefer `system` to target `/etc` by default, tell me and I will update the Makefile and README accordingly.
