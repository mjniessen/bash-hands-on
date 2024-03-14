# create a new directory and change into it
mkcd() {
	mkdir -p -- "$1" && cd -P -- "$1" || return 1
}

# swap name of two files
swap() {
	local TMPFILE=tmp.$$

	# check arguments
	[[ $# -ne 2 ]] && echo "swap: 2 arguments needed" && return 1
	[[ ! -e "$1" ]] && echo "swap: $1 does not exist" && return 1
	[[ ! -e "$2" ]] && echo "swap: $2 does not exist" && return 1

	# swap files
	mv "$1" $TMPFILE
	mv "$2" "$1"
	mv $TMPFILE "$2"
}

# create a new bash script and open it in an editor
new() {
	local NEWFILE="$1"

	if [[ ! -f "${NEWFILE}" ]]; then
		touch "$1"
		chmod +x "$1"
		echo "#!/usr/bin/env bash" >"$1"
		nano "$1"
	else
		echo >&2 "'${NEWFILE}' exists already!"
	fi
}

# show long listing page by page
lm() {
	ll "$@" | less
}
