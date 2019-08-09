#!/bin/bash

if [[ $(stty -F /dev/ttyACM0 speed) -ne 115200 ]]
then
    stty -F /dev/ttyACM0 115200
fi

file="raw$(date +%s)"

> $file

function check_output {
    sleep 1
    ts_mod=$(date -r $file +%s)
    ts_now=$(date +%s)
    if [[ $ts_mod -lt $ts_now ]]
    then
        echo -e '\x20' > /dev/ttyACM0
    fi
}

check_output &

while read line
do
    echo $line >> $file
done < /dev/ttyACM0
