#!/usr/bin/env bash
cd ..

cp -r features/. go_godog/src/features
cp -r features/. java_cucumber/src/test/resources/java_cucumber
cp -r features/. js_cucumber/features
cp -r features/. py_behave

rm -r ~/node/network

cd 
cd node
./goal network create -n network -r network -t template.json
./goal network start -r network
./goal kmd start -d network/node
./update.sh -d network/Node

cd 
cd Documents/Github/algorand-sdk-testing
# verbose
cd go_godog/src
go test -v --godog.format=pretty
cd ../../java_cucumber 
mvn test # need to change to "pretty" in cucumberoptions
cd ../js_cucumber
node_modules/.bin/cucumber-js
cd ../py_behave
behave

cd ..
rm old.tx
rm raw.tx
rm txn.tx


cd 
cd node
./goal kmd stop -d network/Node
./goal network stop -r network
./goal network delete -r network

# normal
# cd go_godog/src
# go test --godog.random
# cd ../../java_cucumber
# mvn test # need to change to "progress" in cucumberoptions
# cd ../js_cucumber
# npm test
# cd ../py_behave
# behave -f null

# cd scripts
# ./gotest.sh
# ./javatest.sh
# ./jstest.sh
# ./pytest.sh