#!/bin/bash
#
# 2018-03-27

files=( "$@" )

if [ ${#files[@]} -lt 1 ]; then
  echo
  echo "USAGE: $0 <video_file1.mp4> [<video_file_N> ...]"
  echo
  echo " * https://trac.ffmpeg.org/wiki/Encode/VP9"
  echo " * http://wiki.webmproject.org/ffmpeg/vp9-encoding-guide"
  echo " * http://slhck.info/video/2017/03/01/rate-control.html"
  echo
  exit 1
fi

echo "+- $0 $@"
echo "|"

for file in "${files[@]}"; do

  if [ ! -e "$file" ]; then
    echo "WARNING: Skipping file '$file': does not exist."
    continue
  fi

  output_file="${file%%.*}.webm"

  ffmpeg_cmd=( ffmpeg
    -loglevel info -stats
    -i "$file"
    -codec:v libvpx-vp9
    -vf format=yuv420p
    -crf 31 -b:v 0
    -deadline good
    -tile-columns 6 -frame-parallel 1 -threads 2 -speed 1
    -flags +cgop -g 240
    -codec:a libopus -b:a 128k
    -ac 2 -filter:a loudnorm # Defaults: -vbr on -compression_level 10
    -movflags faststart
    #-attach "$thumbnail_image_file" -metadata:s:t mimetype=image/jpeg
    #-strict -2 # MP4 container is marked "experimental".
    -f webm -y "$output_file"
  )

  echo "| Running FFmpeg :"
  echo "|   ${ffmpeg_cmd[@]}"
  echo

  time "${ffmpeg_cmd[@]}"
  retv=$?

  if [ $retv -gt 0 ]; then
    echo "WARNING: FFmpeg exited with a non-zero status: $retv"
    echo
    read -p " ~~ Continue ? (Ctrl-C to abort) ~~"
    echo
  fi

done

echo "|"
echo "+- $0 $@"
