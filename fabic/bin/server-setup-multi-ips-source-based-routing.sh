#!/bin/bash
#
# fabic.net / 2017-03-31
# 

if [ $# -lt 1 ]; then
  echo
  echo "USAGE: (sudo)  $0 <clear_netfilter_counters|dump_tables|issue_tests|setup_output_mangling|setup_routing|setup_randomized_basic_source_routing|setup_snat>"
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
  echo " - https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture (MUST READ)"
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
  echo "This is the output of the script at https://github.com/fabic/bash-it/blob/master/fabic/bin/server-setup-multi-ips-source-based-routing.sh"

  cmds=(
    "date"
    "bash -c \'( echo -e \"GET /ip HTTP/1.0\r\nHost: ipinfo.io\r\n\r\n\" | nc -s 178.32.40.98 ipinfo.io 80 )\'"
    "iptables-save -c"
    "ip addr list"
    "ip rule list"
    "ip route show cache"
    "ip route list"
    "ip route list table 92"
    "ip route list table 178"
    "ip route get 216.58.213.142" # google.com
    "iptables -t mangle -nvL"
    "iptables -t filter -nvL"
  )

  # Beware: hacks with Bash spaces here.
  for cmd in "${cmds[@]}"; do
    echo "+- ${cmd}"
    ${cmd} |
      sed -e 's/^/|  /'
    echo "\`"
  done
}

function clear_netfilter_counters() {
  iptables -t raw -Z &&
  iptables -t mangle -Z &&
  iptables -t nat -Z &&
  iptables -t filter -Z &&
  echo "~~> Cleared netfilter counters."
}

# Set up netfilter rules for marking "new" outbound packets.
# (see setup_routing() for the matching `ip rule add fwmark ...` commands.
#
# TODO: find out why and if we need these two --restore/save-mark things,
#       /me can't tell why this is needed.
function setup_output_mangling() {
  echo "~~> Setting up mangle/PREROUTING (flushing first!)"

  # Zero packets stats counters.
  # ^ now done after the below stuff.
  #true && (iptables -t mangle -Z && iptables -t filter -Z ) &&

  iptables -t mangle -F OUTPUT &&
    # Using NF MARK target :
    # iptables -t mangle -A OUTPUT -m conntrack --ctstate NEW -m statistic --mode random --probability 0.333 -m mark --mark 0x00 -j MARK --set-mark 1 &&
    # iptables -t mangle -A OUTPUT -m conntrack --ctstate NEW -m statistic --mode random --probability 0.666 -m mark --mark 0x00 -j MARK --set-mark 2 &&

    # Using CONNMARK target (as per discussion with pekster @ Freenode/#Netfilter):
    # TODO: (or maybe not?): iptables -t mangle -A OUTPUT -j CONNMARK --save-mark &&
    iptables -t mangle -A OUTPUT -m conntrack --ctstate NEW -m connmark --mark 0x00/0x30 -m statistic --mode random --probability 0.333 -j CONNMARK --set-mark 0x10/0x30 &&
    iptables -t mangle -A OUTPUT -m conntrack --ctstate NEW -m connmark --mark 0x00/0x30 -m statistic --mode random --probability 0.500 -j CONNMARK --set-mark 0x20/0x30 &&
    # As per http://ipset.netfilter.org/iptables-extensions.man.html#lbCS :
    # "Copy the ctmark to the nfmark. If a mask is specified, only those bits are copied."
    iptables -t mangle -A OUTPUT -m conntrack --ctstate NEW -m connmark \! --mark 0x00/0x30 -j CONNMARK --restore-mark --ctmask 0x30 &&

    # DEBUG: Optional rules in the "normal (filter)" OUTPUT chain for checking if packet marking... does mark packets.
    if true; then
      iptables -t filter -F OUTPUT &&
      iptables -t filter -A OUTPUT -m mark --mark 0x10 -j ACCEPT && # no mask here: we want the exact value as will be seen by `ip rule fwmark ...`
      iptables -t filter -A OUTPUT -m mark --mark 0x20 -j ACCEPT &&
      iptables -t filter -A OUTPUT -m mark \! --mark 0x00 -j ACCEPT && # Just to identify marked packets that were not previously matched.

      # 3 rules for matching one of our 3 IPv4 local addresses :
      if true; then
        # Useless, indeed shows that no locally generated traffic goes through mangle/PREROUTING:
        # iptables -t mangle -I PREROUTING 1 -m conntrack --ctstate NEW -s 91.134.136.248 -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s &&
        # iptables -t mangle -I PREROUTING 2 -m conntrack --ctstate NEW -s 178.32.40.98   -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s &&
        # iptables -t mangle -I PREROUTING 3 -m conntrack --ctstate NEW -s 92.222.48.73   -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s &&

        # NOOP rules for matching "new connections" packets given their source address;
        # -> proved that new connections already had their source address set when entering the nat/OUTPUT chain,
        #    hence the illusion of having packet marking be used by `ip rule fwmark ...` to perfom "source routing" -_-
        iptables -t mangle -I OUTPUT 1 -m conntrack --ctstate NEW -s 91.134.136.248 -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s &&
        iptables -t mangle -I OUTPUT 2 -m conntrack --ctstate NEW -s 178.32.40.98   -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s &&
        iptables -t mangle -I OUTPUT 3 -m conntrack --ctstate NEW -s 92.222.48.73   -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s &&

        # Just to monitor traffic leaving tha box with the given source addresses.
        iptables -t filter -I OUTPUT 1 -s 91.134.136.248 -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s &&
        iptables -t filter -I OUTPUT 2 -s 178.32.40.98   -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s &&
        iptables -t filter -I OUTPUT 3 -s 92.222.48.73   -j RATEEST --rateest-name noop --rateest-interval 500ms --rateest-ewmalog 1s
      fi
    fi

  retv=$?
  if [ $retv -gt 0 ]; then
    echo "OUPS! Something went wrong with your iptables ... commands (bad exit status)"
  else
    echo "~~> done adding netfilter rules to the OUTPUT/mangle"
    clear_netfilter_counters
  fi

  return $retv
}


