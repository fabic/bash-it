#!/bin/bash
#
# FABIC/2018-01-21

# Grep matches twice, hence we're storing result here in list.
latest_version=( $( curl https://nodejs.org/dist/latest/ |
                      grep -o -P 'node-v(\d|\.){3,}-linux-x64.tar.xz' ) )
latest_version=${latest_version[0]}

tarball_fn="$latest_version"
tarball_url="https://nodejs.org/dist/latest/$tarball_fn"

if [ -e "$tarball_fn" ];
then

  echo "# File '$tarball_fn' already exists."
  echo "#          \` testing tarball integrity."
  if ! tar -tf "$tarball_fn" >/dev/null; then
    echo "#           \` FAILED, tarball may be corrupt (exiting)."
    exit 1
  else
    echo "#           \` Ok."
  fi

else # tarball file do not exist yet.

  cmd=( curl
          -C -
          -o "$tarball_fn"
          "$tarball_url" )

  echo "## Downloading Node.js binary dist. tarball:"
  echo "# Will save tarball as '$tarball_fn'."
  echo "# Invoking Curl:"
  echo "#   ${cmd[@]}"
  echo

  "${cmd[@]}"

  retv=$?
  if [ $retv -gt 0 ]; then
    echo "# ERROR: Curl exited with non-zero status: $retv"
    echo "#        \` command was:"
    echo "#              ${cmd[@]}"
    exit $retv
  fi

fi

echo "# Extracting tarball to ~/.local/"

if ! tar -xf "$tarball_fn" -C ~/.local/ ; then
  echo "# \` Bad exit code !"
  exit 2
fi

echo "# DONE (ok)"
