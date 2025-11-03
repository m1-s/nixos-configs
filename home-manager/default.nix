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
  ];
  home = {
    shellAliases = rec {
      nrs = "sudo nixos-rebuild switch --flake ${configDir} && exec zsh";
      nrt = "sudo nixos-rebuild test --flake ${configDir} && exec zsh";
      nru = "nix flake update --flake ${configDir} && ${nrs}";
      gacp = "gaa && gcn! && gpf";
      cat = "bat --paging=never --style=header,grid,header-filesize,header";
      ndr = "nix-direnv-reload";
      nix-shell = "nix-shell --run zsh";
      fb = "feedback -- ";
      nv = "neovide &";
      gpb = "git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == \"[gone]\" {sub(\"refs/heads/\", \"\", $1); print $1}'); do git branch -D $branch; done";
    };
  };

  programs = {
    home-manager.enable = true;
    autojump.enable = true;
    lazygit = {
      enable = true;
      settings = {
        gui.skipDiscardChangeWarning = true;
        refresher.refreshInterval = 60;
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
      matchBlocks."*".serverAliveInterval = 30;
      extraConfig = ''
        AddKeysToAgent yes
        IdentityFile ~/.ssh/id_ed25519
      '';
    };
  };

  home.packages = with pkgs; [
    bat
    cachix
    curl
    discord
    duf
    feedback
    git-crypt
    hollywood
    htop
    httpie
    jo
    jq
    magic-wormhole
    mtr
    neofetch
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
    vimgolf
    vimv
    vlc
    vscodium
    websocat
    wget
    cntr
    firefox
    libreoffice
    unrar
  ];
}
