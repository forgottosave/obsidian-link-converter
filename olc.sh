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

stop_img_conversion=false			# supress any image-link conversino
convert_img_html_format=true		# convert images to <img src="...">
convert_to_html_escaped_paths=true	# replaces spaces in paths with %20

# check if given path is file or folder
path="$PWD/$1"
files=()
if [ -f "$path" ]; then
	files+=("$path")
elif [ -d "$path" ]; then
	# find all files in directory (works with spaces in filename)
	while IFS= read -r -d '' file; do
    	files+=("$file")
	done < <(find "$path" -type f -print0 | grep -zE ".md" | grep -zvE "/(\.obsidian|\.git)/")
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

			# split match into file_link, #chapter and |replace_name
			replace_name="${match##*|}"
			chapter=""
			if [[ ${match%|*} =~ "#" ]]; then
				chapter="${match%|*}"
				chapter="${chapter##*'#'}"
				# convert chapter
				chapter="#${chapter,,}"
				chapter="${chapter// /-}"
			fi
			file_link="${match%'#'*}"
			file_link="${file_link%'|'*}"

			# find file that matches the link text
			searchdir="$path"
			[ "${file_link%/*}" = "$file_link" ] || searchdir="$searchdir${file_link%/*}"
			searchfile="${file_link##*/}*"
			file_link=$(find "$searchdir" -type f -iname "$searchfile" | head -n 1)

			# convert path to relative path of file
			relative_path=$(realpath "$file_link" --relative-to="$file")
			# fix issues in relative path
			if [[ $relative_path == . ]]; then
    			relative_path=$(basename "$file")
			elif [[ $relative_path == ../* ]]; then
    			relative_path="${relative_path:3}"
			fi
			# html-escape spaces
			unescaped=$relative_path
			if $convert_to_html_escaped_paths; then
				relative_path=${relative_path// /%20}
			fi

			# build "find" and "replace"
			find="\[\[$match\]\]"
			replace="\[$replace_name\]\($relative_path$chapter\)"
			replace="${replace//&/\\\&}"
			# special conversions
			if [[ ${unescaped} == *.png || ${unescaped} == *.jpg || ${unescaped} == *.jpeg ]]; then
				if $stop_img_conversion; then
					replace="$find"
				elif $convert_img_html_format; then
					width=""
					[[ ${unescaped##*/} == ${replace_name%*.} ]] || width=" width=\"${replace_name}\""
					replace="<img src=\"${unescaped// /%20}\"$width>"
				fi			
			fi
			# replace markdown link
			echo "  $find  ->  $replace"
			sed -i "s#${find//#/\\#}#${replace//#/\\#}#g" "$file"
    	done

	done < "$file"

done

