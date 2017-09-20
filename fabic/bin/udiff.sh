#!/bin/sh
#
# FabiC.2014-09-17
#
# Diff. 2 directories recursively, and output a unified diff patch individually for each file.
#( the purpose being to not have the "Only in ..." lines that a diff -r produces.

a="$1"
b="$2"

LANG=C \
	diff -qur "$a" "$b" |
		grep '^Files.*differ$' |
		awk '{print $2, $4}' |
		while read a b ;
		do
			diff -u "$a" "$b"
		done

