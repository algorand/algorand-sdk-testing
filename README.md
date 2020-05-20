# algorand-sdk-testing
Testing files for Algorand SDKs

# About

The files in this repository are used for testing the different Algorand SDK implementations. By writing the tests once and sharing them amongst the SDKs we are able to increase the coverage of our tests, and avoid rewriting similar tests over and over again. In addition to test cases, we have a standard test environment which is managed by docker.

To define tests we use [cucumber](https://cucumber.io/), and feature files written with [gherkin syntax](https://cucumber.io/docs/gherkin/reference/). Each SDK is responsible for finding a framework which can use these files. There are implementations for [many popular programming languages](https://cucumber.io/docs/installation/).

We have different feature files for unit and integration tests. The unit tests should be run as a normal part of development to quickly identify bugs and regressions. Integration tests on the other hand take much longer to run and require a special test environment. The test environment is made up of multiple services and managed with [docker compose](https://docs.docker.com/compose/).

# How to write tests

Tests consist of two things -- the feature files defined in this repository and some code snippets that map the text in the feature files to specific functions. The implementation process will vary by programming language and isn't covered here, [refer to the relevant documentation](https://cucumber.io/docs/installation/) for setting up a new SDK.

## Tags

We use [tags](https://cucumber.io/docs/cucumber/api/#tags), and a simple directory structure, to organize our feature files. All cucumber implementations should allow specifying one or more tags to include, or exclude, when running tests.

## Unit tests

All unit tests should be tagged with `@unit` so that unit tests can be run together during development for quick regression tests. For example, to run unit tests with java a tag filter is provided as follows:
```
~$ mvn test -Dcucumber.filter.tags="@unit"
```

This command will vary by cucumber implementation, the specific framework documentation should be referenced for details.

## Adding a new test

When adding a new test to an existing feature file, or a new feature file, a new tag should be created which describes that test. For example, the **templates** feature file has a corresponding `@templates` tag. By adding a new tag for each feature we are able to add new tests to this repository without breaking the SDKs.

In order for this to work, each SDK maintains a whitelist of tags which have been implemented.

If a new feature file is created, the tag would go at the top of the file. If a new scenario is added the tag would go right above the scenario.

## Implementing tests in the SDK

The code snippets (or step definitions) live in the SDKs. Each SDK has a script which is able to clone this repository, and copy the tests into the correct locations.

When a test fails, the cucumber libraries we use print the code snippets which should be included in the SDK test code. The code snippets are empty functions which should be implemented according to the tests requirements. In many cases some state needs to be modified and stored outside of the functions in order to implement the test. Exactly how this state is managed is up to the developer. Refer to the [cucumber documentation for tips](https://cucumber.io/docs/cucumber/state/) about managing state. There may be better documentation in the specific cucumber language library you're using.

## Running tests

A script is included in each of the SDKs to pull files from this repository and run the tests in a docker container. Just call it from the project root. For example [py-algorand-sdk](https://github.com/algorand/py-algorand-sdk) has [run_docker.sh](https://github.com/algorand/py-algorand-sdk/blob/develop/run_integration.sh), and [java-algorand-sdk](https://github.com/algorand/java-algorand-sdk) has [run_integration_tests.sh](https://github.com/algorand/java-algorand-sdk/blob/develop/run_integration_tests.sh).

At a high level, each driver script should:
1. clone `algorand-sdk-testing`.
2. copy supported feature files from the `features` directory into the SDK.
3. build and start the test environment by calling `./scripts/up.sh`
4. launch an SDK container using `--network host` which runs the cucumber test suite.

This script should be executed as part of the CI process.


## Running tests during development
This will vary by SDK. By calling **up.sh** the environment is available to the integration tests, and tests can be run locally with an IDE or debugger. This is often significantly faster than waiting for the entire test suite to run.

Some of the tests are stateful and will require restarting the environment before re-running the test.

# Integration test environment

Docker compose is used to manage several containers which work together to provide the test environment. Currently that includes algod, kmd, indexer and a postgres database. The services run on specific ports with specific API tokens. Refer to [docker-compose.yml](docker-compose.yml) and the [docker](docker/) directory for how this is configured.

## Start the test environment

There are a number of [scripts](scripts/) to help with managing the test environment. The names should help you understand what they do, but to get started simply run **up.sh** to bring up a new environment, and **down.sh** to shut it down.

When starting the environment we avoid using the cache intentionally. It uses the go-algorand nightly build, and we want to ensure that the containers are always running against the most recent nightly build. In the future these scripts should be improved, but for now we completely avoid using cached docker containers to ensure that we don't accidentally run against a stale environment.
