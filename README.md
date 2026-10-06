# home-dots

Home-manager configuration for NixOS and non-NixOS systems.

## Structure

```
home-dots/
├── flake.nix                  # Host definitions and flake inputs
├── profiles/
│   ├── cli.nix                # CLI profile: shell tools + stylix (terminal only)
│   └── nixos.nix              # NixOS profile: full desktop + CLI
├── hosts/
│   └── example/               # Example host: copy and rename for your own
└── home-modules/
    ├── cli/                   # zsh, git, gpg, tmux, starship, joshuto
    ├── desktop-env/           # hyprland, eww, kitty, rofi, firefox, stylix, ...
    └── development/           # qemu, dev (rust, python, lua, zig)
```

## Profiles

| Profile              | Intended for        | Stylix targets       |
| -------------------- | ------------------- | -------------------- |
| `profiles/cli.nix`   | non-NixOS, CLI only | terminal only (tmux) |
| `profiles/nixos.nix` | NixOS, full desktop | full desktop         |

The `example` host uses `profiles/cli.nix`.

Host files only contain overrides on top of their profile.

## Before you build: replace the placeholders

This is an anonymized copy. A few values are placeholders that you must
replace before it works for you:

| Placeholder                          | Where                                                                                                      | Replace with                                             |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `/home/<you>`                        | `hyprland/hyprlock.conf`, `hyprland/hyprpaper.conf`, `hyprland/scripts/wallpaper`, `hyprland/scripts/tts.sh`, `noctalia/noctalia.toml` | Your home directory, e.g. `/home/alice` (these files do not expand `$HOME`) |
| `/home/<you>/path/to/piper-voice.onnx` | `hyprland/scripts/tts.sh`                                                                                | Path to your piper-tts voice model                       |
| `github:<you>/Dorps-NVIM`            | `flake.nix` (`dorps-neovim` input)                                                                         | Your neovim flake exposing `packages.<system>.default`   |
| `myuser`, `example`                  | `flake.nix` (`systems`)                                                                                    | Your username and host name (see below)                  |
| `Your Name`, `you@example.com`       | `home-modules/cli/git/default.nix`                                                                         | Your git identity                                        |
| `git.example.com`, `myuser`          | `home-modules/cli/git/default.nix` (`mine:` shorthand)                                                     | Your git server, or delete the rewrite                   |
| `cloud.example.com`, `myuser`        | `home-modules/desktop-env/noctalia/noctalia.toml` (CalDAV account)                                         | Your CalDAV server and user, or disable the calendar     |

To find every spot:

```bash
grep -rnE '<you>|example\.com|myuser' .
```

## Switching theme

Edit `activeTheme` in `home-modules/desktop-env/stylix/default.nix`:

```nix
activeTheme = "tokyo-night"; # catppuccin-mocha | catppuccin-latte | tokyo-night | dracula | nord | gruvbox-dark-hard | solarized-dark
```

## Adding a new host

1. Add an entry to the `systems` list in `flake.nix` (or edit the `example`
   one). `hostname` must match the directory name under `hosts/`:

```nix
{
  hostname = "my-host";
  username = "myuser";
  system = "x86_64-linux";
}
```

2. Create `hosts/my-host/home-modules.nix` (copy `hosts/example/`):

```nix
{ ... }: {
  imports = [ ../../profiles/cli.nix ]; # or nixos.nix for NixOS
  # host-specific overrides here
}
```

3. Build and activate:

```bash
nix build .#homeConfigurations."myuser".activationPackage --extra-experimental-features 'nix-command flakes'
./result/activate
```

## NixOS hosts (managed via nixos-rebuild)

On NixOS the home configuration is applied automatically via
`nixos-rebuild switch`. Use the `switch` or `rebuild` shell aliases.

## Standalone activation (non-NixOS)

```bash
nix build .#homeConfigurations."<username>".activationPackage --extra-experimental-features 'nix-command flakes'
./result/activate
```

Replace `<username>` with the username for that host (see `flake.nix`).
