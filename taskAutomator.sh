#!/bin/bash

# This script demonstrates creating, reading, & modifying a file
# whilst committing the changes to GitHub on an irregular interval.

# Constants and global variables
readonly file_name="exampleCountAndTimestamp"
readonly process_name=$(basename "$0") # Get from 1st arg
readonly max_value=9223372036854775807 # Maximum 64-bit integer
counter=0

# Set the internal field separator to comma for reading our file
IFS=','

# Any helper functions 
quitEarly() {
	echo "ERROR: Script $0 is already running, exiting now!" && exit 1
}

incrementAndWriteToFile() {
	# Prevent overflows cause why the hell not
	if (( counter >= max_value )); then
		# Haven't done the math but this would be extremely impressive
		echo "Counter overflow detected, reseting counter now!"
		counter=0
	fi
	new_line="$((++counter)), $(date)"
	echo "Writing new line to file: $new_line"
	# Note always overwrite, not appending (>>)
	echo "$new_line" > "$file_name"
}

pushChangesToGit() {
	# Add changes in current directory to staging
	git add .
	# Commit the changes
	git commit -m "file update $counter"
	# Push changes to remote repo
	git push
	echo "Pushed changes to git."
}

# Make sure only running a single instance
# For windows:
tasklist | findstr "$process_name" > nul
# Check if the exit status of the previous command equals 0
# TODO: this doesn't seem to work on Windows either... oh well
if [[ $? -eq 0 ]]; then
  echo "Script '$process_name' is already running."
  quitEarly
fi

# A potential Windows option for checking if script is already running
# but this requires sudo permissions... rather not
#procCount=$(tasklist /FI "IMAGENAME eq bash.exe" /FI "WINDOWTITLE eq *$processName*" | find /C /I "bash.exe")
#if [[ "$procCount" -gt 1 ]]; then
#	# Already running
#	quitEarly
#fi

# For Linux:
#pidof -o %PPID -x $0 >/dev/null && quitEarly

echo "$process_name is now running!"

# Enter an infinite loop
while true; do
	# TODO: add a random generator for % chance of doing anything at all
	if [ -f "$file_name" ] && [ "$counter" -eq 0 ]; then
		# File exists but our counter is zero so try reading value from file
		echo "reading counter from file now!"
		file_content=$(<"$file_name")
		# Split the file line into array
		split_line=()
		read -ra split_line <<< "$file_content"
		# Make sure we get a tuple value
		if [ ${#split_line[@]} -eq 2 ]; then
			# Then store the counter value
			counter=${split_line[0]}
			echo "got counter from file: $counter"
			datetime=${split_line[1]}
			echo "got timestamp of last file update: $datetime"
		else
			echo "Read invalid file line! Overwriting file now."
		fi
	fi

	# Increment counter and write to file
	incrementAndWriteToFile

	# Now publish the changes back to the git repository
	pushChangesToGit

	# Run this every 60 seconds
	sleep 60
done

# Should never hit this (only on error out of loop)
echo "Looped to infinity and beyond!"
exit 0
