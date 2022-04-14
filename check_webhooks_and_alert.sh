#!/usr/bin/env bash
# Webhook delivery service IP address change notification script
#
# Same as check_webhooks.sh, but triggers a PagerDuty incident if there are changes.
#
# Fill in the following variable with your integration key:

routing_key=''

event_data()
{
  cat <<EOF
{
    "routing_key": "${routing_key}",
    "event_action": "trigger",
    "dedup_key": "pagerduty-webhook-new-ips",
    "payload": {
        "summary": "Changes to ACL (PagerDuty webhook IPs) needed: ${N_NEW} new to add, ${N_OLD} old to remove",
        "source": "$(hostname)",
        "severity": "warning",
        "custom_details": {
            "new_ips": "$(echo ${NEW} | tr '\n' ' ')",
            "old_ips": "$(echo ${OLD} | tr '\n' ' ')"
        }
    }
}
EOF
}

if [ -f "webhooks_result.txt" ]; then
  mv webhooks_result.txt webhooks_result.txt.old
fi

curl -s https://app.pagerduty.com/webhook_ips | tr -d \[\]\" | tr , '\n' | sort > webhooks_result.txt

if [ -f "webhooks_result.txt.old" ]; then
  DIFF=$(diff -q 'webhooks_result.txt.old' 'webhooks_result.txt' > /dev/null)
  if [ $? -ne 0 ]; then
    NEW=$(diff --new-line-format '%L' --old-line-format '' --unchanged-line-format '' webhooks_result.txt.old webhooks_result.txt)
    OLD=$(diff --new-line-format '' --old-line-format '%L' --unchanged-line-format '' webhooks_result.txt.old webhooks_result.txt)
    N_NEW=$(echo $NEW | awk '{print NF}')
    N_OLD=$(echo $OLD | awk '{print NF}')

    curl -X POST -H "Content-Type: application/json" -d "$(event_data)" -D pagerduty_response_headers.txt "https://events.pagerduty.com/v2/enqueue" 1> pagerduty_response.txt 2> /dev/null
    accepted=$(grep -o "202 Accepted" pagerduty_response_headers.txt)
    if [[ -z $accepted ]]; then
      echo "ERROR submitting ACL change alert to PagerDuty; response "`cat pagerduty_response_headers.txt`"\n\n"`cat pagerduty_response.txt`
      mv webhooks_result.txt.old webhooks_result.txt
    else
      rm -f pagerduty_response_headers.txt pagerduty_response.txt
      rm webhooks_result.txt.old
    fi
  fi
fi
