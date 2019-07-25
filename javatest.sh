cd ~/node
./goal network create -n network -r network -t template.json
./goal network start -r network
./goal kmd start -d network/node

cd - 
cd java_cucumber

mvn test -q -Dcucumber.options="--tags \"not @crosstest\"" # for verbose reporting, change "progress" to "pretty" in RunCucumberTest.java

cd ~/node
./goal kmd stop -d network/Node
./goal network stop -r network
./goal network delete -r network
