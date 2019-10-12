#!/usr/bin/env bash
# call from parent directory; scripts/test.sh

rm -r ~/node/network

source $(dirname $0)/shared.sh
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
            ~/node/goal kmd start -d ~/node/network/Node -t 0
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
            ~/node/goal kmd start -d ~/node/network/Node -t 0
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
            ~/node/goal kmd start -d ~/node/network/Node -t 0 
            cd java_cucumber
            mvn test -q -Dcucumber.options="--tags \"@crosstest\""
            javaexitcode=$?
            cd ..
        else
            javaexitcode=0
        fi
    fi

echo Press enter when debugging finished ... 
read 
echo Shutting down...

    
    if $cross
    then
        rm -r temp
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