# Final solution (fallback)...
function setup_snat() {
  iptables -t nat -F POSTROUTING &&
  iptables -t nat -Z &&
  iptables -t nat -A POSTROUTING -o ens3 -m connmark --mark 0x10/0x30 -j SNAT --to 92.222.48.73 &&
  iptables -t nat -A POSTROUTING -o ens3 -m connmark --mark 0x20/0x30 -j SNAT --to 178.32.40.98 &&
  echo "\` done setting up SNAT based on previously marked packets."
}


# Basic "source address selection" found at
# https://unix.stackexchange.com/a/111423
function setup_basic_source_routing() {
  ip route add  32.0.0.0/3 via 91.134.136.1 dev ens3 src 178.32.40.98
  ip route add  64.0.0.0/3 via 91.134.136.1 dev ens3 src 92.222.48.73
  ip route add 128.0.0.0/3 via 91.134.136.1 dev ens3 src 91.134.136.248
}


function setup_randomized_basic_source_routing() {
  local ips=( $(shuf -e 178.32.40.98 92.222.48.73 91.134.136.248) )

  echo "~~> Replacing routes with those randomized source IPs: ${ips[@]}" &&
  ip route replace  32.0.0.0/3 via 91.134.136.1 dev ens3 src "${ips[0]}" &&
  ip route replace  64.0.0.0/3 via 91.134.136.1 dev ens3 src "${ips[1]}" &&
  ip route replace 128.0.0.0/3 via 91.134.136.1 dev ens3 src "${ips[2]}" &&
  ip route flush cache &&
  echo "\` done." &&

  echo "~~> \`ip route list\`"
  ip route list
}


# Sets up two routing tables for "source routing" those 2 additional "aliased" IPs we have;
# and set up two "routing policy" rules for selecting one of these tables _based on_ the
# fwmark of packets, supposedly.
function setup_routing() {
  ip route flush table 92 &&
  ip route add default via 91.134.136.1 src 92.222.48.73 table 92  &&
  echo "\` done setup of routing table 92" &&

  ip route flush table 178 &&
  ip route add default via 91.134.136.1 src 178.32.40.98 table 178 &&
  echo "\` done setup of routing table 178" &&

  # TODO: investigate this statement, eventually :
  #       "fwmark with ipchains/iptables is a decimal number, but that
  #        iproute2 uses hexadecimal number."
  #        ^ http://linux-ip.net/html/adv-rpdb.html
  # From `man ip-rule`: "Each rule should have an explicitly set unique priority value".
  # Blind removal of those two rules of ours.
  ( ip rule del from all fwmark 0x10 priority 1 lookup  92 ;
    ip rule del from all fwmark 0x20 priority 2 lookup 178 ; true ) 2>/dev/null &&
      echo "\` done \"blind\" deletion of our two \"ip rules fwmark\" (about to re-add these)."

  echo "~~> Adding ip policy rules for selection of routing tables 92 & 178." &&
  ip rule add fwmark 0x10 priority 1 table  92 &&
  ip rule add fwmark 0x20 priority 2 table 178 &&
    echo "    \` done adding 2 ip rules." &&

  # http://linux-ip.net/html/routing-cache.html
  echo "Flushing routing cache" &&
  ip route flush cache &&
    echo "\` done."

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

  type -p nc && echo "\"Raw HTTP query\" with netcat:" &&
    (echo -e "GET /ip HTTP/1.0\r\nHost: ipinfo.io\r\n\r\n" | nc ipinfo.io 80) &&
    echo "^ done raw http query." && echo

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

