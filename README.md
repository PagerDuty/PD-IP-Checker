These scripts are designed to be run via a cron job with the MAILTO variable set to generate an email(or any other notification method) when output occurs.

Output will occur when an IP is added/removed or changed for the service you are checking.

- `check_events.sh` - Checks events.pagerduty.com for changed IP addressses.

- `check_mailservers.sh` - Checks acme.pagerduty.com for changed MX record IP addressses.
(Used when you utilize an email integrated service and need to whitelist outgoing traffic to PagerDuty)

- `check_webhooks.sh` - Checks webhooks.pagerduty.com for changed IP addressses.

- `check_webhooks_and_alert.sh` - Same as `check_webhooks.sh` but triggers a PagerDuty incident.
