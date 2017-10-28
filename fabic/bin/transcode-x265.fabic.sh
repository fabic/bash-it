#!/bin/bash
#
# FABIC/2017-10-27
#

# USAGE NOTICE
if [ $# -lt 2 ]; then
    echo "Usage: $0 <source_dir> <destination_dir>"
    echo
    echo -e "\tYet another FFmpeg encoging script."
    echo -e "\n\tThis one searches for video files into <source_dir> and re-encodes"
    echo -e "\tthese with libx265"
    echo -e "\n\tNote that audio tracks are _\"copied as-is\"."
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

# First loop version, which was buggy for some obscur reason.
#find "$1" -type f -iregex ".*\.\(mp4\|mkv\|flv\|avi\|mpg\|mpeg\|ogm\|mov\|dv\)" \
#    | ( while read fil ; do
#        ...
#        done )
# ^ FIXED: Strangely, only one iteration happened when actually performing encoding,
#          while _not_ executing FFmpeg did have the loop do its job just fine.
#          Replace by a process substitution, see bottom of this while-loop.

# Previous long with no sorting of files :
#( while IFS= read -r -d '' _perms _hlinks _user _group _size _date _time fil ; do
#  ...
#  done ) < <(find "$1" -type f \
#                -iregex ".*\.\(mp4\|mkv\|flv\|avi\|mpg\|mpeg\|ogm\|mov\|dv\)" \
#                -print0)

    ( while read -r _perms _hlinks _user _group _size _date _time fil ; do
          outdir="${fil##$srcdir}"
          outdir="$dstdir/${outdir%/*}"
          # File "base name" (without extension).
          filebn="${fil##*/}"
          filebn="${filebn%.*}"

          tmpext=".tmp.mp4"
          outfile="$outdir/${filebn}.mp4"
          outfile_tmp="$outdir/${filebn}${tmpext}"

          echo -e "\n\nNOW PROCESSING FILE '$fil' (`date`)\n\n"

          echo "Source file details (ls) :"
          ls -ladh "$fil"
          echo

          if [ -f "$outfile" ]; then
              echo "FILE '$outfile' EXISTS, SKIPPING..."
              continue
          elif [ ! -d "$outdir" ]; then
              echo "CREATING DESTINATION DIR. '$outdir'."
              mkdir -pv "$outdir" ||
                echo "!!! BEWARE: !!! FAILED to create dir. '$outdir' (and we ain't do nothing about it)."
          fi

          retv=127

          if true; then
            time ffmpeg -loglevel info -stats \
                     -i "$fil"                 \
                     -codec:v libx265 -x265-params log-level=info \
                     -preset slow -crf 24 -bf 2 -flags +cgop -pix_fmt yuv420p -threads 0 \
                     -c:a copy           \
                     -movflags faststart \
                     -y "$outfile_tmp"   \
                                          </dev/null #2>"$filebn.ffmpeg.log"
            retv=$?

            # Note that we're binding stdin to /dev/null here for it fixes an issue
            # where FFmpeg (or the libx265 encoder) vomits a tremendous amount of
            # garbage, and from time to time it will stall, consumming CPU cycles
            # but doing nothing.

            # ^ We're copying the audio track(s) as-is, not re-encoding these,
            #   since we can't easily adjust the bitrate so that we do not loose
            #   quality + this AAC encoder is the FFmpeg native one: there's
            #   the libfdk_aac which is said to perform better, _and_ provide
            #   an accurate VBR encoding mode.
            #-ac 2 -c:a aac -b:a 128k \

            # -x265-params log-level=error : Used as an attempt to force libx265
            # _not to_ output its loads of garbage. As it may happen that FFmpeg
            # is not passing the previously defined '-loglevel info' to libx265
            # (said StackOverflow).
          else
            echo "!! BEWARE !! FFmpeg is not executed here, see 'if false; then ...' in '${BASH_SOURCE[0]}'."
          fi

          echo -e "\n\nDONE WITH FILE '$fil' (`date`).\nFFmpeg exit status is '$retv'\n\n"
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
        done ) < <(find "$1" -type f \
                    -iregex ".*\.\(mp4\|mkv\|flv\|avi\|mpg\|mpeg\|ogm\|mov\|dv\)" \
                    -print0 | xargs -0r ls -ltr --time-style=long-iso             \
                            | sort -k6,6rb -k5,5n)
                               # ^ Sort files by date (newest first, do not
                               #   consider time) and file size (so that we process
                               #   smaller files of the day first).

# EOF
