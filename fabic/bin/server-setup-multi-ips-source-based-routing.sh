#!/bin/bash
#
# fabic.net / 2017-03-31
# 

if [ $# -lt 1 ]; then
  echo
  echo "USAGE: (sudo)  $0 <dump_tables|issue_tests|setup_output_mangling|setup_routing>"
  echo
  echo "  TL;DR: Dude has 3 IPs on its OVH VPS box, and wants that the source address of new"
  echo "         connections (outbound packets) be set automatically to one of these (not just the default first IP of the interface)."
  echo
  echo "  Script that attempts to set up a form of so-called \"source address based routing\""
  echo "  _for_ the specific situation of that VPS of mine that has several public IP addresses"
  echo "  on the same interface."
  echo
  echo " STATUS: (!) does not work -_-"
  echo
  echo " - http://linux-ip.net/html/routing-saddr-selection.html"
  echo " - http://linux-ip.net/html/routing-selection.html"
  echo " - http://inai.de/images/nf-packet-flow.png  (MUST SEE)"
  echo
  echo " - http://ipset.netfilter.org/iptables-extensions.man.html#lbBK   (-m mark matching)"
  echo " - http://ipset.netfilter.org/iptables-extensions.man.html#lbCS   (CONNMARK target)"
  echo " - http://ipset.netfilter.org/iptables-extensions.man.html#lbCD   (-m statistic matching)"
  echo
  echo " - https://unix.stackexchange.com/a/201752"
  echo " - https://unix.stackexchange.com/a/111423"
  echo
  echo " - http://lartc.org/howto/lartc.rpdb.multiple-links.html"
  echo " - https://home.regit.org/netfilter-en/links-load-balancing/"
  echo " - http://lstein.github.io/Net-ISP-Balance/"
  echo
  echo " NOTE: DON'T \`ip rule flush\` from your remote server (again!)."
  echo
  exit 1
fi


# Pretty print the output of several commands, for debugging purposes.
function dump_tables() {
  cmds=(
    "iptables-save -c"
    "iptables -t filter -nvL"
    "iptables -t mangle -nvL"
    "ip addr list"
    "ip rule list"
    "ip route list"
    "ip route list table 92"
    "ip route list table 178"
    "ip route get 216.58.213.142" # google.com
  )

  # Beware: hacks with Bash spaces here.
  for cmd in "${cmds[@]}"; do
    echo "+- ${cmd}"
    ${cmd} |
      sed -e 's/^/|  /'
    echo "\`"
  done
}


# Set up netfilter rules for marking "new" outbound packets.
# (see setup_routing() for the matching `ip rule add fwmark ...` commands.
#
# TODO: find out why and if we need these two --restore/save-mark things,
#       /me can't tell why this is needed.
function setup_output_mangling() {
  echo "~~> Setting up mangle/OUTPUT (flushing first!)"
  iptables -Z &&
  iptables -t mangle -F OUTPUT &&
    iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark &&
    iptables -t mangle -A OUTPUT -m conntrack --ctstate NEW -m statistic --mode random --probability 0.333 -m mark --mark 0x00 -j MARK --set-mark 1 &&
    iptables -t mangle -A OUTPUT -m conntrack --ctstate NEW -m statistic --mode random --probability 0.333 -m mark --mark 0x00 -j MARK --set-mark 2 &&
    iptables -t mangle -A OUTPUT -j CONNMARK --save-mark &&
      # Two optional rules in the "normal" OUTPUT chain for checking if packet marking... does mark packets.
      ( iptables -t filter -C OUTPUT -m mark --mark 0x01 -j ACCEPT || iptables -t filter -A OUTPUT -m mark --mark 0x01 -j ACCEPT ) &&
      ( iptables -t filter -C OUTPUT -m mark --mark 0x02 -j ACCEPT || iptables -t filter -A OUTPUT -m mark --mark 0x02 -j ACCEPT )

  retv=$?
  if [ $retv -gt 0 ]; then
    echo "OUPS! Something went wrong with your iptables ... commands (bad exit status)"
  else
    echo "~~> done adding netfilter rules to the OUTPUT/mangle"
  fi

  return $retv
}

# Sets up two routing tables for "source routing" those 2 additional "aliased" IPs we have;
# and set up two "routing policy" rules for selecting one of these tables _based on_ the
# fwmark of packets, supposedly.
function setup_routing() {
  ip route flush table 92 &&
  ip route add default via 91.134.136.1 src 92.222.48.73 table 92  &&

  ip route flush table 178 &&
  ip route add default via 91.134.136.1 src 178.32.40.98 table 178 &&

  # TODO: investigate this statement, eventually :
  #       "fwmark with ipchains/iptables is a decimal number, but that
  #        iproute2 uses hexadecimal number."
  #        ^ http://linux-ip.net/html/adv-rpdb.html
  # From `man ip-rule`: "Each rule should have an explicitly set unique priority value".
  ip rule add fwmark 1 priority 1 table 92  &&
  ip rule add fwmark 2 priority 2 table 178 &&

  # http://linux-ip.net/html/routing-cache.html
  ip route flush cache

  retv=$?
  if [ $retv -gt 0 ]; then
    echo "OUPS! Something went wrong with your iptables ... commands (bad exit status)"
  else
    echo "~~> done adding netfilter rules to the OUTPUT/mangle"
  fi
}


## Query various "what's my ip" services out there,
## each command is supposed to bind to a different local IP.
function issue_tests() {
  type -p dig && dig +short myip.opendns.com @resolver1.opendns.com

  curl ipinfo.io/ip
  curl ipecho.net/plain && echo
  curl icanhazip.com
  curl ipv4.icanhazip.com
  curl ident.me && echo
  curl v4.ident.me && echo
  curl v6.ident.me && echo
  curl http://checkip.amazonaws.com
  curl http://smart-ip.net/myip
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Iter. over cli args, executing each matching function.
while [ $# -gt 0 ]; do
  action="$1"
  shift

  type="`type -t "$action"`"

  if [ -z "$type" ]; then
    echo "ERROR: unknown action '$action' (exiting now)"
    exit 127
  elif [ "$type" == "function" ];
  then
    echo "~~> Executing \`$action\`"

    "$action"
    retv=$?

    echo "~~> \`$action\` exit status: $retv"

    if [ $retv -gt 0 ]; then
      echo "~~> \` non-zero exit status (!) exiting now"
      exit 126
    fi
  else
    echo "ERROR: '$action' is of type '$type' (and we're not executing such a thing), exiting now"
    break
  fi
done


echo "+-- $0 $@  (done)"

