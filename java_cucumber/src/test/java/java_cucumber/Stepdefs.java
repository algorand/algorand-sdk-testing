package java_cucumber;

import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;
import cucumber.api.java.en.Then;

import com.algorand.algosdk.account.Account;
import com.algorand.algosdk.crypto.Address;
import com.algorand.algosdk.crypto.Digest;
import com.algorand.algosdk.crypto.Ed25519PublicKey;
import com.algorand.algosdk.crypto.MultisigAddress;
import com.algorand.algosdk.crypto.MultisigSignature;
import com.algorand.algosdk.transaction.SignedTransaction;
import com.algorand.algosdk.transaction.Transaction;
import com.algorand.algosdk.util.Encoder;
import com.algorand.algosdk.util.AlgoConverter;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.algorand.algosdk.auction.Bid;
import com.algorand.algosdk.auction.SignedBid;
import com.algorand.algosdk.algod.client.AlgodClient;
import com.algorand.algosdk.algod.client.api.AlgodApi;
import com.algorand.algosdk.algod.client.ApiException;
import com.algorand.algosdk.algod.client.model.*;
import com.algorand.algosdk.kmd.client.KmdClient;
import com.algorand.algosdk.kmd.client.api.KmdApi;
import com.algorand.algosdk.kmd.client.model.*;
import com.algorand.algosdk.mnemonic.Mnemonic;

import java.math.BigInteger;
import java.math.BigDecimal;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.junit.Assert;
import org.threeten.bp.LocalDate;

import java.util.List;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.File;
import java.io.IOException;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.security.GeneralSecurityException;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;


public class Stepdefs {
    SignedTransaction stx;
    SignedTransaction[] stxs;
    byte[] stxBytes;
    Transaction txn;
    String txid;
    Account account;
    Address pk;
    String address;
    byte[] sk;
    BigInteger fee;
    BigInteger fv;
    BigInteger lv;
    Digest gh;
    Address to;
    Address close;
    BigInteger amt;
    String gen;
    byte[] note;
    MultisigAddress msig;
    MultisigSignature msigsig;
    String walletName;
    String walletPswd;
    String walletID;
    AlgodApi acl;
    AlgodClient algodClient;
    KmdApi kcl;
    KmdClient kmdClient;
    String handle;
    List<String> versions;
    NodeStatus status;
    NodeStatus statusAfter;
    List<byte[]> pks;
    List<String> accounts;
    BigInteger lastRound;
    boolean err;
    BigInteger microalgos;
    String mnemonic;
    byte[] mdk;
    String oldAddr;
    Bid bid;
    SignedBid oldBid;
    SignedBid sbid;
    BigInteger paramsFee;
    Supply supply;

    @When("I create a wallet")
    public void createWallet() throws com.algorand.algosdk.kmd.client.ApiException {
        walletName = "Walletjava";
        walletPswd = "";
        CreateWalletRequest req = new CreateWalletRequest();
        req.setWalletName(walletName);
        req.setWalletPassword(walletPswd);
        req.setWalletDriverName("sqlite");
        walletID = kcl.createWallet(req).getWallet().getId();

    }

    @Then("the wallet should exist")
    public void walletExist() throws com.algorand.algosdk.kmd.client.ApiException{
        boolean exists = false;
        APIV1GETWalletsResponse resp = kcl.listWallets();
        for (APIV1Wallet w : resp.getWallets()){
            if (w.getName().equals(walletName)){
                exists = true;
            }
        }
        Assert.assertTrue(exists);
    }

    @When("I get the wallet handle")
    public void getHandle() throws com.algorand.algosdk.kmd.client.ApiException{
        InitWalletHandleTokenRequest req = new InitWalletHandleTokenRequest();
        req.setWalletId(walletID);
        req.setWalletPassword(walletPswd);
        handle = kcl.initWalletHandleToken(req).getWalletHandleToken();
        
    }

    @Then("I can get the master derivation key")
    public void getMdk() throws com.algorand.algosdk.kmd.client.ApiException{
        ExportMasterKeyRequest req = new ExportMasterKeyRequest();
        req.setWalletHandleToken(handle);
        req.setWalletPassword(walletPswd);
        byte[] mdk = kcl.exportMasterKey(req).getMasterDerivationKey();
        Assert.assertTrue(mdk.length > 0);
    }

