{ config, pkgs, lib, inputs, ... }:

{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "mydatabase" "yesblog" ];
    authentication = pkgs.lib.mkOverride 10 ''
    #type database  DBuser  auth-method
    local all       all     trust
    '';
  };

  environment.systemPackages = with pkgs; [
    haskellPackages.cabal-gild
    haskellPackages.hlint
    cabal-install
    ghc
    nodejs
    python3Packages.python
    haskell-language-server
    sqlite
    pkg-config
  ];
}
