#!/usr/bin/env bash

# PagerDuty Status Page - https://status.pagerduty.com

## This script is designed to be run via a cron job with the MAILTO variable
## set to generate an email when output occurs (an IP is added/removed/changed)

# get the list of IP addresses from the PagerDuty acme URL. Storing in a memory variable to reduce disk access
mailservers_results_current = $(dig +short mx acme.pagerduty.com | sed 's/.$//g' | sed 's/^[0-9][0-9]* //g' | xargs dig +short | sort)

if [ -f "mailservers_results.txt" ]; then
  # we check for the diff and supress any outputs on the stdout
  DIFF=$(echo "${mailservers_results_current}" | diff -q 'mailservers_results.txt' - > /dev/null)

  # diff command returns a status code 0 if no change has been detected
  if [ $? -ne 0 ]; then
    # The script has detected that the list of IP addresses has changed.
    # we overwrite the existing file with the changed IP addresses.
    echo ${mailservers_results_current} > mailservers_results.txt
    # display the output on stdout. MAILTO cron variable takes over the job of sending out an email.
    echo -e "\nThe script has detected a change in PagerDuty's Events IP addresses. The new IP addresses are:\n\n${mailservers_results_current}"
  fi
else
  # we fall in this condition when we run the script for the first time
  # or if the mailservers_results.txt has been deleted
  # we create a new one and spit the output on the stdout too
  echo ${mailservers_results_current} | tee mailservers_results.txt
fi