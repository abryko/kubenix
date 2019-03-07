{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, kubenix ? import ../. { inherit pkgs lib; }
, k8sVersion ? "1.13"

# whether any testing error should throw an error
, throwError ? true
, e2e ? true }:

with lib;

let
  images = pkgs.callPackage ./images.nix {};

  test = (kubenix.evalModules {
    modules = [
      kubenix.modules.testing

      {
        testing.throwError = throwError;
        testing.e2e = e2e;
        testing.tests = [
          ./k8s/simple.nix
          ./k8s/deployment.nix
          ./k8s/crd.nix
          ./k8s/1.13/crd.nix
          ./k8s/defaults.nix
          ./k8s/order.nix
          ./helm/simple.nix
          ./istio/bookinfo.nix
          ./submodules/simple.nix
          ./submodules/defaults.nix
          ./submodules/versioning.nix
          ./module.nix
        ];
        testing.defaults = ({kubenix, ...}: {
          imports = [kubenix.modules.k8s];
          kubernetes.version = k8sVersion;
          _module.args.images = images;
        });
      }
    ];
    args = {
      inherit pkgs;
    };
    specialArgs = {
      inherit kubenix;
    };
  }).config;
in test.testing
