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