    @When("I rename the wallet")
    public void renameWallet() throws com.algorand.algosdk.kmd.client.ApiException{
        RenameWalletRequest req = new RenameWalletRequest();
        walletName = "Walletjava_new";
        req.setWalletId(walletID);
        req.setWalletPassword(walletPswd);
        req.setWalletName(walletName);
        kcl.renameWallet(req);
    }

    @Then("I can still get the wallet information with the same handle")
    public void getWalletInfo() throws com.algorand.algosdk.kmd.client.ApiException{
        WalletInfoRequest req = new WalletInfoRequest();
        req.setWalletHandleToken(handle);
        String name = kcl.getWalletInfo(req).getWalletHandle().getWallet().getName();
        Assert.assertEquals(name, walletName);
    }

    @When("I renew the wallet handle")
    public void renewHandle() throws com.algorand.algosdk.kmd.client.ApiException{
        RenewWalletHandleTokenRequest req = new RenewWalletHandleTokenRequest();
        req.setWalletHandleToken(handle);
        kcl.renewWalletHandleToken(req);
    }

    @When("I release the wallet handle")
    public void releaseHandle() throws com.algorand.algosdk.kmd.client.ApiException{
        ReleaseWalletHandleTokenRequest req = new ReleaseWalletHandleTokenRequest();
        req.setWalletHandleToken(handle);
        kcl.releaseWalletHandleToken(req);
    }

    @Then("the wallet handle should not work")
    public void tryHandle() throws com.algorand.algosdk.kmd.client.ApiException{
        RenewWalletHandleTokenRequest req = new RenewWalletHandleTokenRequest();
        req.setWalletHandleToken(handle);
        err = false;
        try{
            kcl.renewWalletHandleToken(req);
        } catch(Exception e){
            err = true;
        }
        Assert.assertTrue(err);
    }

    @Given("payment transaction parameters {int} {int} {int} {string} {string} {string} {int} {string} {string}")
    public void transaction_parameters(int fee, int fv, int lv, String gh, String to, String close, int amt, String gen, String note)  throws GeneralSecurityException, NoSuchAlgorithmException{
        this.fee = BigInteger.valueOf(fee);
        this.fv = BigInteger.valueOf(fv);
        this.lv = BigInteger.valueOf(lv);
        this.gh = new Digest(Encoder.decodeFromBase64(gh));
        this.to = new Address(to);
        this.close = new Address(close);
        this.amt = BigInteger.valueOf(amt);

        this.gen = gen;
        this.note = Encoder.decodeFromBase64(note);
    }

    @Given("mnemonic for private key {string}")
    public void mn_for_sk(String mn) throws GeneralSecurityException{
        account = new Account(mn);
        pk = account.getAddress();
    }

    @When("I create the payment transaction")
    public void createPaytxn() throws NoSuchAlgorithmException, JsonProcessingException, IOException{
        txn = new Transaction(
                    pk,
                    fee,
                    fv,
                    lv,
                    note,
                    gen,
                    gh,
                    amt,
                    to,
                    close
            );
        txn = Account.transactionWithSuggestedFeePerByte(txn, txn.fee);
    }

    @Given("multisig addresses {string}")
    public void msig_addresses(String addresses) throws NoSuchAlgorithmException {
        String[] addrs = addresses.split(" ");
        Ed25519PublicKey[] addrlist = new Ed25519PublicKey[addrs.length];
        for(int x = 0; x < addrs.length; x++){
            addrlist[x] = new Ed25519PublicKey((new Address(addrs[x])).getBytes());
        }
        msig = new MultisigAddress(1, 2, Arrays.asList(addrlist));
        pk = new Address(msig.toString());
    }

    @When("I create the multisig payment transaction")
    public void createMsigTxn() throws NoSuchAlgorithmException{
        txn = new Transaction(
            new Address(msig.toString()),
            fee,
            fv,
            lv,
            note,
            gen,
            gh,
            amt,
            to,
            close
        );
        txn = Account.transactionWithSuggestedFeePerByte(txn, txn.fee);
    }

    @When("I sign the multisig transaction with the private key")
    public void signMsigTxn() throws NoSuchAlgorithmException{
        stx = account.signMultisigTransaction(msig, txn);
    }

