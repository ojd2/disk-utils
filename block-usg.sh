#!/usr/bin/env bash

# vars #
disk="/dev/mapper/fedora-root" # disk to monitor
current_blocks=$(df -m | grep ${disk} | awk {'print $2'}) # get amount of blocks used
mounted=$(df -m | grep ${disk} | awk {'print $6'}) # get disk information
max_threshold="20000" # max 20000 amount of blocks

email="kinokaf@zoho.com" # mail to sent alert to

# functions #
function max_blocks_exceeded() {

    # tell that mail is being sent
    echo "Max amount of MB blocks (${max_threshold}) has exceeded as your MB block amount is set at ${max_threshold} mounted on ${mounted}."
    echo "Sending Alert..."

    # check if the mail program exist
    type email > /dev/null 2>&1 || {
        echo >&2 "Mail does not exist. Install it and run script again. Aborting script..."; exit;
    }

    # if the mail program exist we continue to this and send the alert
    mailbody="Max amount of MB blocks (${max_threshold}) exceeded. Current disk (${disk}) usage is at ${current_blocks} mounted on ${mounted}."
    echo ${mailbody} | mail -s "MB Blocks alert!" "${email}"

    echo "Mail was sent to ${email}"
}

function abort() {

    echo "No problems. Disk (${disk}) mounted on ${mounted} current MB block limit is at ${current_blocks}. Threshold is set to ${max_threshold}."
}

function main() {

    # check if a valid disk is chosen
    if [ ${current_blocks} ]; then
        # check if current MB block disk usage is greater than or equal to max usage.
        if [ ${current_blocks%?} -ge ${max_threshold%?} ]; then
            # if it is greater than or equal to max usage we call our max_exceeded function and send mail
            max_blocks_exceeded
        else
            # if it is ok we do nothing
            abort
        fi
    else
        # if the disk is not valid, print valid disks on system
        echo "Set a valid MB block env, and run script again. Your environment looks like the following: "
        df -m
    fi
}

# init #
main
