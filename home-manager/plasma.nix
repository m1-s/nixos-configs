{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.theme) dark;
in
{
  imports = [ ./plasma-toolbar.nix ];

  home = {
    # wayland native clipboard tools. Without wl-copy, programs fall back to
    # xclip over XWayland, whose selection dies with the short lived xclip
    # process, so copied text never reaches the wayland clipboard reliably.
    packages = [ pkgs.wl-clipboard ];

    # kwin and plasma-apply-colorscheme resolve these by name from the data
    # dirs, so both have to be on disk before the workspace can select them.
    file = {
      ".local/share/color-schemes/Sweet.colors".source = ./sweet.colors;
      ".local/share/aurorae/themes/Sweet-Dark".source = ./aurorae/Sweet-Dark;
    };

    activation.applyPlasmaToSession =
      lib.hm.dag.entryAfter
        [
          "reloadSystemd"
          "configure-plasma"
        ]
        ''
          if ${pkgs.systemd}/bin/systemctl --user is-active --quiet plasma-workspace.target; then
            run ${pkgs.systemd}/bin/systemctl --user start plasma-manager-apply.service
          fi
        '';
  };

  systemd.user.services.plasma-manager-apply = {
    Unit = {
      Description = "Apply plasma-manager settings to the running session";
      After = [ "plasma-workspace.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.xdg.dataHome}/plasma-manager/run_all.sh";
    };
  };

  programs.plasma = {
    enable = true;
    workspace = {
      theme = if dark then "breeze-dark" else "breeze-light";
      colorScheme = if dark then "Sweet" else "BreezeLight";
      wallpaper = ./black-background.jpg;
      windowDecorations =
        if dark then
          {
            library = "org.kde.kwin.aurorae.v2";
            theme = "__aurorae__svg__Sweet-Dark";
          }
        else
          {
            library = "org.kde.breeze";
            theme = "Breeze";
          };
    };
    shortcuts = {
      "ksmserver"."Lock Session" = [
        "Meta+L"
        "Screensaver"
      ];
    };
    configFile = {
      "kxkbrc"."Layout"."VariantList" = "altgr-intl";
      "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
      # KDE writes these into the session environment, so they have to name
      # locales glibc actually generates.
      "plasma-localerc"."Formats"."LC_MEASUREMENT" = "de_DE.UTF-8";
      "plasma-localerc"."Formats"."LC_MONETARY" = "de_DE.UTF-8";
      "kwalletrc"."Wallet"."First Use" = false;
      kscreenlockerrc."Greeter/Wallpaper/org.kde.color/General".Color = "0,0,0";
    };
  };
}
