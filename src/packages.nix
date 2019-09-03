self: super:

with self; {
  defaultMavenRepos = [ http://repo1.maven.org/maven2
                        https://clojars.org/repo ];

  edn = callPackage ./lib/edn.nix {};
  inherit (edn) asEdn toEdn toEdnPP;
  inherit (edn.syntax) tagged hash-map keyword-map list vector set symbol keyword string int bool nil;
  inherit (edn.data) get get-in eq nth nix-str nix-list extract;

  inherit (callPackage ./lib/shell-binder.nix {}) renderClasspath shellBinder;

  dwn = build ./dwn.nix;
  nrepl = build ./nrepl/dwn.nix;
  lein.reader = build ./lein.reader/dwn.nix;
  mvn.reader = build ./mvn.reader/dwn.nix;

  juds = build ./juds/dwn.nix;
  dwnTool = callPackage ./dwn-tool.nix { };

  clojure = build ./clojure/dwn.nix;
  clojurescript = build ./clojurescript/dwn.nix;
  deps = {
    expander = build ./deps.expander/dwn.nix;
    aether = build ./deps.aether/dwn.nix;
  };

  ## Module stuff

  instantiateModule = moduleList: module:
    (self.lib.evalModules {
      modules = moduleList ++ [{
        config._module.args.pkgs = self;
      } module];
    }).config.result // {
      overrideConfig = cfn:
        instantiateModule moduleList (cfn module);
    };

  buildWith = moduleList: pkg:
    (instantiateModule
      moduleList
      ({ config, pkgs, lib, ... }:
        let expr = if builtins.isAttrs pkg then pkg else import pkg;
            dwn = if builtins.isFunction expr
                  then expr {
                    inherit pkgs lib;
                    config = config.dwn;
                  }
                  else expr;
        in {
          imports = dwn.plugins or [];
          inherit dwn;
        }));

  build = buildWith [ ./clojure/module.nix ];

}
