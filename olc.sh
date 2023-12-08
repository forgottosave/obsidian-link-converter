#!/bin/bash

# check if given path is file or folder
path="$PWD/$1"
files=()
if [ -f "$path" ]; then
	files+=("$path")
elif [ -d "$path" ]; then
	# find all files in directory (works with spaces in filename)
	while IFS= read -r -d '' file; do
    	files+=("$file")
	done < <(find "$path" -type f -print0 | grep -zvE "/(\.obsidian|\.git)/")
else
	echo "$1 is not a file or folder"
	exit
fi

# iterate over each given file
for file in "${files[@]}"; do
    echo "converting links in $file"
	# find and replace all links in file
	pattern="\[\[([^]]*)\]\]"
	while IFS= read -r line; do
	    # Continue finding matches in the line until there are no more
	    while [[ $line =~ $pattern ]]; do
    	    match="${BASH_REMATCH[1]}"
			# remove any obsidian sugar (like #chapter and |alternativename)
			linkreplacename="${match##*|}"
			link="${match%'#'*}"
        	# Remove the found match from the line to find the next match
    	    line="${line#*${BASH_REMATCH[0]}}"
			# find file that matches the link text
			linkfile=$(find "$path" -type f -iname "$link.*")
			# convert path to relative path of file
			relative_path=$(realpath "$linkfile" --relative-to="$file")
			# replace markdown link
			find="\[\[$match\]\]"
			replace="\[$linkreplacename\]\($relative_path\)"
			echo "  [[$match]]  ->  [$linkreplacename]($relative_path)"
			sed -i "s#${find//#/\\#}#${replace//#/\\#}#g" "$file"
    	done
	done < "$file"
done

