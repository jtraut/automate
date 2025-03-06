#!/bin/bash

# This script demonstrates creating, reading, & modifying a file
# whilst committing the changes to GitHub on an irregular interval.

# Constants and global variables
readonly file_name="exampleCountAndTimestamp"
readonly process_name=$(basename "$0") # Get from 1st arg
readonly max_value=9223372036854775807 # Maximum 64-bit integer
counter=0
random_num=0 # Range 0 - 1000

# Set the internal field separator to comma for reading our file
IFS=','

# TODO: add arg options for frequency, percentage, git creds etc.

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

generateRandomNum() {
	min=0
	max=1000
	random_num=$((RANDOM%($max-$min+1)+$min))
	echo "Random number generated between 0 and 1000: $random_num"
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

	# Using RNG, trigger events on an irregular basis
	generateRandomNum
	# 0-100%, fractions allowed i.e. 0.25
	percent_accepted=40.0 # TODO: put this down to 1 or less
	# Windows and git bash don't come with bc by default so use awk instead...
	#upper_limit=$(echo "$percent_accepted" * 10 | bc)
	upper_limit=$(awk "BEGIN {print $percent_accepted * 10}")
	echo "percentage $percent_accepted upper limit $upper_limit"
	
	if (( random_num <= upper_limit )); then
		echo "Random event triggered!"
		# Increment counter and write to file
		incrementAndWriteToFile

		# Now publish the changes back to the git repository
		pushChangesToGit
	else
		echo "Random number $random_num did not fall within percentage limit $upper_limit, doing nothing..."
	fi
	# Run this every 60 seconds
	sleep 60
done

# Should never hit this (only on error out of loop)
echo "Looped to infinity and beyond!"
exit 0
