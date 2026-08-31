{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  herdr = inputs.nixpkgs-unstable.legacyPackages.${system}.herdr;

  # `herdr integration install claude` rewrites ~/.claude/settings.json, which
  # home-manager owns as a read-only store symlink. The hook script and the
  # SessionStart entry below replicate what that installer would have written.
  # The bundled asset shells out to python3, which is not otherwise on PATH.
  claudeHook = pkgs.writeShellScript "herdr-claude-agent-state" ''
    export PATH=${pkgs.lib.makeBinPath [ pkgs.python3 ]}:$PATH
    exec ${pkgs.bash}/bin/bash \
      ${herdr.src}/src/integration/assets/claude/herdr-agent-state.sh "$@"
  '';
in
{
  home.packages = [ herdr ];

  # Read-only, so herdr's own settings tab cannot persist changes; edit here.
  # Each keybinding takes a list, so the tmux keys sit next to herdr's defaults
  # instead of replacing them. prefix+s is the exception: tmux's session picker
  # collides with herdr's settings, which moves to prefix+shift+s.
  xdg.configFile."herdr/config.toml".text = ''
    onboarding = false

    [ui]
    agent_panel_sort = "spaces"
    status_indicators = "dots"
    show_agent_labels_on_pane_borders = false

    [ui.sound]
    enabled = false

    # Updates come from nixpkgs, so the background check is pure egress.
    [update]
    version_check = false
    manifest_check = false

    [keys]
    split_vertical = [ "prefix+percent", "prefix+v" ]
    split_horizontal = [ "prefix+double_quote", "prefix+minus" ]
    detach = [ "prefix+d", "prefix+q" ]
    rename_tab = [ "prefix+comma", "prefix+shift+t" ]
    close_tab = [ "prefix+ampersand", "prefix+shift+x" ]
    last_pane = "prefix+semicolon"
    focus_pane_left = [ "prefix+left", "prefix+h" ]
    focus_pane_down = [ "prefix+down", "prefix+j" ]
    focus_pane_up = [ "prefix+up", "prefix+k" ]
    focus_pane_right = [ "prefix+right", "prefix+l" ]
    workspace_picker = [ "prefix+s", "prefix+w" ]
    settings = "prefix+shift+s"
  '';

  programs.claude-code = {
    skills.herdr = "${herdr}/share/herdr/skills/herdr/SKILL.md";

    settings.hooks.SessionStart = [
      {
        matcher = "*";
        hooks = [
          {
            type = "command";
            command = "${claudeHook} session";
            timeout = 10;
          }
        ];
      }
    ];
  };
}
