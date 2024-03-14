# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=200000

# Enable options.
# see https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin (reference
# manual) for more information

shopt -s cdspell                 # correct minor error in spelling of directory components
shopt -s checkhash               # check hash before execution
shopt -s checkwinsize            # update LINES and COLS, if window has been resized
shopt -s no_empty_cmd_completion # No PATH search for completions on an empty lines
shopt -s cmdhist                 # save multilined commands in history, if enabled
shopt -s histappend              # append to the history file, don't overwrite it
shopt -s histreedit              # re-edit a failed history substitution
shopt -s histverify              # history substitution are not immediately passed to the shell parser
shopt -s extglob                 # Necessary for programmable completion.
shopt -s globstar                # pattern "**" used in a pathname expansion match all files and zero or more directories and subdirectories.

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color | *-kitty)
	color_prompt=yes
	;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='\n\[\e[38;5;10m\](\W)\[\e[38;5;12m\]\$ \[\033[0m\]'

	if [ "$EUID" -eq 0 ]; then # Change prompt colors for root user
		PS1='\[\e[38;5;10m\](\W)\[\e[38;5;9m\]\$ \[\033[0m\]'
	fi

	unset prompt_color
	unset info_color
	unset prompt_symbol
else
	PS1='(\W)\$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
	alias diff='diff --color=auto'
	alias ip='ip --color=auto'

	export LESS_TERMCAP_mb=$'\E[1;31m'  # begin blink
	export LESS_TERMCAP_md=$'\E[1;36m'  # begin bold
	export LESS_TERMCAP_me=$'\E[0m'     # reset bold/blink
	export LESS_TERMCAP_so=$'\E[01;33m' # begin reverse video
	export LESS_TERMCAP_se=$'\E[0m'     # reset reverse video
	export LESS_TERMCAP_us=$'\E[1;32m'  # begin underline
	export LESS_TERMCAP_ue=$'\E[0m'     # reset underline
fi

# Set Vim as my default editor
export EDITOR=nvim
export PAGER=less

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Function definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_functions, instead of adding them here directly.
if [ -f ~/.bash_functions ]; then
  . ~/.bash_functions
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

umask 022
renice -n 10 $$ >/dev/null

clear
bash --version
