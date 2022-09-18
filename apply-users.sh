#!/bin/sh
pushd ~/nix-config
nix build .#homeManagerConfigurations.alejandro.activationPackage
./result/activate
popd
