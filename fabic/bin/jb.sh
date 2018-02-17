#!/bin/bash
#
# FABIC/2018-02-15
#
# Dude, you wrote this so that you can launch JetBrains' apps from the command line,
# (so that it inherits you shell's environment, specifically for CLion since you
#  do play with those custom-built Clang/CMake/Ninja/etc).
#

this="`basename "$0"`"
jetbrains_toolbox="$HOME/.local/share/JetBrains/Toolbox"
apps_list=( $(ls "$jetbrains_toolbox/apps/") )
app=""

echo "+- $this $@"

if [ ! -d "$jetbrains_toolbox" ]; then
  echo "| ERROR: Folder '$jetbrains_toolbox' does not exist, exiting now."
  exit 1
fi

if [ $# -lt 1 ]; then
  echo "|"
  echo "| Usage: $0 <app>"
  echo "| Where <app> may be e.g. clion, webstorm, etc"
  echo "| See '$jetbrains_toolbox/apps/' : ${apps_list[@]}"

  if [ ${#apps_list[@]} -lt 1 ]; then
    echo "| ERROR: Found no JetBrains' apps (?!)"
    echo "| ERROR: \` see folder '$jetbrains_toolbox/apps'"
    exit 2
  else
    if false; then
      app="${apps_list[0]}"
    else
      app_bins=( $( ls -1d -tu $jetbrains_toolbox/apps/*/ch-*/*/bin/*.sh | grep -vE '(format|inspect)\.sh$' | sort ) )
      let i=0
      let sel=0
      for _app in ${app_bins[@]}; do
        echo -e "\e[32m$i\e[0m) ${_app#$jetbrains_toolbox/apps/} \e[33m($_app)\e[0m"
        let i=i+1
      done
      echo -en "\e[34m\`~~> Execute program numbered (default $sel) : "
      read -e -i $sel sel
      echo "\`~~> exec ${app_bins[$sel]}"
      exec "${app_bins[$sel]}"
      exit 2
    fi
  fi

  echo "+-"
else
  app="$1"
fi

app_dir="$jetbrains_toolbox/apps/$app"

if [ ! -d "$app_dir" ]; then
  echo
  echo "$0: ERROR: WebStorm dir. '$app_dir' does not exist (or whatever)."
  echo
  exit 127
fi

# ToolBox thing keeps several versions installed.
# (sorted by access time)
app_bins=( $( ls -1d -tu $app_dir/*/*/bin/*.sh | grep -vE '(format|inspect)\.sh$' | sort -Vr ) )

echo "FYI: Found these $app versions installed :"
for _app in ${app_bins[@]}; do echo "* $_app"; done

echo
  read -p " -- Press any key to launch -- (Ctrl-C to abort) --"
echo

exec "${app_bins[0]}" "$@"

