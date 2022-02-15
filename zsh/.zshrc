# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="${XDG_CONFIG_HOME:-${HOME}/.config}/zsh/ohmyzsh"
export ZSH_CUSTOM="${XDG_CONFIG_HOME:-${HOME}/.config}/zsh/custom"

export EDITOR='vim'

# Make git play nice with pinentry
export GPG_TTY=${TTY}

# Capture hidden files with fzf
if rg 2>/dev/null; then
    # Use rg if available
    export FZF_DEFAULT_COMMAND='rg --hidden -l ""'
else
    export FZF_DEFAULT_COMMAND='find .'
fi

alias view="vim -R $1"

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

### Fix slowness of pastes with zsh-syntax-highlighting.zsh
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
### Fix slowness of pastes

source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/antigen/antigen.zsh"

antigen use oh-my-zsh

antigen bundle git
antigen bundle pyenv

antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle vi-mode

antigen bundle romkatv/powerlevel10k
antigen theme romkatv/powerlevel10k

for plugin in "${ZSH_CUSTOM}"/plugins/*; do
    antigen bundle "${plugin}"
done

antigen apply
