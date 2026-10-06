{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.notetaking;
in {
  options.modules.notetaking = {enable = mkEnableOption "notetaking";};
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
      nextcloud-client
    ];
  };
}
