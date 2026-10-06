{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    # gui
    ./firefox
    ./eww
    ./dunst
    ./hyprland
    ./noctalia
    ./rofi
    ./kitty
    ./vscode
    ./voxtype
    ./gaming
    ./xdg
    ./scripts
    ./stylix
    ./notetaking
    ./packages
  ];
}
