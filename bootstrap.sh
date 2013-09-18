#!/usr/bin/env sh

# get the working directory
MTRDIR="$( cd "$( dirname $0 )" && pwd )"

# get the mac address
# ---------------------------------------------------------------------------
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  # gnu/linux
  mac=$( ( ip link show | grep eth | awk '/ether/ {print $2}' | head -1 ) \
           2>/dev/null );
  if [ -z "$mac" ]; then
    # openwrt
    mac=$( ( ifconfig br-lan | awk '/HWaddr/ {print $5}' ) 2> /dev/null );
  fi
elif [[ "$unamestr" == 'Darwin' ]]; then
  # mac os x
  mac=$( ( ifconfig | awk '/ether/ {print $2}' ) 2> /dev/null );
fi

if [ -z "$mac" ]; then
  if [ -z "$MACADDRESS" ]; then
    echo "cannot set mac address; set MACADDRESS env" > /dev/stderr;
    exit 1
  else
    mac=$MACADDRESS;
  fi
fi

# translate to lowercase to achieve a uniform UUID representation
mac=`echo $mac | tr "[:upper:]" "[:lower:]"`
# ---------------------------------------------------------------------------





# retrieve the msmid from the server
# ---------------------------------------------------------------------------
data="{\"mac\" : \"${mac}\"}"
msmid=$( (curl -X POST -H "Content-Type: application/json" -d "$data" \
https://leone-collector.eecs.jacobs-university.de/msmpoint --cacert \
"$MTRDIR/server.crt" --cert "$MTRDIR/client.crt" --key \
"$MTRDIR/client.key" ) 2> /dev/null );

if [ -z "$msmid" ]; then
  echo "server did not send measurement id" > /dev/stderr;
  exit 1
fi
# ---------------------------------------------------------------------------





# prepare a result file
mkdir -p $MTRDIR/results && touch $MTRDIR/results/$msmid

# add crontab entries
crontab -l > currentcron 2> /dev/null
echo "5 * * * * $MTRDIR/mtr.sh \"$MTRDIR\" \"$msmid\"" >> currentcron
echo "45 * * * * $MTRDIR/submit.sh \"$MTRDIR\" \"$msmid\"" >> currentcron
crontab currentcron
rm currentcron
