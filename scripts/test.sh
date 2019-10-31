#!/usr/bin/env bash
# call from parent directory; scripts/test.sh

source $(dirname $0)/shared.sh

# test last release: change to config_stable here and in test.sh
# test current code: change to config_nightly here and in test.sh
source $(dirname $0)/config_future

NETWORK_DIR=~/testnetwork
export NODE_DIR=$NETWORK_DIR/Node
rm -r $NETWORK_DIR

if [ $# -eq 0 ]
then
    cp -r features/. go_godog/src/features
    cp -r features/. java_cucumber/src/test/resources/java_cucumber
    cp -r features/. js_cucumber/features
    cp -r features/. py_behave
    mkdir temp
    $BIN_DIR/goal network create -n testnetwork -r $NETWORK_DIR -t network_config/$TEMPLATE
    INDEXER_DIR=$(ls -d $NETWORK_DIR/Node/testnetwork*)
    KMD_DIR=$(ls -d $NETWORK_DIR/Node/kmd*)
    export KMD_DIR=$(basename $KMD_DIR)
    cp network_config/config.json $NODE_DIR
    $BIN_DIR/goal network start -r $NETWORK_DIR
    $BIN_DIR/goal kmd start -d $NODE_DIR
    cd go_godog/src
    go test # for verbose reporting, add --godog.format=pretty
    goexitcode=$?
    $BIN_DIR/goal kmd start -d $NODE_DIR
    cd ../../java_cucumber
    mvn test -q # change to "pretty" in cucumberoptions if verbose
    javaexitcode=$?
    $BIN_DIR/goal kmd start -d $NODE_DIR
    cd ../js_cucumber
    ensure_nodejs_version
    node_modules/.bin/cucumber-js --no-strict
    jsexitcode=$?
    $BIN_DIR/goal kmd start -d $NODE_DIR
    cd ../py_behave
    behave -f progress2 # for verbose reporting, remove -f progress2
    pyexitcode=$?

    cd ..
    rm -r temp
else
    rungo=false
    runjava=false
    runjs=false
    runpy=false
    cross=false

    while [ $# -gt 0 ]
    do
        case "$1" in
            -h|--help)
                echo "Use no flags to run all tests"
                echo " "
                echo "Options:"
                echo "-h, --help"
                echo "    --go             run go SDK tests"
                echo "    --java           run java SDK tests"
                echo "    --js             run js SDK tests"
                echo "    --py             run py SDK tests"
                echo "    --cross          include crosstests if not running all tests"
                exit 0
                ;;
            --go*)
                rungo=true
                shift
                ;;
            --java*)
                runjava=true
                shift
                ;;
            --js*)
                runjs=true
                shift
                ;;
            --py*)
                runpy=true
                shift
                ;;
            --cross*)
                cross=true
                shift
                ;;
            *)
                echo "Unsupported flag: " $1
                exit 1
                ;;
        esac
    done
    $BIN_DIR/goal network create -n testnetwork -r $NETWORK_DIR -t network_config/$TEMPLATE
    INDEXER_DIR=$(ls -d $NETWORK_DIR/Node/testnetwork*)
    KMD_DIR=$(ls -d $NETWORK_DIR/Node/kmd*)
    export KMD_DIR=$(basename $KMD_DIR)
    cp network_config/config.json $NODE_DIR
    $BIN_DIR/goal network start -r $NETWORK_DIR

    if $cross
    then
        mkdir temp
    fi
    if $rungo
    then
        cp -r features/. go_godog/src/features
        $BIN_DIR/goal kmd start -d $NODE_DIR
        cd go_godog/src
        if $cross
        then
            go test
        else
            go test --godog.tags=~@crosstest
        fi
        goexitcode=$?
        cd ../..
    else
        if $cross
        then
            cp -r features/. go_godog/src/features
            $BIN_DIR/goal kmd start -d $NODE_DIR
            cd go_godog/src
            go test --godog.tags=@crosstest
            goexitcode=$?
            cd ../..
        else
            goexitcode=0
        fi
    fi

    if $runjava
    then
        cp -r features/. java_cucumber/src/test/resources/java_cucumber
        cd java_cucumber
        if $cross
        then
            $BIN_DIR/goal kmd start -d $NODE_DIR
            mvn test -q # change to "pretty" in cucumberoptions if verbose
        else
            mvn test -q -Dcucumber.options="--tags \"not @crosstest\""
        fi
        javaexitcode=$?
        cd ..
    else
        if $cross
        then
            cp -r features/. java_cucumber/src/test/resources/java_cucumber
            $BIN_DIR/goal kmd start -d $NODE_DIR
            cd java_cucumber
            mvn test -q -Dcucumber.options="--tags \"@crosstest\""
            javaexitcode=$?
            cd ..
        else
            javaexitcode=0
        fi
    fi

    if $runjs || $cross
    then
        ensure_nodejs_version
    fi

    if $runjs
    then
        cp -r features/. js_cucumber/features
        $BIN_DIR/goal kmd start -d $NODE_DIR
        cd js_cucumber
        if $cross
        then
            node_modules/.bin/cucumber-js --no-strict
        else
            node_modules/.bin/cucumber-js --no-strict --tags "not @crosstest"
        fi
        jsexitcode=$?
        cd ..
    else
        if $cross
        then
            cp -r features/. js_cucumber/features
            $BIN_DIR/goal kmd start -d $NODE_DIR
            cd js_cucumber
            node_modules/.bin/cucumber-js --no-strict --tags "@crosstest"
            jsexitcode=$?
            cd ..
        else
            jsexitcode=0
        fi
    fi
    if $runpy
    then
        cp -r features/. py_behave
        $BIN_DIR/goal kmd start -d $NODE_DIR
        cd py_behave
        if $cross
        then
            behave -f progress2
        else
            behave --tags=-crosstest -f progress2
        fi
        pyexitcode=$?
        cd ..
    else
        if $cross
        then
            cp -r features/. py_behave
            $BIN_DIR/goal kmd start -d $NODE_DIR
            cd py_behave
            behave --tags=crosstest -f progress2
            pyexitcode=$?
            cd ..
        else
            pyexitcode=0
        fi
    fi
    if $cross
    then
        rm -r temp
    fi
fi

$BIN_DIR/goal kmd stop -d $NODE_DIR
$BIN_DIR/goal network stop -r $NETWORK_DIR
$BIN_DIR/goal network delete -r $NETWORK_DIR
echo $KMD_DIR

if [ $goexitcode -eq 0 ] && [ $javaexitcode -eq 0 ] && [ $jsexitcode -eq 0 ] && [ $pyexitcode -eq 0 ]
then
    exit 0
else
    exit 1
fi
