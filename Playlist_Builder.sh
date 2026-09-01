# First iteration will just make the text files and bash executable to run in OpenDeck
# Future features: option to append existing file

generate() {
cat << EOF > $1
#!/usr/bin/env bash
# Usage: bash /path/to/dev_playlist.sh /path/to/playlist.txt
# Read playlist txt file, put song locations in array, call a random array element in the pwsp-cli action
while IFS=';' read -ra array; do # Reads .txt file and puts all songs into array
ar1+=("\${array[0]}")
done < $2

#printf '%s\n' "\${ar1[@]}" # This line kept in for bug testing purposes


# Setting up the shuffled song order
last=\${#ar1[@]} # Setting up length of arbitrarily long 0:N array
ar2=(\$(seq 0 1 \$((last -1)))) # Creating array from 0 to N-1, N is the length of the playlist
ar3=(\$(shuf -e "\${ar2[@]}")) # Create array of shuffled numbers from 0 to N-1

systemctl --user restart pwsp-daemon # Insures pwsp daemon is running

function get_status {
    /usr/bin/pwsp-cli get state;
} #This just saves the command as get_status
function play_status {
    get_status | awk -F '"' '{print \$2}';
} # Fetches "Playing," "Paused," or "Stopped" out of the get_status function


i=0 # Set iterator to 0
echo i=\$i > "iterator.config" # export iterator to file to enable previous/next


# I think this is more or less the final version of the play loop
while [[ i -le \$((last -1)) ]]; do # Loop while i is smaller than the max index
	if [[ \$(play_status) != Stopped ]]; then # If playing or paused, wait a second before checking status again
		sleep 1

	elif [[ \$(play_status) == Stopped ]]; then # If stopped then play next and increase iterator
		source iterator.config # grabs iterator value from file, enables previous/next
		printf "\nIterator is {\$i}\n" # For testing/development, delete when done
		inp=\${ar3[\$i]} # Set inp as variable for ease of later code lol
		/usr/bin/pwsp-cli action play "\${ar1[inp]}" # plays the song
		echo i=\$((\$i+1)) > "iterator.config" # increase iterator
		source iterator.config # grabs iterator value from file, prevents while loop from repeating an extra time
	fi
done
EOF
}

zenity --info --text="This script will bring up dialogue boxes like this one for you to pick your music. The entire script is available for you to inspect. It uses Zenity calls and basic bash scripting to accomplish everything." # Bring up info box to let user know these will be called

# Option to edit playlist, cancel, or create new
selec=$(zenity --list --title="Choose an option" --column="Playlist Options" "Create a Playlist" "Add to Playlist" "Write new Hardcoded Playlist Executable")

# Name playlist, add music, write to file, make bash script to play it
if [[ "${selec}" == "Create a Playlist" ]]; then
	PLAYLIST_NAME=$(zenity --entry --title="Input required" --text="Name your playlist:")
	while true; do # Will need a loop, while user selection is "add another song", pull up file selection, save file name to playlist, ask again
		if zenity --question --text="Add music to playlist?"; then #Bring up selection
			zenity --file-selection --multiple separator="|" | tr '|' '\n'>> "${PLAYLIST_NAME}.txt"	 # This is what happens when user selects yes
			"," >> "${PLAYLIST_NAME}.txt"
		else
			break # This is what happens when user selects No
		fi
	done
	if zenity --question --text="Write new hardcoded script for playing Playlist?"; then
		#Write bash script to play Playlist in OpenDeck if answer is Yes
		printf "Writing your bash script for playing..."

		generate "${PLAYLIST_NAME}_play.sh" "${PLAYLIST_NAME}.txt"

		printf "Execute <bash [your playlist executable.sh> in OpenDeck or a terminal to play your playlist!"	# Indicated end of file creation
	else
		break
	fi
# Select old playlist, add music to playlist
elif [[ "${selec}" == "Add to Playlist" ]]; then
	PLAYLIST_NAME=$(zenity --file-selection --file-filter="*.txt" --title="Choose your .txt playlist")

	while true; do # Will need a loop, while user selection is "add another song", pull up file selection, save file name to playlist, ask again
		if zenity --question --text="Add music to playlist?"; then #Bring up selection
			zenity --file-selection --multiple separator="|" | tr '|' '\n'>> "${PLAYLIST_NAME}"	 # This is what happens when user selects yes
			"," >> "${PLAYLIST_NAME}"
		else
			break # This is what happens when user selects No
		fi
	done

	# Ask if new executable needed
	if zenity --question --text="Write new hardcoded script for playing Playlist?"; then
		#Write bash script to play Playlist in OpenDeck if answer is Yes
		printf "Writing your bash script for playing..."
		generate "${PLAYLIST_NAME::-4}_play.sh" "${PLAYLIST_NAME}"

		printf "Execute <bash [your playlist executable.sh> in OpenDeck or a terminal to play your playlist!"	# Indicated end of file creation
	else
		continue
	fi
elif [[ "${selec}" == "Write New Hardcoded Playlist Executable" ]]; then
	if zenity --question --text="You want to write a new hardcoded bash play script?"; then #Bring up selection
			SCRIPT_NAME=$(zenity --entry --title="Input required" --text="Name your bash script:")
			PLAYLIST_NAME=$(zenity --file-selection --file-filter="*.txt" --title="Choose your .txt playlist")
			printf "Writing your bash script for playing..."
			generate "${SCRIPT_NAME}.sh" $PLAYLIST_NAME

			printf "Execute <bash [your playlist executable.sh> in OpenDeck or a terminal to play your playlist!"	# Indicated end of file creation
		else
			break # This is what happens when user selects No
		fi
else
	break
fi


