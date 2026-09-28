{ config, ... }:

{
  # process-compose itself comes from project devshells rather than this
  # config, but its settings are user level, so the theme still belongs on the
  # switch. Read-only, so its theme selector cannot persist a change; edit here.
  xdg.configFile."process-compose/settings.yaml".text = ''
    theme: ${if config.theme.dark then "Default" else "Light Modern"}
  '';
}
