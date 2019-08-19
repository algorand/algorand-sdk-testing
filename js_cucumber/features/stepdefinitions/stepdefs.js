const assert = require('assert');
const { Given, When, Then, setDefaultTimeout } = require('cucumber');
const algosdk = require("algosdk")
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const address = require("algosdk/src/encoding/address")
const fs = require('fs');
const path = require("path")
const maindir = path.dirname(path.dirname(path.dirname(__dirname)))
const homedir = require('os').homedir()
const bid = require("algosdk/src/bid")

setDefaultTimeout(60000)

Given("an algod client", async function(){
    data_dir_path = "file://" + homedir + "/node/network/Node/";
    algod_token = "";
    algod_address = "";

    xml = new XMLHttpRequest();
    xml.open("GET", data_dir_path + "algod.net", false);
    xml.onreadystatechange = function () {
        algod_address = xml.responseText.trim();
    };
    xml.send();
    
    xml.open("GET", data_dir_path + "algod.token", false);
    xml.onreadystatechange = function () {
        algod_token = xml.responseText.trim();
    };
    xml.send();
    
    this.acl = new algosdk.Algod(algod_token, algod_address.split(":")[0], algod_address.split(":")[1]);
    return this.acl
})

Given("a kmd client", function(){
    data_dir_path = "file://" + homedir + "/node/network/Node/";
    kmd_folder_name = "kmd-v0.5/";
    kmd_token = "";
    kmd_address = "";
    
    xml.open("GET", data_dir_path + kmd_folder_name + "kmd.net", false);
    xml.onreadystatechange = function () {
        kmd_address = xml.responseText.trim();
    };
    xml.send();
    
    xml.open("GET", data_dir_path + kmd_folder_name + "kmd.token", false);
    xml.onreadystatechange = function () {
        kmd_token = xml.responseText.trim();
    };
    xml.send();

    this.kcl = new algosdk.Kmd(kmd_token, kmd_address.split(":")[0], kmd_address.split(":")[1])

    return this.kcl

});

Given("wallet information", async function(){
    this.wallet_name = "unencrypted-default-wallet";
    this.wallet_pswd = "";

    this.handle = await this.kcl.listWallets().then(result => {
        for(var i = 0; i < result.wallets.length; i++){
            var w = result.wallets[i];
            if (w.name == this.wallet_name) {
                this.wallet_id = w.id;
                return w.id
            }
        }
    }).then(result => this.kcl.initWalletHandle(result, this.wallet_pswd)
    )
    this.handle = this.handle.wallet_handle_token
    this.accounts = await this.kcl.listKeys(this.handle)
    this.accounts = this.accounts.addresses
    return this.accounts

})

When("I get versions with algod", async function(){
    this.versions = await this.acl.versions();
    this.versions = this.versions.versions;
    return this.versions
});

Then("v1 should be in the versions", function(){
    assert.deepStrictEqual(true, this.versions.indexOf("v1") >= 0)
});

When("I get versions with kmd", async function(){
    this.versions = await this.kcl.versions();
    this.versions = this.versions.versions;
    return this.versions
});

When("I get the status", async function(){
    this.status = await this.acl.status();
    return this.status
});

When("I get status after this block", async function(){
    this.statusAfter = await this.acl.statusAfterBlock(this.status.lastRound);
    return this.statusAfter
});

Then("the rounds should be equal", async function(){
    assert.strictEqual(true, this.statusAfter.lastRound > this.status.lastRound)
});

Then("I can get the block info", async function(){
    this.block = await this.acl.block(this.statusAfter.lastRound);
    assert.deepStrictEqual(true, Number.isInteger(this.block.round));
})


Given("payment transaction parameters {int} {int} {int} {string} {string} {string} {int} {string} {string}", function(fee, fv, lv, gh, to, close, amt, gen, note) {
    this.fee = parseInt(fee)
    this.fv = parseInt(fv)
    this.lv = parseInt(lv)
    this.gh = gh
    this.to = to
    this.close = close
    this.amt = parseInt(amt)
    this.gen = gen
    this.note = new Uint8Array(Buffer.from(note, "base64"))

})

