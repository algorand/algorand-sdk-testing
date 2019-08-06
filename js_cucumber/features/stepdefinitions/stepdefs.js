const assert = require('assert');
const { Given, When, Then, setDefaultTimeout } = require('cucumber');
const algosdk = require("algosdk")
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const address = require("algosdk/src/encoding/address")
const encoding = require("algosdk/src/encoding/encoding")
const algtxn = require("algosdk/src/transaction")
const fs = require('fs');
const path = require("path")
const maindir = path.dirname(path.dirname(path.dirname(__dirname)))
const homedir = require('os').homedir()

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

When("I get versions with algod", function(){
    this.versions = this.acl.versions().then(result => result.versions)
});

Then("v1 should be in the versions", function(){
    this.versions.then(function(result){
        assert.deepStrictEqual(true, result.indexOf("v1") >= 0)

    })
});

When("I get versions with kmd", function(){
    this.versions = this.kcl.versions().then(result => result.versions)
});

When("I get the status", function(){
    this.status = this.acl.status();
});

When("I get status after this block", function(){
    this.statusAfter = this.status.then(result => this.acl.statusAfterBlock(result.lastRound));
});

Then("the rounds should be equal", function(){
    this.status.then(function(result){
        this.lastRound = result.lastRound;
    })
    this.statusAfter.then(function(result){
        assert.strictEqual(true, result.lastRound > this.lastRound)
    });
});

Then("I can get the block info", function(){
    this.block = this.statusAfter.then(result => this.acl.block(result.lastRound))
    this.block.then(result => assert.deepStrictEqual(true, Number.isInteger(result.round)))
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
    s = encoding.decode(this.stx)
    m = encoding.encode(s.msig)
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
    this.txn = encoding.decode(new Uint8Array(fs.readFileSync(maindir + '/raw.tx')));
})

When("I write the transaction to file", function(){
    fs.writeFile(maindir + "/raw.tx", Buffer.from(encoding.encode(this.txn)), function(err){
        if (err){
            throw err
        }
    }); 
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
