{
  systemd.services.battery-conservation-mode = {
    description = "Keep battery charge limited to conservation mode";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "echo Long_Life > /sys/class/power_supply/BAT0/charge_types";
  };
}
