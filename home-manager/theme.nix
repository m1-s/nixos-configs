{ lib, ... }:

{
  # The single light/dark switch. Every themeable module derives its colors
  # from this, so flipping it here flips the whole desktop.
  options.theme.dark = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether the desktop uses its dark variant.";
  };
}