    @When("I sign the transaction with the private key")
    public void signTxn() throws NoSuchAlgorithmException{
        stx = account.signTransaction(txn);
    }
    
    @Then("the signed transaction should equal the golden {string}")
    public void equalGolden(String golden) throws JsonProcessingException{
        byte[] signedTxBytes = Encoder.encodeToMsgPack(stx);
        Assert.assertEquals(golden, Encoder.encodeToBase64(signedTxBytes));

    }

    @Then("the multisig transaction should equal the golden {string}")
    public void equalMsigGolden(String golden) throws JsonProcessingException{
        byte[] signedTxBytes = Encoder.encodeToMsgPack(stx);
        Assert.assertEquals(golden, Encoder.encodeToBase64(signedTxBytes));
    }


    @Then("the multisig address should equal the golden {string}")
    public void equalMsigAddrGolden(String golden){
        Assert.assertEquals(golden, msig.toString());
    }

    @When("I get versions with algod")
    public void aclV() throws ApiException{
        versions = acl.getVersion().getVersions();
    }

    @Then("v1 should be in the versions")
    public void v1InVersions(){
        Assert.assertTrue(versions.contains("v1"));
    }

    @When("I get versions with kmd") 
    public void kclV() throws com.algorand.algosdk.kmd.client.ApiException{
        versions = kcl.getVersion().getVersions();
    }

    @When("I get the status")
    public void status() throws ApiException{
        status = acl.getStatus();
    }

    @When("I get status after this block")
    public void statusBlock() throws ApiException, InterruptedException {
        Thread.sleep(4000);
        statusAfter = acl.waitForBlock(status.getLastRound());
    }

    @Then("the rounds should be equal")
    public void roundsEq() {
        Assert.assertTrue(statusAfter.getLastRound().compareTo(status.getLastRound()) == 1);
    }

    @Then("I can get the block info")
    public void block() throws ApiException{
        acl.getBlock(status.getLastRound().add(BigInteger.valueOf(1)));
    }

    //FIXTHIS
    @When("I import the multisig")
    public void importMsig() {
        // ImportMultisigRequest req = new ImportMultisigRequest();
        throw new cucumber.api.PendingException();
    }

    @Then("the multisig should be in the wallet")
    public void msigInWallet() throws com.algorand.algosdk.kmd.client.ApiException{
        ListMultisigRequest req = new ListMultisigRequest();
        req.setWalletHandleToken(handle);
        List<String> msigs = kcl.listMultisg(req).getAddresses();
        boolean exists = false;
        for (String m : msigs){
            if (m.equals(msig.toString())){
                exists = true;
            }
        }
        Assert.assertTrue(exists);
    }

    @When("I export the multisig")
    public void expMsig() throws com.algorand.algosdk.kmd.client.ApiException{
        ExportMultisigRequest req = new ExportMultisigRequest();
        req.setAddress(msig.toString());
        req.setWalletHandleToken(handle);
        pks = kcl.exportMultisig(req).getPks();

    }

    @Then("the multisig should equal the exported multisig")
    public void msigEq(){
        boolean eq = true;
        for (int x = 0; x < msig.publicKeys.size(); x++){
            if (msig.publicKeys.get(x).getBytes() != pks.get(x)){
                eq = false;
            }
        }
        Assert.assertTrue(eq);
    }
    @When("I delete the multisig")
    public void deleteMsig() throws com.algorand.algosdk.kmd.client.ApiException{
        DeleteMultisigRequest req = new DeleteMultisigRequest();
        req.setAddress(msig.toString());
        req.setWalletHandleToken(handle);
        req.setWalletPassword(walletPswd);
        kcl.deleteMultisig(req);
    }

    @Then("the multisig should not be in the wallet")
    public void msigNotInWallet()throws com.algorand.algosdk.kmd.client.ApiException{
        ListMultisigRequest req = new ListMultisigRequest();
        req.setWalletHandleToken(handle);
        List<String> msigs = kcl.listMultisg(req).getAddresses();
        boolean exists = false;
        for (String m : msigs){
            if (m.equals(msig.toString())){
                exists = true;
            }
        }
        Assert.assertTrue(!exists);
    }

