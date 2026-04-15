{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" "uid-range" ];
    # nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # pin nix flake registry, to avoid downloading the latest all the time
    # registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
