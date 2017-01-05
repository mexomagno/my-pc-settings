#!/bin/bash

###########################################################
# Shared bash functions
# These are some commonly used (by me) functions I made.
# Some are pretty useful :D
###########################################################

isNumber() {
	if [ "$1" -eq "$1" ] 2>/dev/null; then
		return 1
	else
		return 0
	fi
}
constrain(){
	# constrain(a, b, c), constrains value a between b and c
	input_1="$1"
	input_2="$2"
	input_3="$3"
	isNumber "$input_1"
	is_1_number="$?"
	isNumber "$input_2"
	is_2_number="$?"
	isNumber "$input_3"
	is_3_number="$?"
	if [ "$is_1_number" == 0 ] || [ "$is_2_number" == 0 ] || [ "$is_3_number" == 0 ] ; then
		>&2 echo "constrain() must receive 3 numbers" 
		return 1
	fi
	if [ "$input_1" -lt "$input_2" ]; then
		echo "$input_2"
		return 0
	elif [ "$input_1" -gt "$input_3" ]; then
		echo "$input_3"
		return 0
	else
		echo "$input_1"
		return 0
	fi
}
brightness_m() {
	# Change the screen brightness. 
	# Usage: 
	#	brightness ([value from 0 to 100]|+|-)
	# If no input, print the current brighness percentage
	# If input is a number, it is assumed that it's a value from 0 to 100 (percentage)
	# If input is + or -, it is assumed that the user wants an increase-decrease of $step units in percentage

	# Get backlight info
	DIR="/sys/class/backlight/intel_backlight"
	# Current raw value of brightness
	CURRENT_VAL_RAW="$(sudo cat "$DIR/brightness")"
	# Max raw value
	MAX_VAL_RAW="$(sudo cat "$DIR/max_brightness")"
	input="$1"
	# Check if it's empty
	if [ "$input" == "" ]; then
		CURRENT_BRIGHTNESS_PERCENT="$(($CURRENT_VAL_RAW*100/$MAX_VAL_RAW + 1))"
		CURRENT_BRIGHTNESS_PERCENT="$(constrain $CURRENT_BRIGHTNESS_PERCENT 0 100)"
		echo "Current brightness: $CURRENT_BRIGHTNESS_PERCENT"
		return
	fi
	# Case for - or +
	RAW_STEP="$((MAX_VAL_RAW/10))"
	NEW_VAL_RAW=CURRENT_VAL_RAW
	# if is not a number, error
	isNumber $input
	if [ "$?" == "0" ]; then
		if [ "$input" == "+" ]; then
			# Brightness up
			NEW_VAL_RAW="$(($CURRENT_VAL_RAW+$RAW_STEP))"
			NEW_VAL_RAW="$(constrain $NEW_VAL_RAW 0 $MAX_VAL_RAW)"
		elif [ "$input" == "-" ]; then
			# Brightness down
			NEW_VAL_RAW="$(($CURRENT_VAL_RAW-$RAW_STEP))"
			NEW_VAL_RAW="$(constrain $NEW_VAL_RAW 1 $MAX_VAL_RAW)"
		else
			echo "Error: '$input' is not a number"
			return
		fi
	else
		# It's a number. Check if number is within accepted range
		if [ "$input" -gt 100 ] || [ "$input" -lt 0 ]; then
			echo "Error: Value must be between 0 and 100"
			return
		fi
		NEW_VAL_RAW="$(($MAX_VAL_RAW*$input/100))"
	fi
	# Convert percentage to actual value
	NEW_VAL_PERCENT="$(($NEW_VAL_RAW*100/$MAX_VAL_RAW + 1))"
	NEW_VAL_PERCENT="$(constrain $NEW_VAL_PERCENT 0 100)"
	if [ "$NEW_VAL_RAW" -eq "0" ]; then
		NEW_VAL_RAW="1"
		NEW_VAL_PERCENT="minimum"
	else
		NEW_VAL_PERCENT="$NEW_VAL_PERCENT%"
	fi
	# Set brightness
	# sudo sh -c 'echo $input > "$DIR/brightness"'
	echo $NEW_VAL_RAW  | sudo tee "$DIR/brightness" > /dev/null
	echo "Brightness set to $NEW_VAL_PERCENT ($NEW_VAL_RAW)"
	unset DIR
	unset CURRENT_VAL_RAW
	unset MAX_VAL_RAW
	unset NEW_VAL_RAW
	unset NEW_VAL_PERCENT
	unset RAW_STEP
	unset input
}
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
		echo -n "Enter executable file name: "
		read exec_path
	fi
	# Check if file exists
	if [ ! -f "$exec_path" ] || [ ! -f "$(pwd)/$exec_path" ]; then
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
		echo -n "Enter absolute path to an icon image (empty for none): "
		read APP_ICON
		while [ "$APP_ICON" != "" ] && [ ! -f "$APP_ICON" ]; do
			echo -n "File doesn't exist. Retry: "
			read APP_ICON
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