    @When("I generate a key using kmd")
    public void genKeyKmd() throws com.algorand.algosdk.kmd.client.ApiException, NoSuchAlgorithmException{
        GenerateKeyRequest req = new GenerateKeyRequest();
        req.setDisplayMnemonic(false);
        req.setWalletHandleToken(handle);
        pk = new Address(kcl.generateKey(req).getAddress());
    }

    @Then("the key should be in the wallet")
    public void keyInWallet() throws com.algorand.algosdk.kmd.client.ApiException {
        ListKeysRequest req = new ListKeysRequest();
        req.setWalletHandleToken(handle);
        List<String> keys = kcl.listKeysInWallet(req).getAddresses();
        boolean exists = false;
        for (String k : keys){
            if (k.equals(pk.toString())){
                exists = true;
            }
        }
        Assert.assertTrue(exists);
    }

    @When("I delete the key")
    public void deleteKey() throws com.algorand.algosdk.kmd.client.ApiException{
        DeleteKeyRequest req = new DeleteKeyRequest();
        req.setAddress(pk.toString());
        req.setWalletHandleToken(handle);
        req.setWalletPassword(walletPswd);
        kcl.deleteKey(req);
    }

    @Then("the key should not be in the wallet")
    public void keyNotInWallet() throws com.algorand.algosdk.kmd.client.ApiException{
        ListKeysRequest req = new ListKeysRequest();
        req.setWalletHandleToken(handle);
        List<String> keys = kcl.listKeysInWallet(req).getAddresses();
        boolean exists = false;
        for (String k : keys){
            if (k.equals(pk.toString())){
                exists = true;
            }
        }
        Assert.assertTrue(!exists);
    }

    @When("I generate a key")
    public void genKey()throws NoSuchAlgorithmException{
        account = new Account();
        pk = account.getAddress();
        address = pk.toString();
    }

    //FIXTHIS
    @When("I import the key")
    public void importKey() throws com.algorand.algosdk.kmd.client.ApiException{
        // ImportKeyRequest req = new ImportKeyRequest();
        // req.setWalletHandleToken(handle);
        throw new cucumber.api.PendingException();
    }

    @When("I get the private key")
    public void getSk() throws com.algorand.algosdk.kmd.client.ApiException, GeneralSecurityException{
        ExportKeyRequest req = new ExportKeyRequest();
        req.setAddress(pk.toString());
        req.setWalletHandleToken(handle);
        req.setWalletPassword(walletPswd);
        sk = kcl.exportKey(req).getPrivateKey();
        account = new Account(Arrays.copyOfRange(sk, 0, 32));
    }

    @Then("the private key should be equal to the exported private key")
    public void expSkEq() throws com.algorand.algosdk.kmd.client.ApiException {
        ExportKeyRequest req = new ExportKeyRequest();
        req.setAddress(pk.toString());
        req.setWalletHandleToken(handle);
        req.setWalletPassword(walletPswd);
        Assert.assertEquals(kcl.exportKey(req).getPrivateKey(), sk);
    }

    @Given("a kmd client")
    public void kClient() throws FileNotFoundException, IOException{
        String home = System.getProperty("user.home");
        String data_dir_path = home + "/node/network/Node/";
        data_dir_path += System.getenv("KMD_DIR") + "/";
        BufferedReader reader = new BufferedReader(new FileReader(data_dir_path + "kmd.token"));
        String kmdToken = reader.readLine();
        reader.close();
        reader = new BufferedReader(new FileReader(data_dir_path + "kmd.net"));
        String kmdAddress = reader.readLine();
        kmdClient = new KmdClient();
        kmdClient.setConnectTimeout(20000);
        kmdClient.setApiKey(kmdToken);
        kmdClient.setBasePath("http://" + kmdAddress);
        kcl = new KmdApi(kmdClient);

    }

    @Given("an algod client")
    public void aClient() throws FileNotFoundException, IOException{
        String home = System.getProperty("user.home");
        String data_dir_path = home + "/node/network/Node/";
        BufferedReader reader = new BufferedReader(new FileReader(data_dir_path + "algod.token"));
        String algodToken = reader.readLine();
        reader.close();
        reader = new BufferedReader(new FileReader(data_dir_path + "algod.net"));
        String algodAddress = reader.readLine();
        algodClient = new AlgodClient();
        algodClient.setConnectTimeout(20000);
        algodClient.setApiKey(algodToken);
        algodClient.setBasePath("http://" + algodAddress);
        acl = new AlgodApi(algodClient);

    }

