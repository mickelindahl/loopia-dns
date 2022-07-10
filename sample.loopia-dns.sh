#!/bin/bash

# Mail to
MAILTO={mailto}

# First the adress we want to update, CHANGE THIS to your address
HOSTNAME={hostname}
PASSWORD={password}

# Second the login:pass we'll use, CHANGE THIS to your login and password

# Get IP adress from Loopia
myip=`curl -s dns.loopia.se/checkip/checkip.php | sed 's/^.*: \([^<]*\).*$/\1/'`
echo $myip
# Check that we actually got anything
if [ x"$myip" = x ]
then
  echo Failed to get IP. Exiting.
  exit 255
fi

# Check that we actually got anything more or less sane
# Should really check that it's actually is an ipadress
# on the format 1.2.3.4 where each number is less than 256.
fmyip=`echo "$myip" | tr -cd '0-9.'`

if [ x"$fmyip" != x"$myip" ]
then
  echo Failed to understand IP received: "$myip"
  echo Exiting
  exit 255
fi

# Fix to check what ip is currently active
fmyip="$(cut -d' ' -f4 <<<`host $HOSTNAME`)"
if [ x"$myip" = x"$fmyip" ]
then
  echo No change detected. Wont run update.
  exit 0
fi

# Base URL
burl=https://dns.loopia.se/XDynDNSServer/XDynDNS.php

# Extra options
eops='wildcard=NOCHG'

# Credentials
cred="$HOSTNAME:$PASSWORD"

# Build URL
url="$burl"'?hostname='"$HOSTNAME"'&'myip="$myip"'&'"$eops"
echo $url
response=`curl -s --user "$cred" "$url"`

if [ x"$response" = x"good" ]; then

  MSG="Loopia dns update for debianserver - good $fmyip -> $myip"
  echo "$MSG"
  mail -s "Success loopia dns update" $MAILTO <<< "$MSG"

elif [ x"$response" = x"nochg" ]; then

  MSG="Loopia dns update for debianserver - no change. Ip for $HOSTNAME still is $myip"
  echo "$MSG"
  mail -s "Skipping loopia dns update" $MAILTO <<< "$MSG"

else

  MSG="Loopia dns update for debianserver - failed. Please check loopiadns.sh script. Error message: $response"
  echo "$MSG"
  mail -s "Failed loopia dns update" $MAILTO <<< "$MSG"

fi
