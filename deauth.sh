#!/bin/bash
echo 'Your network interface name?'
read interface

INTERFACE= $interface

echo 'Victim network BSSID'
read bssid
BSSID=$bssid

echo 'Your mac address'
read mac
WHITELIST=(mac)


