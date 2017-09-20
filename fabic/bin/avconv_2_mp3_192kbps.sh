#!/bin/bash

AvConv="$( type -p avconv )"

audio_files=( "$@" )

for fil in "${audio_files[@]}";
do

  echo "+~~> File '$fil'"

  if [ ! -f "$fil" ]; then
    echo "| SKIPPING file '$fil' : NOT FOUND"
    echo "+-"
    echo
    continue
  fi

  out_mp3_file="`basename "$fil"`.mp3"

  AvConvCmd=(
    "$AvConv"
      -i "$fil"
      -ab 192k
      -map_metadata 0
      -id3v2_version 3
      "$out_mp3_file"
    )

  echo "| Running :"
  echo "|   ${AvConvCmd[@]}"
  echo

  time "${AvConvCmd[@]}"

  retv=$?

  echo
  echo "| ^ file '$fil' : FINISHED, exit status: $retv"

  if [ $retv -gt 0 ]; then
    echo "+---> !!! non-zero exit status while converting file '$fil'"
    exit $retv
  fi

  if [ ! -e "$out_mp3_file" ]; then
    echo "| OUPS! output file '$out_mp3_file' does NOT exist after avconv conversion"
  else
    ls -lh "$out_mp3_file"
  fi

  echo "|"
  echo "+--"
  echo
done

echo "+--- $0 ... : FINISHED"

