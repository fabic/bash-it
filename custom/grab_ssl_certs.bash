# https://github.com/fabic/bash-it/tree/master/custom/grab_ssl_certs.sh

##
## Extract SSL certificates from a given host
## ( note that SNI is sent, see arg. -servername)
## ( note that the actual CA certs file on your Sabayon/Gentoo
##   sys. is /etc/ssl/certs/ca-certificates.crt )
##
## Usage: grab_ssl_certs example.com [443]
## Usage: grab_ssl_certs https://example.com:1443/abc/def/
##
## @link http://stackoverflow.com/a/7886248k
## @since 2015-08-03
## @author fabi@fabic.net
##
function grab_ssl_certs()
{
    local server="$1"
    local port=""

    # 3rd optional arg. may be "extract" : in which case we need to
    # strip off from the output anything that's not btw. BEGIN-END CERTIFICATE.
    local extract_cert=0
    local sed_expr=""
    [ "${3:-dont}" == "extract" ] && extract_cert=1
    [ $extract_cert -gt 0 ] && sed_expr="/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p"
    [ -n "$sed_expr" ] && >&2 echo "~~> Will pipe output through \`sed -ne \"$sed_expr\""

    server="${server#http?://}"
    server="${server%%/*}"

    port="${server#*:}"
    [ "$port" == "$server" ] && port=""
    server="${server%:$port}"

    port="${2:-${port:-443}}"

    >&2 echo "~~> Server: $server (port: $port)"

    # Method #1 : GNUtls
    (
    if type -p gnutls-cli >/dev/null ;
    then
        >&2 echo "~~> Using gnutls-cli"
        gnutls-cli --print-cert "$server" -p"$port" </dev/null
    # Method #2: OpenSSL
    elif type -p openssl >/dev/null ;
    then
        >&2 echo "~~> Using openssl"
        >&2 echo "\`~> openssl rand ..."
        # 2015-08-03 : /me tryin' to get around that so called "warning" which
        #   ends up seemingly in silent error of not being able to proceed to any handshake :
        #     "warning, not much extra random data, consider using the -rand option"
        # This command will possibly entail that a $HOME/.rnd file is updated with some pseudo-random bytes :
        openssl rand -out /dev/null -base64 1024 2> /dev/null

        >&2 echo "\`~> openssl s_client ..."
        # Piping through Sed :
        if false; then
            echo | \
                openssl s_client -showcerts -prexit \
                    -connect "$server:$port" \
                    -servername "$server" 2>&1
        # 2': using x509 sub-command.
        elif false; then
            echo | openssl s_client -connect "$server:$port" -servername "$server" 2>/dev/null | openssl x509
        # 2": likewise above, but using a sub-shell construct which somewhat eludes me at the moment...
        else
            openssl x509 -in <(openssl s_client -connect "$server:$port" -servername "$server" 2>/dev/null)
        fi
    fi
    ) | sed -ne "$sed_expr"
      # ^ basically we're doing this:
      # | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'

      # fixme: couldn't come up with a working conditional invocation of Sed here,
      #        turns out stdin is lost somehow when sed is called. Tried duplicating
      #        stdin so as to have Sed read from it, didn't work -_-
      # | ( exec 3>&1 ; [ $extract_cert -gt 0 ] && 1>&3 sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | cat )

      # Note: This works:
      # | ( sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' )

      # But: this won't :-|
      # | ( true && sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' )
}

# vi: et ts=4 sts=4 sw=4
