# algorand-sdk-testing
Testing files for Algorand SDKs

## How to write tests
Tests consist of two things -- feature files, which are housed in this repository and some code snippets that map the text in the feature files to specific functions. The code snippets (or step definitions) live in the SDKs, and when testing, feature files are pulled from algorand-sdk-testing so that all SDKs have the same tests. A feature file contains several scenarios, which you can think of as tests, and each scenario is made up of steps (see the 'features' directory for examples). Sometimes information needs to be passed between different steps of a single scenario or test; in Python, this is done by using the context object that is passed into each function.

Some tests are scenario outlines; which basically means you can run that particularly test with different parameters by adding lines to the examples table below the scenario. These are pretty easy to add to; just make sure the inputs are in the right format. 

To add new scenarios, either add to an existing feature file or create a new one. Then write the mapping from the English step statements to functions.

## How to run tests
A run_docker.sh file is included in each of the SDKs to pull files and run the tests in a docker container. Just call it from the project root (i.e. for py-algorand-sdk, do ./test/cucumber/docker/run_docker.sh)

## Adding a new SDK
1. Write all the mappings from gherkin to the new SDK
2. Add a Dockerfile, run_docker.sh, and sdk.py file for SDK specific testing procedures (see any existing Algorand SDK as an example)