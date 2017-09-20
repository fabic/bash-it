#!/bin/bash
#
# File: transcode.sh
#
# Author: "Fabien Cadet" <cadet.fabien@gmail.com>
#
# 2013-05-14
#
# See https://www.virag.si/2012/01/web-video-encoding-tutorial-with-ffmpeg-0-9/
# TODO: http://www.virag.si/2012/01/webm-web-video-encoding-tutorial-with-ffmpeg-0-9/
#

# Usage: transcode_ffmpeg <preset> <infile> [<outfile>]
transcode_ffmpeg() {
    preset="$1"
    infile="$2"
    outfile="${3:-${infile%.*}}.$preset"

    echo -e "\n\tpreset: $preset\n\tInfile: $infile\n\tOutfile: $outfile\n";

    case $preset in
        '480p500kbs')
            # “Standard” web video (480p at 500kbit/s):
            ffmpeg -i "$infile" -vcodec libx264 -vprofile high -preset slow -b:v 500k \
                	-maxrate 500k -bufsize 1000k -vf scale=-1:480 -threads 4 -acodec libvo_aacenc \
                	-b:a 128k "$outfile.mp4"
            # 484 instead of 480 because avconv complains that width is not div. by 2 -_-
            #time avconv -i "$infile" -vcodec libx264 -vprofile high -preset slow -b:v 500k \
            #    -maxrate 500k -bufsize 1000k -vf scale=-1:484 -threads 4 -acodec libvo_aacenc \
            #    -b:a 128k "$outfile.mp4"
            ;;

        '360p250kbs')
            # 360p video for older mobile phones (360p at 250kbit/s in baseline profile):
            ffmpeg -i "$infile" -vcodec libx264 -vprofile baseline -preset slow \
                -b:v 250k -maxrate 250k -bufsize 500k -vf scale=-1:360 \
                -threads 4 -acodec libvo_aacenc -ab 96k "$outfile.mp4"
            ;;

        '480p400kbs')
            # 480p video for iPads and tablets (480p at 400kbit/s in main profile):
            ffmpeg -i "$infile" -vcodec libx264 -vprofile main -preset slow \
                -b:v 400k -maxrate 400k -bufsize 800k -vf scale=-1:480 \
                -threads 4 -acodec libvo_aacenc -ab 128k "$outfile.mp4"
            ;;

        'PAL')
            # High-quality SD video for archive/storage (PAL at 1Mbit/s in high profile):
            ffmpeg -i "$infile" -vcodec libx264 -vprofile high -preset slower \
                -b:v 1000k -vf scale=-1:576 -threads 4 -acodec libvo_aacenc -ab 196k "$outfile.mp4"
            ;;

        'AAC')
            # TODO: ffmpeg ?
            echo \
                avconv -i "$infile" -vn -threads 4 -acodec libvo_aacenc -b:a 96k "$outfile.audio.mp4"
            ;;

        'MP3-*')
            let bitrate=1024*${preset#MP3-}
            echo -e "\tBitrate (-ab): $bitrate\n"
            ffmpeg -i "$infile" -threads 4 -vn -ar 44100 -ac 2 -ab $bitrate -f mp3 "$outfile.mp3"
            ;;
    esac

    echo "END!"
    return $?
}

transcode_avconv() {
    preset="$1"
    infile="$2"
    outfile="${3:-${infile%.*}}.$preset"

    echo -e "\n\tpreset: $preset\n\tInfile: $infile\n\tOutfile: $outfile\n";

    case $preset in
        '480p500kbs')
            # “Standard” web video (480p at 500kbit/s):
            # 484 instead of 480 because avconv complains that width is not div. by 2 -_-
            avconv -i "$infile" -vcodec libx264 -vprofile high -preset slow -b:v 500k \
                -maxrate 500k -bufsize 1000k -vf scale=-1:484 -threads 4 -acodec libvo_aacenc \
                -b:a 128k "$outfile.mp4"
            ;;

        '360p250kbs')
            # 360p video for older mobile phones (360p at 250kbit/s in baseline profile):
            echo \
                ffmpeg -i "$infile" -vcodec libx264 -vprofile baseline -preset slow \
                -b:v 250k -maxrate 250k -bufsize 500k -vf scale=-1:360 \
                -threads 4 -acodec libvo_aacenc -ab 96k "$outfile.mp4"
            ;;

        '480p400kbs')
            # 480p video for iPads and tablets (480p at 400kbit/s in main profile):
            echo \
                ffmpeg -i "$infile" -vcodec libx264 -vprofile main -preset slow \
                -b:v 400k -maxrate 400k -bufsize 800k -vf scale=-1:480 \
                -threads 4 -acodec libvo_aacenc -ab 128k "$outfile.mp4"
            ;;

        'PAL')
            # High-quality SD video for archive/storage (PAL at 1Mbit/s in high profile):
            echo \
                ffmpeg -i "$infile" -vcodec libx264 -vprofile high -preset slower \
                -b:v 1000k -vf scale=-1:576 -threads 4 -acodec libvo_aacenc -ab 196k "$outfile.mp4"
            ;;

        'AAC')
            avconv -i "$infile" -vn -threads 4 -acodec libvo_aacenc -b:a 96k "$outfile.audio.mp4"
            ;;

        'MP3-*')
            let bitrate="${preset#MP3-}k"
            echo -e "\tBitrate (-ab): $bitrate\n"
            avconv -i "$infile" -vn -threads 0 -acodec libmp3lame -b:a $bitrate "$outfile.mp3"
            ;;
    esac

    return $?
}

function vidinfo() {
    ffprobe -v quiet -print_format json -show_streams -show_format
    #ffprobe "$1" 2>&1 |
    #    grep -P '^\s+Stream #\d\.\d.*:\s+Video:' |
    #        awk 'BEGIN {FS=", "}{print $3}'
    return $?
}


#echo `basename "$0"`
#echo "${BASH_SOURCE[0]}"

# If we're being called directly (i.e. not being sourced) :
if [ `basename "$0"` == `basename "${BASH_SOURCE[0]}"` ]; then
    transcode_ffmpeg "$@"
    #transcode_avconv "$@"
fi