Given("mnemonic for private key {string}", function(mn) {
    result = algosdk.mnemonicToSecretKey(mn)
    this.pk = result.addr
  
    this.sk = result.sk
})

Given("multisig addresses {string}", function(addresses) {
    addrlist = addresses.split(" ")
    this.msig = {
        version: 1,
        threshold: 2,
        addrs: addrlist
    }
    this.pk = algosdk.multisigAddress(this.msig)
})


When("I create the payment transaction", function() {
    this.txn = {
        "from": this.pk,
        "to": this.to,
        "fee": this.fee,
        "firstRound": this.fv,
        "lastRound": this.lv,
        "genesisHash": this.gh,
    };
    if (this.gen) {
        this.txn["genesisID"] = this.gen
    }
    if (this.close) {
        this.txn["closeRemainderTo"] = this.close
    }
    if (this.note) {
        this.txn["note"] = this.note
    }
    if (this.amt) {
        this.txn["amount"] = this.amt
    }
})


When("I sign the transaction with the private key", function() {
    let obj = algosdk.signTransaction(this.txn, this.sk)
    this.stx = obj.blob
})

When("I sign the multisig transaction with the private key", function() {
    let obj = algosdk.signMultisigTransaction(this.txn, this.msig, this.sk)
    this.stx = obj.blob
})

When("I sign the transaction with kmd", async function(){
    this.stxKmd = await this.kcl.signTransaction(this.handle, this.wallet_pswd, this.txn)
    return this.stxKmd
})

When("I sign the multisig transaction with kmd", async function(){
    addrs = [];
    for(i = 0; i < this.msig.addrs.length; i++){
        addrs.push(Buffer.from(address.decode(this.msig.addrs[i]).publicKey).toString("base64"))
    }
    await this.kcl.importMultisig(this.handle, this.msig.version, this.msig.threshold, addrs)

    key = address.decode(this.pk).publicKey
    this.stxKmd = await this.kcl.signMultisigTransaction(this.handle, this.wallet_pswd, this.txn, key, null)
    this.stxKmd = this.stxKmd.multisig
    return this.stxKmd
})

Then('the signed transaction should equal the golden {string}', function(golden){
    assert.deepStrictEqual(Buffer.from(golden, "base64"), Buffer.from(this.stx))
})


Then("the signed transaction should equal the kmd signed transaction", function(){
    assert.deepStrictEqual(Buffer.from(this.stx), Buffer.from(this.stxKmd))
})

Then("the multisig address should equal the golden {string}", function(golden) {
    assert.deepStrictEqual(algosdk.multisigAddress(this.msig), golden)
})

Then('the multisig transaction should equal the golden {string}', function(golden){
    assert.deepStrictEqual(Buffer.from(golden, "base64"), Buffer.from(this.stx))
})

Then("the multisig transaction should equal the kmd signed multisig transaction", async function(){
    await this.kcl.deleteMultisig(this.handle, this.wallet_pswd, algosdk.multisigAddress(this.msig))
    s = algosdk.decodeObj(this.stx)
    m = algosdk.encodeObj(s.msig)
    assert.deepStrictEqual(Buffer.from(m), Buffer.from(this.stxKmd, "base64"))
})


When("I generate a key using kmd", async function(){
    this.pk = await this.kcl.generateKey(this.handle)
    this.pk = this.pk.address
    return this.pk
});

Then("the key should be in the wallet", async function(){
    keys = await this.kcl.listKeys(this.handle)
    keys = keys.addresses
    assert.deepStrictEqual(true, keys.indexOf(this.pk) >= 0)
    return keys
})

When("I delete the key", async function(){
    return await this.kcl.deleteKey(this.handle, this.wallet_pswd, this.pk)
})

Then("the key should not be in the wallet", async function(){
    keys = await this.kcl.listKeys(this.handle)
    keys = keys.addresses
    assert.deepStrictEqual(false, keys.indexOf(this.pk) >= 0)
    return keys
})

