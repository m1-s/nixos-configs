{
  programs.plasma = {
    panels = [
      {
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
              Sensors = {
                highPrioritySensorIds = [ "cpu/cpu.*/usage" ];
                totalSensors = [ "cpu/all/usage" ];
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
              Sensors.highPrioritySensorIds = [
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
                highPrioritySensorIds = [ "memory/physical/used" ];
                lowPrioritySensorIds = [ "memory/physical/total" ];
                totalSensors = [ "memory/physical/usedPercent" ];
              };
              "FaceGrid/Appearance" = {
                chartFace = "org.kde.ksysguard.linechart";
                showTitle = false;
              };
              "FaceGrid/SensorColors"."memory/physical/used" = "61,174,233";
              "FaceGrid/Sensors".highPrioritySensorIds = [ "memory/physical/used" ];
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
                highPrioritySensorIds = [ "disk/all/usedPercent" ];
                lowPrioritySensorIds = [ "disk/all/total" ];
                totalSensors = [ "disk/all/usedPercent" ];
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
              "FaceGrid/Sensors".highPrioritySensorIds = [ "disk/all/usedPercent" ];
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
}
