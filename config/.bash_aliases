# directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd..='cd ..'

# various ls shortcuts for specific needs
alias l='ll -a'          # short default
alias la='ll -A'         # Show [a]ll files (including hidden ones)
alias lc='lt -c'         # Sort by/show [c]hange time,most recent first. (-r reverses order)
alias lk='ll -S'         # Sort by size ([k]ilobytes), biggest first. (-r reverses order)
alias ll='ls -l'         # Show [l]ong listing format
alias lr='ll -R'         # [r]ecursive ls
alias ls='ls -h --color' # just colored and human-readable
alias lt='ll -t'         # Sort by date/[t]ime - most recent first (-r reverses order)
alias lu='lt -u'         # Sort by/show access time / when [u]sed - most recent first (-r reverses order)

alias lx='ll -XB --group-directories-first' # e[x]traordinary

# shortcuts
alias h='history'

# changing defaults
alias lsblk='lsblk -f -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,UUID,FSTYPE,MOUNTPOINTS,FSAVAIL,FSUSE%'

# neovim
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# apt - example taken from Kali Linux
alias checkupdates='sudo apt-get update && sudo apt-get upgrade'

# notify / alert - example taken from Ubuntu Linux
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

