{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    ghostty-shaders.url = "github:kronecorylus/ghostty-shader-playground";
    ghostty-shaders.flake = false;

    llm-agents.url = "github:numtide/llm-agents.nix";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    feedback = {
      url = "github:norfairking/feedback";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };

    # This does not contain cryptographic secrets.
    # However, it contains information that is related to my customers such as
    # IP adresses of their servers. Although these are public, I do not want to
    # disclose them.
    private-config = {
      url = "git+ssh://git@github.com/m1-s/nixos-config-private";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , home-manager
    , nixos-wsl
    , plasma-manager
    , pre-commit-hooks
    , feedback
    , ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      feedbackOverlay = _: _: { feedback = feedback.packages.${system}.default; };
      lutrisOverlay = _: prev: {
        lutris = prev.lutris.override {
          extraLibraries = pkgs: with pkgs; [ libadwaita gtk4 ];
        };
      };

      modulesFromDir =
        let
          inherit (nixpkgs) lib;
          getNixFilesInDir = dir: builtins.filter
            (file: lib.hasSuffix ".nix" file)
            (builtins.attrNames (builtins.readDir dir));
          genKey = str: lib.replaceStrings [ ".nix" ] [ "" ] str;
          moduleFrom = dir: str: { "${genKey str}" = "${dir}/${str}"; };
        in
        dir:
        builtins.foldl' (x: y: x // (moduleFrom dir y)) { } (getNixFilesInDir dir);
    in
    {
      homeManagerModules = modulesFromDir ./home-manager;

      checks.x86_64-linux = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            statix = {
              enable = true;
              settings.ignore = [ "hosts/thinkbook-hardware-config.nix" ];
            };

            deadnix.enable = true;
            deadnix.excludes = [ "hosts/thinkbook-hardware-config.nix" ];
          };
        };
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };

      nixosConfigurations = {
        tower = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            nixos-wsl.nixosModules.default
            ./common.nix
            ./hosts/tower.nix
            (_: {
              wsl.enable = true;
              home-manager = {
                extraSpecialArgs = { inherit inputs; };
                users.m1-s = { ... }: {
                  home.stateVersion = "23.11";
                  programs.home-manager.enable = true;
                  imports = with self.homeManagerModules; [
                    default
                  ];
                };
              };
            })
          ];
        };

        thinkbook = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/thinkbook.nix
            ./nixos-modules/font.nix
            ./nixos-modules/kde.nix
            ./nixos-modules/sound.nix
            ./nixos-modules/virtualization.nix
            # ./nixos-modules/miniature-trains.nix
            ./common.nix
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ feedbackOverlay lutrisOverlay ];
            }
            (_: {
              home-manager = {
                extraSpecialArgs = { inherit inputs; };
                useGlobalPkgs = true;
                sharedModules = [
                  plasma-manager.homeModules.plasma-manager
                ];
                users.m1-s = { ... }: {
                  home.stateVersion = "23.11";
                  imports = with self.homeManagerModules; [
                    default
                    plasma
                    chromium
                    gaming
                  ];
                };
              };
            })
          ];
        };
      };
    };
}
