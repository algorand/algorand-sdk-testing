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


if $py
then
    pip3 install $TRAVIS_BUILD_DIR -q
else
    pyenv global 3.7.1
    pip3 install git+https://github.com/algorand/py-algorand-sdk/ -q
fi
pip3 install behave -q

cd js_cucumber
npm install --silent
if $js
then
    npm install $TRAVIS_BUILD_DIR --silent
fi

cd ../java_cucumber
if $java
then
    cd $TRAVIS_BUILD_DIR
    mvn package -q -DskipTests
    ALGOSDK_VERSION=$(mvn -q -Dexec.executable=echo  -Dexec.args='${project.version}' --non-recursive exec:exec)
    cd -
    find "${TRAVIS_BUILD_DIR}/target" -type f -name "*.jar" -exec mvn install:install-file -q -Dfile={} -DpomFile="${TRAVIS_BUILD_DIR}/pom.xml" \;
else
    git clone https://github.com/algorand/java-algorand-sdk.git ~/java-algorand-sdk
    cd ~/java-algorand-sdk
    mvn package -q -DskipTests
    ALGOSDK_VERSION=$(mvn -q -Dexec.executable=echo  -Dexec.args='${project.version}' --non-recursive exec:exec)
    cd -
    find ~/java-algorand-sdk/target -type f -name "*.jar" -exec mvn install:install-file -q -Dfile={} -DpomFile="${HOME}/java-algorand-sdk/pom.xml" \;
    rm -rf ~/java-algorand-sdk
fi
mvn versions:use-dep-version -DdepVersion=$ALGOSDK_VERSION -Dincludes=com.algorand:algosdk -DforceVersion=true -q


# get algorand tools; comment this section out if you already have this
cd ..
mkdir ~/inst
# this is the link for linux; change this if on mac or windows
curl -L https://github.com/algorand/go-algorand-doc/blob/master/downloads/installers/linux_amd64/install_master_linux-amd64.tar.gz?raw=true -o ~/inst/installer.tar.gz
tar -xf ~/inst/installer.tar.gz -C ~/inst
~/inst/update.sh -i -c stable -p ~/node -d ~/node/data -n

# don't comment this out; tests depend on the specific network setup
cp template.json ~/node