    @Given("wallet information")
    public void walletInfo() throws com.algorand.algosdk.kmd.client.ApiException{
        walletName = "unencrypted-default-wallet";
        walletPswd = "";
        List<APIV1Wallet> wallets = kcl.listWallets().getWallets();
        for (APIV1Wallet w: wallets){
            if (w.getName().equals(walletName)){
                walletID = w.getId();
            }
        }
        InitWalletHandleTokenRequest tokenreq = new InitWalletHandleTokenRequest();
        tokenreq.setWalletId(walletID);
        tokenreq.setWalletPassword(walletPswd);
        handle = kcl.initWalletHandleToken(tokenreq).getWalletHandleToken();
        ListKeysRequest req = new ListKeysRequest();
        req.setWalletHandleToken(handle);
        accounts = kcl.listKeysInWallet(req).getAddresses();
    }

    @Given("default transaction with parameters {int} {string}")
    public void defaultTxn(int amt, String note) throws ApiException, NoSuchAlgorithmException{
        TransactionParams params = acl.transactionParams();
        lastRound = params.getLastRound();
        if (note.equals("none")){
            this.note = null;
        } else{
            this.note = Encoder.decodeFromBase64(note);
        }
        txn = new Transaction(
                    new Address(accounts.get(0)),
                    params.getFee(),
                    params.getLastRound(),
                    params.getLastRound().add(BigInteger.valueOf(1000)),
                    this.note,
                    BigInteger.valueOf(amt),
                    new Address(accounts.get(1)),
                    params.getGenesisID(),
                    new Digest(params.getGenesishashb64())
            );
        txn = Account.transactionWithSuggestedFeePerByte(txn, txn.fee);
        pk = new Address(accounts.get(0));
    }

    @Given("default multisig transaction with parameters {int} {string}")
    public void defaultMsigTxn(int amt, String note) throws ApiException, NoSuchAlgorithmException{
        TransactionParams params = acl.transactionParams();
        lastRound = params.getLastRound();
        if (note.equals("none")){
            this.note = null;
        } else{
            this.note = Encoder.decodeFromBase64(note);
        }
        Ed25519PublicKey[] addrlist = new Ed25519PublicKey[accounts.size()];
        for(int x = 0; x < accounts.size(); x++){
            addrlist[x] = new Ed25519PublicKey((new Address(accounts.get(x))).getBytes());
        }
        msig = new MultisigAddress(1, 1, Arrays.asList(addrlist));
        txn = new Transaction(
                    new Address(msig.toString()),
                    params.getFee(),
                    params.getLastRound(),
                    params.getLastRound().add(BigInteger.valueOf(1000)),
                    this.note,
                    BigInteger.valueOf(amt),
                    new Address(accounts.get(1)),
                    params.getGenesisID(),
                    new Digest(params.getGenesishashb64())
            );
        txn = Account.transactionWithSuggestedFeePerByte(txn, txn.fee);
        pk = new Address(accounts.get(0));
    }

    @When("I send the transaction")
    public void sendTxn() throws JsonProcessingException, ApiException{
        txid = acl.rawTransaction(Encoder.encodeToMsgPack(stx)).getTxId();
    }

    @When("I send the multisig transaction")
    public void sendMsigTxn() throws JsonProcessingException, ApiException{
        try{
            acl.rawTransaction(Encoder.encodeToMsgPack(stx));
        } catch(Exception e) {
            err = true;
        }
    }

    @Then("the transaction should go through")
    public void checkTxn() throws ApiException, InterruptedException{
        Thread.sleep(8000);
        acl.waitForBlock(lastRound.add(BigInteger.valueOf(2)));
        Assert.assertTrue(acl.transactionInformation(pk.toString(), txid).getFrom().equals(pk.toString()));
        Assert.assertTrue(acl.transaction(txid).getFrom().equals(pk.toString()));
    }

    @Then("the transaction should not go through")
    public void txnFail(){
        Assert.assertTrue(err);
    }

