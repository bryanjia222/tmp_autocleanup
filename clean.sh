#!/bin/bash

# Define target directory, default is current directory
target_directory="${1:-.}"

# Get the current script name
script_name="$(basename "$0")"

# Find files or directories not modified in the last 7 days, only in the current directory, excluding files starting with "keep." and the current script itself
files_to_delete=$(find "$target_directory" -maxdepth 1 -mindepth 1 \( -type f -o -type d \) -mtime +7 ! -name 'keep.*' ! -name "$script_name" | sed 's|^\./||')

# If no matching files or directories are found, output a message and exit
if [ -z "$files_to_delete" ]; then
  echo "No files or directories not modified in the last 7 days were found."
  exit 0
fi

# Display the list of found files or directories and preview using less/more
# Highlight directories with a different color for distinction
color_reset="\e[0m"
color_dir="\e[1;34m"

formatted_files_to_delete=$(echo "$files_to_delete" | while IFS= read -r line; do
  if [ -d "$line" ]; then
    echo -e "${color_dir}$line${color_reset}"
  else
    echo "$line"
  fi
done)

echo -e "The following files or directories have not been modified in the last 7 days:\n$formatted_files_to_delete" | less

# Ask user for confirmation before deleting
read -p "Do you want to delete these files or directories? (y/n): " confirm

# Perform action based on user input
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  echo "$files_to_delete" | xargs -d '\n' rm -r
  echo "Files or directories have been deleted."
else
  echo "Operation cancelled."
fi

