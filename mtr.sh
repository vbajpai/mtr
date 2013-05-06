#!/usr/bin/env sh

MTRDIR=$1
MSMID=$2

$MTRDIR/bin/mtr -c 1 --no-dns -4 --csv --aslookup --filename $MTRDIR/topsites \
  >> $MTRDIR/results/$MSMID 2> /dev/null
$MTRDIR/bin/mtr -c 1 --no-dns -6 --csv --aslookup --filename $MTRDIR/topsites \
  >> $MTRDIR/results/$MSMID 2> /dev/null
