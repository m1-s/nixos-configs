{ pkgs, ... }: {
  home.packages = with pkgs;[
    rusty-path-of-building
    winetricks
    wineWow64Packages.stable
    lutris-free
    wowup-cf
  ];
}
