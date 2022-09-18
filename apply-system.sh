#!/bin/sh
pushd ~/nix-config
sudo nixos-rebuild switch --flake .#
popd