    @When("I sign the transaction with kmd")
    public void signKmd() throws JsonProcessingException, com.algorand.algosdk.kmd.client.ApiException{
        SignTransactionRequest req = new SignTransactionRequest();
        req.setTransaction(Encoder.encodeToMsgPack(txn));
        req.setWalletHandleToken(handle);
        req.setWalletPassword(walletPswd);
        stxBytes = kcl.signTransaction(req).getSignedTransaction();
    }
    @Then("the signed transaction should equal the kmd signed transaction")
    public void signBothEqual() throws JsonProcessingException {
        Assert.assertEquals(Encoder.encodeToBase64(stxBytes), Encoder.encodeToBase64(Encoder.encodeToMsgPack(stx)));
    }

    // FIXTHIS
    @When("I sign the multisig transaction with kmd")
    public void signMsigKmd() throws JsonProcessingException, com.algorand.algosdk.kmd.client.ApiException{
        // may need to import account first
        // SignMultisigRequest req = new SignMultisigRequest();
        // req.setTransaction(Encoder.encodeToMsgPack(txn));
        // req.setWalletHandleToken(handle);
        // req.setWalletPassword(walletPswd);
        throw new cucumber.api.PendingException();
    }
    @Then("the multisig transaction should equal the kmd signed multisig transaction")
    public void signMsigBothEqual() throws JsonProcessingException {
        Assert.assertEquals(Encoder.encodeToBase64(stxBytes), Encoder.encodeToBase64(Encoder.encodeToMsgPack(stx)));
    }

    @When("I read a transaction from file")
    public void readTxn() throws IOException {
        String path = System.getProperty("user.dir");
        Path p = Paths.get(path);
        path = p.getParent() + "/raw.tx";
        FileInputStream inputStream = new FileInputStream(path);
        File file = new File(path);
        byte[] data = new byte[(int) file.length()];
        inputStream.read(data);
        stx = Encoder.decodeFromMsgPack(data, SignedTransaction.class);
        inputStream.close();
    }

    @When("I write the transaction to file")
    public void writeTxn() throws JsonProcessingException, IOException{
        String path = System.getProperty("user.dir");
        Path p = Paths.get(path);
        path = p.getParent() + "/raw.tx";
        byte[] data = Encoder.encodeToMsgPack(stx);
        FileOutputStream out = new FileOutputStream(path);
        out.write(data);
        out.close();
    }

    @Then("the transaction should still be the same")
    public void checkEnc() throws IOException{
        String path = System.getProperty("user.dir");
        Path p = Paths.get(path);
        path = p.getParent() + "/raw.tx";
        FileInputStream inputStream = new FileInputStream(path);
        File file = new File(path);
        byte[] data = new byte[(int) file.length()];
        inputStream.read(data);
        SignedTransaction stxnew = Encoder.decodeFromMsgPack(data, SignedTransaction.class);
        inputStream.close();

        path = p.getParent() + "/old.tx";
        inputStream = new FileInputStream(path);
        file = new File(path);
        data = new byte[(int) file.length()];
        inputStream.read(data);
        SignedTransaction stxold = Encoder.decodeFromMsgPack(data, SignedTransaction.class);
        inputStream.close();

        Assert.assertEquals(stxold, stxnew);

    }

    @Then("I do my part")
    public void signSaveTxn() throws IOException, JsonProcessingException, NoSuchAlgorithmException, com.algorand.algosdk.kmd.client.ApiException, Exception{
        String path = System.getProperty("user.dir");
        Path p = Paths.get(path);
        path = p.getParent() + "/txn.tx";
        FileInputStream inputStream = new FileInputStream(path);
        File file = new File(path);
        byte[] data = new byte[(int) file.length()];
        inputStream.read(data);
        inputStream.close();

        txn = Encoder.decodeFromMsgPack(data, Transaction.class);
        ExportKeyRequest req = new ExportKeyRequest();
        req.setAddress(txn.sender.toString());
        req.setWalletHandleToken(handle);
        req.setWalletPassword(walletPswd);
        sk = kcl.exportKey(req).getPrivateKey();
        account = new Account(Arrays.copyOfRange(sk, 0, 32));

        stx = account.signTransaction(txn);
        data = Encoder.encodeToMsgPack(stx);
        FileOutputStream out = new FileOutputStream(path);
        out.write(data);
        out.close();
    }

