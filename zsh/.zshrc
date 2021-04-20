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

alias view="vim -R $1"

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/antigen/antigen.zsh"

antigen use oh-my-zsh

antigen bundle git
antigen bundle pyenv

antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle romkatv/powerlevel10k
antigen theme romkatv/powerlevel10k

for plugin in "${ZSH_CUSTOM}"/customrc/*; do
    [ -e "$plugin" ] || continue
    antigen bundle "${ZSH_CUSTOM}/plugins/$(basename $plugin)"
done

antigen apply

