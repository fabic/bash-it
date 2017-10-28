#!/bin/bash
#
# FABIC/2017-10-27

if [ $# -lt 2 ]; then
    echo "Usage: $0 <source_dir> <destination_dir>"
    exit 1
fi

srcdir="$1"
dstdir="$2"

if [ ! -d "$srcdir" ]; then
    echo "ERROR: Source directory '$srcdir' does not exist (or whatever alike)."
    exit 2
fi

if [ ! -d "$dstdir" ]; then
    echo "Creating output top-level directory '$dstdir'"
    mkdir "$dstdir" ||
        echo "WARNING: Failed to create dest. dir. '$dstdir'"
fi

find "$1" -type f -iregex ".*\.\(mp4\|mkv\|flv\|avi\|mpg\|mpeg\|ogm\|mov\|dv\)" \
    | ( while read fil ; do
          outdir="${fil##$srcdir}"
          outdir="$dstdir/${outdir%/*}"
          filebn="${fil##*/}"
          filebn="${filebn%.*}"
          tmpext=".tmp.mp4"
          outfile="$outdir/${filebn}.mp4"
          outfile_tmp="$outdir/${filebn}${tmpext}"

          if [ -f "$outfile" ]; then
              echo "FILE '$outfile' EXISTS, SKIPPING..."
              continue
          elif [ ! -d "$outdir" ]; then
              echo "CREATING DESTINATION DIR. '$outdir'."
              mkdir -pv "$outdir" ||
                  echo "### BEWARE: FAILED to create dir. '$outdir'"
          fi

          echo -e "\n\nNOW PROCESSING FILE '$fil'\n\n"

          time ( ffmpeg -loglevel error -stats \
                   -i "$fil" \
                   -codec:v libx265 -x265-params log-level=error \
                   -preset slow -crf 24 -bf 2 -flags +cgop -pix_fmt yuv420p -threads 0 \
                   -c:a copy \
                   -movflags faststart \
                   -y "$outfile_tmp" ) \
                                         2> "$outfile.ffmpeg.log"

              #-ac 2 -c:a aac -b:a 128k \

          retv=$?

          echo -e "\n\nDONE WITH FILE '$fil', FFmpeg exit status is '$retv'\n\n"
          echo "OUTPUT FILE shall be '$outfile_tmp' :"
          ls -ladh "$outfile_tmp"
          echo

          if [ $retv -gt 0 ]; then
              echo "WARNING: FFmpeg exited with a non-zero status code, STOPPING NOW.".
              break
          elif [ ! -f "$outfile_tmp" ]; then
              echo "WARNING: Temporary output file '$outfile_tmp' DOES NOT EXIST !"
          else
              echo "DONE: Now renaming temp. file to '$outfile'"
              mv -v "$outfile_tmp" "$outfile" ||
                  echo "WARNING: Failed to renamed the temporary output file '$outfile_tmp' to '$outfile'."
              ls -ladh "$outfile"
          fi

          echo -e "\n\n\t( NEXT ITERATION )\n\n"
        done )

