{ config, lib, pkgs, ... }:

with lib;

{
  options.dwn.nrepl = {
    host = mkOption {
      default = "127.0.0.1";
      type = types.string;
      description = ''
        Nrepl host name
      '';
    };
    port = mkOption {
      default = 4050;
      type = types.int;
      description = ''
        Nrepl port
      '';
    };
    middleware = mkOption {
      default = [];
      type = types.listOf types.string;
      description = ''
        Nrepl middleware
      '';
    };
    enable-cider = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Enable cider on nrepl
      '';
    };
  };

  config.dwn.mvn.dependencies = [ pkgs.nrepl ];

  config.dwn.clj.main = {
    dwn-nrepl = {
      namespace = "webnf.dwn.nrepl";
      prefixArgs = [ ( pkgs.toEdnPP ( pkgs.keyword-map config.dwn.nrepl)) ];
    };
  };
    
}