{
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    settings = {
      connect-timeout = 5;
      log-lines = 25; # this is more than default
      trusted-users = [ "@wheel" ];
      fallback = true;
      netrc-file = "/etc/nix/netrc";
    };
  };
}
