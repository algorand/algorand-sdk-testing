cd
cd node
./goal network create -r network -n network -t template.json
./goal network start -r network
./goal kmd start -d network/Node

cd
cd Documents/Github/algorand-sdk-testing/go_godog/src
go test --godog.format=pretty --godog.tags=~@crosstest

cd 
cd node
./goal kmd stop -d network/Node
./goal network stop -r network
./goal network delete -r network