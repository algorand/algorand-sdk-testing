#!/usr/bin/env bash

rootdir=`dirname $0`

pushd $rootdir/.. > /dev/null

goal network stop -r /tmp/testnetwork/
/bin/rm -rf /tmp/testnetwork

goal network create -n testnetwork -r /tmp/testnetwork -t network_config/future_template.json
cp $rootdir/algod.token      /tmp/testnetwork/Node/
cp $rootdir/config.json      /tmp/testnetwork/Node/
cp $rootdir/kmd_config.json  /tmp/testnetwork/Node/kmd-v0.5/
cp $rootdir/kmd.token        /tmp/testnetwork/Node/kmd-v0.5/

goal network start -r /tmp/testnetwork/

kmd start -t 0 -d /tmp/testnetwork/Node/kmd-v0.5/

##   cd ~/go/src/github.com/algorand/go-algorand-sdk/test
##   godog --strict=true --format=pretty --tags="@applications" . 
