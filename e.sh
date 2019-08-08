#!/bin/bash

if [[ ! -f vibration.log ]]
then
    echo "##date time g-force" > vibration.log
fi

if [[ $(stty -F /dev/ttyACM0 speed) -ne 115200 ]]
then
    stty -F /dev/ttyACM0 115200
fi


function check_output {
    timestamp=$(date +%s)
    sleep 1
    last=$(tail -1 vibration.log)
    re_dt="^([0-9]{2}/[0-9]{2}/[0-9]{4}\s[0-9]{2}:[0-9]{2}:[0-9]{2}).*$"
    if [[ $last =~ $re_dt ]]
    then
        ts=$(date -d "${BASH_REMATCH[1]}" +%s)
        if [[ $ts -lt $timestamp ]]
        then
            echo -e '\x20' > /dev/ttyACM0
        fi
    else
        echo -e '\x20' > /dev/ttyACM0
    fi
}

check_output &

re="^([0-9]+),\s(-?[0-9]*\.[0-9]*),\s(-?[0-9]*\.[0-9]*),\s(-?[0-9]*\.[0-9]*).*$"
while read line
do
    if [[ $line =~ $re ]]
    then
        t=$(date +"%m/%d/%Y %H:%M:%S")
        ms=${BASH_REMATCH[1]}
        x=${BASH_REMATCH[2]}
        y=${BASH_REMATCH[3]}
        z=${BASH_REMATCH[4]}
        g=$(echo $x $y $z | awk '{print sqrt($1*$1+$2*$2+$3*$3)}')
        echo $t $ms $g >> vibration.log
    else
        echo $line
    fi
done < /dev/ttyACM0
