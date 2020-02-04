package java_cucumber;

import com.algorand.algosdk.account.Account;
import com.algorand.algosdk.algod.client.ApiException;
import com.algorand.algosdk.crypto.Digest;
import com.algorand.algosdk.crypto.LogicsigSignature;
import com.algorand.algosdk.kmd.client.model.SignTransactionRequest;
import com.algorand.algosdk.logic.Logic;
import com.algorand.algosdk.templates.ContractTemplate;
import com.algorand.algosdk.templates.HTLC;
import com.algorand.algosdk.templates.Split;
import com.algorand.algosdk.transaction.SignedTransaction;
import com.algorand.algosdk.transaction.Transaction;
import com.algorand.algosdk.util.Digester;
import com.algorand.algosdk.util.Encoder;
import com.fasterxml.jackson.core.JsonProcessingException;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;

import java.io.IOException;
import java.math.BigInteger;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;

public class TemplateDefs {
    Stepdefs base;

    ContractTemplate contract;
    String htlcPreImage;
    Long contractFundAmount;


    public TemplateDefs(Stepdefs base) {
        this.base = base;
    }

    @Given("a split contract with ratio {int} to {int} and minimum payment {int}")
    public void a_split_contract_with_ratio_to_and_minimum_payment(Integer ratn, Integer ratd, Integer minPay) throws ApiException, NoSuchAlgorithmException {
        base.getParams();

        contract = Split.MakeSplit(
                base.getAddress(0),
                base.getAddress(1),
                base.getAddress(2),
                ratn,
                ratd,
                base.params.getLastRound().add(BigInteger.valueOf(1000)).intValue(),
                minPay,
                2000);
        contractFundAmount = 100000000L;
    }

    @When("I fund the contract account")
    public void i_fund_the_contract_account() throws JsonProcessingException, com.algorand.algosdk.kmd.client.ApiException, ApiException {
        base.getParams();

        Transaction txn = new Transaction(
                base.getAddress(0),
                contract.address,
                contractFundAmount,
                base.params.getLastRound().longValue(),
                base.params.getLastRound().add(BigInteger.valueOf(1000)).longValue(),
                "",
                new Digest(base.params.getGenesishashb64()));

        SignTransactionRequest req = new SignTransactionRequest();
        req.setTransaction(Encoder.encodeToMsgPack(txn));
        req.setWalletHandleToken(base.handle);
        req.setWalletPassword(base.walletPswd);
        byte[] stx = base.kcl.signTransaction(req).getSignedTransaction();
        base.txid = base.acl.rawTransaction(stx).getTxId();
    }

    @When("I send the split transactions")
    public void i_send_the_split_transactions() throws IOException, NoSuchAlgorithmException, ApiException {
        base.getParams();

        // Read inputs to compute a valid split.
        Logic.ProgramData data = Logic.readProgram(contract.program, null);
        int ratd = data.intBlock.get(5);
        int ratn = data.intBlock.get(6);
        int minTrade = data.intBlock.get(7);
        int amt1 = minTrade * ratn;
        int amt2 = minTrade * ratd;

        byte[] transactions = Split.GetSendFundsTransaction(
                contract,
                amt1,
                amt2,
                base.params.getLastRound().intValue(),
                base.params.getLastRound().add(BigInteger.valueOf(500)).intValue(),
                1,
                new Digest(base.params.getGenesishashb64()));

        base.pk = contract.address;
        base.txid = base.acl.rawTransaction(transactions).getTxId();
    }

    @Given("an HTLC contract with hash preimage {string}")
    public void an_HTLC_contract_with_hash_preimage(String string) throws NoSuchAlgorithmException {
        byte[] hashImage = Digester.digest(string.getBytes());

        htlcPreImage = Encoder.encodeToBase64(hashImage);

        contract = HTLC.MakeHTLC(
                base.getAddress(0),
                base.getAddress(1),
                "sha256",
                htlcPreImage,
                100,
                1000000);
        contractFundAmount = 100000000L;
    }

    @When("I claim the algos")
    public void i_claim_the_algos() throws IOException, ApiException, NoSuchAlgorithmException {
        ArrayList<byte[]> args = new ArrayList<>();
        //args.add(Encoder.decodeFromBase64(htlcPreImage));
        args.add(htlcPreImage.getBytes());
        LogicsigSignature lsig = new LogicsigSignature(contract.program, args);
        base.txn = new Transaction(
                contract.address,
                base.getAddress(0),
                BigInteger.valueOf(0),
                BigInteger.valueOf(12345),
                base.params.getLastRound(),
                base.params.getLastRound().add(BigInteger.valueOf(1000)),
                "",
                new Digest(base.params.getGenesishashb64()));
        Account.setFeeByFeePerByte(base.txn, BigInteger.valueOf(30));
        base.stx = new SignedTransaction(base.txn, lsig);
        base.pk = contract.address;
        System.out.println(Encoder.encodeToBase64(Encoder.encodeToMsgPack(base.stx)));
        base.txid = base.acl.rawTransaction(Encoder.encodeToMsgPack(base.stx)).getTxId();
    }

}
