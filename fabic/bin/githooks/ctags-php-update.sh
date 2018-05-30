#!/bin/bash
#
# F/2018-05-21
#
# Found at http://web-techno.net/vim-php-ide/

set -e

rewt="$(cd "`git rev-parse --git-dir`/.." && pwd)"
cd "$rewt" || (echo "ERROR: $0: Could not ch.dir. into project root dir. '$rewt'" ; false) || exit 1

trap '[ -e "$rewt/$$.tags" ] && rm -v "$rewt/$$.tags"' EXIT

# --PHP-kinds=+cfi-vj

ctags --tag-relative=yes -R -f "$$.tags" \
  --fields=+aimlS --languages=php \
  --PHP-kinds=+cdfint-av          \
  --exclude=composer.phar         \
  --exclude=*Test.php             \
  --exclude=*phpunit*             \
  --exclude="\.git"

retv=$?
[ $retv -eq 0 ] || (echo "ERROR: $0: ctags command non-zero exit status: $retv" ; false) || exit $retv

[ -s "$$.tags" ] &&
  mv -v "$$.tags" "tags"
