

# Sublime Text (Fcj.2013-11-23) :

ST_BIN=`which sublime_text 2> /dev/null`

# Fallback to the possible abs. path of it under /opt/
[ -z "$ST_BIN" -a -f /opt/sublime_text_3/sublime_text ] && ST_BIN=${ST_BIN:-/opt/sublime_text_3/sublime_text}

if [ -x $ST_BIN ]; then
	alias st="$ST_BIN"
	alias stn="st -n"
	alias stw="stn -w"
else
	alias st=${EDITOR:-vi}
fi

