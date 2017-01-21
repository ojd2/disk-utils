#!/usr/bin/env bash

# vars #
disk="/dev/mapper/fedora-root" # disk to monitor
current_capacity=$(df -P | grep ${disk} | awk {'print $5'}) # get disk usage from monitored POSIX disk
mounted=$(df -P | grep ${disk} | awk {'print $6'}) # get disk information via POSIX
max_capacity="90%" # max 90% mount capacity

email="kinokaf@zoho.com" # email to

# functions #
function max_exceeded() {

    # tell that mail is being sent
    echo "Max capacity of (${max_capacity}) has exceeded as your disk usage is it at ${current_capacity} mounted on ${mounted}."
    echo "Sending Alert..."

    # check if the mail program exist
    type email > /dev/null 2>&1 || {
        echo >&2 "Mail does not exist. Install it and run script again. Aborting script..."; exit;
    }

    # if the mail program exist we continue to this and send the alert
    mailbody="Max capacity (${max_usage}) exceeded. Current disk (${disk}) usage is at ${current_capacity} mounted on ${mounted}."
    echo ${mailbody} | mail -s "Disk alert!" "${email}"

    echo "Mail was sent to ${email}"
}

function abort() {

    echo "No problems. Disk (${disk}) mounted on ${mounted} capacity is at ${current_capacity}. Max is set to ${max_capacity}."
}

function main() {

    # check if a valid disk is chosen
    if [ ${current_capacity} ]; then
        # check if current disk usage is greater than or equal to max usage.
        if [ ${current_capacity%?} -ge ${max_capacity%?} ]; then
            # if it is greater than or equal to max usage we call our max_exceeded function and send mail
            max_exceeded
        else
            # if it is ok we do nothing
            abort
        fi
    else
        # if the disk is not valid, print valid disks on system
        echo "Set a valid POSIX disk env, and run script again. Your environment looks like the following: "
        df -P
    fi
}

# init #
main
