{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # pin nix flake registry, to avoid downloading the latest all the time
    # registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
