{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.rofi;
  c = config.lib.stylix.colors;
in {
  options.modules.rofi = {enable = mkEnableOption "rofi";};
  config = mkIf cfg.enable {
    # Enabled as system module
    #home.packages = with pkgs; [
    # rofi-emoji-wayland
    #];
    programs.rofi = {
      enable = true;
      modes = ["drun" "window" "ssh" "emoji"];
      plugins = [pkgs.rofi-emoji];
      extraConfig = {
        show-icons = false;
        display-drun = " ";
        display-run = " ";
        display-ssh = " ";
        display-emoji = ":)";
        display-filebrowser = " ";
        display-window = " ";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
      };
      theme = ./theme.rasi;
    };

    # Generated from stylix base16 colors
    home.file.".config/rofi/colors.rasi".text = ''
      * {
          background:     #${c.base00}FF;
          background-alt: #${c.base01}FF;
          foreground:     #${c.base05}FF;
          selected:       #${c.base0E}FF;
          active:         #${c.base02}FF;
          urgent:         #${c.base08}FF;
      }
    '';
    #home.file.".config/rofi/config.rasi".source = ./config.rasi;
    home.file.".config/rofi/fonts.rasi".source = ./fonts.rasi;
  };
}
