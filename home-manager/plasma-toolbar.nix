{ lib, pkgs, ... }:

let
  # the systemmonitor applet stores sensor ids as a json array *string*, not
  # as a kconfig list
  sensorIds = ids: "[${lib.concatMapStringsSep ", " (id: "\"${id}\"") ids}]";
in
{
  programs.plasma = {
    panels = [
      {
        height = 36;
        location = "bottom";
        screen = 0;
        widgets = [
          {
            name = "AndromedaLauncher";
            config.General = {
              activationIndicator = false;
              compactListItems = true;
              enableGreeting = false;
              floating = true;
              showItemsInGrid = true;
              useSystemFontSettings = true;
            };
          }
          {
            name = "org.kde.plasma.icontasks";
            config.General = {
              highlightWindows = false;
              launchers = [
                "applications:firefox.desktop"
                "applications:com.mitchellh.ghostty.desktop"
                "applications:systemsettings.desktop"
                "preferred://filemanager"
                "applications:org.kde.plasma-systemmonitor.desktop"
                "applications:thunderbird.desktop"
                "applications:net.lutris.Lutris.desktop"
              ];
            };
          }
          {
            plasmusicToolbar = {
              playbackSource = "auto";
              panelIcon.albumCover = {
                useAsIcon = true;
                fallbackToIcon = true;
                radius = 4;
              };
              songText = {
                maximumWidth = 220;
                scrolling = {
                  enable = true;
                  behavior = "alwaysScrollExceptOnHover";
                  speed = 3;
                  resetOnPause = true;
                };
              };
              musicControls.showPlaybackControls = true;
            };
          }
          {
            name = "org.kde.plasma.systemmonitor.cpucore";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              popupHeight = 564;
              popupWidth = 396;
              Appearance = {
                chartFace = "org.kde.ksysguard.linechart";
                title = "Individual Core Usage";
                updateRateLimit = 1500;
              };
              SensorColors = {
                "cpu/cpu0/usage" = "61,174,233";
                "cpu/cpu1/usage" = "61,122,233";
                "cpu/cpu10/usage" = "233,120,61";
                "cpu/cpu11/usage" = "233,172,61";
                "cpu/cpu12/usage" = "233,223,61";
                "cpu/cpu13/usage" = "191,233,61";
                "cpu/cpu14/usage" = "140,233,61";
                "cpu/cpu15/usage" = "88,233,61";
                "cpu/cpu16/usage" = "61,233,86";
                "cpu/cpu17/usage" = "61,233,137";
                "cpu/cpu18/usage" = "61,233,189";
                "cpu/cpu19/usage" = "61,226,233";
                "cpu/cpu2/usage" = "61,71,233";
                "cpu/cpu3/usage" = "103,61,233";
                "cpu/cpu4/usage" = "154,61,233";
                "cpu/cpu5/usage" = "206,61,233";
                "cpu/cpu6/usage" = "233,61,208";
                "cpu/cpu7/usage" = "233,61,157";
                "cpu/cpu8/usage" = "233,61,105";
                "cpu/cpu9/usage" = "233,68,61";
              };
              Sensors = {
                highPrioritySensorIds = sensorIds [ "cpu/cpu.*/usage" ];
                totalSensors = sensorIds [ "cpu/all/usage" ];
              };
              "org.kde.ksysguard.barchart/General" = {
                showGridLines = false;
                showLegend = false;
                showYAxisLabels = false;
              };
            };
          }
          {
            name = "org.kde.plasma.systemmonitor.net";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              popupHeight = 234;
              popupWidth = 244;
              Appearance = {
                chartFace = "org.kde.ksysguard.linechart";
                title = "Network Speed";
                updateRateLimit = 1500;
              };
              SensorColors = {
                "network/all/download" = "197,14,210";
                "network/all/upload" = "27,210,14";
              };
              Sensors.highPrioritySensorIds = sensorIds [
                "network/all/download"
                "network/all/upload"
              ];
            };
          }
          {
            name = "org.kde.plasma.systemmonitor.memory";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              popupHeight = 236;
              popupWidth = 236;
              Appearance = {
                chartFace = "org.kde.ksysguard.piechart";
                showTitle = true;
                title = "Memory Usage";
                updateRateLimit = 5000;
              };
              SensorColors."memory/physical/used" = "61,174,233";
              Sensors = {
                highPrioritySensorIds = sensorIds [ "memory/physical/used" ];
                lowPrioritySensorIds = sensorIds [ "memory/physical/total" ];
                totalSensors = sensorIds [ "memory/physical/usedPercent" ];
              };
              "FaceGrid/Appearance" = {
                chartFace = "org.kde.ksysguard.linechart";
                showTitle = false;
              };
              "FaceGrid/SensorColors"."memory/physical/used" = "61,174,233";
              "FaceGrid/Sensors".highPrioritySensorIds = sensorIds [ "memory/physical/used" ];
            };
          }
          {
            name = "org.kde.plasma.systemmonitor.diskusage";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              popupHeight = 217;
              popupWidth = 196;
              Appearance = {
                chartFace = "org.kde.ksysguard.piechart";
                showTitle = true;
                title = "Disk Usage";
                updateRateLimit = 10000;
              };
              SensorColors = {
                "disk/.*/usedPercent" = "61,174,233";
                "disk/898c6aee-5669-4d4e-97f3-5639f25206f1/usedPercent" = "61,174,233";
                "disk/all/usedPercent" = "233,120,61";
              };
              Sensors = {
                highPrioritySensorIds = sensorIds [ "disk/all/usedPercent" ];
                lowPrioritySensorIds = sensorIds [ "disk/all/total" ];
                totalSensors = sensorIds [ "disk/all/usedPercent" ];
              };
              "FaceGrid/Appearance" = {
                chartFace = "org.kde.ksysguard.linechart";
                showTitle = false;
                updateRateLimit = 10000;
              };
              "FaceGrid/SensorColors" = {
                "disk/.*/usedPercent" = "61,174,233";
                "disk/898c6aee-5669-4d4e-97f3-5639f25206f1/usedPercent" = "61,174,233";
                "disk/all/usedPercent" = "233,120,61";
              };
              "FaceGrid/Sensors".highPrioritySensorIds = sensorIds [ "disk/all/usedPercent" ];
            };
          }
          {
            name = "org.kde.plasma.volume";
            config = {
              popupHeight = 386;
              popupWidth = 440;
              General.migrated = true;
            };
          }
          {
            name = "org.kde.plasma.brightness";
            config = {
              popupHeight = 286;
              popupWidth = 400;
            };
          }
          {
            name = "org.kde.plasma.networkmanagement";
            config = {
              popupHeight = 385;
              popupWidth = 366;
            };
          }
          {
            name = "org.kde.plasma.bluetooth";
            config = {
              popupHeight = 441;
              popupWidth = 440;
            };
          }
          {
            name = "org.kde.plasma.battery";
            config = {
              popupHeight = 326;
              popupWidth = 376;
              General.showPercentage = true;
            };
          }
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              popupHeight = 475;
              popupWidth = 584;
              Appearance = {
                displayTimezoneFormat = "UTCOffset";
                showLocalTimezone = true;
                use24hFormat = 2;
              };
            };
          }
        ];
      }
    ];
  };

  # plasma-manager adds the panel widgets via addWidget in a *live* plasmashell,
  # which writes its default linechart face back over the piechart we set. run
  # after the panel script but before run_all.sh restarts plasmashell, so the
  # restart picks our value up. applet ids change on every recreation, so look
  # them up by plugin name.
  home.file.".local/share/plasma-manager/scripts/4_fix_chartface.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      appletsrc="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
      [ -f "$appletsrc" ] || exit 0

      for plugin in \
        org.kde.plasma.systemmonitor.memory \
        org.kde.plasma.systemmonitor.diskusage; do
        awk -v p="$plugin" '
          /^\[Containments\]\[[0-9]+\]\[Applets\]\[[0-9]+\]$/ {
            c = $0; a = $0
            sub(/^\[Containments\]\[/, "", c); sub(/\].*/, "", c)
            sub(/^.*\[Applets\]\[/, "", a); sub(/\]$/, "", a)
            next
          }
          $0 == "plugin=" p { print c, a }
        ' "$appletsrc" | while read -r c a; do
          ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file "$appletsrc" \
            --group Containments --group "$c" --group Applets --group "$a" \
            --group Configuration --group Appearance \
            --key chartFace org.kde.ksysguard.piechart
        done
      done
    '';
  };

}
