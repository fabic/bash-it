#!/bin/bash
#
# FABIC/2017-11-02
#
# Dude, you wrote this so that you can launch WebStorm from the command line,
# (so that it inherits you shell's environment).
#

jetbrains_toolbox="$HOME/.local/share/JetBrains/Toolbox"
expected_webstorm_at="$jetbrains_toolbox/apps/WebStorm"

if [ ! -d "$expected_webstorm_at" ]; then
  echo
  echo "$0: ERROR: WebStorm dir. '$expected_webstorm_at' does not exist (or whatever)."
  echo
  exit 127
fi

# ToolBox thing keeps several versions installed.
webstorm_bins=( $( ls -1d $expected_webstorm_at/*/*/bin/webstorm.sh | sort -Vr ) )

echo "FYI: Found these WebStorm versions installed :"
echo ${webstorm_bins[@]}

exec "${webstorm_bins[0]}" "$@"

