#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

autoload -Uz compinit
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

# connect to tmux default session in remote shells
if [ -n "$SSH_CONNECTION" -a -z "$TMUX" ] && command -v tmux >/dev/null; then
    tmux new -A -s default
fi

## load plugins
export ZPLUG_HOME=~/.zplug

if [ ! -f "$ZPLUG_HOME/init.zsh" ] && command -v git >/dev/null; then
    git clone https://github.com/zplug/zplug.git "$ZPLUG_HOME"
fi
if [ -f "$ZPLUG_HOME/init.zsh" ]; then
    source "$ZPLUG_HOME/init.zsh"

    zplug "MichaelAquilina/zsh-you-should-use"
    zplug "softmoth/zsh-vim-mode"
    zplug "zsh-users/zsh-completions"
#    zplug "zsh-users/zsh-syntax-highlighting"
    zplug "zdharma/fast-syntax-highlighting"

    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi

    zplug load
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
