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

  # herdr has no equivalent of tmux's automatic-rename-format: a tab shows its
  # custom_name or its index, never a pane title. So push the topic instead,
  # taken from the title claude sets on its pane with the spinner glyph already
  # stripped. State stays in herdr's own status dots, not in the name.
  tabTitleScript = pkgs.writeShellScript "herdr-claude-tab-title" ''
    [ "''${HERDR_ENV:-}" = 1 ] || exit 0

    pane=$(${herdr}/bin/herdr pane current --current 2>/dev/null) || exit 0
    topic=$(${pkgs.jq}/bin/jq -r '.result.pane.terminal_title_stripped // empty' <<< "$pane")
    tab=$(${pkgs.jq}/bin/jq -r '.result.pane.tab_id // empty' <<< "$pane")
    [ -n "$topic" ] && [ -n "$tab" ] || exit 0

    ${herdr}/bin/herdr tab rename "$tab" "$topic" >/dev/null 2>&1 || true
  '';

  tabTitleHook = [
    {
      hooks = [
        {
          type = "command";
          command = "${tabTitleScript}";
        }
      ];
    }
  ];
in
{
  home.packages = [ herdr ];

  # Read-only, so herdr's own settings tab cannot persist changes; edit here.
  # Each keybinding takes a list, so the tmux keys sit next to herdr's defaults
  # instead of replacing them. prefix+s is the exception: tmux's session picker
  # collides with herdr's settings, which moves to prefix+shift+s.
  # tmux's two choose-tree binds split by depth: s picks a session (workspace),
  # w picks a window (tab). herdr has no tab picker, so w opens the goto tree,
  # which is the only surface listing tabs.
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
    workspace_picker = "prefix+s"
    goto = [ "prefix+w", "prefix+g" ]
    settings = "prefix+shift+s"
  '';

  programs.claude-code = {
    skills.herdr = "${herdr}/share/herdr/skills/herdr/SKILL.md";

    settings.hooks = {
      SessionStart = [
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

      Stop = tabTitleHook;
      UserPromptSubmit = tabTitleHook;
    };
  };
}
