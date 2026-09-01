#!/usr/bin/env bash

# Usage: bash /path/to/Short_beetle_Executable.sh /path/to/playlist.txt

# Read playlist txt file, put song locations in array, call a random array element in the pwsp-cli action
while IFS=';' read -ra array; do # Reads .txt file and puts all songs into array
ar1+=("${array[0]}")
done < $1

#printf '%s\n' "${ar1[@]}" # This line kept in for bug testing purposes


# Setting up the shuffled song order
last=${#ar1[@]} # Setting up length of arbitrarily long 0:N array
ar2=($(seq 0 1 $((last -1)))) # Creating array from 0 to N-1, N is the length of the playlist
ar3=($(shuf -e "${ar2[@]}")) # Create array of shuffled numbers from 0 to N-1

systemctl --user restart pwsp-daemon # Insures pwsp daemon is running

function get_status {
    /usr/bin/pwsp-cli get state;
} #This just saves the command as get_status
function play_status {
    get_status | awk -F '"' '{print $2}';
} # Fetches "Playing," "Paused," or "Stopped" out of the get_status function

# Now to play the music

i=0 # Set iterator to 0
echo i=$i > "iterator.config" # export iterator to file to enable previous/next

# I think I need to change the playlist loop logic to use ifs if I want to make any more progress
# Nest ifs inside current while
while [[ i -le $((last -1)) ]]; do # Loop while i is smaller than the max index
	if [[ $(play_status) == Stopped ]]; then # If stopped then increase iterator and go to the start of the while loop
		source iterator.config # grabs iterator value from file
		printf "\nIterator is {$i}\n" # For testing/development, delete when done
		inp=${ar3[$i]} # Set inp as variable for ease of later code lol
		/usr/bin/pwsp-cli action play "${ar1[inp]}" # plays the song
		echo i=$(($i+1)) > "iterator.config" # increase iterator
	else
		sleep 1
	fi
done


rm iterator.config
