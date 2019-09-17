#!/usr/bin/env bash
# call from parent directory; scripts/test.sh

rm -r ~/node/network

source $(dirname $0)/shared.sh

if [ $# -eq 0 ]
then
    cp -r features/. go_godog/src/features
    cp -r features/. java_cucumber/src/test/resources/java_cucumber
    cp -r features/. js_cucumber/features
    cp -r features/. py_behave
    mkdir temp
    cd ~/node
    ./goal network create -n network -r network -t template.json
    INDEXER_DIR=~/node/$(ls -d network/Node/network*)
    KMD_DIR=~/node/$(ls -d network/Node/kmd*)
    export KMD_DIR=$(basename $KMD_DIR)
    cd -
    cp network_config/config.json ~/node/network/Node
    cd ~/node
    ./goal network start -r network
    ./update.sh -d network/Node
    ./goal kmd start -d network/Node
    cd -
    cd go_godog/src
    go test # for verbose reporting, add --godog.format=pretty
    goexitcode=$?
    ~/node/goal kmd start -d ~/node/network/Node
    cd ../../java_cucumber
    mvn test -q # change to "pretty" in cucumberoptions if verbose
    javaexitcode=$?
    ~/node/goal kmd start -d ~/node/network/Node
    cd ../js_cucumber
    ensure_nodejs_version
    node_modules/.bin/cucumber-js --no-strict
    jsexitcode=$?
    ~/node/goal kmd start -d ~/node/network/Node
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
        esac
    done
    cd ~/node
    ./goal network create -n network -r network -t template.json
    INDEXER_DIR=~/node/$(ls -d network/Node/network*)
    KMD_DIR=$(ls -d network/Node/kmd*)
    export KMD_DIR=$(basename $KMD_DIR)
    cd -
    cp network_config/config.json ~/node/network/Node
    cd ~/node
    ./goal network start -r network
    ./update.sh -d network/Node
    cd -

    if $cross
    then
        mkdir temp
    fi
    if $rungo
    then
        cp -r features/. go_godog/src/features
        ~/node/goal kmd start -d ~/node/network/Node
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
            ~/node/goal kmd start -d ~/node/network/Node
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
            ~/node/goal kmd start -d ~/node/network/Node
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
            ~/node/goal kmd start -d ~/node/network/Node
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
        ~/node/goal kmd start -d ~/node/network/Node
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
            ~/node/goal kmd start -d ~/node/network/Node
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
        ~/node/goal kmd start -d ~/node/network/Node
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
            ~/node/goal kmd start -d ~/node/network/Node
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
