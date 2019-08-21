{ config, lib, pkgs, ... }:

with lib;
let
  paths = types.listOf (types.either types.path types.package);
  sourceDir = if config.dwn.dev then toString else lib.id;
  sourceDirs = map sourceDir config.dwn.clj.sourceDirectories;
in

{
  options.dwn.clj = {
    sourceDirectories = mkOption {
      default = [];
      type = types.listOf types.path;
      description = ''
        Source roots for clojure compilation
      '';
    };
    # compileClasspath = mkOption {
    #   internal = true;
    #   default = config.dwn.clj.compileClasspath;
    #   type = paths;
    #   description = ''
    #     JVM compile classpath
    #   '';
    # };
    # runtimeClasspath = mkOption {
    #   internal = true;
    #   type = paths;
    #   description = ''
    #     JVM runtime classpath
    #   '';
    # };
    aot = mkOption {
      default = [];
      type = types.listOf types.string;
      description = ''
        Clojure namespaces to AOT compile
      '';
    };
    warnOnReflection = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Clojure compiler option `warn-on-reflection`
      '';
    };
    uncheckedMath = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Clojure compiler option `unchecked-math`
      '';
    };
    disableLocalsClearing = mkOption {
      default = config.dwn.dev;
      type = types.bool;
      description = ''
        Clojure compiler option `disable-locals-clearing`
      '';
    };
    directLinking = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Clojure compiler option `direct-linking`
      '';
    };
    elideMeta = mkOption {
      default = if config.dwn.dev then [] else [":line" ":file" ":doc" ":added"];
      type = types.listOf types.string;
      description = ''
        Clojure compiler option `elide-meta`
      '';
    };
  };

  config = mkIf (0 != lib.length config.dwn.clj.sourceDirectories) {
    dwn.mvn = {
      dependencies = [ pkgs.clojure ];
    };
    dwn.jvm.runtimeClasspath =
      sourceDirs
      ++ (lib.optional (0 != lib.length config.dwn.clj.aot) (
        pkgs.cljCompile {
          name = config.dwn.name + "-clj-classes";
          inherit (config.dwn.clj) aot;
          classpath = sourceDirs ++ config.dwn.jvm.javaClasses ++ config.dwn.jvm.compileClasspath;
          options = {
            inherit (config.dwn.clj) warnOnReflection uncheckedMath disableLocalsClearing elideMeta directLinking;
          };
        }
      ));
    dwn.paths =
      if config.dwn.dev then
        (map toString config.dwn.clj.sourceDirectories)
        ++ [(pkgs.writeScriptBin "start-nrepl" ''
           echo Start nrepl ${toString config.dwn.clj.sourceDirectories} ${toString config.dwn.jvm.runtimeClasspath}
        '')]
      else
        [];
  };
}
