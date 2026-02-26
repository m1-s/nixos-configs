{ pkgs, ... }: {
  home.packages = with pkgs;[
    rusty-path-of-building
    winetricks
    wineWowPackages.stable
    lutris-free
    wowup-cf
  ];
}
