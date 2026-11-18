---
name: go-algorand-update
description: Perform the necessary steps to prepare this repo for a go-algorand release 
---

This repo needs to be updated to support the features coming in the next go-algorand release. Before doing anything, ask the user which go-algorand ref (master, stable tag, or beta tag) they want to update this repo for and whether vFuture is in scope or not

Before doing anything, verify you can run `data-factory/generate.sh`. Stop immediately and let the user know if you cannot run the script. Do NOT try to fix/install anything before going to the user.

To determine the upcoming changes, perform a diff of the current `data-factory/go-algorand` reference and upstream go-algorand master. Below are some guidelines

* opcode changes are always out of scope since it does not affect the SDK
* any changes to transactions (new fields, new sig types, msig/lsig capabilities, etc.) should be reflected in the data factory
* all API changes should be reflected in the tests, including responses and requests

Do not make any changes until you have provided an overview of the changes to the user and asked any clarifying questions.
