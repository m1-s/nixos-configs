{
  imports = [ ./thinkbook-hardware-config.nix ];
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices."luks-e6657e6a-15e8-4274-95dc-abf3814e2d2c".device = "/dev/disk/by-uuid/e6657e6a-15e8-4274-95dc-abf3814e2d2c";
    tmp.cleanOnBoot = true;
  };
  system.stateVersion = "23.11";
  networking.hostName = "thinkbook";
  networking.networkmanager.enable = true;
  services.automatic-timezoned.enable = true;
  hardware.bluetooth.enable = true;
  programs.gnupg.agent.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  programs.steam.enable = true;

  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "m1-s" ];
}
