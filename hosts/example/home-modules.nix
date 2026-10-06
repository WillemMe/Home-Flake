# Example host. Copy this directory to hosts/<your-hostname>/ and edit.
# Host files only contain overrides on top of a profile.
{ ... }: {
  # Replace with ../../profiles/nixos.nix on NixOS for the full desktop.
  imports = [ ../../profiles/cli.nix ];

  # Host-specific overrides, e.g.:
  # config.modules = {
  #   gaming.enable = true;
  # };
}
