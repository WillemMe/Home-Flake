{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.noctalia;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  options.modules.noctalia = {
    enable = mkEnableOption "noctalia";
  };

  config = mkIf cfg.enable {
    # HM module installs the package itself — no environment.systemPackages entry needed.
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = (builtins.fromTOML (builtins.readFile ./noctalia.toml));
    };
  };
}