When("I generate a key", function(){
    var result = algosdk.generateAccount()
    this.pk = result.addr
    this.sk = result.sk
})

When("I import the key", async function(){
    return await this.kcl.importKey(this.handle, this.sk)
})

Then("the private key should be equal to the exported private key", async function(){
    exp = await this.kcl.exportKey(this.handle, this.wallet_pswd, this.pk)
    exp = exp.private_key    
    assert.deepStrictEqual(Buffer.from(exp).toString("base64"), Buffer.from(this.sk).toString("base64"))
    return await this.kcl.deleteKey(this.handle, this.wallet_pswd, this.pk)
})


When("I get the private key", async function(){
    sk = await this.kcl.exportKey(this.handle, this.wallet_pswd, this.pk)
    this.sk = sk.private_key
    return this.sk
})


Given("default transaction with parameters {int} {string}", async function(amt, note) {    
    this.pk = this.accounts[0]
    result = await this.acl.getTransactionParams()
    this.lastRound = result.lastRound
    this.txn = {
            "from": this.accounts[0],
            "to": this.accounts[1],
            "fee": result["fee"],
            "firstRound": result["lastRound"] + 1,
            "lastRound": result["lastRound"] + 1000,
            "genesisHash": result["genesishashb64"],
            "genesisID": result["genesisID"],
            "note": new Uint8Array(Buffer.from(note, "base64")),
            "amount": parseInt(amt)
        }
    return this.txn
});


Given("default multisig transaction with parameters {int} {string}", async function(amt, note) {    
    this.pk = this.accounts[0]
    result = await this.acl.getTransactionParams()
    this.msig = {
        version: 1,
        threshold: 1,
        addrs: this.accounts
    }

    this.txn = {
            "from": algosdk.multisigAddress(this.msig),
            "to": this.accounts[1],
            "fee": result["fee"],
            "firstRound": result["lastRound"] + 1,
            "lastRound": result["lastRound"] + 1000,
            "genesisHash": result["genesishashb64"],
            "genesisID": result["genesisID"],
            "note": new Uint8Array(Buffer.from(note, "base64")),
            "amount": parseInt(amt)
        }
    return this.txn
});

When("I import the multisig", async function(){

    addrs = [];
    for(i = 0; i < this.msig.addrs.length; i++){
        addrs.push(Buffer.from(address.decode(this.msig.addrs[i]).publicKey).toString("base64"))
    }
    return await this.kcl.importMultisig(this.handle, this.msig.version, this.msig.threshold, addrs)
})

Then("the multisig should be in the wallet", async function(){
    keys = await this.kcl.listMultisig(this.handle)
    keys = keys.addresses
    assert.deepStrictEqual(true, keys.indexOf(algosdk.multisigAddress(this.msig)) >= 0)
    return keys
})


Then("the multisig should not be in the wallet", async function(){
    keys = await this.kcl.listMultisig(this.handle)
    if(typeof keys.addresses === "undefined"){
        return true
    }
    else{
        keys = keys.addresses
        assert.deepStrictEqual(false, keys.indexOf(algosdk.multisigAddress(this.msig)) >= 0)
        return keys
    }
})


When("I export the multisig", async function(){
    this.msigExp = await this.kcl.exportMultisig(this.handle, algosdk.multisigAddress(this.msig))
    return this.msigExp
})


When("I delete the multisig", async function(){
    return await this.kcl.deleteMultisig(this.handle, this.wallet_pswd, algosdk.multisigAddress(this.msig))
})


Then("the multisig should equal the exported multisig", function(){
    for(i = 0; i < this.msigExp.length; i++){
        assert.deepStrictEqual(address.encode(Buffer.from(this.msigExp[i], "base64")), this.msig.addrs[i])
    }
})


Then('the node should be healthy', async function () {
    health = await this.acl.healthCheck();
    assert.deepStrictEqual(health, {});
});


