

# add to sdk:
mkdir ~/algorand-sdk-testing
git clone https://github.com/algorand/algorand-sdk-testing.git ~/algorand-sdk-testing
cd ~/algorand-sdk-testing
scripts/setup.sh
scripts/test.sh --languagetag --cross

