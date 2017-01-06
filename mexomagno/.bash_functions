#!/bin/bash

###########################################################
# Shared bash functions
# These are some commonly used (by me) functions I made.
# Some are pretty useful :D
###########################################################


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
