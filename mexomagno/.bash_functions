#!/bin/bash

###########################################################
# Shared bash functions
# These are some commonly used (by me) functions I made.
# Some are pretty useful :D
###########################################################

# Bash utilities
array_contains () { 
	# Usage: array_contains array element
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

get_current_ip (){
	ip="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"
	echo $ip
}

# Custom functions
img2web(){
	# Prepare image for website
	# Usage: img2web <inputfile> <size> <outputdir>

	# Check if inputfile exists
	[[ ! -f "$1" ]] && echo "Error: Input file doesn't exist" && return 1
	# Check if outputdir exists
	[[ ! -d "$3" ]] && echo "Error: Output directory doesn't exist" && return 1
	# Check if number is valid
	isNumber "$2"
	[[ "$?" == "0" ]] && echo "Error: Size argument is not a number" && return 1
	# Check if number is between valid values
	MIN_VAL=1
	MAX_VAL=10000
	[[ "$2" -lt "$MIN_VAL" ]] || [[ "$2" -gt "$MAX_VAL" ]] && echo "Error: Size argument must be between $MIN_VAL and $MAX_VAL" && return 1
	# Finally, convert image
	mogrify -path "$3" -filter Triangle -define filter:support=2 -thumbnail "$2" -unsharp 0.25x0.08+8.3+0.045 -dither None -posterize 136 -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB "$1"
	echo "Saved file in "$3""
	return 0
}
new-gnome-launcher-app(){
	# This functions adds some executable file to the gnome launcher.
	# It does the following:
	# 	- Add symlink to /usr/bin
	# 	- Add entry for gnome launcher

	# Check if root
	# if [ "$(id -u)" != "0" ]; then 
	# 	echo "Must run as root"
	# 	return 1
	# fi

	# If parameter is entered, assume it's the executable's directory.
	# Else, ask for it
	if [ "$?" -gt "1" ]; then
		exec_path="$1"
	else
		read -e -p "Enter executable file name: " exec_path
	fi
	# Check if file exists
	if [ ! -f "$exec_path" ] && [ ! -f "$(pwd)/$exec_path" ]; then
		echo "File doesn't exist"
		unset exec_path
		return 1
	fi
	# Get absolute path to file
	if [ "${exec_path:0:1}" != "/" ]; then
		echo "'$exec_path' was not an absolute path"
		exec_path="$(pwd)/$exec_path"
		echo "Assuming path '$exec_path'"
	fi
	exec_basename="$(basename "$exec_path")"
	# Check if symlink already exists
	if [ -f "/usr/bin/$exec_basename" ]; then
		echo "File '/usr/bin/$exec_basename' already exists. We wont be able to create the symlink."
		unset exec_basename
		unset exec_path
		return 1
	fi
	# Add entry for gnome panel
	gnome_panel_entry_path="/usr/share/applications/$exec_basename.desktop"
	if [ -f "$gnome_panel_entry_path" ]; then
		echo "Entry '$(basename "$gnome_panel_entry_path")' already exists!"
		unset exec_basename
		unset gnome_panel_entry_path
		unset exec_path
		return 2
	fi
	# ask for display name
	while [ "$USER_RESPONSE" != "y" ] && [ "$USER_RESPONSE" != "Y" ]; do
		echo -n "Enter the program's name: "
		read APP_NAME
		while [ "$APP_NAME" == "" ]; do
			echo -n "Please enter something: "
			read APP_NAME
		done
		# ask for a description
		echo -n "Enter a short description: "
		read APP_DESCRIPTION
		# ask for an icon file
		read -e -p  "Enter absolute path to an icon image (empty for none): " APP_ICON
		while [ "$APP_ICON" != "" ] && [ ! -f "$APP_ICON" ]; do
			read -e -p "File doesn't exist. Retry: " APP_ICON
		done 
		# ask if it needs a terminal
		echo -n "Will this program need a terminal? [y/n]: "
		read APP_TERMINAL
		while [ "$APP_TERMINAL" != "y" ] && [ "$APP_TERMINAL" != "n" ]; do
			echo -n "Please enter something: "
			read APP_TERMINAL
		done
		if [ "$APP_TERMINAL" == "y" ]; then
			APP_TERMINAL="true"
		else
			APP_TERMINAL="false"
		fi
		# ask for tags
		echo -n "Enter some categories that fit your program (';' separated): "
		read APP_CATEGORIES
		# Check if user is satisfied
		while [ "$USER_RESPONSE" == "" ] || [ "$USER_RESPONSE" != "y" ] && [ "$USER_RESPONSE" != "Y" ] && [ "$USER_RESPONSE" != "n" ] && [ "$USER_RESPONSE" != "N" ]; do
			echo -e "Is this information correct?\n"
			echo -e "\tName: \t\t$APP_NAME"
			echo -e "\tExecutable: \t$exec_path"
			echo -e "\tDescription: \t$APP_DESCRIPTION"
			echo -e "\tIcon File: \t$APP_ICON"
			echo -e "\tTerminal: \t$APP_TERMINAL"
			echo -e "\tCategories: \t$APP_CATEGORIES"
			echo -n "(y/n): "
			read USER_RESPONSE
		done
		if [ "$USER_RESPONSE" == "n" ] || [ "$USER_RESPONSE" == "N" ]; then
			echo "Then please enter everything again, kind sir"
			unset USER_RESPONSE
		fi
	done
	# User is happy
	# Add link to /usr/bin
	echo "Adding link to /usr/bin"
	sudo ln -s "$exec_path" "/usr/bin/$exec_basename"
	# Add gnome panel entry
	echo "Creating gnome-panel entry"
	echo "[Desktop Entry]" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Type=Application" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Encoding=UTF-8" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Name=$APP_NAME" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Comment=$APP_DESCRIPTION" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Icon=$APP_ICON" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Exec=$exec_path" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Terminal=$APP_TERMINAL" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Categories=$APP_CATEGORIES" | sudo tee -a "$gnome_panel_entry_path" > /dev/null
	echo "Entry added in '$gnome_panel_entry_path'"
	unset USER_RESPONSE
	unset APP_NAME
	unset APP_CATEGORIES
	unset APP_TERMINAL
	unset APP_DESCRIPTION
	unset APP_ICON
	unset exec_path
	unset exec_basename
	unset gnome_panel_entry_path
	return 0
}

say() {
	# Usage: say "text to say" language[:language_variant] speed
	#
	# Example:
	#          say "Hello world"
	#          say "Hello world" english_us 
	#          say "Hello world" english_us 1
	#          say "Hello world" english_us:2
	#          say "Hello world" english_us:2 1
	#
	# Uses the naturalreaders.com api
	# NaturalReaders has free and paid voices. For the paid ones, it uses an api key, and parameter v4. For others, no api key is required and uses parameter v0
	#
	# Supported languages: spanish_la, spanish_es, french, english_us, english_uk, german, italian, portuguese, swedish, dutch
	# Supported language variants depend on the chosen language
	if [ -z "$1" ]; then
		echo "You must enter some text"
		return 1
	fi

	DEFAULT_SPEED=1  # Supported: Integers from -4 to 9
	SUPPORTED_LANGUAGES=( spanish_la spanish_es french english_us english_uk german italian portuguese swedish dutch )
	MIN_SPEED="-4"
	MAX_SPEED="9"
	API_KEY="b98x9xlfs54ws4k0wc0o8g4gwc0w8ss"
	# Voices declaration via tuples like ( voice_code voice_version voice_name voice_variant_index )
	# English US
	v_sharon=( 42 0 "Sharon" 1 )
	v_ava=( 1 4 "Ava" 2 )
	v_tracy=( 37 0 "Tracy" 3 )
	v_ryan=( 33 0 "Ryan" 4 )
	v_tom=( 0 4 "Tom" 5 )
	v_samantha=( 2 4 "Samantha" 6 )
	v_rod=( 41 0 "Rod" 7 )
	# English UK
	v_rachel=( 32 0 "Rachel" 1 )
	v_peter=( 31 0 "Peter" 2 )
	v_graham=( 25 0 "Graham" 3 )
	v_serena=( 4 4 "Serena" 4 )
	v_daniel=( 3 4 "Daniel" 5 )  # Brittishest
	v_charles=( 2 0 "Charles" 6 )
	v_audrey=( 3 0 "Audrey" 7 )  # Brittisher
	# Spanish ES
	v_rosa=( 20 0 "Rosa" 1 )
	v_alberto=( 19 0 "Alberto" 2 )
	v_monica=( 7 4 "Monica" 3 )
	v_jorge=( 8 4 "Jorge" 4 )  # Loquendo
	n_spanish_es_voices=4
	# Spanish LA
	v_juan=( 5 4 "Juan" 1 )
	v_paulina=( 6 4 "Paulina" 2 )
	n_spanish_la_voices=2
	# French
	v_alain=( 7 0 "Alain" 1 )
	v_juliete=( 8 0 "Juliete" 2 )
	v_nicolas=( 9 4 "Nicolas" 3 )
	v_chantal=( 10 4 "Chantal" 4 )
	v_bruno=( 22 0 "Bruno" 5 )
	v_alice=( 21 0 "Alice" 6 )
	v_louice=( 43 0 "Louice" 7 )
	n_french_voices=7
	# German
	v_reiner=( 5 0 "Reiner" 1 )
	v_klara=( 6 0 "Klara" 2 )
	v_klaus=( 28 0 "Klaus" 3 )
	v_sarah=( 35 0 "Sarah" 4 )
	v_yannick=( 12 4 "Yannick" 5 )
	v_petra=( 11 4 "Petra" 6 )
	n_german_voices=6
	# Italian
	v_vittorio=( 36 0 "Vittorio" 1 )
	v_chiara=( 23 0 "Chiara" 2 )
	v_federica=( 14 4 "Federica" 3 )
	v_luca=( 13 4 "Luca" 4 )
	n_italian_voices=4
	# Portuguese
	v_celia=( 44 0 "Celia" 1 )
	v_luciana=( 16 4 "Luciana" 2 )
	v_joana=( 18 4 "Joana" 3 )
	v_catarina=( 17 4 "Catarina" 4 )
	n_portuguese_voices=4

	DEFAULT_VOICE=( ${v_juan[@]} )

	# Choose voice according to the settings
	if [ -z $2 ]; then
		voice=( ${DEFAULT_VOICE[@]} )
	else
		# Parse voice selection
		language="$(echo $2 | cut -d':' -f1)"
		language_variant="$(echo $2 | cut -d':' -f2)"
		if [ -z $language_variant ] || [ "$language_variant" == "$language" ]; then
			language_variant="1"
		fi
		# Check if language is supported
		if [ "$language" == "english_us" ]; then
			if [ "$language_variant" == "1" ]; then	
				voice=( ${v_sharon[@]} )
			elif [ "$language_variant" == "2" ]; then	
				voice=( ${v_ava[@]} )
			elif [ "$language_variant" == "3" ]; then	
				voice=( ${v_tracy[@]} )
			elif [ "$language_variant" == "4" ]; then	
				voice=( ${v_ryan[@]} )
			elif [ "$language_variant" == "5" ]; then	
				voice=( ${v_tom[@]} )
			elif [ "$language_variant" == "6" ]; then	
				voice=( ${v_samantha[@]} )
			elif [ "$language_variant" == "7" ]; then	
				voice=( ${v_rod[@]} )
			else
				echo "Unsupported variant '$language_variant' for language '$language'"
				return 1
			fi
		elif [ "$language" == "english_uk" ]; then
			if [ "$language_variant" == "1" ]; then	
				voice=( ${v_rachel[@]} )
			elif [ "$language_variant" == "2" ]; then	
				voice=( ${v_peter[@]} )
			elif [ "$language_variant" == "3" ]; then	
				voice=( ${v_graham[@]} )
			elif [ "$language_variant" == "4" ]; then	
				voice=( ${v_serena[@]} )
			elif [ "$language_variant" == "5" ]; then	
				voice=( ${v_daniel[@]} )
			elif [ "$language_variant" == "6" ]; then	
				voice=( ${v_charles[@]} )
			elif [ "$language_variant" == "7" ]; then	
				voice=( ${v_audrey[@]} )
			else
				echo "Unsupported variant '$language_variant' for language '$language'"
				return 1
			fi
		elif [ "$language" == "spanish_es" ]; then
			if [ "$language_variant" == "1" ]; then	
				voice=( ${v_rosa[@]} )
			elif [ "$language_variant" == "2" ]; then	
				voice=( ${v_alberto[@]} )
			elif [ "$language_variant" == "3" ]; then	
				voice=( ${v_monica[@]} )
			elif [ "$language_variant" == "4" ]; then	
				voice=( ${v_jorge[@]} )
			else
				echo "Unsupported variant '$language_variant' for language '$language'"
				return 1
			fi
		elif [ "$language" == "spanish_la" ]; then
			if [ "$language_variant" == "1" ]; then
				voice=( ${v_juan[@]} )
			elif [ "$language_variant" == "2" ]; then	
				voice=( ${v_paulina[@]} )
			else
				echo "Unsupported variant '$language_variant' for language '$language'"
				return 1
			fi
		elif [ "$language" == "french" ]; then
			if [ "$language_variant" == "1" ]; then	
				voice=( ${v_alain[@]} )
			elif [ "$language_variant" == "2" ]; then	
				voice=( ${v_juliete[@]} )
			elif [ "$language_variant" == "3" ]; then	
				voice=( ${v_nicolas[@]} )
			elif [ "$language_variant" == "4" ]; then	
				voice=( ${v_chantal[@]} )
			elif [ "$language_variant" == "5" ]; then	
				voice=( ${v_bruno[@]} )
			elif [ "$language_variant" == "6" ]; then	
				voice=( ${v_alice[@]} )
			elif [ "$language_variant" == "7" ]; then	
				voice=( ${v_louice[@]} )
			else
				echo "Unsupported variant '$language_variant' for language '$language'"
				return 1
			fi
		elif [ "$language" == "german" ]; then
			if [ "$language_variant" == "1" ]; then	
				voice=( ${v_reiner[@]} )
			elif [ "$language_variant" == "2" ]; then	
				voice=( ${v_klara[@]} )
			elif [ "$language_variant" == "3" ]; then	
				voice=( ${v_klaus[@]} )
			elif [ "$language_variant" == "4" ]; then	
				voice=( ${v_sarah[@]} )
			elif [ "$language_variant" == "5" ]; then	
				voice=( ${v_yannick[@]} )
			elif [ "$language_variant" == "6" ]; then	
				voice=( ${v_petra[@]} )
			else
				echo "Unsupported variant '$language_variant' for language '$language'"
				return 1
			fi
		elif [ "$language" == "italian" ]; then
			if [ "$language_variant" == "1" ]; then	
				voice=( ${v_vittorio[@]} )
			elif [ "$language_variant" == "2" ]; then	
				voice=( ${v_chiara[@]} )
			elif [ "$language_variant" == "3" ]; then	
				voice=( ${v_federica[@]} )
			elif [ "$language_variant" == "4" ]; then	
				voice=( ${v_luca[@]} )
			else
				echo "Unsupported variant '$language_variant' for language '$language'"
				return 1
			fi
		elif [ "$language" == "portuguese" ]; then
			if [ "$language_variant" == "1" ]; then	
				voice=( ${v_celia[@]} )
			elif [ "$language_variant" == "2" ]; then	
				voice=( ${v_luciana[@]} )
			elif [ "$language_variant" == "3" ]; then	
				voice=( ${v_joana[@]} )
			elif [ "$language_variant" == "4" ]; then	
				voice=( ${v_catarina[@]} )
			else
				echo "Unsupported variant '$language_variant' for language '$language'"
				return 1
			fi
		else
			echo "Unsupported language: $language"
			return 1
		fi
	fi
	echo "Using voice: '${voice[2]}'"
	# set speed
	if [ -z $3 ]; then
		speed=$DEFAULT_SPEED
	else
		speed=$3
		if (( $MIN_SPEED > $3 || $3 > $MAX_SPEED )); then
		# if [ "${SUPPORTED_SPEEDS[@]}" == "${SUPPORTED_SPEEDS[@]#"$speed"}" ]; then
			echo "Unsupported speed: $speed"
			return 1
		fi
	fi
	echo "Voice speed: $speed"
	voice_code="${voice[0]}"
	voice_version="${voice[1]}"
	extra_parameter="?"
	if [ "$voice_version" == "4" ]; then
		extra_parameter="macspeak?apikey=$API_KEY&"
	fi
	url="https://api.naturalreaders.com/v"$voice_version"/tts/"$extra_parameter"src=pw&r="$voice_code"&s="$speed"&t=$1"
	#echo $url
	OUTPUT_FILE="/tmp/tts.mp3"
	wget -qO- "$url" > $OUTPUT_FILE
	sleep 0.1
	# Check if the mp3 was generated
	if [ ! -f "$OUTPUT_FILE" ]; then
		echo "Error: Your voice could not be generated. Check if the voice service is working as expected"
		echo "Your request URL was '$url'"
		return 1
	fi
	mpg321 -q "$OUTPUT_FILE"
	rm "$OUTPUT_FILE"
	return 0
}

check_if_at_home() {
	# Get router's mac address
	CURRENT_GATEWAY_MAC="$(arp -n | grep `route -n | awk '/UG/{print $2}'` -s 2>/dev/null | awk '{print tolower($3)}')"
	if [ "$CURRENT_GATEWAY_MAC" != "$HOME_GATEWAY_MAC" ]; then
		false
	else
		true
	fi
}

stream_to_bmo() {
	# Meant to be used like:
	# stream_to_bmo 'file/to/stream.mp3'

	# Check if in local network
	if [ ! check_if_at_home ]; then
		echo "Currently you can only stream to BMO over the local network. Sorry :("
		return 1
	fi
	# Check if there are arguments
	if [ -z "$1" ]; then
		echo "Nothing to stream"
		return 0
	fi
	# Check if the file exists
	if [ ! -f "$1" ]; then
		echo "The file doesn't exist"
		return 1
	fi
	filename="$1"
	file_extension="${filename##*.}"
	file_extension="$(echo $file_extension | awk '{print tolower($1)}')"
	# SUPPORTED_FILES=( flac mp3 wav wma m3u aac ogg )
	# # Check if the file extension is supported
	# if [ ! $(array_contains SUPPORTED_FILES file_extension) ]; then
	# 	echo "The file is not supported"
	# 	return 1
	# fi

	# Stream using VLC
	STREAM_PORT="8080"
	STREAM_ADDR="/radio.mp3"
	echo "Broadcasting... Tune to :$STREAM_PORT$STREAM_ADDR"
	# Make stream
	SCREEN_PROCESS_NAME="bmo_stream"
	screen -S $SCREEN_PROCESS_NAME -d -m -L cvlc "$1" --sout '#transcode{vcodec=none,acodec=mp3,ab=192,channels=2,samplerate=44100}:http{dst=:8080/radio.mp3}' :sout-keep
	#echo "The process was daemonized on 'screen'. Reattach by issing 'screen -r $SCREEN_PROCESS_NAME"
	# Send request to bmo to play the audio stream
	sleep 0.5
	CURRENT_IP="$( get_current_ip )"
	ssh -p $RASPI_SSHPORT $RASPI_ADMIN_USER@$RASPI_PRIVATE_IP "mpc add http://$CURRENT_IP:$STREAM_PORT$STREAM_ADDR; mpc play"
	screen -r $SCREEN_PROCESS_NAME
	ssh -p $RASPI_SSHPORT $RASPI_ADMIN_USER@$RASPI_PRIVATE_IP "mpc clear;"
	echo "Finished broadcast"
}
alias stream-to-bmo="stream_to_bmo"

bmo_say (){
	if [ -z "$1" ]; then
		echo "Nothing to do"
		return 0
	fi
	# Say text on bmo server
	ssh -p $RASPI_SSHPORT $RASPI_ADMIN_USER@$RASPI_PRIVATE_IP "source .bash_functions; say '$1'"
}

show_disk_space(){
	# Shows remaining disk space each second
	echo "Remaining disk space"
	while [ 1 ]; do
		# Get windows disk space in bytes and human readable
		ws_b="$(df /dev/sda4 | tail -1 |  awk '{print $4}')"
		ws_h="$(df -h /dev/sda4 | tail -1 |  awk '{print $4}')"
		# Get ubuntu disk space
		us_b="$(df /dev/sda6 | tail -1 |  awk '{print $4}')"
		us_h="$(df -h /dev/sda6 | tail -1 |  awk '{print $4}')"
		# Get shared disk space
		sh_b="$(df /dev/sdb2 | tail -1 |  awk '{print $4}')"
		sh_h="$(df -h /dev/sdb2 | tail -1 |  awk '{print $4}')"
		# Print
		echo -e "\tWindows partition:\t $ws_b ($ws_h)"
		echo -e "\tUbuntu partition:\t $us_b ($us_h)"
		echo -e "\tShared partition:\t $sh_b ($sh_h)"
		sleep 1
		tput cuu1
		tput el
		tput cuu1
		tput el
		tput cuu1
		tput el
	done
}
alias show-disk-space="show_disk_space"

pyless(){
	pygmentize "$1" | less -r
}



# TODO
# encrypt(){
#	
#}
# decrypt(){
#
#}
# img2thumb(){
# Create thumbnail of image
#}


