#!/bin/bash

counter=1

for file in *.jpg; do
	if [ $counter -lt 10 ]; then
		f="000${counter}.jpg"
	elif [ $counter -lt 99 ]; then
		f="00${counter}.jpg"
	elif [ $counter -lt 999 ]; then
		f="0${counter}.jpg"
	else
		f="${counter}.jpg"
	fi
	mv "$file" $f 2> /dev/null 
	counter=$((counter+1))
done
