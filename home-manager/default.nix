{ pkgs, ... }:
let
  configDir = "~/repos/nixos-configs";
in
{
  imports = [
    ./nvim
    ./git.nix
    ./tmux.nix
    ./ghostty.nix
    ./claude-code.nix
  ];

  home.shellAliases = rec {
    claude = "claude --dangerously-skip-permissions";
    nrs = "sudo nixos-rebuild switch --flake ${configDir} && exec zsh";
    nrt = "sudo nixos-rebuild test --flake ${configDir} && exec zsh";
    nru = "nix flake update --flake ${configDir} && ${nrs}";
    gacp = "gaa && gcn! && gpf";
    cat = "bat --paging=never --style=header,grid,header-filesize,header";
    ndr = "nix-direnv-reload";
    nix-shell = "nix-shell --run zsh";
    fb = "feedback -- ";
    gpb = "git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == \"[gone]\" {sub(\"refs/heads/\", \"\", $1); print $1}'); do git branch -D $branch; done";
    wss = "watson start supercede";
    ws = "watson stop";
  };

  programs = {
    home-manager.enable = true;
    autojump.enable = true;
    lazygit = {
      enable = true;
      settings = {
        gui.skipDiscardChangeWarning = true;
        refresher.refreshInterval = 60;
        git.pagers = [{ pager = "delta --dark --paging=never"; }];
      };
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      initContent = pkgs.lib.mkOrder 550 ''
        fpath+="/etc/profiles/per-user/maksim/share/zsh/site-functions"
        gbdr(){ git branch -D $1; git push -d origin $1 }
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "copybuffer"
          "copyfile"
          "dirhistory"
          "git"
          "history"
          "web-search"
        ];
        theme = "agnoster";
        extraConfig = "DISABLE_MAGIC_FUNCTIONS=true;";
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          ForwardAgent = false;
          AddKeysToAgent = "yes";
          Compression = false;
          ServerAliveInterval = 30;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          IdentityFile = "~/.ssh/id_ed25519";
        };

        miniature-train = {
          HostName = "192.168.178.107";
          User = "m1-s";
        };
      };
    };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "nbr" ''
      machine="$1"; shift
      exec nom build --max-jobs 0 --builders-use-substitutes --builders "ssh-ng://$machine x86_64-linux - 64 1 nixos-test,kvm" "$@"
    '')
  ] ++ (with pkgs; [
    bat
    cachix
    delta
    cntr
    curl
    discord
    duf
    feedback
    firefox
    git-crypt
    hollywood
    htop
    httpie
    jo
    jq
    libreoffice
    magic-wormhole
    mtr
    fastfetch
    niv
    nix-diff
    nix-output-monitor
    nix-tree
    nixos-anywhere
    nixpkgs-fmt
    scanmem
    shfmt
    signal-desktop
    sl
    spotify
    thunderbird
    tig
    tree
    unrar
    vimgolf
    vimv
    vlc
    vscodium
    watson
    websocat
    wget
    wgnord
    gh
    pueue
  ]);
}
