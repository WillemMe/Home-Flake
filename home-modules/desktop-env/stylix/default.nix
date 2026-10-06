{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.stylix;

  activeTheme = "tomorrow-night"; # <-- change this to switch theme

  lightThemes = ["catppuccin-latte"];

  themeFiles = {
    "catppuccin-mocha" = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    "catppuccin-latte" = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
    "tokyo-night" = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    "tokyo-night-storm" = "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-storm.yaml";
    "tomorrow-night" = "${pkgs.base16-schemes}/share/themes/tomorrow-night.yaml";
    "dracula" = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    "nord" = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    "gruvbox-dark-hard" = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    "solarized-dark" = "${pkgs.base16-schemes}/share/themes/solarized-dark.yaml";
  };
in {
  options.modules.stylix = {
    enable = mkEnableOption "stylix";
    desktop = mkOption {
      type = types.bool;
      default = false;
      description = "Enable desktop theming targets (firefox, hyprland, vscode, dunst, kitty, etc.)";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = cfg.desktop;
      base16Scheme = themeFiles.${activeTheme};

      cursor = lib.mkIf cfg.desktop {
        package = pkgs.graphite-cursors;
        name = "graphite-dark";
        size = 24;
      };
      polarity =
        if builtins.elem activeTheme lightThemes
        then "light"
        else "dark";

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.inter;
          name = "Inter";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          terminal = 13;
          applications = 11;
          desktop = 11;
          popups = 11;
        };
      };

      targets = {
        alacritty.enable = false;
        # Desktop targets — only active when running a full desktop profile
        firefox.enable = lib.mkDefault cfg.desktop;
        hyprland.enable = cfg.desktop;
        hyprlock.enable = cfg.desktop;
        vscode.enable = cfg.desktop;
        dunst.enable = cfg.desktop;
        nvf.enable = lib.mkDefault cfg.desktop;
        kitty.enable = lib.mkDefault cfg.desktop;
        gtk.enable = cfg.desktop;
        qt.enable = cfg.desktop;
        rofi.enable = false; # custom theme managed in rofi module
        tmux.enable = false; # themed manually in tmux module using base16 colors
      };
    };
  };
}
