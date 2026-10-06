{...}: {
  imports = [
    ../home-modules/cli/default.nix
    ../home-modules/desktop-env/stylix
  ];

  config.modules = {
    zsh.enable = true;
    git.enable = true;
    gpg.enable = false;
    joshuto.enable = true;
    tmux.enable = true;
    starship.enable = true;

    # CLI-only theming — desktop targets off by default
    stylix.enable = true;
  };
}
