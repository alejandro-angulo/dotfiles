# dotfiles

My nix configuration. The name of this repo is a bit of a misnormer since I'm no
longer managing dotfiles with a tool like stow.

## Usage

To apply a system configuration, run `nixos-rebuild switch`. See `nixos-rebuild
--help` for more information.

## Development

Set up `direnv`

```bash
echo 'use flake' > .envrc && direnv allow
```

And setup pre-commit hooks

```bash
pre-commit install
```

## Inspiration

Heavily inspired by Jake Hamilton's configuration:
https://github.com/jakehamilton/config

Check out the companion flake tour video as well:
https://www.youtube.com/watch?v=ARjAsEJ9WVY
