#!/usr/bin/env bash
go=false
java=false
js=false
py=false

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

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

go get github.com/cucumber/godog/cmd/godog/...
if ! $go
then
    export GO111MODULE=on
    go get -u github.com/algorand/go-algorand-sdk/...@develop
fi


if $py
then
    pip3 install $TRAVIS_BUILD_DIR -q
else
    cd /opt/pyenv/plugins/python-build/../..
    git pull origin master
    cd -
    pyenv install --list
    pyenv install 3.7.1 --skip-existing
    pyenv global 3.7.1
    pip3 install "git+https://github.com/algorand/py-algorand-sdk@develop" -q
fi
pip3 install behave -q

# ensure correct nodejs version (>=10) if running on travis
source "$SCRIPTPATH/shared.sh"
ensure_nodejs_version

pushd js_cucumber
npm install --silent
if $js
then
    npm install $TRAVIS_BUILD_DIR --silent
fi
popd

pushd java_cucumber
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
popd


# test last release: change to config_stable here and in test.sh
# test current code: change to config_nightly here and in test.sh
source "$SCRIPTPATH/config_future"

mkdir ~/inst
# this is the link for linux; change this if on mac or windows
curl -L https://algorand-releases.s3.amazonaws.com/channel/nightly/install_nightly_linux-amd64_1.0.288.tar.gz -o ~/inst/installer.tar.gz
tar -xf ~/inst/installer.tar.gz -C ~/inst
~/inst/update.sh -i -c $CHANNEL -p $BIN_DIR -d $BIN_DIR/data -n
