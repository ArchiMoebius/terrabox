export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

CASE_SENSITIVE="true"

zstyle ':omz:update' mode disabled  # disable automatic updates

HIST_STAMPS="dd.mm.yyyy"

plugins=(git sudo)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export EDITOR='nvim'

source ~/.dotrc