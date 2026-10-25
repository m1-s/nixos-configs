{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  # The channel's gh-stack is several releases behind upstream.
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

  # gh-stack appends an attribution footer to every PR body it generates and
  # exposes no option to turn it off.
  gh-stack = unstable.gh-stack.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace cmd/submit.go \
        --replace-fail "parts = append(parts, footer)" "_ = footer"
    '';
    # upstream's submit tests assert the footer this patch removes
    doCheck = false;
  });
in
{
  home.sessionVariables.GH_STACK_NO_UPDATE_NOTIFIER = "1";

  programs.gh = {
    enable = true;
    extensions = [ gh-stack ];
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };
}
