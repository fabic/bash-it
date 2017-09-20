#!/bin/bash

src="$1"
dst="$2"

find "$src" -type f -iregex '.*\(mkv\)$' |
while read fn_orig; do
	fn_new=$(echo "$fn_orig" | tr / _ )
	echo --- $fn_new ---
done

