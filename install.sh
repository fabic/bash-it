#!/usr/bin/env bash

test -w $HOME/.bash_profile &&
  cp $HOME/.bash_profile $HOME/.bash_profile.bak &&
  echo "Your original .bash_profile has been backed up to .bash_profile.bak"

# F.2012-12-18
# ~/.bash_it symlink to "here" :
BASH_IT=$(cd `dirname "$0"` && pwd)
BASH_IT=${BASH_IT##$HOME/}

echo "Symlinking \`$BASH_IT' to \`$HOME' :"
ln -sfnv "$BASH_IT" ~/.bash_it
BASH_IT="$HOME/.bash_it"

if [ ! -e "$BASH_IT/bash_it.sh" ]; then
    echo "Could not find bash_it.sh at \`$BASH_IT', exiting.."
    exit
fi

# F.2012-12-19 Wed.
if [ ! -e "$BASH_IT/dot_bash_profile" ]; then
    cp "$BASH_IT/template/bash_profile.template.bash" "$BASH_IT/dot_bash_profile"
    echo "Copied the template .bash_profile as dot_bash_profile, edit this file to customize bash-it"
fi

echo "Symlinking \`$BASH_IT/dot_bash_profile' to \`$HOME' :"
ln -sfv --backup=numbered "$HOME/.bash_it/dot_bash_profile" "$HOME/.bash_profile"

while true
do
  read -p "Do you use Jekyll? (If you don't know what Jekyll is, answer 'n') [Y/N] " RESP

  case $RESP
    in
    [yY])
      cp --backup=numbered $BASH_IT/template/jekyllconfig.template.bash $HOME/.jekyllconfig
      echo "Copied the template .jekyllconfig into your home directory. Edit this file to customize bash-it for using the Jekyll plugins"
      break
      ;;
    [nN])
      break
      ;;
    *)
      echo "Please enter Y or N"
  esac
done

function load_all() {
  file_type=$1
  [ ! -d "$BASH_IT/$file_type/enabled" ] && mkdir "$BASH_IT/${file_type}/enabled"
  for src in $BASH_IT/${file_type}/available/*; do
      filename="$(basename ${src})"
      [ ${filename:0:1} = "_" ] && continue
      dest="${BASH_IT}/${file_type}/enabled/${filename}"
      if [ ! -e "${dest}" ]; then
          ln -s "../available/${filename}" "${dest}"
      else
          echo "File ${dest} exists, skipping"
      fi
  done
}

function load_some() {
    file_type=$1
    for path in `ls $BASH_IT/${file_type}/available/[^_]*`
    do
      if [ ! -d "$BASH_IT/$file_type/enabled" ]
      then
        mkdir "$BASH_IT/$file_type/enabled"
      fi
      file_name=$(basename "$path")
      while true
      do
        read -p "Would you like to enable the ${file_name%%.*} $file_type? [Y/N] " RESP
        case $RESP in
        [yY])
          ln -s "../available/${file_name}" "$BASH_IT/$file_type/enabled"
          break
          ;;
        [nN])
          break
          ;;
        *)
          echo "Please choose y or n."
          ;;
        esac
      done
    done
}

for type in "aliases" "plugins" "completion"
do
  while true
  do
    read -p "Would you like to enable all, some, or no $type? Some of these may make bash slower to start up (especially completion). (all/some/none) " RESP
    case $RESP
    in
    some)
      load_some $type
      break
      ;;
    all)
      load_all $type
      break
      ;;
    none)
      break
      ;;
    *)
      echo "Unknown choice. Please enter some, all, or none"
      continue
      ;;
    esac
  done
done
