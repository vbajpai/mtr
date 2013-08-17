#!/usr/bin/env sh

MTRDIR=$1
MSMID=$2


# send the measurement results to the server and delete the results
# ---------------------------------------------------------------------------
curl -X POST -F results=@"$MTRDIR/results/$MSMID" \
"https://measurements.vaibhavbajpai.com/mtr/$MSMID/result" \
--cacert "$MTRDIR/server.crt" --cert "$MTRDIR/client.crt" \
--key "$MTRDIR/client.key" > /dev/null 2>&1 && \
rm -rf $MTRDIR/results/$MSMID
# ---------------------------------------------------------------------------
