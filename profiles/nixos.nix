{ ... }: {
  imports = [
    ../home-modules/default.nix
    ./cli.nix
  ];

  config = {
    my.isNixOS = true;

    modules = {
      firefox.enable = true;
      eww.enable = false;
      dunst.enable = false;
      hyprland.enable = true;
      noctalia.enable = true;
      rofi.enable = false;
      kitty.enable = true;
      vscode.enable = true;
      xdg.enable = true;
      packages.enable = true;
      scripts.enable = true;
      dev.enable = true;
      notetaking.enable = true;

      # Promote stylix to full desktop theming
      stylix.desktop = true;
    };
  };
}
