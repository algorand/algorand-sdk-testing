#!/usr/bin/env bash
# call from parent directory; scripts/test.sh

cp -r features/. go_godog/src/features
cp -r features/. java_cucumber/src/test/resources/java_cucumber
cp -r features/. js_cucumber/features
cp -r features/. py_behave

rm -r ~/node/network

if [ $# -eq 0 ]
then
    cd ~/node
    ./goal network create -n network -r network -t template.json
    ./goal network start -r network
    ./goal kmd start -d network/node
    ./update.sh -d network/Node
    cd -
    cd go_godog/src
    go test # for verbose reporting, add --godog.format=pretty
    goexitcode=$?
    cd ../../java_cucumber 
    mvn test -q # change to "pretty" in cucumberoptions if verbose
    javaexitcode=$?
    cd ../js_cucumber
    node_modules/.bin/cucumber-js
    jsexitcode=$?
    cd ../py_behave
    behave -f progress2 # for verbose reporting, remove -f progress2
    pyexitcode=$?

    cd ..
    rm old.tx
    rm raw.tx
    rm txn.tx
else
    go=false
    java=false
    js=false
    py=false
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
                go=true
                shift
                ;;
            --java*)
                java=true
                shift
                ;;
            --js*)
                js=true
                shift
                ;;
            --py*)
                py=true
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
    ./goal network start -r network
    ./goal kmd start -d network/node
    ./update.sh -d network/Node
    cd -

    if $go
    then
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
            cd go_godog/src
            go test --godog.tags=@crosstest
            goexitcode=$?
            cd ../..
        else
            goexitcode=0
        fi
    fi

    if $java
    then
        cd java_cucumber 
        if $cross
        then
            mvn test -q # change to "pretty" in cucumberoptions if verbose
        else
            mvn test -q -Dcucumber.options="--tags \"not @crosstest\""
        fi
        javaexitcode=$?
        cd ..
    else
        if $cross
        then
            cd java_cucumber
            mvn test -q -Dcucumber.options="--tags \"@crosstest\""
            javaexitcode=$?
            cd ..
        else
            javaexitcode=0
        fi
    fi

    if $js
    then
        cd js_cucumber
        if $cross
        then
            node_modules/.bin/cucumber-js
        else
            node_modules/.bin/cucumber-js --tags "not @crosstest"
        fi
        jsexitcode=$?
        cd ..
        
    else
        if $cross
        then
            cd js_cucumber
            node_modules/.bin/cucumber-js --tags "@crosstest"
            jsexitcode=$?
            cd ..
        else
            jsexitcode=0
        fi
    fi
    if $py
    then
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
        rm old.tx
        rm raw.tx
        rm txn.tx  
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
