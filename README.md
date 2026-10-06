# home-dots

Home-manager configuration for NixOS and non-NixOS systems.

Everything is toggled through a single `modules.<name>.enable` option tree.
Hosts do not enable modules one by one — they import a **profile** that sets a
whole sensible default set, and only add overrides on top.

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
    ├── template.nix           # Copy this to start a new module
    ├── cli/                   # zsh, git, gpg, tmux, starship, joshuto
    │   └── starship/starship-profiles/   # Switchable prompt presets
    ├── desktop-env/           # hyprland, noctalia, kitty, firefox, vscode,
    │                          # stylix, xdg, scripts, packages, notetaking,
    │                          # voxtype, gaming, eww, dunst, rofi
    └── development/           # qemu, dev (rust, python, lua, zig)
```

## Before you build: replace the placeholders

This is an anonymized copy. A few values are placeholders that you must
replace before it works for you:

| Placeholder                            | Where                                                                                                                                  | Replace with                                                                 |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `/home/<you>`                          | `hyprland/hyprlock.conf`, `hyprland/hyprpaper.conf`, `hyprland/scripts/wallpaper`, `hyprland/scripts/tts.sh`, `noctalia/noctalia.toml` | Your home directory, e.g. `/home/alice` (these files do not expand `$HOME`)  |
| `/home/<you>/path/to/piper-voice.onnx` | `hyprland/scripts/tts.sh`                                                                                                              | Path to your piper-tts voice model                                           |
| `github:<you>/Dorps-NVIM`              | `flake.nix` (`dorps-neovim` input)                                                                                                     | Your neovim flake exposing `packages.<system>.default`                       |
| `myuser`, `example`                    | `flake.nix` (`systems`)                                                                                                                | Your username and host name (see "Adding a new host")                        |
| `Your Name`, `you@example.com`         | `home-modules/cli/git/default.nix`                                                                                                     | Your git identity                                                            |
| `git.example.com`, `myuser`            | `home-modules/cli/git/default.nix` (`mine:` shorthand)                                                                                 | Your git server, or delete the rewrite                                       |
| `cloud.example.com`, `myuser`          | `home-modules/desktop-env/noctalia/noctalia.toml` (CalDAV account)                                                                     | Your CalDAV server and user, or disable the calendar                         |

To find every spot:

```bash
grep -rnE '<you>|example\.com|myuser' .
```

## Profiles

Instead of listing every module per host, a host imports one profile:

| Profile              | Intended for        | What it turns on                            |
| -------------------- | ------------------- | ------------------------------------------- |
| `profiles/cli.nix`   | non-NixOS, CLI only | zsh, git, tmux, starship, joshuto + stylix (terminal targets only) |
| `profiles/nixos.nix` | NixOS, full desktop | everything in `cli.nix` + hyprland, noctalia, kitty, firefox, vscode, xdg, packages, scripts, dev, notetaking, and `stylix.desktop = true` |

The `example` host uses `profiles/cli.nix`.

`profiles/nixos.nix` also sets `my.isNixOS = true`, which enables the
NixOS-only shell aliases (`switch`, `rebuild`, `update`).

Host files then contain only their deltas, e.g. a NixOS host that adds gaming
and voice dictation:

```nix
{ ... }: {
  imports = [ ../../profiles/nixos.nix ];
  config.modules = {
    gaming.enable = true;
    voxtype.enable = true;
  };
}
```

A CLI host that wants one desktop program imports just that module and enables
it by hand, e.g. kitty:

```nix
{ ... }: {
  imports = [
    ../../profiles/cli.nix
    ../../home-modules/desktop-env/kitty
  ];
  config.modules.kitty.enable = true;
  config.stylix.targets.kitty.enable = true;
}
```

### Writing a new module

Copy `home-modules/template.nix`, replace `PROGRAM`, then add it to the
`imports` of the matching `home-modules/*/default.nix`. Importing a module never
activates it — the profile (or host) decides via `modules.<name>.enable`.

## Presets you can switch

Three things in this repo use a named-preset switch rather than hand-written
config:

### Prompt profile (starship)

Edit `activeProfile` in `home-modules/cli/starship/default.nix`:

```nix
activeProfile = "rightprompt"; # plain | minimal | powerline | pentest | compact | rightprompt
```

Each name maps to a TOML file in `home-modules/cli/starship/starship-profiles/`.
`minimal.toml` is additionally installed to `$XDG_CONFIG_HOME/starship-minimal.toml`,
which the `logsh` shell function uses via `STARSHIP_CONFIG` to keep recorded
sessions readable.

### Theme (stylix)

Edit `activeTheme` in `home-modules/desktop-env/stylix/default.nix`:

```nix
activeTheme = "tomorrow-night";
# catppuccin-mocha | catppuccin-latte | tokyo-night | tokyo-night-storm
# | tomorrow-night | dracula | nord | gruvbox-dark-hard | solarized-dark
```

Polarity is derived from the theme name (`lightThemes`). How far the theme
reaches is controlled by `modules.stylix.desktop`: `false` (CLI profile) themes
only terminal/CLI targets, `true` (NixOS profile) enables GTK, Qt, hyprland,
hyprlock, firefox, vscode, dunst, kitty and the cursor theme. `rofi` and `tmux`
are themed by hand in their own modules.

### Voice profiles (voxtype)

`home-modules/desktop-env/voxtype/default.nix` defines `settings.profiles`
(`command-line`, `security`, `nl`) with per-profile whisper prompts, so
dictation context is selected by name instead of editing the config. Recording
is bound in hyprland to `SUPER+V` (hold to record, release to stop) rather than
voxtype's own hotkey handling; transcription runs against a remote whisper
endpoint (`whisper.remote_endpoint`).

## Shell helpers

Defined in `home-modules/cli/zsh/default.nix` alongside the alias set:

| Helper            | Does                                                                 |
| ----------------- | -------------------------------------------------------------------- |
| `logsh`           | records the session to `./99_terminal/<timestamp>.log` with asciinema, using the minimal prompt and no fzf/zoxide noise |
| `edir` / `ddir`   | tar + `age -p` encrypt / decrypt a directory in place                 |
| `~dots`, `~dorps-nvim`, `~wordlists` | named directory hashes, so `cd ~dots` works |

## Adding a new host

1. Add an entry to the `systems` list in `flake.nix` (or edit the `example`
   one). `hostname` must match the directory name under `hosts/`:

```nix
{
  hostname = "my-host";
  username = "myuser";
  system = "x86_64-linux";
  displayserver = "x";     # optional, defaults to "wayland"
  extraModules = [ ];      # optional, extra HM modules / inline config
}
```

`displayserver` is exposed to modules as `config.my.displayserver` (used by the
kitty module to pick X11 vs Wayland settings). `extraModules` is where per-host
flake wiring goes — e.g. a desktop host pulls in
`voxtype.homeManagerModules.default`, and a non-NixOS host can pin its own `nix`
package or drop the kitty package (to use the system one).

2. Create `hosts/my-host/home-modules.nix` (copy `hosts/example/`):

```nix
{ ... }: {
  imports = [ ../../profiles/cli.nix ]; # or nixos.nix for NixOS
  # host-specific overrides here
}
```

3. Build and activate (see below).

## NixOS hosts (managed via nixos-rebuild)

The flake exposes `homeManagerModules."<username>@<hostname>"`, which your
system flake imports into its `home-manager.users.<username>`. So on NixOS the
home config is applied by `nixos-rebuild switch` — the shell aliases `switch`,
`rebuild` and `update` wrap this. They run against the flake that `~dots`
points to, so point that directory hash at your **system** flake (see
`dirHashes` in `home-modules/cli/zsh/default.nix`).

| Alias     | Does                                                             |
| --------- | ---------------------------------------------------------------- |
| `switch`  | `nixos-rebuild switch --flake ~dots`                             |
| `rebuild` | update the `home-flake` input, then switch with `nom` output      |
| `update`  | update all flake inputs (system + home) and commit the lockfile   |

Because these hosts are evaluated from the system flake, that flake also
supplies the shared `inputs` argument — the noctalia module imports
`inputs.noctalia.homeModules.default`, which is **not** an input of this
repo's `flake.nix`. The full desktop profile is therefore meant to be built
through the system flake, not standalone.

## Standalone activation (non-NixOS)

```bash
nix build .#homeConfigurations."<username>".activationPackage --extra-experimental-features 'nix-command flakes'
./result/activate
```

Replace `<username>` with the username for that host (see `flake.nix`);
`homeConfigurations` is keyed by username, not hostname.

## Noctalia

Noctalia (the hyprland bar/panels/launcher/OSD shell) replaces the older
eww + dunst + rofi stack — those modules are still in the tree but are disabled
in `profiles/nixos.nix`. Its settings live in
`home-modules/desktop-env/noctalia/noctalia.toml` and are read into the HM
module. To capture changes made through the GUI back into the repo:

```bash
noctalia config export full > noctalia.toml
```

Panels are driven from hyprland keybinds (`noctalia msg panel-toggle launcher`,
`control-center`, `window-switcher`, …) — see
`home-modules/desktop-env/hyprland/configs/binds.conf`.
