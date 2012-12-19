# F.2011-08-16 : Some custom miscellaneous aliases...

# fixme
alias fu='/sbin/fuser -v'
alias lsof='/usr/sbin/lsof'

alias papache='( httpd_pids=`pgrep -u $USER,apache,root httpd` ; [ ! "$httpd_pids" ] || ps -H u -p $httpd_pids )'

# Screen :
alias sls='screen -ls'
alias sr='screen -r'
alias sR='screen -R'
