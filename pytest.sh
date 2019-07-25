cd ~/node
./goal network create -n network -r network -t template.json
./goal network start -r network
./goal kmd start -d network/node

cd -
cd py_behave

behave --tags=-crosstest --f progress2 # for verbose reporting, remove --f progress2

cd ~/node
./goal kmd stop -d network/Node
./goal network stop -r network
./goal network delete -r network
