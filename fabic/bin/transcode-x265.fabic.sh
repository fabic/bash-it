#!/bin/bash
#
# FABIC/2017-10-27
#

# USAGE NOTICE
if [ $# -lt 2 ]; then
    echo "Usage: $0 <source_dir> <destination_dir> [H265|VP9]"
    echo
    echo -e "\tYet another FFmpeg encoging script."
    echo -e "\n\tThis one searches for video files into <source_dir> and re-encodes"
    echo -e "\tthese with libx265"
    echo -e "\n\tNote that audio tracks are _\"copied as-is\"."
    exit 1
fi

srcdir="$1"
dstdir="$2"
use_codec="${3:-VP9}"


# Remove eventual leading slash (sugar).
srcdir="${srcdir%/}"
dstdir="${dstdir%/}"

if [ ! -d "$srcdir" ]; then
    echo "ERROR: Source directory '$srcdir' does not exist (or whatever alike)."
    exit 2
fi

if [ ! -d "$dstdir" ]; then
    echo "Creating output top-level directory '$dstdir'"
    mkdir "$dstdir" ||
        echo "WARNING: Failed to create dest. dir. '$dstdir'"
fi

# TODO: ensure source and dest. dir. be not the same !



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
          # Remove the source dir. (including the last '/').
          outdir="${fil##$srcdir/}"
          # Remove the filename portion (including the last '/').
          outdir="$dstdir/${outdir%/*}"
          # File "base name" (without extension).
          filebn="${fil##*/}"
          filebn="${filebn%.*}"

          ext="webm"
          tmpext=".tmp.$ext"
          outfile="$outdir/${filebn}.${ext}"
          outfile_tmp="$outdir/${filebn}${tmpext}"

          thumbnail_image_file="${outfile%.$ext}.jpg"

          echo -e "\n\nNOW PROCESSING FILE '$fil' (`date`)\n\n"

          # Source file may have disappeared.
          if [ ! -e "$fil" ]; then
            echo -e "\n\n\nERROR (!): Source file '$fil' has gone away :-/ ( SKIPPING ).\n\n"
            continue
          fi

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

          # Generate a COVER IMAGE that we'll add later on to the MP4.
          # https://superuser.com/q/538112
          if true; then
            echo -e "Generating a thumbnail image :"
            if ! time ffmpeg -ss 10 -i "$fil"       \
              -vf "thumbnail,scale=-1:480" \
              -frames:v 1                 \
              -vsync vfr                  \
              -y "$thumbnail_image_file" </dev/null ;
            then
              echo "WARNING: Generation of the cover image may well have failed here,"
              echo "         for FFmpeg exit status is non-zero: $?"
            else
              echo "Done, cover image would be :"
              ls -lahd "$thumbnail_image_file"
              echo
            fi
          fi

          # Will be set to the exit status of FFmpeg.
          retv=127

          # Actual encoding happens here.
          if true; then
            if [ "$use_codec" == "VP9" ]; then
              ffmpeg_cmd=(
                ffmpeg
                  -loglevel info -stats
                  -i "$fil"
                  -codec:v libvpx-vp9
                    -vf format=yuv420p
                    -crf 31 -b:v 0
                    -deadline good
                    -tile-columns 2 -threads 4
                    -flags +cgop -g 240
                  -codec:a libopus -b:a 96k
                    -ac 2 -filter:a loudnorm # Defaults: -vbr on -compression_level 10
                  -movflags faststart
                  #-attach "$thumbnail_image_file" -metadata:s:t mimetype=image/jpeg
                  #-strict -2 # MP4 container is marked "experimental".
                  -y "$outfile_tmp"
              )
            elif [ "$use_codec" == "H265" ]; then
              ffmpeg_cmd=(
                ffmpeg
                  -loglevel info -stats
                  -i "$fil"
                  -codec:v libx265 #-x265-params log-level=info
                  -preset medium -threads 0
                  -vf format=yuv420p
                  -crf 26 -bf 2 -flags +cgop -g 60
                  -c:a copy
                  -movflags faststart
                  -y "$outfile_tmp"
              )
            else
              echo -e "\n\nERROR: \$use_codec=\"$use_codec\" is neither H265, nor VP9."
              break
            fi

            echo -e "\nNow running the actual FFmpeg/libx265 video transcoding, "
            echo -en "command will be something like :\n"
            echo -e "    ${ffmpeg_cmd[@]} \"$outfile_tmp\" </dev/null \n"

            time \
              "${ffmpeg_cmd[@]}" </dev/null

            retv=$?

            # Flags that you removed (and put back -_-) :
            #   * -bf 2  : max. number of B-frames, defaults to 16 for H264.
            #   * -flags +cgop -g 60 : Enable Closed Group Of Images, and a GOP
            #                          length of 60 frames ~= 2 seconds x 30 images/sec.
            #   * -profile:v main : libx265 still doesn't know about this option.
            #
            # * -crf 24 : visual output is said to be "visually transparent".
            # * -crf 28 : default for libx265.

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

            # -pix_fmt yuv420p <=> -vf format=yuv420p
          else
            echo "!! BEWARE !! FFmpeg is not executed here, see 'if false; then ...' in '${BASH_SOURCE[0]}'."
            #retv=0
          fi

          echo -e "\n\nDONE WITH FILE '$fil' (`date`).\nFFmpeg exit status is '$retv'\n\n"
          echo "OUTPUT FILE shall be '$outfile_tmp' :"
          ls -ladh "$outfile_tmp"
          echo

          # Check exit status, and rename temp. file to the final output
          # file name (with optional handling of cover image).
          if [ $retv -gt 0 ]; then
              echo "WARNING: FFmpeg exited with a non-zero status code, STOPPING NOW.".
              break
          elif [ ! -f "$outfile_tmp" ]; then
              echo "WARNING: Temporary output file '$outfile_tmp' DOES NOT EXIST !"
          else # GOOD.
              echo "DONE: Now renaming temp. file to '$outfile'"
              mv -v "$outfile_tmp" "$outfile" ||
                  echo "WARNING: Failed to renamed the temporary output file '$outfile_tmp' to '$outfile'."
              echo "INFO: Input file versus output file :"
              ls -ladh "$fil" "$outfile"

              # Add cover image to the MP4 output file.
              if type -p mp4art >/dev/null && [ -e "$thumbnail_image_file" ] \
                                           && [ "$ext" == "mp4" ];
              then
                echo "About to add the previously generated cover image '$thumbnail_image_file' :"
                mp4art -zv --add "$thumbnail_image_file" "$outfile" ||
                  echo "WARNING: The mp4art command failed for some reason."
              else
                echo "NOTICE: We're NOT adding a cover image to that MP4 file,"
                echo "        for either the mp4art binary wasn't found, "
                echo "        or the thumbnail image '$thumbnail_image_file' was not generated."
              fi
          fi

          # Send notification e-mail (with the cover image attached).
          if false; then
            echo "Sending notification e-mail."
            # FIXME: check that the cover image exists.
            cat <<EOF | mail -s "$0: $outfile" -a "$thumbnail_image_file" cadet.fabien+sys@gmail.com
Hi! this is $0, just to let you know that I'm done with one more file encoding,
here are your input and output files compared :

$(ls -lahd "$fil" "$outfile")

FFmpeg command was :

 ${ffmpeg_cmd[@]} </dev/null

* http://winterfell.local/~fabi/$outfile
* smb://winterfell/fabi/$outfile

Media details :

$(ffprobe -hide_banner "$outfile" 2>&1)

Cheers.
EOF
          fi

          # Remove thumbnail image.
          if [ -e "$thumbnail_image_file" ]; then
            echo "Removing the generated cover image '$thumbnail_image_file'."
            rm -v "$thumbnail_image_file" ||
              echo "WARNING: Ouch?! failed to remove '$thumbnail_image_file' ?!"
          fi

          echo -e "\n\n\t( NEXT ITERATION )\n\n"

               # Here's the process-substitution artifact that will feed the loop
               # with files.
        done ) < <(find "$1" -type f \
                    -iregex ".*\.\(mp4\|mkv\|flv\|webm\|xvid\|divx\|avi\|mpg\|mpeg\|ogm\|mov\|dv\)" \
                    -print0 | xargs -0r ls -ltr --time-style=long-iso             \
                            | sort -k5,5n)
                            #| sort -k6,6rb -k5,5n)
                               # ^ Sort files by date (newest first, do not
                               #   consider time) and file size (so that we process
                               #   smaller files of the day first).

# EOF
