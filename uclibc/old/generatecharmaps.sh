#! /ffp/bin/sh

cat $1 | awk 'BEGIN { i = 0 } ; { if ($1 == "CHARMAP") i=1 ; else if ($1 == "END") i=0 ; else if (i==1) { sub("/","0",$2) ; sub("<U","0x",$1) ; sub(">","",$1) ; print "{", $2, ",", $1, "}," } }'
