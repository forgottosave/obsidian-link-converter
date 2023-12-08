#!/bin/bash

echo "This script is not finished yet, please wait for the proper updates"

calculate_relative_path() {
    local source=$1
    local target=$2

    local common_part=$source
    local result=""

    while [[ "${target#$common_part}" == "${target}" ]]; do
        common_part=$(dirname "$common_part")
        result="../$result"
    done

    result="$result${target#$common_part/}"
    echo "$result"
}





# check if given path is file or folder
path="$PWD/$1"
files=()
if [ -f "$path" ]; then
	files+=("$path")
elif [ -d "$path" ]; then
	# find all files in directory
	#files=($(find "$path" -type f | grep -vE "/(\.obsidian|\.git)/"))
	# mapfile -t files << (find "$path" -type f -print0 | grep -zvE "/(\.obsidian|\.git)/")
	while IFS= read -r -d '' file; do
    	files+=("$file")
	done < <(find "$path" -type f -print0 | grep -zvE "/(\.obsidian|\.git)/")
else
	echo "$1 is not a file or folder"
	exit
fi
# iterate over each given file
for file in "${files[@]}"; do
    echo "converting in file $file ..."
	declare -A linkmap
	# find all links in file
	pattern="\[\[([^]]*)\]\]"
	while IFS= read -r line; do
	    # Continue finding matches in the line until there are no more
	    while [[ $line =~ $pattern ]]; do
    	    linkmatch="${BASH_REMATCH[1]}"
			# remove any obsidian sugar (like #chapter and |alternativename)
			# TODO: make alternativename usable instead of just removing it
			linkmatch="${linkmatch%'#'*}"
        	echo "  Matched portion: $linkmatch"
	        # Remove the found match from the line to find the next match
    	    line="${line#*${BASH_REMATCH[0]}}"
			# find file that matches the link text
			linkfile=$(find "$path" -type f -iname "$linkmatch.*")
			# convert path to relative path of file
			relative_path=$(calculate_relative_path "$file" "$linkfile")
			echo "    found according file: $relative_path"
			# replace markdown link
			find="\[\[$linkmatch\]\]"
			replace="\[$relative_path\]\($relative_path\)"
			echo "    replacing \"$find\" with \"$replace\""
			sed -i "s#$find#$replace#g" "$file"
    	done
	done < "$file"
done
