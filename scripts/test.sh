#!/usr/bin/env bash
# call from parent directory; scripts/test.sh

cp -r features/. go_godog/src/features
cp -r features/. java_cucumber/src/test/resources/java_cucumber
cp -r features/. js_cucumber/features
cp -r features/. py_behave

rm -r ~/node/network


cd ~/node
./goal network create -n network -r network -t template.json
./goal network start -r network
./goal kmd start -d network/node
./update.sh -d network/Node

cd -
cd go_godog/src
go test
goexitcode=$?
cd ../../java_cucumber 
mvn test -q # change to "pretty" in cucumberoptions if verbose
javaexitcode=$?
cd ../js_cucumber
node_modules/.bin/cucumber-js
jsexitcode=$?
cd ../py_behave
behave -f progress2
pyexitcode=$?

cd ..
rm old.tx
rm raw.tx
rm txn.tx

cd ~/node
./goal kmd stop -d network/Node
./goal network stop -r network
./goal network delete -r network

if [ $goexitcode -eq 0 ] && [ $javaexitcode -eq 0 ] && [ $jsexitcode -eq 0 ] && [ $pyexitcode -eq 0 ]
then
    exit 0
else
    exit 1
fi
