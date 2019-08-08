#!/bin/bash

if [[ $(stty -F /dev/ttyACM0 speed) -ne 115200 ]]
then
    stty -F /dev/ttyACM0 115200
fi

while read line
do
    echo $line >> raw.log
done < /dev/ttyACM0
