
cd ~/node
./goal network create -r network -n network -t template.json
./goal network start -r network
./goal kmd start -d network/Node

cd -
cd go_godog/src
go test --godog.tags=~@crosstest # for verbose reporting, add --godog.format=pretty

cd ~/node
./goal kmd stop -d network/Node
./goal network stop -r network
./goal network delete -r network
