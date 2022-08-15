# algorand-sdk-testing

Testing files for Algorand SDKs

## About

The files in this repository are used for testing the different Algorand SDK implementations. By writing the tests once and sharing them amongst the SDKs we are able to increase the coverage of our tests, and avoid rewriting similar tests over and over again. In addition to test cases, we have a standard test environment which is managed by docker.

To define tests we use [cucumber](https://cucumber.io/), and feature files written with [gherkin syntax](https://cucumber.io/docs/gherkin/reference/). Each SDK is responsible for finding a framework which can use these files. There are implementations for [many popular programming languages](https://cucumber.io/docs/installation/).

We have different feature files for unit and integration tests. The unit tests should be run as a normal part of development to quickly identify bugs and regressions. Integration tests on the other hand take much longer to run and require a special test environment. The test environment is made up of multiple services and managed with [docker compose](https://docs.docker.com/compose/).

## Test Descriptions

### Unit Tests

These reside in the [unit features directory](features/unit)

| tag                               | description                                           |
| --------------------------------- | ----------------------------------------------------- |
| @unit                             | Select all unit tests.                                |
| @unit.abijson                     | ABI types and method encoding/decoding unit tests.    |
| @unit.algod                       | Algod REST API unit tests.                            |
| @unit.algod.ledger_refactoring    |                                                       |
| @unit.applications                | Application endpoints added to Algod and Indexer.     |
| @unit.atomic_transaction_composer | ABI / atomic transaction construction unit tests.     |
| @unit.dryrun                      | Dryrun endpoint added to Algod.                       |
| @unit.feetest                     | Fee transaction encoding tests.                       |
| @unit.indexer                     | Indexer REST API unit tests.                          |
| @unit.indexer.logs                | Application logs endpoints added to Indexer.          |
| @unit.indexer.rekey               | Rekey endpoints added to Algod and Indexer            |
| @unit.offline                     | The first unit tests we wrote for cucumber.           |
| @unit.rekey                       | Rekey Transaction golden tests.                       |
| @unit.responses                   | REST Client Response serialization tests.             |
| @unit.responses.231               | REST Client Unit Tests for Indexer 2.3.1+             |
| @unit.responses.genesis           | REST Client Unit Tests for GetGenesis endpoint        |
| @unit.responses.messagepack       | REST Client MessagePack Unit Tests                    |
| @unit.responses.messagepack.231   | REST Client MessagePack Unit Tests for Indexer 2.3.1+ |
| @unit.stateproof.responses        | REST Client Response Tests for State Proof.           |
| @unit.stateproof.responses.msgp   | REST Client MessagePack Tests for State Proofs.       |
| @unit.stateproof.paths            | REST Client Unit Tests for State Proof feature.       |
| @unit.tealsign                    | Test TEAL signature utilities.                        |
| @unit.transactions                | Transaction encoding tests.                           |
| @unit.transactions.keyreg         | Keyreg encoding tests.                                |
| @unit.transactions.payment        | Payment encoding tests.                               |
| @unit.dryrun.trace.application    | DryrunResult formatting tests.                        |

### Integration Tests

These reside in the [integration features directory](features/integration)

| tag                    | description                                                                            |
| ---------------------- | -------------------------------------------------------------------------------------- |
| @abi                   | Test the Application Binary Interface (ABI) with atomic txn composition and execution. |
| @algod                 | General tests against algod REST endpoints.                                            |
| @application.evaldelta | Test that eval delta fields are included in algod and indexer.                         |
| @applications.verified | Submit all types of application transactions and verify account state.                 |
| @assets                | Submit all types of asset transactions.                                                |
| @auction               | Encode and decode bids for an auction.                                                 |
| @c2c                   | Test Contract to Contract invocations and injestion.                                   |
| @compile               | Test the algod compile endpoint.                                                       |
| @dryrun                | Test the algod dryrun endpoint.                                                        |
| @dryrun.testing        | Test the testing harness that relies on dryrun endpoint. Python only.                  |
| @indexer               | Test all types of indexer queries and parameters against a static dataset.             |
| @indexer.231           | REST Client Integration Tests for Indexer 2.3.1+                                       |
| @indexer.applications  | Endpoints and parameters added to support applications.                                |
| @kmd                   | Test the kmd REST endpoints.                                                           |
| @rekey                 | Test the rekeying transactions.                                                        |
| @send                  | Test the ability to submit transactions to algod.                                      |

### Test Implementation Status

#### Almost all the tags above are implemented by all 4 of our official SDK's

However, a few are not fully supported:

| tag                             | SDK's which implement        |
| ------------------------------- | ---------------------------- |
| @application.evaldelta          | Java only                    |
| @dryrun.testing                 | Python only                  |
| @indexer.rekey                  | missing from Python and JS   |
| @unit.responses.genesis         | missing from Python and Java |
| @unit.responses.messagepack     | missing from Python          |
| @unit.responses.messagepack.231 | missing from Python and JS   |
| @unit.responses.messagepack     | missing from Python and JS   |
| @unit.transactions.keyreg       | go only                      |

## SDK Overview

Full featured Algorand SDKs have 6 major components. Depending on the compatibility level, certain components may be missing. The components include:

1. REST Clients
2. Transaction Utilities
3. Encoding Utilities
4. Crypto Utilities
5. TEAL Utilities
6. Testing

![SDK Overview](docs/SDK%20Components.png)

### REST Client

The most basic functionality includes the REST clients for communicating with **algod** and **indexer**. These interfaces are defined by OpenAPI specifications:

- algod v1 / indexer v1 (generated at build time at **daemon/algod/api/swagger.json**)
- kmd v1 (generated at build time at **daemon/kmd/api/swagger.json**)
- [algod v2](https://github.com/algorand/go-algorand/blob/master/daemon/algod/api/algod.oas2.json)
- [indexer v2](https://github.com/algorand/indexer/blob/develop/api/indexer.oas2.json)

### Transaction Utilities

One of the basic features of an Algorand SDK is the ability to construct all types of Algorand transactions. This includes simple transactions [of all types](https://developer.algorand.org/docs/reference/transactions/) and the tooling to configure things like [leases](https://developer.algorand.org/docs/reference/transactions/#common-fields-header-and-type) and [atomic transfers (group transactions)](https://developer.algorand.org/docs/features/atomic_transfers/#group-transactions)

### Encoding Utilities

In order to ensure transactions are compact and can hash consistently, there are some special encoding requirements. The SDKs must provide utilities to work with these encodings. Algorand uses MessagePack as a compact binary-encoded JSON alternative, and fields with default values are excluded from the encoded object. Additionally to ensure consistent hashes, the fields must be alphebatized.

### Crypto Utilities

All things related to crypto to make it easier for developers to work with the blockchain. This includes standard things like ED25519 signing, up through Algorand specific LogicSig and MultiSig utilities. There are also some convenience methods for converting Mnemonics.

### TEAL Utilities

Everything related to working with [TEAL](https://developer.algorand.org/docs/reference/teal/specification/#transaction-execution-approval-language-teal). This includes some utilities for parsing and validating compiled TEAL programs.

### Testing

Each SDK has a number of unit tests specific to that particular SDK. The details of SDK-specific unit tests are up to the developers discretion. There are also a large number of cucumber integration tests stored in this repository which cover various unit-style tests and many integration tests. To assist with working in this environment each SDK must provide tooling to download and install the cucumber files, and a Dockerfile which configures an environment suitable for building the SDK and running the tests, and 3 makefile targets: `make unit`, `make integration`, and `make docker-test`. The rest of this document relates to details about the Cucumber test.

## How to write tests

Tests consist of two things -- the feature files defined in this repository and some code snippets that map the text in the feature files to specific functions. The implementation process will vary by programming language and isn't covered here, [refer to the relevant documentation](https://cucumber.io/docs/installation/) for setting up a new SDK.

### Tags

We use [tags](https://cucumber.io/docs/cucumber/api/#tags), and a simple directory structure, to organize our feature files. All cucumber implementations should allow specifying one or more tags to include, or exclude, when running tests.

### Unit tests

All unit tests should be tagged with `@unit` so that unit tests can be run together during development for quick regression tests. For example, to run unit tests with java a tag filter is provided as follows:

```bash
~$ mvn test -Dcucumber.filter.tags="@unit"
```

This command will vary by cucumber implementation, the specific framework documentation should be referenced for details.

### Adding a new test

When adding a new test to an existing feature file, or a new feature file, a new tag should be created which describes that test. For example, the **templates** feature file has a corresponding `@templates` tag. By adding a new tag for each feature we are able to add new tests to this repository without breaking the SDKs.

In order for this to work, each SDK maintains a whitelist of tags which have been implemented.

If a new feature file is created, the tag would go at the top of the file. If a new scenario is added the tag would go right above the scenario.

If possible, please run a formatter on the file modified. There are several, including one built into VSCode Cucuber/Gherkin plugin.

### Implementing tests in the SDK

The code snippets (or step definitions) live in the SDKs. Each SDK has a script which is able to clone this repository, and copy the tests into the correct locations.

When a test fails, the cucumber libraries we use print the code snippets which should be included in the SDK test code. The code snippets are empty functions which should be implemented according to the tests requirements. In many cases some state needs to be modified and stored outside of the functions in order to implement the test. Exactly how this state is managed is up to the developer. Refer to the [cucumber documentation for tips](https://cucumber.io/docs/cucumber/state/) about managing state. There may be better documentation in the specific cucumber language library you're using.

### Running tests

The SDKs come with a Makefile to coordinate running the cucumber test suites. There are 3 main targets:

- **unit**: runs all of the short unit tests.
- **integration**: runs all integration tests.
- **docker-test**: installs feature file dependencies, starts the test environment, and runs the SDK tests in a docker container.

At a high level, the **docker-test** target is required to:

1. clone `algorand-sdk-testing`.
2. copy supported feature files from the `features` directory into the SDK.
3. build and start the test environment by calling `./scripts/up.sh`
4. launch an SDK container using `--network host` which runs the cucumber test suite.

### Running tests during development

This will vary by SDK. By calling **up.sh** the environment is available to the integration tests, and tests can be run locally with an IDE or debugger. This is often significantly faster than waiting for the entire test suite to run.

Some of the tests are stateful and will require restarting the environment before re-running the test.

Once the test environment is running you can use `make unit` and `make integration` to run tests.

## Integration test environment

Docker compose is used to manage several containers which work together to provide the test environment. Currently that includes algod, kmd, indexer and a postgres database. The services run on specific ports with specific API tokens. Refer to [docker-compose.yml](docker-compose.yml) and the [docker](docker/) directory for how this is configured.

![Integration Test Environment](docs/SDK%20Test%20Environment.png)

### Start the test environment

There are a number of [scripts](scripts/) to help with managing the test environment. The names should help you understand what they do, but to get started simply run **up.sh** to bring up a new environment, and **down.sh** to shut it down.

When starting the environment we avoid using the cache intentionally. It uses the go-algorand nightly build, and we want to ensure that the containers are always running against the most recent nightly build. In the future these scripts should be improved, but for now we completely avoid using cached docker containers to ensure that we don't accidentally run against a stale environment.
