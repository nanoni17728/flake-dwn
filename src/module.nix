{ config, lib, pkgs, ... }:

with lib;
let

  inherit (pkgs.callPackage ./src/nix/lib/clojure.nix {}) callPackage;

  dwn-script = callPackage ./dwn-next.nix { configFile = "/etc/dwn.edn"; };
  cfg = config.services.dwn;

in {

  options = {
    services.dwn = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the dwn runner service";
      };
      config = mkOption {
        type = types.any;
        default = null;
        description = "Service config to be edn-printed and passed to the dwn service";
      };
      configLocation = mkOption {
        type = types.path;
        default = "/etc/dwn.edn";
        description = "Config file location";
      };
      workingDirectory = mkOption {
        default = "/var/empty";
        description = "Cwd of java process";
      };
      extraJavaOptions = mkOption {
        default = [];
        description = "Array of java flags";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."dwn.edn".source = cfg.configFile;
    systemd.services.dwn = {
      description = "DWN clojure runner service";
      after = [ "network-interfaces.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        echo "STARTING UP IN `pwd`"
        exec ${dwn-script} ${toString cfg.extraJavaOptions};
      '';
      reload = ''
        echo "Reloading ..."
        kill -HUP $MAINPID
      '';
      serviceConfig = {
        WorkingDirectory = cfg.workingDirectory;
      };
    };
  };

}
