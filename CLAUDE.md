# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal NixOS flake managing two hosts via NixOS + home-manager. Pinned to the `nixos-26.05` channel.

## Commands

Aliases (defined in `home-manager/default.nix`) target the live checkout at `~/repos/nixos-configs`:

- `nrs` — `nixos-rebuild switch` for the current host, then re-exec zsh
- `nrt` — `nixos-rebuild test` (apply without making it the boot default)
- `nru` — `nix flake update` then `nrs`
- `nbr <machine> <flake-ref>` — build a flake ref on a remote builder (e.g. `nbr tower .#nixosConfigurations.tower.config.system.build.toplevel`)

Build a host without switching (use a pueue group per the global instructions, this is slow):

```bash
nix build .#nixosConfigurations.thinkbook.config.system.build.toplevel
```

Lint / format runs as pre-commit hooks (configured in `flake.nix` `checks.pre-commit-check`): `nixpkgs-fmt`, `statix`, `deadnix`. Run all checks with `nix flake check`. The dev shell (`nix develop`, auto-loaded via direnv) installs the hooks. `hosts/thinkbook-hardware-config.nix` is excluded from statix/deadnix.

## Architecture

`flake.nix` is the single wiring point. Two `nixosConfigurations`:

- **tower** — WSL host (`nixos-wsl`), minimal: `common.nix` + `hosts/tower.nix`
- **thinkbook** — physical laptop, KDE/Plasma desktop with unfree packages, gaming, virtualization

Module layout follows three buckets:

- **`common.nix`** — NixOS config shared by every host. Imports the baseline `nixos-modules/*` plus the `private-config` flake input and home-manager's NixOS module.
- **`nixos-modules/`** — system-level NixOS modules. Plain Nix files, imported *explicitly* by `common.nix` (baseline) or per-host (e.g. thinkbook pulls in `kde.nix`, `sound.nix`, `virtualization.nix`, `font.nix`). Adding a file here does NOT auto-enable it.
- **`home-manager/`** — per-user (`m1-s`) home-manager modules. Every `.nix` file here is auto-exposed as a named module via `flake.nix`'s `modulesFromDir` (module key = filename without `.nix`). Hosts then select which to import by name (e.g. `imports = with self.homeManagerModules; [ default plasma chromium gaming ]`). `home-manager/default.nix` is the always-on base and imports the cross-host tools (`nvim`, `git`, `tmux`, `ghostty`, `claude-code`).

`private-config` is a separate private flake input (`git+ssh://…/nixos-config-private`) holding customer-related, non-secret data; it is imported in `common.nix`.

### Conventions

- Adding a new home-manager feature: drop a `.nix` file in `home-manager/`, then either import it from `home-manager/default.nix` (if it should apply everywhere) or add its filename to a host's `homeManagerModules` import list in `flake.nix`.
- Adding a new system feature: drop a `.nix` file in `nixos-modules/`, then import it from `common.nix` (all hosts) or a specific `hosts/*.nix`.
- This repo's own Claude Code config (global context, skills, settings, statusline) is itself managed declaratively in `home-manager/claude-code.nix` — edit there, not in `~/.claude`, to change agent behavior.
