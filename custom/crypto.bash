# custom/crypto.bash
#
# @link http://how-to.linuxcareer.com/using-openssl-to-encrypt-messages-and-files
#
# @since 2015-09-25
# @author fabi@fabic.net

# Tar files & symetric crypt (to stdout).
# Ex.:
#     symcrypt *.bz2 > huh.tar.bin
function symcrypt() {
    local what=( "$@" )
    tar -cf - "${what[@]}" \
        | openssl enc -aes-256-cbc
}

# Decrypt $1 file & tar -f - "$@"
#
# i.e. 1st arg. is the ciphered filename,
# further arguments are for Tar.
#
# Ex.:
#     symdecrypt huh.tar.bin -tv
function symdecrypt() {
    local what="$1"
    shift
    local targs=( "$@" )
    openssl enc -aes-256-cbc -d -in "$what" \
        | tar -f - "${targs[@]}"
}
