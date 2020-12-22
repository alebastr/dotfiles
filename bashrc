# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# tmux-specific aliases and helpers
test -e ~/dotfiles/tmux.sh && source ~/dotfiles/tmux.sh

# User specific aliases and functions
test -e ~/.env.local    && source ~/.env.local
test -e ~/.bashrc.local && source ~/.bashrc.local

