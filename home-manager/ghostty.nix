{
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (config.theme) dark;
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
    # sweet's hues darkened until they carry on a light background
    themes.sweet-light = {
      background = "#f5f6f8";
      foreground = "#2f3547";
      cursor-color = "#2f3547";
      selection-background = "#dfe3ea";
      palette = [
        "0=#3a3f4b"
        "1=#c01742"
        "2=#1f8f4d"
        "3=#9a7b00"
        "4=#1f5fc0"
        "5=#8b21ad"
        "6=#00738a"
        "7=#4a5163"
        "8=#3a3f4b"
        "9=#c01742"
        "10=#1f8f4d"
        "11=#9a7b00"
        "12=#1f5fc0"
        "13=#8b21ad"
        "14=#00738a"
        "15=#4a5163"
      ];
    };
    settings = {
      theme = if dark then "sweet" else "sweet-light";
      # ghostty defaults shift+insert to the primary selection, while GTK/Qt
      # apps paste the clipboard from it. Match the apps, so the same key works
      # everywhere for text that was copied rather than mouse selected.
      keybind = [ "shift+insert=paste_from_clipboard" ];
      # drop the toast ghostty shows on every clipboard copy, keep the one for
      # config reloads
      app-notifications = "no-clipboard-copy";
      custom-shader = "${./ghostty-shaders/cursor_blaze.glsl}";
      maximize = true;
    };
  };
}
