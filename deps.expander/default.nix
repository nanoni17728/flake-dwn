{ lib, classpathFor, shellBinder, mvnResolve, defaultMavenRepos }:

shellBinder.mainLauncher rec {
  name = "dependency-expander";
  namespace = "webnf.dwn.deps.expander";

  classpath = classpathFor {
    name = "${name}-classpath";
    cljSourceDirs = [ ./src ../nix.data/src ../nix.aether/src ];
    fixedDependencies = import ./deps.bootstrap.nix;
    aot = [ namespace ];
    compilerOptions = {
      elideMeta = [":line" ":file" ":doc" ":added"];
      directLinking = true;
    };
  };
}
