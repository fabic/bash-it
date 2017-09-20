# https://github.com/fabic/bash-it/tree/master/custom/grab_ssl_certs.sh

## Extract SSL certificates from a given host
## ( note that SNI is sent, see arg. -servername)
## ( note that the actual CA certs file on your Sabayon/Gentoo
##   sys. is /etc/ssl/certs/ca-certificates.crt )
##
## @link http://stackoverflow.com/a/7886248k
## @since 2015-08-03
## @author fabi@fabic.net
function grab_ssl_certs() {
    local server="$1"
    local port="${2:-443}"

    # Method #1 : GNUtls
    if true; then
        gnutls-cli --print-cert "$server" -p"$port" </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
    # Method #2: OpenSSL
    elif false; then
        # 2015-08-03 : /me tryin' to get around that so called "warning" which
        #   ends up seemingly in silent error of not being able to proceed to any handshake :
        #     "warning, not much extra random data, consider using the -rand option"
        # This command will possibly entail that a $HOME/.rnd file is updated with some pseudo-random bytes :
        openssl rand -out /dev/null -base64 1024 2> /dev/null

        # Piping through Sed :
        if true; then
            echo | \
                openssl s_client -showcerts -prexit \
                    -connect "$server:$port" \
                    -servername "$server" 2>&1 | \
                        sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
        # 2': using x509 sub-command.
        elif false; then
            echo | openssl s_client -connect "$server:$port" -servername "$server" 2>/dev/null | openssl x509
        # 2": likewise above, but using a sub-shell construct which somewhat eludes me at the moment... 
        else
            openssl x509 -in <(openssl s_client -connect "$server:$port" -servername "$server" 2>/dev/null)
        fi
    fi 
}

# vi: et ts=4 sts=4 sw=4
