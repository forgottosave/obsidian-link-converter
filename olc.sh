#!/bin/bash

# check if given path is file or folder
path="$PWD/$1"
files=()
if [ -f "$path" ]; then
	files+=("$path")
elif [ -d "$path" ]; then
	# find all files in directory
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
    	    match="${BASH_REMATCH[1]}"
			# remove any obsidian sugar (like #chapter and |alternativename)
			linkreplacename="${match##*|}"
			link="${match%'#'*}"
        	echo "  Matched portion: $match, with replace-name: $linkreplacename"
	        # Remove the found match from the line to find the next match
    	    line="${line#*${BASH_REMATCH[0]}}"
			# find file that matches the link text
			linkfile=$(find "$path" -type f -iname "$link.*")
			echo "    found file: $linkfile"
			# convert path to relative path of file
			relative_path=$(realpath "$linkfile" --relative-to="$file")
			echo "    with relative path: $relative_path"
			# replace markdown link
			find="\[\[$match\]\]"
			replace="\[$linkreplacename\]\($relative_path\)"
			echo "    replacing \"$find\" with \"$replace\""
			sed -i "s#${find//#/\\#}#${replace//#/\\#}#g" "$file"
    	done
	done < "$file"
done
