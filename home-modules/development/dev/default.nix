{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.dev;
in {
  options.modules.dev = {enable = mkEnableOption "dev";};
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Rust
      cargo
      rustc

      # Python
      python3
      uv

      # Other languages
      lua
      zig
    ];
  };
}
