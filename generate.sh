#!/bin/bash
set -o nounset

SSH_AGENT_ID=$(pgrep ssh-agent)
if [ "$?" -ne 0 ]; then
    ssh-add -K
fi

function updateRepo {
    pushd $1
    ISCLEAN=$(expr `git status --porcelain 2>/dev/null | wc -l`)
    if [ "$ISCLEAN" -eq 0 ]; then
        git checkout master
        git pull
    else
        MODULE=$(pwd |  awk 'BEGIN { FS="/" } { print $NF }')
        echo ""
        echo "Cannot update $MODULE - changes pending"
        echo ""
    fi
    popd
}

if [ ! -d apiGateway ]; then
    git clone git@gitlab.com:icwt-global/read-my-book-api.git apiGateway
else
    updateRepo apiGateway
fi

if [ ! -d client ]; then
    git clone git@gitlab.com:myfailemtions/rmb.git client
else
    updateRepo client
fi

docker-compose up --build
