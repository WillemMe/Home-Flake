{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    # cli
    ./zsh
    ./git
    ./gpg
    ./joshuto
    ./tmux
    ./starship
  ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    home-manager
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only

    # CLI utilities
    tealdeer
    htop
    wget
    rsync
    file
    unzip
    age
    pass
  ];
}
