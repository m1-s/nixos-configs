{
  security.sudo.wheelNeedsPassword = false;
  users.users.m1-s = {
    isNormalUser = true;
    extraGroups = [
      "kvm"
      "libvirtd"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      # tower
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6W6sqrJAV0JjASRVvr+HMRp3p46UnmKJXbU1MFaySkBCViVVIarey+Od9JsVp8qhOLPNdd060b5Jjbe76nCpFCVhh45+OX7QhVPpluT8yyr6PzOdDvp1kirSiyeeXlr0VfluXGPRSJXhH33GOSyPiXxwVUQ3YxUo4KQVe1q6eAvwX6/UROmMgdnDdvooC2qKO98IKFu0p9zfWtm6WSmtCeMfu38QG+lq8axpPUbYTsDfZ5PZm/QA053Jt+rt8YiohU+cP2hhgSIcVrQOZAYfc7AzzSPRDU0aMdHhJNh+ivX0eRjYKqpkTZclbY0xEOb55mkWdlVs2+sUs0dYuN3oFocADN6RC1qX6vV9GwUjBiWV+jMjRJCnTn5yh8Ht+YbK6I1zVvvYstFjIT1S5RBx81iahBAARs1PCwls3eT06+KZLb1jA1CD8RXl63Dy+m+AmLqBeX8/cyMegv/rUJQRJK+WeCF5u9QCEwT2AaNVmtWXkCSsCxHgorUTvMVW/RkM= michael@DESKTOP-05A25P3"
    ];
  };
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "4096";
  }];
}
