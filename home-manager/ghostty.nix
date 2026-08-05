{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${system}.ghostty;
    themes.sweet = {
      background = "#161925";
      foreground = "#c3c7d1";
      cursor-color = "#c3c7d1";
      selection-background = "#282c34";
      palette = [
        "0=#282c34"
        "1=#ed254e"
        "2=#71f79f"
        "3=#f9dc5c"
        "4=#7cb7ff"
        "5=#c74ded"
        "6=#00c1e4"
        "7=#dcdfe4"
        "8=#282c34"
        "9=#ed254e"
        "10=#71f79f"
        "11=#f9dc5c"
        "12=#7cb7ff"
        "13=#c74ded"
        "14=#00c1e4"
        "15=#dcdfe4"
      ];
    };
    settings = {
      theme = "sweet";
      custom-shader = "${./ghostty-shaders/cursor_blaze.glsl}";
      maximize = true;
    };
  };
}
