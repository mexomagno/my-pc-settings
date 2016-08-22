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
brightness() {
	# Change the screen brightness. 
	# Usage: brightness [value from 0 to 100]

	# check if root
	# [[ "$(id -u)" != "0" ]] && echo "Warning: Not running as sudo"
	# Sets the backlight brightness
	DIR="/sys/class/backlight/intel_backlight"
	VAL="$(sudo cat "$DIR/brightness")"
	MAX_VAL="$(sudo cat "$DIR/max_brightness")"
	input="$1"
	# Check if it's a number
	isNumber "$input"
	[[ "$?" == "0" ]] && echo "Error: '$input' is not a number" && return 1
	# Check if it's between accepted range
	if [ "$input" -gt "100" ] || [ "$input" -lt "0" ]; then
		echo "Error: Value must be between 0 and 100"
		return 1
	fi
	# Convert percentage to actual value
	actual_value="$(($MAX_VAL*$input/100))"
	if [ "$input" -eq "0" ]; then
		actual_value="1"
		input="minimum"
	else
		input="$input%"
	fi
	# Set brightness
	# sudo sh -c 'echo $input > "$DIR/brightness"'
	echo $actual_value  | sudo tee "$DIR/brightness" > /dev/null
	#PERCENT="$((100*$input/$MAX_VAL))"
	echo "Brightness set to $input ($actual_value)"
	unset DIR
	unset VAL
	unset input
	unset MAX_VAL
	unset actual_value
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
