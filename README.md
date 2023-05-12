# algorand-sdk-testing

Testing files for Algorand SDKs

## About

The files in this repository are used for testing the different Algorand SDK implementations. By writing the tests once and sharing them amongst the SDKs we are able to increase the coverage of our tests, and avoid rewriting similar tests over and over again. In addition to test cases, we have a standard test environment which is managed by docker.

To define tests we use [cucumber](https://cucumber.io/), and feature files written with [gherkin syntax](https://cucumber.io/docs/gherkin/reference/). Each SDK is responsible for finding a framework which can use these files. There are implementations for [many popular programming languages](https://cucumber.io/docs/installation/).

We have different feature files for unit and integration tests. The unit tests should be run as a normal part of development to quickly identify bugs and regressions. Integration tests, on the other hand, take much longer to run and require a special test environment. The test environment is made up of multiple services and managed with [docker compose](https://docs.docker.com/compose/).

## Test Descriptions

### Unit Tests

These reside in the [unit features directory](features/unit)

| tag                                  | description                                                                                                 |
|--------------------------------------|-------------------------------------------------------------------------------------------------------------|
| @unit                                | Select all unit tests.                                                                                      |
| @unit.abijson                        | ABI types and method encoding/decoding unit tests.                                                          |
| @unit.algod                          | Algod REST API unit tests.                                                                                  |
| @unit.blocksummary                   | Algod / Indexer block REST API unit tests.                                                                  |
| @unit.applications                   | Application endpoints added to Algod and Indexer.                                                           |
| @unit.applications.boxes             | Box endpoints for Algod and Indexer.                                                                        |
| @unit.atomic_transaction_composer    | ABI / atomic transaction construction unit tests.                                                           |
| @unit.atc_method_args                | Test that algod's Atomic Transaction Composer assserts that the same number of arguments given as expected. |
| @unit.client-no-headers              | Tests that clients don't add non-standard http headers when no (or an empty) auth token is provided.        |
| @unit.dryrun                         | Dryrun endpoint added to Algod.                                                                             |
| @unit.dryrun.trace.application       | DryrunResult formatting tests.                                                                              |
| @unit.feetest                        | Fee transaction encoding tests.                                                                             |
| @unit.indexer                        | Indexer REST API unit tests.                                                                                |
| @unit.indexer.logs                   | Application logs endpoints added to Indexer.                                                                |
| @unit.indexer.rekey                  | Rekey endpoints added to Algod and Indexer.                                                                 |
| @unit.offline                        | Offline account operations.                                                                                 |
| @unit.ready                          | Test the ready endpoint.                                                                                    |
| @unit.rekey                          | Rekey Transaction golden tests.                                                                             |
| @unit.responses                      | REST Client Response serialization tests.                                                                   |
| @unit.responses.genesis              | REST Client Unit Tests for GetGenesis endpoint.                                                             |
| @unit.responses.messagepack          | REST Client MessagePack Unit Tests.                                                                         |
| @unit.responses.messagepack.231      | REST Client MessagePack Unit Tests for Indexer 2.3.1+.                                                      |
| @unit.responses.participationupdates | REST Client Response serialization test for ParticipationUpdates.                                           |
| @unit.responses.blocksummary         | REST Client updates for indexer/algod block endpoints.                                                      |
| @unit.responses.statedelta           | REST Client updates for algod statedelta endpoint.                                                          |
| @unit.responses.sync                 | REST Client updates for algod sync round endpoints.                                                         |
| @unit.responses.timestamp            | REST Client updates for timestamp offset endpoint.                                                          |
| @unit.sourcemap                      | Test the sourcemap endpoint.                                                                                |
| @unit.statedelta                     | Test the statedelta endpoint.                                                                               |
| @unit.stateproof.responses           | REST Client Response Tests for State Proof.                                                                 |
| @unit.stateproof.responses.msgp      | REST Client MessagePack Tests for State Proofs.                                                             |
| @unit.stateproof.paths               | REST Client Unit Tests for State Proof feature.                                                             |
| @unit.sync                           | Test the follower sync endpoints.                                                                           |
| @unit.tealsign                       | Test TEAL signature utilities.                                                                              |
| @unit.timestamp                      | Test the devmode timestamp offset endpoint.                                                                 |
| @unit.transactions                   | Transaction encoding tests.                                                                                 |
| @unit.transactions.keyreg            | Keyreg encoding tests.                                                                                      |
| @unit.transactions.payment           | Payment encoding tests.                                                                                     |

### Integration Tests

These reside in the [integration features directory](features/integration)

| tag                    | description                                                                            |
| ---------------------- | -------------------------------------------------------------------------------------- |
| @abi                   | Test the Application Binary Interface (ABI) with atomic txn composition and execution. |
| @algod                 | General tests against algod REST endpoints.                                            |
| @applications.boxes    | Test application boxes and box references functionality.                               |
| @applications.verified | Submit all types of application transactions and verify account state.                 |
| @assets                | Submit all types of asset transactions.                                                |
| @auction               | Encode and decode bids for an auction.                                                 |
| @c2c                   | Test Contract to Contract invocations and ingestion.                                   |
| @compile               | Test the algod compile endpoint.                                                       |
| @compile.sourcemap     | Test that the algod compile endpoint returns a valid Source Map.                       |
| @dryrun                | Test the algod dryrun endpoint.                                                        |
| @dryrun.testing        | Test the testing harness that relies on dryrun endpoint. Python only.                  |
| @kmd                   | Test the kmd REST endpoints.                                                           |
| @rekey_v1              | Test rekeying transactions.                                                            |
| @send                  | Test the ability to submit transactions to algod.                                      |
| @simulate              | Test the ability to simulate transactions with algod.                                  |

### Test Implementation Status

#### Almost all the tags above are implemented by all 4 of our official SDK's

However, a few are not fully supported:

| tag                             | SDK's which implement        |
| ------------------------------- | ---------------------------- |
| @dryrun.testing                 | Python only                  |
| @unit.c2c                       | missing from Python          |
| @unit.indexer.rekey             | missing from Python and JS   |
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
5. Enriched Interaction
6. dApp Testing and Simulate
7. SDK Testing

![SDK Overview](docs/SDK%20Components.png)

### REST Client

The most basic functionality includes the REST clients for communicating with **algod** and **indexer**. These interfaces are defined by OpenAPI specifications:

- kmd v1 (generated at build time at **daemon/kmd/api/swagger.json**)
- [algod v2](https://github.com/algorand/go-algorand/blob/master/daemon/algod/api/algod.oas2.json)
- [indexer v2](https://github.com/algorand/indexer/blob/develop/api/indexer.oas2.json)

### Transaction Utilities

One of the basic features of an Algorand SDK is the ability to construct all types of Algorand transactions. This includes simple transactions [of all types](https://developer.algorand.org/docs/reference/transactions/) and the tooling to configure things like [leases](https://developer.algorand.org/docs/reference/transactions/#common-fields-header-and-type) and [atomic transfers (group transactions)](https://developer.algorand.org/docs/features/atomic_transfers/#group-transactions)

### Encoding Utilities

To ensure that transactions are compact and can hash consistently, there are some special encoding requirements. The SDKs must provide utilities to work with these encodings. Algorand uses MessagePack as a compact binary-encoded JSON alternative, and fields with default values are excluded from the encoded object. Additionally to ensure consistent hashes, the fields must be alphabetized. Finally, dApp args and return values can be encoded and decoded in accordance with the [ARC-004 ABI-Type Specification](https://arc.algorand.foundation/ARCs/arc-0004#encoding).

### Crypto Utilities

All things related to crypto to make it easier for developers to work with the blockchain. This includes standards such as ED25519 signing, up through Algorand specific LogicSig and MultiSig utilities. There are also some convenience methods for converting Mnemonics.

### Enriched Interaction

In certain cases, API's are provided to ease interacting
with the Algorand blockchain.
This includes [wallet interaction](https://developer.algorand.org/docs/get-details/accounts/create/#wallet-derived-kmd),
ARC-4 dApp interaction via the [Atomic Transaction Composer](https://developer.algorand.org/docs/get-details/atc/?from_query=atomic#template-modal-overlay),
and [Smart Signature](https://developer.algorand.org/docs/get-details/dapps/smart-contracts/frontend/smartsigs/?from_query=smart%20signatgure#template-modal-overlay) utilities.

### dApp Testing and Simulate

Utilities for testing [Smart Contracts and dApps](https://developer.algorand.org/docs/get-details/dapps/smart-contracts/). This currently includes utilities for using [dry-runs](https://developer.algorand.org/docs/get-details/dapps/smart-contracts/debugging/?from_query=dry#dryrun-rest-endpoint). It also enables interacting with the [simulate REST endpoint](https://developer.algorand.org/docs/rest-apis/algod/?from_query=simulate#post-v2transactionssimulate).

### SDK Testing

There are besploke unit-tests for each SDK. The details of SDK-specific unit tests are up to the developer's discretion. There are also a large number of cucumber tests stored in this repository which cover various unit-style tests and many integration tests. To assist with working in this environment each SDK must provide tooling to download and install the cucumber files, stand up a Sandbox environment that provides
**algod** and **indexer** endpoints,
a Dockerfile which configures an environment suitable for building the SDK and running the tests, and 3 `Makefile` targets:

- `make unit`
- `make integration`
- `make docker-test`

The rest of this document relates to details about the Cucumber test.

## How to write tests

Tests consist of two components:

- the feature files defined in this repository
- code snippets that map the text in the feature files to specific functions

The implementation process will vary by programming language and isn't covered here. Refer to the [Cucumber docs](https://cucumber.io/docs/installation/) for setting up a new SDK.

### Tags

We use [tags](https://cucumber.io/docs/cucumber/api/#tags), and a simple directory structure to organize our feature files. All cucumber implementations should allow specifying one or more tags to include, or exclude, when running tests.

### Unit tests

All unit tests should be tagged with `@unit` so that unit tests can be run together during development for quick regression tests. For example, to run unit tests with java a tag filter is provided as follows:

```bash
~$ mvn test -Dcucumber.filter.tags="@unit"
```

This command will vary by cucumber implementation. The specific framework documentation should be referenced for details.

### Adding a new test

When testing a new feature, add a new feature file
or add new scenario to an existing feature file, along with a new tag. For example, the [assets feature file](./features/integration/assets.feature) is tagged with `@assets`. By adding a new tag for each feature we are able to add new tests to this repository without breaking the SDKs.

In order for this to work, each SDK maintains a whitelist of tags which have been implemented.

If a new feature file is created, the tag would go at the top of the file. If a new scenario is added the tag would go right above the scenario.

If possible, please run a formatter on the file modified. There are several, including one built into VSCode Cucumber/Gherkin plugin.

### Implementing tests in the SDK

The code snippets (or step definitions) live in the SDKs. Each SDK has a script which is able to clone this repository, and copy the tests into the correct locations.

When a test fails, the cucumber libraries we use print the code snippets which should be included in the SDK test code. The code snippets are empty functions which should be implemented according to the tests requirements. In many cases some state needs to be modified and stored outside of the functions in order to implement the test. Exactly how this state is managed is up to the developer. Refer to the [cucumber documentation for tips](https://cucumber.io/docs/cucumber/state/) about managing state. There may be better documentation in the specific cucumber language library you're using.

### Running tests

The SDKs come with a `Makefile` to coordinate running the cucumber test suites. There are 3 main targets:

- **unit**: runs all of the short unit tests.
- **integration**: runs all integration tests.
- **harness**: downloads this repo and calls `up.sh` to stand up a sandbox ready for running tests
- **docker-test**: installs feature file dependencies, starts the test environment, and runs the SDK tests in a docker container.

At a high level, the **docker-test** target is required to:

1. clone `algorand-sdk-testing`
2. copy supported feature files from the `features` directory into the SDK
3. build and start the test environment by calling `./scripts/up.sh` which clones `sandbox` and stands it up
4. stand up the SDK's Docker container
5. run all cucumber tests against the `sandbox` containers

### Running tests during development

This will vary by SDK. By calling **up.sh** the environment is available to the integration tests, and tests can be run locally with an IDE or debugger. This is often significantly faster than waiting for the entire test suite to run.

Some of the tests are stateful and will require restarting the environment before re-running the test.

Once the test environment is running you can use `make unit` and `make integration` to run tests.

## Integration test environment

Algorand's [sandbox](https://github.com/algorand/sandbox) is used to manage several containers which work together to provide the test environment. This includes `algod`, `kmd`, `indexer` and a `postgres` database. The services run on specific ports with specific API tokens. Refer to [.env](.env) and to [sandbox'es docker-compose.yml](https://github.com/algorand/sandbox/blob/master/docker-compose.yml) for how these are configured.

![Integration Test Environment](docs/SDK%20Test%20Environment.png)

### Managing the test environment

[up.sh](scripts/up.sh) is used to bring up the test environment. Not surprisingly, [down.sh](scripts/down.sh) brings it all down.

When starting the environment, we default to using `go-algorand`'s nightly build. If you're interested in running tests against a specific branch of `go-algorand`, you should set `TYPE="source"` in `.env`
and set `ALGOD_URL`, and either `ALGOD_BRANCH` or `ALGOD_SHA` appropriately.

`indexer` and even the `sandbox` itself can be configured similarly through `.env`.
