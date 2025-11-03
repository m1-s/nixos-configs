{ pkgs, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.extraModprobeConfig = "options kvm-amd nested=Y";

  environment.systemPackages = with pkgs; [
    libvirt
    virt-manager
  ];

  virtualisation.libvirtd.enable = true;
}
