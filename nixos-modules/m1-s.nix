{
  security.sudo.wheelNeedsPassword = false;
  users.users.m1-s = {
    isNormalUser = true;
    extraGroups = [
      "libvirtd"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMr4lDExw1i0/wFYiHT2ld3rCzacnKyfQcHrjOk+AAhS michael.schneider@aegidien.de" ];
  };
  # outside of home manager as it does not have this option
  programs.ssh.startAgent = true;

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "4096";
  }];
}
