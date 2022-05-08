#!/bin/bash

while read str
do
    echo "${str//Safari/Chrome}"
done

