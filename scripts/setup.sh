go get github.com/DATA-DOG/godog/cmd/godog
go get -u github.com/algorand/go-algorand-sdk/...

pip3 install behave
pip3 install py-algorand-sdk

cd ../js_cucumber
npm install

# get algorand tools
cd ..
mkdir ~/inst
curl -L https://github.com/algorand/go-algorand-doc/blob/master/downloads/installers/linux_amd64/install_master_linux-amd64.tar.gz?raw=true -o inst/install_master_linux-amd64.tar.gz
cd ~/inst
tar -xf install_master_linux-amd64.tar.gz
./update.sh -i -c stable -p ~/node -d ~/node/data -n
