{ pkgs, inputs, ... }:
let
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
in
{
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

    context = ''
      ## About me

      - German freelancer working in IT

      ## General

      - When creating PRs, do not include a test plan.
      - After creating a PR, watch the CI status with gh pr --watch --fail-fast.
        If it fails, create a fix, amend & force push it until the CI succeeds.
      - When creating a commit, never use --no-edit. Repos run formatters and
        linters as pre-commit hooks. If a formatting hook fails, it will usually
        apply it's fix automatically so you only have to stage it. If a linting hook
        fails, it may not be able to apply the fix automatically so you need to fix
        it.
      - Never mention claude code when creating PRs or commit messages.
      - Never write comments on PRs without explicit consent.
      - Always use pueue for ANY command that might take longer than 10
        seconds to avoid timeouts. This includes but is not limited to:
        - Any build operations (nix build, make, ninja, cargo, ghci)
        - Any test runs that might be slow
        Each instance must use its own pueue group (derived from the git repo
        folder name) so that jobs from the same instance run sequentially while
        different instances run in parallel.
        To run and wait (note: quote the entire command to preserve argument quoting):
        ```bash
        # Set up the group (idempotent, safe to run every time)
        GROUP="$(basename "$(git rev-parse --show-toplevel)")"
        pueue group add "$GROUP" 2>/dev/null || true
        pueue parallel 1 -g "$GROUP"
        pueue add -g "$GROUP" -- 'command arg1 "arg with spaces"'
        pueue follow <task-id> | tail -n 10 # waits for the command to finish
        ```

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
      - Do not write code comments that duplicate information already present
        in the code. Comments should explain why, not restate what the code
        already says.
      - DO NOT comment on self-explanatory code (e.g., `x = x + 1 // increment x`).
      - Code comments must be timeless. Do not write comments that reference a
        previous iteration of the code or explain how it changed (e.g., "now we
        do X instead of Y", "switched from A to B"). Nobody reading the code can
        see the previous version, so such comments only confuse. Describe the
        code as it is, not how it came to be.
      - Comments must be understandable from just the code. They must not rely on
        prior knowledge from a conversation with an AI or a previous debugging
        session. A reader seeing the code for the first time must be able to make
        full sense of the comment.
    '';

    skills.grill-me = ''
      ---
      name: grill-me
      description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
      ---

      Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

      Ask the questions one at a time.

      If a question can be answered by exploring the codebase, explore the codebase instead.
    '';

    skills.github-pr-review =
      "${inputs.claude-git-pr-skill}/github-pr-review/skills/github-pr-review/SKILL.md";

    settings = {
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
      };
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      statusLine = {
        type = "command";
        command = "bash ${statuslineScript}";
      };
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
