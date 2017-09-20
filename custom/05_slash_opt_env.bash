# File: custom/01_slash_opt_env.bash
#
# F.2010-08-16 : My custom way of dealing with /opt manually compiled stuff.
#

# Where hand-built stuff reside...
PREFIX=/opt

# Note that this one is typically declared from your ~/.bash_profile
SlashOptSubdirs=${SlashOptSubdirs:-( "$SlashOptSubdirs" )}

[ ! -d "$PREFIX" ] && return

# A specific bin/ directory might exist :
[ -d "$PREFIX/bin" ] && pathprepend "$PREFIX/bin"

# When building several PHP versions, which one to use :
#PHP_VERSION=-5.3.17
#PHP_VERSION=-5.4.9
#PHP_VERSION=-5.3.23

# Array of things that get installed in their own prefixes, such as
# when doing ./configure --prefix=/opt/thing-1.2.3
#SlashOptSubdirs=( mercurial html_tidy apache php$PHP_VERSION git vim )

# For each "sub-prefix", search for bin/, lib/, lib64/, man/,
# share/man/, share/info/ and update the related environment variables.
for subdir in "${SlashOptSubdirs[@]}";
do

    dir="$PREFIX/$subdir"

    if [ ! -e "$dir" ]; then
        echo "$BASH_SOURCE : Warning: \`$dir' prefix not found."
        continue
    fi

    # PATH
    [ -d "$dir/bin" ] && pathprepend "$dir/bin"

    # LD_LIBRARY_PATH
    # 
    # Commented out, seems not be a good idea apparently (see http://xahlee.org/UnixResource_dir/_/ldpath.html),
    # and hopefully those custom-built software get rpath-ed somehow, /me guess.
    #[ -d "$dir/lib"   ] && pathprepend "$dir/lib" LD_LIBRARY_PATH
    #[ -d "$dir/lib64" ] && pathprepend "$dir/lib64" LD_LIBRARY_PATH

    # todo: What about LD_RUN_PATH ?

    # INCLUDE
    [ -d "$dir/include" ] && pathprepend "$dir/include" INCLUDE

    # MANPATH
    [ -d "$dir/share/man" ] && pathprepend "$dir/share/man" MANPATH
    [ -d "$dir/man"       ] && pathprepend "$dir/man" MANPATH

    # INFOPATH
    [ -d "$dir/share/info" ] && pathprepend "$dir/share/info" MANPATH
done