    @Then("the node should be healthy")
    public void nodeHealth() throws ApiException{
        acl.healthCheck();
    }

    @When("I get the ledger supply")
    public void getLedger() throws ApiException{
        supply = acl.getSupply();
    }

    @Then("the ledger supply should tell me the total money")
    public void checkLedger() {
        Assert.assertTrue(supply.getTotalMoney() instanceof BigInteger);
    }

    @Then("I get transactions by address and round")
    public void txnsByAddrRound() throws ApiException{
        Assert.assertTrue(acl.transactions(accounts.get(0), BigInteger.valueOf(1), acl.getStatus().getLastRound(), null, null, BigInteger.valueOf(10)).getTransactions() instanceof List<?>);
    }

    @Then("I get transactions by address only")
    public void txnsByAddrOnly() throws ApiException{
        Assert.assertTrue(acl.transactions(accounts.get(0), null, null, null, null, BigInteger.valueOf(10)).getTransactions() instanceof List<?>);
    }

    @Then("I get transactions by address and date")
    public void txnsByAddrDate() throws ApiException{
        Assert.assertTrue(acl.transactions(accounts.get(0), null, null, LocalDate.now(), LocalDate.now(), BigInteger.valueOf(10)).getTransactions() instanceof List<?>);
    }

    @Then("I get pending transactions")
    public void pendingTxns() throws ApiException{
        Assert.assertTrue(acl.getPendingTransactions(BigInteger.valueOf(10)).getTruncatedTxns() instanceof TransactionList);
    }

    @When("I get the suggested params")
    public void suggestedParams() throws ApiException{
        paramsFee = acl.transactionParams().getFee();
    }

    @When("I get the suggested fee")
    public void suggestedFee() throws ApiException {
        fee = acl.suggestedFee().getFee();
    }

    @Then("the fee in the suggested params should equal the suggested fee")
    public void checkSuggested() {
        Assert.assertTrue(paramsFee.equals(fee));
    }

    @When("I create a bid")
    public void createBid() throws NoSuchAlgorithmException {
        account = new Account();
        pk = account.getAddress();
        address = pk.toString();
        bid = new Bid(pk, pk, BigInteger.valueOf(1L), BigInteger.valueOf(2L), BigInteger.valueOf(3L), BigInteger.valueOf(4L));
    }

    @When("I encode and decode the bid")
    public void encDecBid() throws JsonProcessingException, IOException{
        sbid = Encoder.decodeFromMsgPack(Encoder.encodeToMsgPack(sbid), SignedBid.class);
    }

    @When("I sign the bid")
    public void signBid() throws NoSuchAlgorithmException{
        sbid = account.signBid(bid);
        oldBid = account.signBid(bid);
    }

    @Then("the bid should still be the same")
    public void checkBid() {
        Assert.assertTrue(sbid.equals(oldBid));
    }

    @When("I decode the address")
    public void decAddr() throws NoSuchAlgorithmException{
        pk = new Address(address);
        oldAddr = address;
    }

    @When("I encode the address")
    public void encAddr() {
        address = pk.toString();
    }

    @Then("the address should still be the same")
    public void checkAddr() {
        Assert.assertEquals(address, oldAddr);
    }

    @When("I convert the private key back to a mnemonic")
    public void skToMn() {
        mnemonic = account.toMnemonic();
    }

    @Then("the mnemonic should still be the same as {string}")
    public void checkMn(String mn) {
        Assert.assertEquals(mn, mnemonic);
    }

    @Given("mnemonic for master derivation key {string}")
    public void mnforMdk(String mn) throws GeneralSecurityException {
        mdk = Mnemonic.toKey(mn);
    }

    @When("I convert the master derivation key back to a mnemonic")
    public void mdkToMn() {
        mnemonic = Mnemonic.fromKey(mdk);
    }

    @When("I create the flat fee payment transaction")
    public void createPaytxnFlat() throws NoSuchAlgorithmException{
        txn = new Transaction(
                    pk,
                    fee,
                    fv,
                    lv,
                    note,
                    gen,
                    gh,
                    amt,
                    to,
                    close
            );    
    }

