#!/bin/bash

LANG=en_US.UTF-8
export LANG
SCRIPT="$(readlink -f $0)"
WHERE="$(dirname "${SCRIPT}")"

forced=0
if [ "$1" == "forced" ] ; then
    forced=1
fi

IDOFFSET=100000
UIDCOUNT=65536


for usr in $(cd /home/ ; ls -1d *) ; do

    usr_exists=0
    do_continue=0

    # User already here?
    egrep -q "^${usr}:" /etc/subuid
    if [ $? -eq 0  -a $forced -eq 0 ]; then
        usr_exists=1
        continue
    fi

    uid=$(id -u ${usr} 2>/dev/null)
    gid=$(id -g ${usr} 2>/dev/null)

    # do we have uid and gid
    if [ -z "$uid" -o -z "$gid" ]; then
        # move on, nothing to do
        continue
    fi
    group=$(id -gn ${usr})

    if [ "$uid" -ge 32000 ] && [ "$uid" -le 39999 ]; then
        do_continue=1
    fi

    if [ "$uid" -ge 7000 ] && [ "$uid" -le 7999 ]; then
        do_continue=1
    fi

    if  [ $do_continue -ne 1 ]; then
        continue
    fi

    uidmap_start=$((($IDOFFSET * uid ) + 1))
    gidmap_start=$((($IDOFFSET * gid ) + 1))

    # Write into file
    if [ $usr_exists -eq 0 ]; then
        echo "${usr}:${uidmap_start}:${UIDCOUNT}" >> /etc/subuid
        echo "${usr}:${gidmap_start}:${UIDCOUNT}" >> /etc/subgid
    fi

    # Create a fake user/group for this
    SUBUID=$(echo "`awk -F: "/^${usr}:/"'{ print $2 }' /etc/subuid` -1 +`id -u ${usr}`" | bc)
    SUBGID=$(echo "`awk -F: "/^${group}:/"'{ print $2 }' /etc/subgid` -1 +`id -u ${usr}`" | bc)

    if [ $SUBUID -lt $IDOFFSET ]; then
        echo "Weird calculated $SUBUID"
        continue
    fi

done
