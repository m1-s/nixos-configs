{ certs }: { pkgs, ... }:
let
  initialAdminPassword = "h4Iho\"JFn't2>iQIR9";
in
{
  security.pki.certificateFiles = [
    certs.ca.cert
  ];

  wsl.wslConf.network.generateHosts = false;
  networking.extraHosts = ''
    127.0.0.1 ${certs.domain}
  '';

  services = {
    keycloak = {
      enable = true;
      settings.hostname = certs.domain;
      inherit initialAdminPassword;
      sslCertificate = "${certs.${certs.domain}.cert}";
      sslCertificateKey = "${certs.${certs.domain}.key}";
      database = {
        type = "postgresql";
        username = "bogus";
        name = "also bogus";
        passwordFile = let file = pkgs.writeText "dbPassword" "foo"; in "${file}";
      };
    };
  };
}
