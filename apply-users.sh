#!/bin/sh
pushd ~/dotfiles
nix build .#homeManagerConfigurations.alejandro.activationPackage
./result/activate
popd
