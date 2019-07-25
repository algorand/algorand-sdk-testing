# algorand-sdk-testing
Testing framework for Algorand SDKs


## How to run tests
1. Clone the repo
2. Run ./setup.sh to install dependencies (if you already have a ~/node with a node/private network, comment that section out before running)
3. Run ./test.sh or individual SDK tests, which skip crosstests (for example ./jstest.sh)


## Updating an SDK

1. Update the SDK
2. Commit
3. Trigger a build in this repo; this will grab the latest SDK versions from the SDK repositories. This step is not necessary if you don't need immediate build results; there is a daily cron job that will run the tests.


## Adding a new SDK
1. Write all the mappings from gherkin to the new SDK under a new directory (cpp_cucumber if it's the C++ SDK and the tool is called cucumber)
2. Add setup/installation procedure in setup.sh
3. Add cucumber/run command to test.sh; also add a line to copy feature files from the features directory so all of the feature files are the same
4. Create a new individual script (for example cpptest.sh if the new SDK is in C++)
5. Preferably test all of these before committing changes


## Adding more tests
1. If you just want to add more examples, add them in the scenario outlines in the main set of feature files
2. If you want to add new features, add them in the main feature files and make sure to write mappings for any new steps for each SDK


## Things to be careful of: 
- If you use libraries that are not already used by the SDKs themselves, make sure to add them to setup.sh 
- godog does not reset variables between tests, so make sure that you are referencing something that was set in a previous step of the current scenario
- If you are testing locally, remember to rerun setup.sh every so often so you have the latest versions of the SDKs

