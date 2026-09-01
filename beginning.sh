#!/usr/bin/env bash

# This script will start the current song over from the beginning
# Usage: While a playlist is running, bash /path/to/previous.sh

source iterator.config # Pull integrator from iterator.config file
if [[ $i -ge 1 ]]; then # Make sure I don't send the iterator into the negatives!
    echo i=$(($i-1)) > "iterator.config" # Reduce iterator by 2 and write to file
    /usr/bin/pwsp-cli action stop # Stop current song and trigger the next
else
    echo i=0 > "iterator.config" # Back to the first iterator
    /usr/bin/pwsp-cli action stop # Stop current song and trigger the next
fi
