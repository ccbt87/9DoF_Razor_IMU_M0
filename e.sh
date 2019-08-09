#!/bin/bash

if [[ $(stty -F /dev/ttyACM0 speed) -ne 115200 ]]
then
    stty -F /dev/ttyACM0 115200
fi

function change_rate {
    re="^IMU rate set to ([0-9]{1,3}) Hz"
    echo -e '\x72' > /dev/ttyACM0
    while read line
    do
        if [[ $line =~ $re ]]
        then
            if [[ $rate -eq ${BASH_REMATCH[1]} ]]
            then
                break
            else
                echo -e '\x72' > /dev/ttyACM0
            fi
        fi
    done < /dev/ttyACM0
}

#rate=100
if [[ -n $rate ]]
then
    change_rate
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
