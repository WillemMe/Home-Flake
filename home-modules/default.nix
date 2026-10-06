{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./cli
    ./desktop-env
    ./development
  ];
}
