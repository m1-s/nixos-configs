{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  # gh-image's go.mod requires a Go newer than the pinned channel provides, and
  # the channel's gh-stack is several releases behind upstream.
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

  # Uploads screenshots to GitHub; the gh CLI has no API for attachments.
  # Same source as the github-image-upload skill in claude-code.nix.
  gh-image = unstable.buildGoModule {
    pname = "gh-image";
    version = "1.2.0";
    src = inputs.gh-image-skill;
    vendorHash = "sha256-TzVyLcfpa3eN9bHQJnuPuGeiOgxYbBurFdKq0EfpJL4=";
    ldflags = [
      "-s"
      "-w"
      "-X"
      "main.version=1.2.0"
    ];
    doCheck = false;
    meta.mainProgram = "gh-image";
  };
in
{
  home.sessionVariables.GH_STACK_NO_UPDATE_NOTIFIER = "1";

  programs.gh = {
    enable = true;
    extensions = [
      gh-image
      unstable.gh-stack
    ];
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };
}
