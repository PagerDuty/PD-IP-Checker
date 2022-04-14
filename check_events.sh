#!/usr/bin/env bash

# More information on PagerDuty Events - https://support.pagerduty.com/docs/event-management
# PagerDuty Status Page - https://status.pagerduty.com

## This script is designed to be run via a cron job with the MAILTO variable
## set to generate an email when output occurs (an IP is added/removed/changed)

# get the list of IP addresses from the PagerDuty Events URL. Storing in a memory variable to reduce disk access
events_results_current = $(dig +short events.pagerduty.com | sort)

if [ -f "events_results.txt" ]; then
  # we check for the diff and supress any outputs on the stdout
  DIFF=$(echo "${events_results_current}" | diff -q 'events_results.txt' - > /dev/null)

  # diff command returns a status code 0 if no change has been detected
  if [ $? -ne 0 ]; then
    # The script has detected that the list of IP addresses has changed.
    # we overwrite the existing file with the changed IP addresses.
    echo ${events_results_current} > events_results.txt
    # display the output on stdout. MAILTO cron variable takes over the job of sending out an email.
    echo -e "\nThe script has detected a change in PagerDuty's Events IP addresses. The new IP addresses are:\n\n${events_results_current}"
  fi
else
  # we fall in this condition when we run the script for the first time
  # or if the events_results.txt has been deleted
  # we create a new one and spit the output on the stdout too
  echo ${events_results_current} | tee events_results.txt 
fi