{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql_18;

    ensureDatabases = [
      "data_engineering"
    ];

    ensureUsers = [
      {
        name = "nonename";
      }
      {
        name = "data_engineer";
      }
    ];

    enableTCPIP = true;

    authentication = pkgs.lib.mkOverride 10 ''
      local   all               all              peer
      host    data_engineering  data_engineer    127.0.0.1/32    scram-sha-256
      host    data_engineering  data_engineer    ::1/128         scram-sha-256
    '';
  };
}
