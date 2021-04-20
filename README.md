# dotfiles

## Usage

Make sure you have `stow` installed and run the following

```bash
git clone --recurse-submodules https://github.com/alejandro-angulo/dotfiles
cd dotfiles
stow base16-shell git termite vim tmux zsh
```

If this repo is already cloned, remember to run `git submodule update --init`
after pulling in case any new submodules were added.

Optionally stow the following:

- `stow asoundrc` - Used for my desktop setup
- `stow i3` - Used for my desktop setup
- `stow sway` - Used for my laptop setup
- `stow termite` - Used on my personal machines
- `stow xprofile` - Used for my desktop setup

### tmux

I had to manually run `tmux source-file ~/.config/tmux/tmux.conf` to get the
config to work. Also run `bash ~/.config/tmux/tpm/tpm` or alternately start a
tmux session and hit <kbd>prefix</kbd> then <kbd>Ctrl</kbd> + <kbd>I</kbd>
(default prefix is <kbd>Ctrl</kbd> + <kbd>b</kbd>).

### vim

Need to install plugins, use `vim +PluginInstall +qall`. May see an error about
being unable to find a color scheme but this should be resolved after
installing plugins.

