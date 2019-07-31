# algorand-sdk-testing
Testing framework for Algorand SDKs

## How to write tests
Tests in this framework consist of two things -- a feature file and some code snippets that map the text in the feature file to specific functions. A feature file contains several scenarios (which you can think of as tests) and each scenario is made up of steps. As an example, see [wallet.feature](https://github.com/algorand/algorand-sdk-testing/blob/master/py_behave/wallet.feature), line 7, which gets mapped to the first function in [steps.py](https://github.com/algorand/algorand-sdk-testing/blob/master/py_behave/steps/steps.py). This works similarly in other languages. Sometimes information needs to be passed between different steps of a single scenario or test; in Python, this is done by using the context object that is passed into each function. 

Some tests are scenario outlines; which basically means you can run that particularly test with different parameters by adding lines to the examples table below the scenario (see [multisig.feature](https://github.com/algorand/algorand-sdk-testing/blob/master/py_behave/wallet.feature)). These are pretty easy to add to; just make sure the inputs are in the right format. 

To add new scenarios, either add to an existing feature file or create a new one. Then write the mapping from the English step statements to functions in each language so that all the SDKs are tested on the new scenario.

Step function locations: 

- [steps_test.go](https://github.com/algorand/algorand-sdk-testing/blob/master/go_godog/src/steps_test.go)
- [Stepdefs.java](https://github.com/algorand/algorand-sdk-testing/blob/master/java_cucumber/src/test/java/java_cucumber/Stepdefs.java)
- [stepdefs.js](https://github.com/algorand/algorand-sdk-testing/blob/master/js_cucumber/features/stepdefinitions/stepdefs.js)
- [steps.py](https://github.com/algorand/algorand-sdk-testing/blob/master/py_behave/steps/steps.py)


## How to run tests
1. Clone the repo
2. Run scripts/setup.sh to install dependencies
3. Run scripts/test.sh

## Updating an SDK
1. Update as normal and commit; this will grab the tests from this repo and run them as part of the SDK's travis build

## Adding a new SDK
1. Write all the mappings from gherkin to the new SDK under a new directory (cpp_cucumber if it's the C++ SDK and the tool is called cucumber)
2. Add setup/installation procedure in setup.sh
3. Add a line to copy feature files from the features directory so all of the feature files are the same in test.sh
4. Add corresponding code for running tests in test.sh 
5. Preferably test all of these before committing changes
6. Add sdkupdate.sh to new SDK and call it in .travis.yml

## Things to be careful of: 
- If you use libraries that are not already used by the SDKs themselves, make sure to add them to setup.sh 
- godog does not reset variables between tests, so make sure that you are referencing something that was set in a previous step of the current scenario
- If you are testing locally, check every so often that you have the latest versions of the SDKs

