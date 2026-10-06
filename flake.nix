#Flake to use when standalone
{
  description = "Standalone flake for home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dorps-neovim = {
      # Replace with the URL of the published Dorps-NVIM repo, or any flake
      # that exposes `packages.<system>.default` (your neovim build).
      url = "github:<you>/Dorps-NVIM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      dorps-neovim,
      voxtype,
      stylix,
      ...
    }:
    let
      # One entry per host. To add a host, copy an entry, create
      # hosts/<hostname>/home-modules.nix, and see the README.
      systems = [
        {
          hostname = "example"; # must match the directory name under hosts/
          username = "myuser"; # replace with your username
          system = "x86_64-linux";
          # Optional per-host home-manager modules, e.g. voxtype, or nix
          # settings on a non-NixOS machine:
          # extraModules = [
          #   voxtype.homeManagerModules.default
          #   { _module.args.voxtype = voxtype; }
          #   { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
          # ];
        }
      ];
      mkHomeManager =
        {
          system,
          hostname,
          username,
          displayserver ? "wayland",
          extraModules ? [ ],
        }:
        let
          # Module that declares the option and sets it
          myDisplayModule = { lib, ... }: {
            options.my = {
              displayserver = lib.mkOption {
                type = lib.types.enum [
                  "x"
                  "wayland"
                ];
                default = "wayland";
                description = "Which display server this home profile targets.";
                example = "x";
              };
              isNixOS = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether this home profile is running on NixOS.";
              };
            };

            config = {
              my.displayserver = lib.mkDefault displayserver;
            };
          };

          modules = [
            stylix.homeModules.stylix

            myDisplayModule
            ./hosts/${hostname}/home-modules.nix
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.stateVersion = "26.05";
            }
            {
              home.packages = [
                dorps-neovim.packages.${system}.default
              ];
            }
          ]
          ++ extraModules;

          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          modules = modules;
          config = home-manager.lib.homeManagerConfiguration {
            inherit pkgs modules;
          };
        };

      # Home manager for standalone
      homeConfigurations = builtins.listToAttrs (
        map (
          {
            username,
            hostname,
            ...
          }@entry:
          {
            name = "${username}";
            value = (mkHomeManager entry).config;
          }
        ) systems
      );

      # Homemanager module install for NixOS user
      homeManagerModules = builtins.listToAttrs (
        map (
          {
            username,
            hostname,
            ...
          }@entry:
          {
            name = "${username}@${hostname}";
            value = {
              imports = (mkHomeManager entry).modules;
            };
          }
        ) systems
      );
    in
    {
      inherit homeConfigurations homeManagerModules;
    };
}
