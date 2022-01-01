#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

autoload -U compinit
compinit

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

## keep background processes at full speed
#setopt NOBGNICE
## restart running processes on exit
#setopt HUP

## history
setopt APPEND_HISTORY
## for sharing history between zsh processes
#setopt INC_APPEND_HISTORY
#setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=2000

## never ever beep ever
#setopt NO_BEEP

## automatically decide when to page a list of completions
#LISTMAX=0

#zstyle ':vcs_info:*' enable hg svn git cvs

## disable mail checking
MAILCHECK=0

autoload -U colors
colors

setopt autocd
bindkey -v

## do not use Ctrl-S and Ctrl-Q for flow control
stty -ixon -ixoff

# tmux-specific aliases and helpers
test -f ~/dotfiles/tmux.sh && source ~/dotfiles/tmux.sh

if command -v most >/dev/null; then
    export PAGER=most
fi

## load plugins
export ADOTDIR=$HOME/.antigen

if [ ! -f "$ADOTDIR/antigen.zsh" ] && command -v git >/dev/null; then
    git clone https://github.com/zsh-users/antigen "$ADOTDIR"
fi
if [ -f "$ADOTDIR/antigen.zsh" ]; then
    source "$ADOTDIR/antigen.zsh"

    antigen bundle zsh-users/zsh-completions
    antigen bundle zdharma-continuum/fast-syntax-highlighting
    antigen bundle softmoth/zsh-vim-mode@main

    antigen apply
fi

## load local configuration
test -e ~/.env.local   && source ~/.env.local
test -e ~/.zshrc.local && source ~/.zshrc.local

## initialize prompt
if [ -e ~/.prompt.zsh ]; then
    source  ~/.prompt.zsh
else
    autoload -U promptinit
    promptinit
    prompt clint
fi

## print fortune
test -e /usr/bin/fortune && /usr/bin/fortune
