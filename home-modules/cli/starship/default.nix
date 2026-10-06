{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.starship;

  activeProfile = "rightprompt"; # <-- change this to switch prompt style
  # Valid values:  plain | "minimal" | "powerline" | "pentest" | "compact" | "rightprompt"
in {
  options.modules.starship = {enable = mkEnableOption "starship";};

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = builtins.fromTOML (
        builtins.readFile ./starship-profiles/${activeProfile}.toml
      );
    };

    home.file."${config.xdg.configHome}/starship-minimal.toml".source = ./starship-profiles/minimal.toml;
  };
}
