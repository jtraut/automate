# automate
Bash script automation example.

Written in vim.

Instructions:

`git fork` then change directory `cd automate` and run the script `./taskAutomator.sh`

Script accepts optional args for event trigger percentage and frequeny, e.g.

`./taskAutomator.sh 5.75` to trigger an event 5.75% of the time on the default 60s interval.

OR `./taskAutomator.sh 20.5 120` to trigger an event 20.5% of the time on a 2 minute interval (120s).


Make sure to have your git account configured:

Run

  git config --global user.email "you@example.com"
  
  git config --global user.name "Your Name"

Will then see usual (yet irregular) activity on your GitHub account for as long as the script runs.
