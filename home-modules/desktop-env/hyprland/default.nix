{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {enable = mkEnableOption "hyprland";};
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpaper
      hyprpicker
      nautilus
      networkmanagerapplet
      overskride
      pomodoro-gtk
      vulkan-loader
      brillo
      brightnessctl
      pamixer
      libcanberra-gtk3
      swappy
      playerctl
      pavucontrol
      gnomeExtensions.appindicator
      papirus-folders
      tokyonight-gtk-theme
      tela-icon-theme
    ];

    home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
    home.file.".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
    home.file.".config/hypr/hypridle.conf".source = ./hypridle.conf;
    home.file.".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
    home.file.".config/hypr/configs/general.conf".source = ./configs/general.conf;
    home.file.".config/hypr/configs/exec.conf".source = ./configs/exec.conf;
    home.file.".config/hypr/configs/window.conf".source = ./configs/window.conf;
    home.file.".config/hypr/configs/binds.conf".source = ./configs/binds.conf;
    home.file.".config/hypr/wallpapers" = {
      source = ./wallpapers;
      recursive = true;
    };
    home.file.".config/hypr/scripts" = {
      source = ./scripts;
      recursive = true;
    };
    home.file.".config/hypr/face.png".source = ./face.png;

    gtk = {
      enable = true;

      iconTheme = {
        name = "Tela blue";
        package = pkgs.tela-icon-theme;
      };

      gtk4.theme = lib.mkOptionDefault null;
    };

    #  dconf.settings = {
    #    "org/gnome/desktop/interface" = {
    #      gtk-theme = "Breeze-Dark";
    #      color-scheme = "prefer-dark";
    #    };
    # };

    qt = {
      enable = true;
    };
  };
}
