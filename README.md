# dotfiles

In the prcess of moving system setup/configration to nix. Still getting the
hang of nix so there may be some things I'm ding that aren't "the nix way."

## Usage

Clone this repo to `~/dotfiles` (scripts depend on the repo living in this
location but should be updated to not rely on a specific path).

Run `apply-system.sh` to apply the NixOS configuration and `apply-users.sh` to
apply the home-manager configuration.

**NOTE** `apply-system.sh` depends on the machine's host name matching one of
the configuration names in `flake.nix`.

Run `update.sh` to (you guessed it) update packages.

## Development

Set up direnv (should be available after applying the user configuration):

```bash
echo 'use flake' > .envrc
```

And setup pre-commit hooks (manual step for now but can probably be automated
with some dev shell wizardry):

```bash
pre-commit install
```
