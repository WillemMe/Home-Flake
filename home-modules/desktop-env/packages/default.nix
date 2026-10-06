{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.packages;
in {
  options.modules.packages = {
    enable = mkEnableOption "packages";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Wayland utilities
      ntfs3g
      usbutils
      grim
      slurp
      slop

      # Media
      mpv
      pqiv
      libheif
      gthumb
      loupe
      gnome-icon-theme
      libqalculate
      feh
      hexedit
      #wf-recorder
      #google-cloud-sdk

      # Applications
      virt-manager
      #    vesktop # for discord screen share
      thunderbird-140
      nextcloud-client
      spotify
      #burpsuite
      wireguard-tools
      mission-center
      signal-desktop
      yubioath-flutter

      # Office
      libreoffice
      hunspell
      hunspellDicts.nl_nl
      hunspellDicts.en_US
      go
      #texliveFull
      # Host-specific hardware tools
      #arduino-ide
      opentabletdriver
      #openscad-unstable
      #flashprint
      prusa-slicer
    ];
    programs.obs-studio = {
      enable = false;

      package = (
        pkgs.obs-studio.override {
          cudaSupport = true;
        }
      );

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
    };
  };
}
