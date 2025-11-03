{
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
