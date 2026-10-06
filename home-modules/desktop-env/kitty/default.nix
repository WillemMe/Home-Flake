{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.kitty;
  isWayland = config.my.displayserver == "wayland";

  sharedSettings = {
    allow_remote_control = "yes";
    background_opacity = lib.mkForce "0.97";
    confirm_os_window_close = 0;

    initial_window_width = "95c";
    initial_window_height = "35c";
    window_border_width =
      if isWayland
      then 0
      else 2;

    tab_bar_style = "fade";
    tab_fade = 1;
    active_tab_font_style = "bold";
    inactive_tab_font_style = "bold";
    term = "xterm-256color";
  };

  waylandSettings = {
    linux_display_server = "wayland";
    wayland_titlebar_color = "background";
    window_padding_width = "15 20 0 20";
    hide_window_decorations = "no";
  };

  x11Settings = {
    linux_display_server = "x11";
    input_delay = 0;
    repaint_delay = 2;
    sync_to_monitor = "no";
    wayland_enable_ime = "no";
    window_padding_width = "15 20";
  };
in {
  options.modules.kitty = {enable = mkEnableOption "kitty";};
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = lib.mkDefault pkgs.kitty;
      settings =
        sharedSettings
        // (
          if isWayland
          then waylandSettings
          else x11Settings
        );
      keybindings = {
        "kitty_mod+t" = "new_tab_with_cwd";
      };
    };
  };
}