    @Given("encoded multisig transaction {string}")
    public void encMsigTxn(String encTxn) throws IOException {
        stx = Encoder.decodeFromMsgPack(Encoder.decodeFromBase64(encTxn), SignedTransaction.class);
        Ed25519PublicKey[] addrlist = new Ed25519PublicKey[stx.mSig.subsigs.size()];
        for(int x = 0; x < addrlist.length; x++){
            addrlist[x] = stx.mSig.subsigs.get(x).key;
        }
        msig = new MultisigAddress(stx.mSig.version, stx.mSig.threshold, Arrays.asList(addrlist));
    }

    @When("I append a signature to the multisig transaction")
    public void appendMsig() throws NoSuchAlgorithmException {
        stx = account.appendMultisigTransaction(msig, stx);
    }

    @Given("encoded multisig transactions {string}")
    public void encMsigTxns(String encTxns) throws IOException {
        String[] txnArray = encTxns.split(" ");
        stxs = new SignedTransaction[txnArray.length];
        for (int t = 0; t < txnArray.length; t++){
            stxs[t] = Encoder.decodeFromMsgPack(Encoder.decodeFromBase64(txnArray[t]), SignedTransaction.class);
        }
    }

    @When("I merge the multisig transactions")
    public void mergeMsig() {
        stx = Account.mergeMultisigTransactions(stxs);
    }

    @When("I convert {long} microalgos to algos and back")
    public void microToAlgo(long ma) {
        microalgos = BigInteger.valueOf(ma);
        BigDecimal algos = AlgoConverter.toAlgos(microalgos);
        microalgos = AlgoConverter.toMicroAlgos(algos);
    }

    @Then("it should still be the same amount of microalgos {long}")
    public void checkMicro(long ma) {
        Assert.assertTrue(microalgos.equals(BigInteger.valueOf(ma)));
    }

    @Then("I get account information")
    public void accInfo() throws ApiException {
        acl.accountInformation(accounts.get(0));
    }

    @When("I get the node health")
    public void i_get_the_node_health() throws ApiException {
       acl.healthCheck();
    }

    @When("I get recent transactions")
    public void i_get_recent_transactions() throws ApiException {
        Assert.assertTrue(acl.transactions(accounts.get(0), null, null, null, null, BigInteger.valueOf(0)).getTransactions() instanceof List<?>);
    }

    @When("I get recent transactions, limited by count {int}")
    public void i_get_recent_transactions_limited_by_count(Integer cnt) throws ApiException {
        Assert.assertTrue(acl.transactions(accounts.get(0), null, null, null, null, BigInteger.valueOf(cnt)).getTransactions() instanceof List<?>);

    }

    @When("I get recent transactions limited by first round {int} and last round {int}")
    public void i_get_recent_transactions_limited_by_first_round_and_last_round(Integer first, Integer last) throws ApiException {
        Assert.assertTrue(acl.transactions(accounts.get(0), BigInteger.valueOf(first), BigInteger.valueOf(last), null, null, BigInteger.valueOf(10)).getTransactions() instanceof List<?>);
    }

    @Then("I can get transaction information using the TXID")
    public void i_can_get_transaction_information_using_the_TXID() throws ApiException {
        Assert.assertTrue(acl.transactionInformation(pk.toString(), txid).getFrom().equals(pk.toString()));
    }

    @When("I make a new account")
    public void i_make_a_new_account() throws NoSuchAlgorithmException {
        account = new Account();
        pk = account.getAddress();
        address = pk.toString();
    }

    @Then("I get account information using the new account")
    public void i_get_account_information_using_the_new_account() throws ApiException {
        acl.accountInformation(address);
    }

    @When("I create a change online status transaction using parameters {int} {int} {int} {string} {string} {int} {string}")
    public void i_create_a_change_online_status_transaction_using_parameters(Integer int1, Integer int2, Integer int3, String string, String string2, Integer int4, String string3) {
        // Write code here that turns the phrase above into concrete actions
        throw new cucumber.api.PendingException();
    }

    @Then("the status change transaction should equal the golden {string}")
    public void the_status_change_transaction_should_equal_the_golden(String string) {
        // Write code here that turns the phrase above into concrete actions
        throw new cucumber.api.PendingException();
    }
}
