HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Ignore duplicate commands in history
setopt HIST_IGNORE_DUPS

# Use vi style keys
bindkey -v
bindkey jj vi-cmd-mode

# Idk
zstyle :compinstall filename '/home/Link/.zshrc'

# Enable autocompletion
autoload -Uz compinit
compinit

# Press tab twice for arrow key driven selection
zstyle ':completion:*' menu select

# Customize the shell prompt
PS1='%m%#[%~]>'

# qt programs use GTK themes
export QT_STYLE_OVERRIDE=GTK+
# for the benefit of ranger shell -t
export TERMCMD=st
export LESS=-R
# Steam fixes
find ~/.steam/root/ \( -name "libgcc_s.so*" -o -name "libstdc++.so*" -o -name "libxcb.so*" -o -name "libgpg-error.so*" \) -delete
export STEAM_RUNTIME=0

# Command aliases
alias ls='ls --color=auto --quoting-style=literal'
alias grep='grep --color=auto'
alias rm='rm -Iv --one-file-system'
alias mv='mv -iv'
alias sxiv="sxiv -faqo"
alias steam-de='xinit ~/.bin/steam-session.sh -- :1 vt$XDG_VTNR'
alias touch-de='startx /usr/bin/startxfce4'

# Add ~/.bin to the path
typeset -U path
path=(~/.bin $path)

function zle-line-init zle-keymap-select {
	RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
	RPS2=$RPS1
	zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# Device specific settings
#host="$(hostnamectl status --static)"
#if [ $host = "GIR" ]; then
#	#nothing here yet
#fi

# https://wiki.archlinux.org/index.php/Core_utilities/Tips_and_tricks#Colored_output_when_reading_from_stdin
zmodload zsh/zpty

pty() {
	zpty pty-${UID} ${1+$@}
	if [[ ! -t 1 ]];then
		setopt local_traps
		trap '' INT
	fi
	zpty -r pty-${UID}
	zpty -d pty-${UID}
}

ptyless() {
	pty $@ | less
}

# https://wiki.archlinux.org/index.php/Zsh#Dirstack
DIRSTACKFILE="$HOME/.cache/zsh/dirs"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

DIRSTACKSIZE=20

setopt autopushd pushdsilent pushdtohome

## Remove duplicate entries
setopt pushdignoredups

## This reverts the +/- operators.
setopt pushdminus

# Set the window title
precmd () {
  print -Pn "\e]0;[%n@%M][%~]%#\a"
} 
preexec () { print -Pn "\e]0;[%n@%M][%~]%# ($1)\a" }

# run or raise ranger. rethink name- rg() maybe?
ranger() {
    if [ -z "$RANGER_LEVEL" ]
    then
        /usr/bin/ranger
    else
        exit
    fi
}

# Define a function to run things under or attach to existing tmux
run_under_tmux() {
	# Run $1 under session or attach if such session already exist.
	# $2 is optional path, if no specified, will use $1 from $PATH.
	# If you need to pass extra variables, use $2 for it as in example below..
	# Example usage:
	# 	torrent() { run_under_tmux 'rtorrent' '/usr/local/rtorrent-git/bin/rtorrent'; }
	#	mutt() { run_under_tmux 'mutt'; }
	#	irc() { run_under_tmux 'irssi' "TERM='screen' command irssi"; }


	# There is a bug in linux's libevent...
	# export EVENT_NOEPOLL=1

	command -v tmux >/dev/null 2>&1 || return 1

	if [ -z "$1" ]; then return 1; fi
	local name="$1"
	if [ -n "$2" ]; then
		local file_path="$2"
	else
		local file_path="command ${name}"
	fi

	if tmux has-session -t "${name}" 2>/dev/null; then
		tmux attach -d -t "${name}"
	else
		tmux new-session -s "${name}" "${file_path}" \; set-option status \; set set-titles-string "${name} (tmux@${HOST})"
	fi
}

# Start irssi in or attach to existing tmux
#irc() { run_under_tmux irssi; }
#irc() { abduco -A irc dvtm }

# So I think this is the framework for detecting if you're running ssh, and changing colors if true
#over_ssh() {
#	if [ -n "${SSH_CLIENT}" ]; then
#		return 0
#	else
#		return 1
#	fi
#}
#
#if over_ssh && [ -z "${TMUX}" ]; then
#	prompt_is_ssh='%F{blue}[%F{red}SSH%F{blue}] '
#elif over_ssh; then
#	prompt_is_ssh='%F{blue}[%F{253}SSH%F{blue}] '
#else
#	unset prompt_is_ssh
#fi