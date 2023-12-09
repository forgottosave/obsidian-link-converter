#!/bin/bash

#####################################################################
#  OBSIDIAN-LINK CONVERTER                                          #
#  author: Timon Ensel                                              #
#  license: MIT                                                     #
#  github: https://github.com/forgottosave/obsidian-link-converter  #
#                                                                   #
#  Use this script to convert all obsidian-style links, like        #
#  [[filename]], or [[filename|replacename]]                        #
#  to 'proper' markdown-style links in a directory.                 #
#####################################################################


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
	echo "error: $1 is not a file or folder"
	exit
fi

# iterate over each given file
for file in "${files[@]}"; do
    echo "converting links in $file"

	# find and replace all links in file
	pattern="\[\[([^]]*)\]\]"
	while IFS= read -r line; do

	    # replace every match in the line
	    while [[ $line =~ $pattern ]]; do
    	    match="${BASH_REMATCH[1]}"
			# remove the found match from the line to find the next match
    	    line="${line#*${BASH_REMATCH[0]}}"

			# remove any obsidian sugar (#chapter and |replace_name)
			replace_name="${match##*|}"
			file_link="${match%'#'*}"
			file_link="${file_link%'|'*}"

			# find file that matches the link text
			searchdir="$path"
			[ "${file_link%/*}" = "$file_link" ] || searchdir="$searchdir${file_link%/*}"
			searchfile="${file_link##*/}.*"
			file_link=$(find "$searchdir" -type f -iname "$searchfile" | head -n 1)

			# convert path to relative path of file
			relative_path=$(realpath "$file_link" --relative-to="$file")
			# fix issues in relative path
			if [[ $relative_path == . ]]; then
    			relative_path=$(basename "$file")
			elif [[ $relative_path == ../* ]]; then
    			relative_path="${relative_path:3}"
			fi

			# replace markdown link
			find="\[\[$match\]\]"
			replace="\[$replace_name\]\($relative_path\)"
			echo "  [[$match]]  ->  [$replace_name]($relative_path)"
			sed -i "s#${find//#/\\#}#${replace//#/\\#}#g" "$file"
    	done

	done < "$file"

done

