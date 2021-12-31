# dotfiles

## Usage

Make sure you have [`stow`](https://www.gnu.org/software/stow/) installed and
install the desired configurations using `stow -t ~ <configuration>`

**NOTE** Make sure to install submodules. Either pass `--recurse-submodules` to
your clone command or run `git submodule init && git submodule update` after
the repo is already cloned.

## Configurations

| Configuration   | Description                                    |
| --------------- | ---------------------------------------------- |
| `alacritty`     | terminal                                       |
| `base16-shell`  | color scheme                                   |
| `direnv-poetry` | direnv integration with poetry package manager |
| `direnv-zsh`    | direnv integration with zsh                    |
| `git`           | git (self-explanatory)                         |
| `lsd-zsh`       | ls deluxe integration with zsh                 |
| `mako`          | notification daemon                            |
| `ranger`        | terminal file manager                          |
| `spotify-tui`   | terminal spotify client                        |
| `sway`          | window manager                                 |
| `sway-carbon`   | sway config specific to my desktop's config    |
| `sway-gospel`   | sway config specific to my laptop's config     |
| `tmux`          | terminal multiplexer                           |
| `vim`           | text editor                                    |
| `zsh`           | z shell                                        |

### git

The git configuration includes integration with
[delta](https://github.com/dandavison/delta). As long a delta is available in
`$PATH`, it should just work without any extra configuration.

### tmux

I had to manually run `tmux source-file ~/.config/tmux/tmux.conf` to get the
config to work. Also run `bash ~/.config/tmux/tpm/tpm` or alternately start a
tmux session and hit <kbd>prefix</kbd> then <kbd>Ctrl</kbd> + <kbd>I</kbd>
(default prefix is <kbd>Ctrl</kbd> + <kbd>b</kbd>).

### vim

Need to install plugins, use `vim +PluginInstall +qall`. May see an error about
being unable to find a color scheme but this should be resolved after
installing plugins.