When('I get the ledger supply', async function () {
    this.supply = await this.acl.ledgerSupply();
    return this.supply
});


Then('the ledger supply should tell me the total money', function () {
    assert.deepStrictEqual(true, "totalMoney" in this.supply);
});


Then('I get transactions by address and round', async function () {
    lastRound = await this.acl.status()
    transactions = await this.acl.transactionByAddress(this.accounts[0], 1, lastRound["lastRound"])
    assert.deepStrictEqual(true, Object.entries(transactions).length === 0 || "transactions" in transactions)
});


Then('I get pending transactions', async function () {
    transactions = await this.acl.pendingTransactions(10)
    assert.deepStrictEqual(true, Object.entries(transactions).length === 0 || "truncatedTxns" in transactions)
});


When('I get the suggested params', async function () {
    this.params = await this.acl.getTransactionParams()
    return this.params
});


When('I get the suggested fee', async function () {
    this.fee = await this.acl.suggestedFee()
    this.fee = this.fee.fee
    return this.fee
});


Then('the fee in the suggested params should equal the suggested fee', function () {
    assert.deepStrictEqual(this.params.fee, this.fee)
});


When('I create a bid', function () {
    addr = algosdk.generateAccount().addr
    temp = {
        "bidderKey": addr,
        "bidAmount": 1,
        "maxPrice": 2,
        "bidID": 3,
        "auctionKey": addr,
        "auctionID": 4
    }
    
    this.bid = new bid.Bid(temp);
    this.oldBid = new bid.Bid(temp);
    return this.bid
});


When('I encode and decode the bid', function () {
    this.bid = algosdk.decodeObj(algosdk.encodeObj(this.bid));
    return this.bid
});


Then('the bid should still be the same', function () {
    assert.deepStrictEqual(algosdk.encodeObj(this.bid), algosdk.encodeObj(this.oldBid))
});


When('I decode the address', function () {
    this.old = this.pk
    this.addrBytes = address.decode(this.pk).publicKey
});


When('I encode the address', function () {
    this.pk = address.encode(this.addrBytes)
});


Then('the address should still be the same', function () {
    assert.deepStrictEqual(this.pk, this.old)
});


When('I convert the private key back to a mnemonic', function () {
    this.mn = algosdk.secretKeyToMnemonic(this.sk)
});


Then('the mnemonic should still be the same as {string}', function (mn) {
    assert.deepStrictEqual(this.mn, mn)
});


Given('mnemonic for master derivation key {string}', function (mn) {
    this.mdk = algosdk.mnemonicToMasterDerivationKey(mn)
});


When('I convert the master derivation key back to a mnemonic', function () {
    this.mn = algosdk.masterDerivationKeyToMnemonic(this.mdk)
});


When('I create the flat fee payment transaction', function () {
    return 'pending';
});


Given('encoded multisig transaction {string}', function (encTxn) {
    this.mtx = Buffer.from(encTxn, "base64")
    this.stx = algosdk.decodeObj(this.mtx);
});


When('I append a signature to the multisig transaction', function () {
    addresses = this.stx.msig.subsig.slice()
    for (i=0; i < addresses.length; i++){
        addresses[i] = address.encode(addresses[i].pk)
    }
    msig = {
        version: this.stx.msig.v,
        threshold: this.stx.msig.thr,
        addrs: addresses
    }
    this.stx = algosdk.appendSignMultisigTransaction(this.mtx, msig, this.sk).blob
});


When('I merge the multisig transactions', function () {
    this.stx = algosdk.mergeMultisigTransactions(this.mtxs)
});


When('I convert {int} microalgos to algos and back', function (int) {
    return 'pending';
});


Then('it should still be the same amount of microalgos {int}', function (int) {
    return 'pending';
});


Given('encoded multisig transactions {string}', function (encTxns) {
    this.mtxs = [];
    mtxs = encTxns.split(" ")
    for (i = 0; i < mtxs.length; i++){
        this.mtxs.push(Buffer.from(mtxs[i], "base64"))
    }

});


