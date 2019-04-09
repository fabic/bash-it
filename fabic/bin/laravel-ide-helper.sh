#!/bin/bash
#
# F/2018-05-17
#
# Run barryvdh/laravel-ide-helper commands...
#

# Check current dir. is a Laravel project,
# or infer the project root from this script location.
[[ -f ./artisan && -d bootstrap/ && -d vendor/ ]] &&
  rewt="$(cd -P . && pwd)" ||
  rewt="$(cd `dirname "$0"`/.. && pwd)" # move out of ./bin/

echo
echo "+- Hello o/ ich bin $0"
echo "| https://packagist.org/packages/barryvdh/laravel-ide-helper"

echo "| Ch. dir. to Laravel app. root: $rewt"
cd "$rewt" || exit 127

[ -e ./artisan ] || (echo "| ERROR: Couldn't find the ./artisan script here at '$rewt'"; false) || exit 125

# ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

[ -e bootstrap/compiled.php ] &&
  echo "| Found a \`bootstrap/compiled.php\`, now running \`./artisan clear-compiled\` so as to clean it." &&
  php artisan clear-compiled

echo "| phpDoc generation for Laravel Facades" &&
  php artisan ide-helper:generate

[ -e _ide_helper.php ] &&
  echo "| Got that \`_ide_helper.php\` we want  o/"

# ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

echo "| PhpStorm Meta file .phpstorm.meta.php" &&
  php artisan ide-helper:meta

[ -e .phpstorm.meta.php ] &&
  echo "| Got that \`.phpstorm.meta.php\` we want  o/"

# ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

eloquentModels=( $(find app/ -maxdepth 1 -name \*.php -exec grep -l 'extends\s*Model' {} \+) )

if [ ${#eloquentModels[@]} -gt 0 ];
then
  echo "| phpDoc for models" &&
    php artisan ide-helper:models

  echo "| php artisan ide-helper:eloquent" &&
    php artisan ide-helper:eloquent
else
  echo "| FYI: Project has no Eloquent models."
fi

echo "| ~ DONE ~"

# ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

# Ask to publish the package config/ file.
if [ ! -e config/ide-helper.php ]; then
  read -p "~~> Wanna publish the config/ file ?  [y/n] " answer
  if [[ $answer =~ y(es)? ]]; then
    php artisan vendor:publish --provider="Barryvdh\\LaravelIdeHelper\\IdeHelperServiceProvider" --tag=config
  fi
else
  echo "| ok, you've got that config/ide-helper.php file in case you forgot about it."
fi

echo "| https://packagist.org/packages/barryvdh/laravel-ide-helper"
echo "+- Bye o/  (says $0)"

