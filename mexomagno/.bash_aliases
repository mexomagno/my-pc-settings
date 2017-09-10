########################################################
# Shared aliases. 
# These aliases can be used from any linux partition with a
# bash prompt.
# WARNING: You must source ".sensible_data" before sourcing this, 
# or else lots of aliases will render useless
########################################################


# Common use
alias sudo="sudo "
alias l="ls"
alias ll="ls -l"
alias la="ls -A"
alias lla="ls -lA"
alias df="df -h"
alias cd..="cd .."
alias mv="mv -v"
alias shutdown="sudo shutdown -Ph 0"
alias reboot="sudo reboot"
alias logout="gnome-session-quit"
alias install="sudo apt-get install"

# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gd="git diff"
alias gb="git branch"
alias gl="git log --oneline"

# Shortcuts
alias raspi="if [ check_if_at_home ]; then ssh -p $RASPI_SSHPORT $RASPI_PRIVATE_IP; else ssh -p $RASPI_SSHPORT $RASPI_PUBLIC_DOMAIN; fi"
# alias raspi-l="ssh -p $RASPI_SSHPORT $RASPI_PRIVATE_IP"
alias bmo="raspi"
alias bodega-blumos="ssh $WORK_WEBDNS"
alias digitalocean="ssh $WORK_VPS_HOST"
# alias mount-raspi-l="sudo sshfs -o port=$RASPI_SSHPORT,umask=027,gid=100,uid=1000,IdentityFile="$IDENTITY_FILE_LOCATION,allow_other,reconnect,auto_cache,ServerAliveInterval=20" $RASPI_ADMIN_USER@$RASPI_PRIVATE_IP:/ $RASPI_FS"
# alias mount-raspi="sudo sshfs -o port=$RASPI_SSHPORT,umask=027,gid=100,uid=1000,IdentityFile="$IDENTITY_FILE_LOCATION,allow_other,reconnect,auto_cache,ServerAliveInterval=20" $RASPI_ADMIN_USER@$RASPI_PUBLIC_DOMAIN:/ $RASPI_FS"
alias mount-raspi="if [ check_if_at_home ]; then RASPI_HOST=$RASPI_PRIVATE_IP; else RASPI_HOST=$RASPI_PUBLIC_DOMAIN; fi; sudo sshfs -o port=$RASPI_SSHPORT,umask=027,gid=100,uid=1000,IdentityFile="$IDENTITY_FILE_LOCATION,allow_other,reconnect,auto_cache,ServerAliveInterval=20" $RASPI_ADMIN_USER@$RASPI_HOST:/ $RASPI_FS"
alias umount-raspi="sudo fusermount -u "$RASPI_FS""
alias anakena="ssh $DCC_USER@$DCC_DOMAIN"
alias resrc=". $HOME/.bashrc"
# Provided in skel. Use like "command; alert"
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias minecraft-server="cd '$SHARED_FS/mexomagno/Google Drive/Minecraft Servers/JKCTM' && ./run.bat"
alias syslog="sudo tail -f /var/log/syslog"
alias mpc="if [ check_if_at_home ]; then MPDHOST=$RASPI_PRIVATE_IP; else MPDHOST=$RASPI_PUBLIC_DOMAIN; fi; mpc -h $MPD_PASS@$MPDHOST -p $MPD_PORT"
# alias mpc="mpc -h $MPD_PASS@$RASPI_PUBLIC_DOMAIN -p $MPD_PORT"

# TODO
#alias vlc="mpv"
#alias beep
#alias beep-forever
#alias beep-when-internet
#alias play-anything
#alias play-random