When("I create the multisig payment transaction", function() {
    this.txn = {
        "from": algosdk.multisigAddress(this.msig),
        "to": this.to,
        "fee": this.fee,
        "firstRound": this.fv,
        "lastRound": this.lv,
        "genesisHash": this.gh,
    };
    if (this.gen) {
        this.txn["genesisID"] = this.gen
    }
    if (this.close) {
        this.txn["closeRemainderTo"] = this.close
    }
    if (this.note) {
        this.txn["note"] = this.note
    }
    if (this.amt) {
        this.txn["amount"] = this.amt
    }
    return this.txn
})

When("I send the transaction", async function(){
    this.txid = await this.acl.sendRawTransaction(this.stx)
    this.txid = this.txid.txId
    return this.txid
})

When("I send the multisig transaction", async function(){
    try {
        this.txid = await this.acl.sendRawTransaction(this.stx)
        this.err = false
        return this.txid

    } catch (e){
        this.err = true
    }

})

Then("the transaction should go through", async function(){
    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
      }
    await sleep(8000)
    await this.acl.statusAfterBlock(this.lastRound + 2)
    info = await this.acl.transactionInformation(this.pk, this.txid)
    assert.deepStrictEqual(true, "type" in info)
})


Then("the transaction should not go through", function(){
    assert.deepStrictEqual(true, this.err)
})


When("I create a wallet", async function(){
    this.wallet_name = "Walletjs"
    this.wallet_pswd = ""
    this.wallet_id = await this.kcl.createWallet(this.wallet_name, this.wallet_pswd)
    this.wallet_id = this.wallet_id.wallet.id
    return this.wallet_id
})

Then("the wallet should exist", async function(){
    result = await this.kcl.listWallets()
    exists = false
    for(var i = 0; i < result.wallets.length; i++){
        var w = result.wallets[i];
        if (w.name == this.wallet_name) {
            exists = true
        }
    }
    assert.deepStrictEqual(true, exists)
})

When("I get the wallet handle", async function(){
    this.handle = await this.kcl.initWalletHandle(this.wallet_id, this.wallet_pswd)
    this.handle = this.handle.wallet_handle_token
    return this.handle
})

Then("I can get the master derivation key", async function(){
    mdk = await this.kcl.exportMasterDerivationKey(this.handle, this.wallet_pswd)
    return mdk
})

When("I rename the wallet", async function(){
    this.wallet_name = "Walletjs_new"
    return await this.kcl.renameWallet(this.wallet_id, this.wallet_pswd, this.wallet_name)
})

Then("I can still get the wallet information with the same handle", async function(){
    return await this.kcl.getWallet(this.handle)
})

When("I renew the wallet handle", async function(){
    return await this.kcl.renewWalletHandle(this.handle)
})

When("I release the wallet handle", async function(){
    return await this.kcl.releaseWalletHandle(this.handle)
})

Then("the wallet handle should not work", async function(){
    try{
        await this.kcl.renewWalletHandle(this.handle)
        this.err = false
    } catch (e){
        this.err = true
    }
    assert.deepStrictEqual(true, this.err)
})

When("I read a transaction from file", function(){
    this.txn = algosdk.decodeObj(new Uint8Array(fs.readFileSync(maindir + '/raw.tx')));
    return this.txn
})

When("I write the transaction to file", function(){
    fs.writeFileSync(maindir + "/raw.tx", Buffer.from(algosdk.encodeObj(this.txn)));
})

Then("the transaction should still be the same", function(){
    stxnew = new Uint8Array(fs.readFileSync(maindir + '/raw.tx'));
    stxold = new Uint8Array(fs.readFileSync(maindir + '/old.tx'));
    assert.deepStrictEqual(stxnew, stxold)
})

Then("I do my part", async function(){
    stx = new Uint8Array(fs.readFileSync(maindir + '/txn.tx'));
    this.txid = await this.acl.sendRawTransaction(stx)
    this.txid = this.txid.txId
    return this.txid
})


