{ inputs, ... }: {
  imports = [
    ./nixos-modules/experimental.nix
    ./nixos-modules/m1-s.nix
    ./nixos-modules/virtualization.nix
    ./nixos-modules/zsh.nix
    ./nixos-modules/nix-service.nix
    inputs.private-config.default
    inputs.home-manager.nixosModules.home-manager
  ];
}
