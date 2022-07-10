#!/bin/bash

# Mail to
MAILTO={mailto}

# First the adress we want to update, CHANGE THIS to your address
hostname={hostname}

# Second the login:pass we'll use, CHANGE THIS to your login and password
cred='$hostname:lpfmnxps'

echo "Cred: $cred"

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

# Check if we already set this ip-adress
# We should really check DNS but since there is no good
# general command line that works similar on most UNIX
# we can't rely on it.

#tempdir="$TMP"
#[ x"$tempdir" = x ] && tempdir="$TMPDIR"
#[ x"$tempdir" = x ] && tempdir=/tmp

#ipfile="$tempdir"/"$hostname".ip
#echo $ipfile
#if [ -r "$ipfile" ]
#then
  #fmyip=`grep '^'"$myip"'$' "$ipfile"`

# Fix to check what ip is currently active 
fmyip="$(cut -d' ' -f4 <<<`host $hostname`)"
if [ x"$myip" = x"$fmyip" ]
then
  echo No change detected. Wont run update.
  exit 0
fi

#fi

# Store the IP for future updates
#if [ -d "$tempdir" -a -w "$tempdir" ]
#then
#  echo "$myip" > "$ipfile"
#else
#  echo Warning, tempdir do not exist or is not writable: "$tempdir"
#fi

# Base URL
burl=https://dns.loopia.se/XDynDNSServer/XDynDNS.php

# Extra options
eops='wildcard=NOCHG'

# Build URL
url="$burl"'?hostname='"$hostname"'&'myip="$myip"'&'"$eops"
echo $url
response=`curl -s --user "$cred" "$url"`

if [ x"$response" = x"good" ]; then

  MSG="Loopia dns update for debianserver - good $fmyip -> $myip"
  mail -s "Success loopia dns update" $MAILTO <<< "$MSG"

elif [ x"$response" = x"nochg" ]; then

  MSG="Loopia dns update for debianserver - no change. Ip for $hostname still is $myip"
  mail -s "Skipping loopia dns update" $MAILTO <<< "$MSG"

else

  MSG="Loopia dns update for debianserver - failed. Please check loopiadns.sh script. Error message: $response"
  mail -s "Failed loopia dns update" $MAILTO <<< "$MSG"

fi

echo
