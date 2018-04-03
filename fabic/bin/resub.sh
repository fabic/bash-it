#!/bin/bash
#
# F/2018-04-03

echo "+-- $0 $@"

if [ $# -lt 2 ]; then
  echo
  echo "USAGE: $0 <infile.mp4> <input_subtitle.srt> [file name suffix]"
  echo "                                            \` e.g. vosten, x265_720p"
  echo "  Basic script that uses FFmpeg to add a subtitle track to your downloaded videos."
  echo "  Beware of the -map X:n arguments here that select the first video and audio track only."
  echo
  exit 1
fi

infile="$1"
subfile="$2"
[ -n "$3" ] && suffix="_${3:-}" || suffix=""


ext="${infile//*.}"
outfile="${infile%.$ext}${suffix}.${ext}"

function display_infos() {
  echo "| infile:  $infile"
  echo "| ext:     $ext"
  echo "| subfile: $subfile"
  echo "| outfile: $outfile"
  echo "+-"
}

display_infos

if [ "$infile" == "$outfile" ]; then
  echo
  echo "ERROR: infile == outfile ?!"
  echo
  exit 1
fi

cmd=(
  ffmpeg -hide_banner -loglevel info
    -i "$infile"
    -sub_charenc latin1
    -i "$subfile"
    -map 0:0 -map 0:1 -map 1:0
    -c:v copy -c:a copy -c:s mov_text
      "$outfile"
      )

echo "| Running FFmpeg :"
echo "|"
echo "|   ${cmd[@]}"
echo "+-"
echo

time \
  "${cmd[@]}"

retv=$?

echo
echo "+-"
display_infos
echo "|"
echo "| FFmpeg command was:"
echo "|   ${cmd[@]}"

if [ ! -s "$outfile" ]; then
  echo
  echo "+~~> WARNING: Output file '$outfile' is empty (or does not exist) ! <~~"
  echo
else
  echo "|"
  echo "| `ls -lh "$outfile"`"
fi

echo "|"
echo "+-- DONE, exit status: $retv"
echo "    \` $0 $@"
echo

exit $retv

