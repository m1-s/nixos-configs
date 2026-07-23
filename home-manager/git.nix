{
  programs.git-absorb.enable = true;

  programs.git = {
    enable = true;

    settings = {
      user.name = "Michael Schneider";
      user.email = "michael@m1-s.com";
      pull.ff = "only";
      # diff.external = "${pkgs.difftastic}/bin/difft";
      # diff.tool = "nvimdiff";
      # difftool.prompt = false;
      # merge.tool = "nvimdiff";
      # merge.conflictstyle = "diff3";
      # mergetool = {
      #   prompt = false;
      #   vimdiff.layout = "LOCAL,REMOTE/MERGED";
      #   hideResolved = true;
      # };
      rerere.enabled = true;
      log.decorate = true;
      stash.showPatch = true;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      advice = {
        detachedHead = false;
        forceDeleteBranch = false;
      };
    };
  };
}
