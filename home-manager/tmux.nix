{ pkgs, ... }:

let
  # claude sets the terminal title to the session topic, which tmux tracks as
  # pane_title. Use it as the window name, glyph included. The pane loop means
  # any claude pane in the window wins, so opening a second pane cannot take the
  # name over; only windows without any claude pane fall back to tmux's default.
  hasClaude = "#{P:#{?#{==:#{pane_current_command},claude},1,}}";
  claudeTopic = "#{P:#{?#{==:#{pane_current_command},claude},#{=/27/…:pane_title},}}";
  tmuxDefaultName = "#{?pane_in_mode,[tmux],#{pane_current_command}}#{?pane_dead,[dead],}";
  windowName = "#{?${hasClaude},${claudeTopic},${tmuxDefaultName}}";

  # claude pins its title glyph to ✳ under a multiplexer, so the title carries no
  # state anymore. The state comes from the @claude_busy pane option that claude's
  # hooks set (see claude-code.nix): yellow while thinking, green when done. Busy
  # sets the option and idle unsets it, so the pane loop cannot concatenate two
  # idle panes into a truthy "00".
  claudeBusy = "#{P:#{?#{==:#{pane_current_command},claude},#{@claude_busy},}}";
  claudeColor = "#[fg=#{?${claudeBusy},yellow,green}]";

  # tmux only re-evaluates automatic-rename-format when a pane produces output,
  # so an idle claude window would keep a stale name. Render the same thing in
  # the status line, which is re-expanded on every redraw.
  windowStatus = "#I:#{?${hasClaude},${claudeColor}${claudeTopic}#[default],${tmuxDefaultName}}#{?window_flags,#{window_flags}, }";

  # choose-tree's default format prints the window name and, for single pane
  # windows, the pane title behind it — which is the same topic twice. Show the
  # untruncated topic instead for claude windows, default rendering otherwise.
  claudeTopicFull = "#{P:#{?#{==:#{pane_current_command},claude},#{pane_title},}}";
  paneTitleSuffix = ''#{?#{&&:#{pane_title},#{!=:#{pane_title},#{host_short}}},: "#{pane_title}",}'';
  treeWindowLine = "#{?${hasClaude},${claudeColor}${claudeTopicFull}#[default]#{window_flags},#{window_name}#{window_flags}#{?#{==:#{window_panes},1},${paneTitleSuffix},}}";
  treeFormat = "#{?pane_format,#{?pane_marked,#[reverse],}#{pane_current_command}#{?pane_active,*,}#{?pane_marked,M,}${paneTitleSuffix},#{?window_format,#{?window_marked_flag,#[reverse],}${treeWindowLine},#{session_windows} windows#{?session_grouped, (group #{session_group}: #{session_group_list}),}#{?session_attached, (attached),}}}";
in
{
  programs.tmux = {
    aggressiveResize = true;
    clock24 = true;
    enable = true;
    historyLimit = 50000;
    keyMode = "vi";
    sensibleOnTop = true;
    focusEvents = true;
    disableConfirmationPrompt = true;
    escapeTime = 1; # set to 1 because 0 prints strange characters
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    extraConfig = ''
      # without this tmux quantizes 24 bit colors to the 256 color palette,
      # which distorts the color schemes of TUIs running inside it
      set -ag terminal-features ",*:RGB"

      # sync tmux buffer with terminal clipboard
      set -g set-clipboard on

      set -g automatic-rename-format "${windowName}"
      set -g window-status-format "${windowStatus}"
      set -g window-status-current-format "${windowStatus}"

      bind s choose-tree -Zs -F '${treeFormat}'
      bind w choose-tree -Zw -F '${treeFormat}'

      # tmux highlights the selected choose-tree line with its default yellow
      # background, which swallows the yellow thinking color. A dark bar keeps
      # both state colors readable.
      set -g mode-style "noattr,bg=#3a4152,fg=default"

      # re-expand the status line every second so a state change in a background
      # window shows up without waiting for that window to produce output
      set -g status-interval 1

      set -g repeat-time 0
      set -g pane-base-index 1
      # make pane switching non repeatable to avoid collisions with opening
      # shell history
      bind-key    Up    select-pane -U
      bind-key    Down  select-pane -D
      bind-key    Left  select-pane -L
      bind-key    Right select-pane -R

      # new windows open in same directory when split
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Styles the active pane border. Helps when you have
      # more than two panes.
      set-option -g renumber-windows on
      set -g visual-activity on

      # start window indexing at one instead of zero
      set -g base-index 1

      # Use vim keybindings in copy mode
      setw -g mode-keys vi
    '';
    plugins = with pkgs.tmuxPlugins; [
      tmux-colors-solarized
      vim-tmux-navigator
      {
        plugin = tmux-thumbs;
        extraConfig = ''
          unbind f
          set -g @thumbs-key f
          set -g @thumbs-command "tmux set-buffer -w -- {} && tmux paste-buffer && tmux save-buffer - | xclip -i"
          set -g @thumbs-upcase-command "command -v xdg-open {} && xdg-open {} || command -v open && open {}"
          # match sri und sha256 hashes for nix
          set -g @thumbs-regexp-1 '(sha256-[0-9a-zA-z=/+]{44}|[0-9a-f]{7,40}|[0-9a-z]{52})'
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
        '';
      }
    ];
  };
}
