{ pkgs, ... }: {
  home.packages = with pkgs;[
    rusty-path-of-building
    starsector
    winetricks
    wineWow64Packages.stable
    lutris-free
    wowup-cf
  ];
}
