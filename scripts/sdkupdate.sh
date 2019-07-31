mkdir ~/algorand-sdk-testing
git clone https://github.com/algorand/algorand-sdk-testing.git ~/algorand-sdk-testing
cd ~/algorand-sdk-testing
scripts/setup.sh

case "$1" in 
    --go*)
        scripts/test.sh --go --cross
        ;;
    --java*)
        scripts/test.sh --java --cross
        ;;
    --js*)
        scripts/test.sh --js --cross
        ;;
    --py*)
        scripts/test.sh --py --cross
        ;;
esac


# add this to curl this file:
# curl https://raw.githubusercontent.com/algorand/algorand-sdk-testing/master/scripts/sdkupdate.sh -o ~/sdkupdate.sh
# chmod +x ~/sdkupdate.sh
# ~/sdkupdate.sh --languagetag