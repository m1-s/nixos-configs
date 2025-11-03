{
  programs.neovide.enable = true;
  programs.neovim.extraConfig = ''
    if exists("g:neovide")
      let g:neovide_cursor_vfx_mode = "pixiedust"
      let g:neovide_scale_factor = 1
      let g:neovide_cursor_vfx_particle_density = 100
      set guifont=Hack:h14
    endif
  '';
}
