mkdir ~/algorand-sdk-testing
git clone https://github.com/algorand/algorand-sdk-testing.git ~/algorand-sdk-testing
cd ~/algorand-sdk-testing

case "$1" in 
    --go*)
        scripts/setup.sh --go
        scripts/test.sh --go --cross
        ;;
    --java*)
        scripts/setup.sh --java
        scripts/test.sh --java --cross
        ;;
    --js*)
        scripts/setup.sh --js
        scripts/test.sh --js --cross
        ;;
    --py*)
        scripts/setup.sh --py
        scripts/test.sh --py --cross
        ;;
esac


# add these to travis to curl this file:

# put this in install
# curl https://raw.githubusercontent.com/algorand/algorand-sdk-testing/master/scripts/sdkupdate.sh -o ~/sdkupdate.sh
# chmod +x ~/sdkupdate.sh

# put this in script (make sure to change languagetag to the right language)
# ~/sdkupdate.sh --languagetag 