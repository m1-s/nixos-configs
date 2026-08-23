{ pkgs, inputs, ... }:
let
  # Diffs are rendered with syntax highlighting, which paints comments in a mid
  # grey. Against the dark theme's diff backgrounds that grey only reaches a
  # contrast ratio of 1.5:1, so the backgrounds are darkened here. The syntax
  # colors are not part of the theme and cannot be adjusted.
  diffTheme = {
    name = "Sweet diff";
    base = "dark";
    overrides = {
      diffAdded = "rgb(20,52,25)";
      diffAddedDimmed = "rgb(34,44,36)";
      diffAddedWord = "rgb(40,110,64)";
      diffRemoved = "rgb(60,24,30)";
      diffRemovedDimmed = "rgb(48,34,36)";
      diffRemovedWord = "rgb(148,64,80)";
    };
  };

  statuslineScript = pkgs.writeShellScript "claude-statusline" ''
    input=$(cat)

    cwd=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.workspace.current_dir // .cwd // empty')
    [ -z "$cwd" ] && cwd=$(pwd)

    # Shorten home directory to ~
    cwd="''${cwd/#$HOME/~}"

    model=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.model.display_name // empty')

    # Context usage
    used=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.used_percentage // empty')
    if [ -n "$used" ]; then
      ctx_str=$(printf "ctx:%.0f%%" "$used")
    else
      ctx_str=""
    fi

    # Git branch (skip optional locks so we never block)
    branch=$(GIT_OPTIONAL_LOCKS=0 ${pkgs.git}/bin/git -C "''${cwd/#\~/$HOME}" symbolic-ref --short HEAD 2>/dev/null || true)

    # Build the line
    line=""

    # directory segment
    line="''${line}$(printf '\033[0;36m')''${cwd}$(printf '\033[0m')"

    # git branch segment
    if [ -n "$branch" ]; then
      line="''${line} $(printf '\033[0;33m')''${branch}$(printf '\033[0m')"
    fi

    # model segment
    if [ -n "$model" ]; then
      line="''${line} $(printf '\033[0;35m')''${model}$(printf '\033[0m')"
    fi

    # context segment
    if [ -n "$ctx_str" ]; then
      line="''${line} $(printf '\033[0;32m')''${ctx_str}$(printf '\033[0m')"
    fi

    printf '%s' "$line"
  '';

  # claude no longer animates its terminal title under a multiplexer, so tmux
  # cannot read the thinking state off pane_title. Publish it as a per-pane
  # option instead, which home-manager/tmux.nix colors the window name by.
  tmuxStateScript = pkgs.writeShellScript "claude-tmux-state" ''
    [ -n "''${TMUX:-}" ] && [ -n "''${TMUX_PANE:-}" ] || exit 0

    if [ "$1" = busy ]; then
      ${pkgs.tmux}/bin/tmux set-option -p -t "$TMUX_PANE" @claude_busy 1 2>/dev/null || true
    else
      ${pkgs.tmux}/bin/tmux set-option -pu -t "$TMUX_PANE" @claude_busy 2>/dev/null || true
    fi
  '';

  tmuxStateHook = state: [{
    hooks = [{
      type = "command";
      command = "${tmuxStateScript} ${state}";
    }];
  }];
in
{
  home.shellAliases.claude = "claude --dangerously-skip-permissions";

  home.file.".claude/themes/sweet-diff.json".text = builtins.toJSON diffTheme;

  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

    context = ''
      ## General

      - When creating PRs, do not include a test plan.
      - PR descriptions are a short changelog: concise bullet points, one per
        change. No prose sections, no summary paragraph.
      - When a PR changes the UI, include screenshots of the changed UI in the
        PR description. Use the github-image-upload skill to upload them.
        Lay out before/after screenshots side by side, in a two-column markdown
        table with "Before" and "After" headers.
      - Before updating a PR description (e.g. inserting screenshots), fetch its
        current body first — I may have edited it meanwhile. Edit on top of that
        state, never overwrite my changes.
      - gh extensions are installed declaratively in home-manager/gh.nix. Never
        run `gh extension install`; if an extension is missing, add it there.
      - `gh image` authenticates with the github.com `user_session` browser
        cookie, which grants full account access. Never run `gh image
        extract-token` or `check-token`, and never print that cookie's value
        into a response, file, or commit.
      - After creating a PR, watch the CI status with gh pr --watch --fail-fast.
        If it fails, create a fix, amend & force push it until the CI succeeds.
      - When watching a CI run and it exits immediately after the push, the
        branch most likely conflicts with master. Rebase on master, force push
        and watch the new run.
      - When creating a commit, never use --no-edit. Repos run formatters and
        linters as pre-commit hooks. If a formatting hook fails, it will usually
        apply it's fix automatically so you only have to stage it. If a linting hook
        fails, it may not be able to apply the fix automatically so you need to fix
        it.
      - You have the current git worktree to yourself, but other agents may be
        working in sibling worktrees of the same repository at the same time.
        Only the working tree and index are per-worktree; the stash, branches,
        tags, reflog and config are shared. So `git stash` is unreliable —
        another agent can pop or drop your entry. Commit to your own branch
        instead of stashing, leave branches you do not own alone, and never run
        `git gc` or `git worktree prune`.
      - Never mention claude code when creating PRs or commit messages.
      - Never write comments on PRs without explicit consent.
      - Never mention estimated implementation time durations.

      ## Nix

      - To build on a remote machine, use `nbr <machine> <flake-ref>` (nix build remote).
        Example: `nbr myMachine .#foo`

      ## Coding

      - Commit messages: Start with the affected code/file/business-topic (e.g., "login: ..."), not the change type (e.g., "refactor: ...").
      - Never run a project's full test suite since that takes a long time.
        Instead, only run the tests that are directly connected to the
        change/refactoring you made.
      - Prefer vertically structured code: organize code by feature/domain
        (everything for one feature lives together as a self-contained slice)
        rather than horizontally by technical layer (controllers, services,
        models in separate trees).
      - Never add comments when generating new code. Exception: doc comments in
        the language's standard documentation format (Haddock, rustdoc, JSDoc,
        docstrings, godoc, …) in the standard places — above modules, above
        top-level functions and on data type fields/constructors.
      - Keep comments extremely concise and sacrifice grammar for sake of
        concision.
    '';

    skills = {
      grill-me = ''
        ---
        name: grill-me
        description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
        ---

        Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

        Ask the questions one at a time.

        If a question can be answered by exploring the codebase, explore the codebase instead.
      '';

      github-pr-review =
        "${inputs.claude-git-pr-skill}/github-pr-review/skills/github-pr-review/SKILL.md";

      github-image-upload =
        "${inputs.gh-image-skill}/skills/github-image-upload/SKILL.md";
    };

    plugins = [ "${inputs.claude-code-plugins}/plugins/frontend-design" ];

    settings = {
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
      };
      alwaysThinkingEnabled = true;
      outputStyle = "Concise";
      theme = "custom:sweet-diff";
      tui = "fullscreen";
      skipDangerousModePermissionPrompt = true;
      statusLine = {
        type = "command";
        command = "bash ${statuslineScript}";
      };
      hooks = {
        UserPromptSubmit = tmuxStateHook "busy";
        Stop = tmuxStateHook "idle";
        Notification = tmuxStateHook "idle";
        SessionStart = tmuxStateHook "idle";
        SessionEnd = tmuxStateHook "idle";
      };
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
