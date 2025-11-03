{ pkgs, ... }: {
  nixpkgs.overlays = [
    (_: prev: {
      path-of-building = prev.path-of-building.overrideAttrs (old:
        let
          newData = old.passthru.data.overrideAttrs (_: {
            src = pkgs.fetchFromGitHub {
              owner = "PathOfBuildingCommunity";
              repo = "PathOfBuilding";
              rev = "v2.47.3";
              hash = "sha256-wxsU178BrjdeBTTPY2C3REWlyORWI+/fFijn5oa2Gms=";
            };
          });
        in
        {
          preFixup = ''
            qtWrapperArgs+=(
              --set LUA_PATH "$LUA_PATH"
              --set LUA_CPATH "$LUA_CPATH"
              --chdir "${newData}"
            )
          '';
        });
      lutris = prev.lutris.override {
        extraLibraries =
          pkgs: with pkgs; [
            libadwaita
            gtk4
          ];
      };
    })
  ];

  home.packages = with pkgs;[
    path-of-building
    winetricks
    wineWowPackages.stable
    lutris-free
  ];
}
