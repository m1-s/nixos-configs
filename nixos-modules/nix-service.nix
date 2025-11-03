{
  nix = {
    settings = {
      connect-timeout = 5;
      log-lines = 25; # this is more than default
      trusted-users = [ "@wheel" ];
      fallback = true;
    };
    extraOptions = ''
      min-free = ${toString (50 * 1024 * 1024 * 1024)} # 50 GB
      max-free = ${toString (1024 * 1024 * 1024)} # 150 GB
    '';
  };
}
