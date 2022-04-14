# Description

The supplied bash scripts are supposed to be run via a cron job and assume that the MAILTO variable in the cron is set to send out a notification email when any IP address change happens.

# Prerequisites to run this script

The scripts depend on the external `dig` command to get the list of IP addresses from the PagerDuty servers. You should be able to install the `dig` command using the following steps:

## On RedHat-based GNU/Linux servers

Install it from the `bind-utils` package available in the repositories.

Command: `dnf install bind-utils`

You will require root permissions to install the package.

## On Debian-based GNU/Linux servers

Install it from the `dnsutils` package available in the repositories.

Command: `apt install dnsutils`

You will require root permissions to install the package.

# Output

It is assumed that there are two scenario's to each script run, which are:

## When the IP addresses change

The script(s) will display a list of all the new IP addresses fetched from the server on the stdout and will send out a notification email to the email address set in the MAILTO variable in the cron.

This notification email may then be captured to initiate an incident in PagerDuty.

## When the IP addresses do not change

There is no change in the files or output on the stdout and no notification email is sent out.

# Description of the files in the repository

| File name | Remarks |
|-|-|
| `check_events.sh`      | Checks events.pagerduty.com for changed IP addressses. |
| `check_mailservers.sh` | Checks `acme.pagerduty.com` for changed MX record IP addressses. (Used when you utilize an email integrated service and need to whitelist outgoing traffic to PagerDuty) |
| `check_webhooks.sh` | Checks `webhooks.pagerduty.com` for changed IP addressses. |
| `check_webhooks_and_alert.sh` | Checks `webhooks.pagerduty.com` for changed IP addressses, same as `check_webhooks.sh`, but also triggers a PagerDuty incident. |
