#!/usr/bin/env bash
go=false
java=false
js=false
py=false

case "$1" in 
    --go*)
        go=true
        ;;
    --java*)
        java=true
        ;;
    --js*)
        js=true
        ;;
    --py*)
        py=true
        ;;
esac

go get github.com/DATA-DOG/godog/cmd/godog
if ! $go
then
    go get -u github.com/algorand/go-algorand-sdk/...
fi

pip3 install behave
if $py
then
    pip3 install "git+https://github.com/algorand/py-algorand-sdk@$TRAVIS_COMMIT"
else
    pip3 install git+https://github.com/algorand/py-algorand-sdk/
fi

cd js_cucumber
npm install
if $js
then
    npm install --save "algorand/js-algorand-sdk#$TRAVIS_COMMIT"
fi

cd ../java_cucumber
if $java
then
    mvn versions:use-dep-version -Dincludes=com.github.algorand:java-algorand-sdk -DdepVersion=$TRAVIS_COMMIT -DforceVersion=true
    mvn versions:commit
fi


# get algorand tools; comment this section out if you already have this
cd ..
mkdir ~/inst
# this is the link for linux; change this if on mac or windows
curl -L https://github.com/algorand/go-algorand-doc/blob/master/downloads/installers/linux_amd64/install_master_linux-amd64.tar.gz?raw=true -o ~/inst/installer.tar.gz
tar -xf ~/inst/installer.tar.gz -C ~/inst
~/inst/update.sh -i -c stable -p ~/node -d ~/node/data -n

# don't comment this out; tests depend on the specific network setup
cp template.json ~/node




