# algorand-sdk-testing
Testing framework for Algorand SDKs


## How to run tests
1. Clone the repo
2. Run ./setup.sh to install dependencies (if you already have a ~/node with a node/private network, comment that section out before running)
4. Run ./test.sh or individual SDK tests, which skip crosstests (for example ./jstest.sh)


## Updating an SDK

1. Update the SDK
2. Optionally run tests
3. Commit changes; this should trigger a travis build in both the SDK's repo and this repo. If anything fails, update accordingly. 

## Adding more tests
1. If you just want to add more examples, add them in the scenario outlines in the main set of feature files
2. If you want to add new features, add them in the main feature files and make sure to write mappings for any new steps for each SDK
