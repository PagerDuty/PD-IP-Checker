#!/usr/bin/env bash

# PagerDuty Webhooks Documentation - https://support.pagerduty.com/docs/webhooks
# PagerDuty Status Page - https://status.pagerduty.com

## This script is designed to be run via a cron job with the MAILTO variable
## set to generate an email when output occurs (an IP is added/removed/changed)

# get the list of IP addresses from the PagerDuty Webhooks URL. Storing in a memory variable to reduce disk access
webhooks_results_current = $(curl -s https://app.pagerduty.com/webhook_ips | tr -d \[\]\" | tr , '\n' | sort)

if [ -f "webhooks_results.txt" ]; then
  # we check for the diff and supress any outputs on the stdout
  DIFF=$(echo "${webhooks_results_current}" | diff -q 'webhooks_results.txt' - > /dev/null)

  # diff command returns a status code 0 if no change has been detected
  if [ $? -ne 0 ]; then
    # The script has detected that the list of IP addresses has changed.
    # we overwrite the existing file with the changed IP addresses.
    echo ${webhooks_results_current} > webhooks_results.txt
    # display the output on stdout. MAILTO cron variable takes over the job of sending out an email.
    echo -e "\nThe script has detected a change in PagerDuty Webhook's IP addresses. The new IP addresses are:\n\n${webhooks_results_current}"
  fi
else
  # we fall in this condition when we run the script for the first time
  # or if the webhooks_results.txt has been deleted
  # we create a new one and spit the output on the stdout too
  echo ${webhooks_results_current} | tee webhooks_results.txt
fi