cd 
cd node
./goal network create -n network -r network -t template.json
./goal network start -r network
./goal kmd start -d network/node

cd
cd Documents/Github/algorand-sdk-testing/java_cucumber

mvn test -Dcucumber.options="--tags \"not @crosstest\""

cd 
cd node
./goal kmd stop -d network/Node
./goal network stop -r network
./goal network delete -r network