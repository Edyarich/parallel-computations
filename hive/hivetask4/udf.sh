#!/bin/bash

while read age
do
    if [ $age -ge 0 ] && [ $age -le 100 ]
    then
        echo $(( 100 - $age ))
    else
        echo NULL
    fi
done

