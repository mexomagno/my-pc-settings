#!/bin/bash
# Shared bashrc file. This file must be sourced from every linux os using a bash prompt.
# It is reccomended that you source this from your local .profile file.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Load custom environment variables
#[[ -f "$DIR/.bash_env" ]] && . "$DIR/.bash_env"

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	  *) return;;
esac
# Dont put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth
# Append to the history file, dont overwrite
shopt -s histappend
# History file sizes
HISTSIZE=2000
HISTFILESIZE=3000
# Always check for window size and redraw if necessary
shopt -s checkwinsize
# Make "less" pager more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
# Identify our chroot by setting a variable with it's name
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi
# If terminal supports color, use it
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# Set our super beautiful prompt. If we're ROOT, it will be different
	if [ -f "$DIR/.prompt_format" ]; then 
		. "$DIR/.prompt_format"
	else
		# default colors
		PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
	fi
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
# If this is an xterm, set title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*)
	;;
esac
# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls="ls --color=auto"
	alias grep="grep --color=auto"
	alias fgrep="fgrep --color=auto"
	alias egrep="egrep --color=auto"
fi
# load sensible data variables
[[ ! -f "$DIR/.sensible_data" ]] && echo "WARNING: '.sensible_data' not found! NOT loading shared aliases and functions" && exit 1
. "$DIR/.sensible_data" 
# load custom aliases
[[ -f "$DIR/.bash_aliases" ]] && . "$DIR/.bash_aliases"
# load custom functions
[[ -f "$DIR/.bash_functions" ]] && . "$DIR/.bash_functions"

# Enable bash-completions
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi
unset DIR

# Load our own bashrc file
#[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"
