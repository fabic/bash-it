# custom/wordcount.sh
#
# FC.2015-07-03

# Count the number of occurences of words.
#
# http://2ndscale.com/rtomayko/2011/awkward-ruby
function wordfrequency() {
    awk '
        BEGIN { FS="[^a-zA-Z0-9]+" }

        {
            for (i=1; i<=NF; i++) {
                word = tolower($i)
                words[word]++
            }
        }

        END {
            for (w in words)
                 printf("%3d %s\n", words[w], w)
        }
    ' \
    | sort -rn
}
