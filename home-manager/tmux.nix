{ pkgs, ... }:

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
