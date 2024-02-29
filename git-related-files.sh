#!/bin/bash

# Check if a file path argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide the file path as an argument."
    exit 1
fi

# Your specified file is the first argument
file=$1

# For each commit, list all other files that were changed
commits=$(git log --pretty="%H" -- $file)
files=()
counts=()

for commit in $commits; do
	files_in_commit=$(git show --pretty="" --name-only $commit)
	for file_in_commit in $files_in_commit; do
		# Exclude the original file from the count
		if [ "$file_in_commit" != "$file" ]; then
			index=-1
			for i in "${!files[@]}"; do
				if [[ "${files[$i]}" = "${file_in_commit}" ]]; then
					index=$i
					break
				fi
			done
			if [[ $index -eq -1 ]]; then
				files+=("$file_in_commit")
				counts+=(1)
			else
				counts[$index]=$((counts[$index] + 1))
			fi
		fi
	done
done

# Combine files and counts into an array of "count - file" pairs
count_file_pairs=()
for i in "${!files[@]}"; do
  count_file_pairs+=("${counts[$i]} - ${files[$i]}")
done

# Sort the array and get the top 5
IFS=$'\n'
sorted=($(sort -nr <<<"${count_file_pairs[*]}"))
unset IFS

# Print out the top 5 files and their frequencies
for i in "${sorted[@]:0:5}"; do
  echo "$i"
done
