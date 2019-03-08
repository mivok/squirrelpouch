#!/bin/bash
# Runs commands on many hosts at once using pssh, and using knife search to
# get a list of hosts to connect to.
# Requires knife, pssh and jq

if [[ -z $1 ]]; then
    echo "Usage: $0 SEARCH_TERM COMMAND"
    echo "Run a command on many aws instances, identified by name."
    exit 1
fi

HOSTS=$(
    aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*$1*" | \
    jq -r '.Reservations[].Instances[] | .PrivateIpAddress | select(. != null)'
)
shift

if [[ -z $HOSTS ]]; then
    echo "No results returned from search"
    exit 1
fi

pssh \
    -O 'StrictHostKeyChecking no' \
    --host "$HOSTS" \
    --par 5\
    --timeout 3600 \
    --inline \
    "$@"
