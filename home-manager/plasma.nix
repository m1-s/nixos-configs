{ pkgs, ... }:

{
  # wayland native clipboard tools. Without wl-copy, programs fall back to
  # xclip over XWayland, whose selection dies with the short lived xclip
  # process, so copied text never reaches the wayland clipboard reliably.
  home.packages = [ pkgs.wl-clipboard ];

  programs.plasma = {
    enable = true;
    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      wallpaper = ./black-background.jpg;
    };
    shortcuts = {
      "ksmserver"."Lock Session" = [ "Meta+L" "Screensaver" ];
    };
    configFile = {
      "kxkbrc"."Layout"."VariantList" = "altgr-intl";
      "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
      "kwalletrc"."Wallet"."First Use" = false;
      kscreenlockerrc."Greeter/Wallpaper/org.kde.color/General".Color =
        "0,0,0";
    };
  };
}
