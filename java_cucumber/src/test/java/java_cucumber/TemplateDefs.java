package java_cucumber;

import com.algorand.algosdk.algod.client.ApiException;
import com.algorand.algosdk.algod.client.model.TransactionID;
import com.algorand.algosdk.algod.client.model.TransactionParams;
import com.algorand.algosdk.crypto.Address;
import com.algorand.algosdk.crypto.Digest;
import com.algorand.algosdk.kmd.client.model.SignTransactionRequest;
import com.algorand.algosdk.logic.Logic;
import com.algorand.algosdk.templates.ContractTemplate;
import com.algorand.algosdk.templates.Split;
import com.algorand.algosdk.transaction.Transaction;
import com.algorand.algosdk.util.Encoder;
import com.fasterxml.jackson.core.JsonProcessingException;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;

import java.io.IOException;
import java.math.BigInteger;
import java.security.NoSuchAlgorithmException;

public class TemplateDefs {
    Stepdefs base;

    ContractTemplate split;


    public TemplateDefs(Stepdefs base) {
        this.base = base;
    }

    @Given("a split contract with ratio {int} to {int} and minimum payment {int}")
    public void a_split_contract_with_ratio_to_and_minimum_payment(Integer ratn, Integer ratd, Integer minPay) throws ApiException, NoSuchAlgorithmException {
        base.getParams();

        split = Split.MakeSplit(
                base.getAddress(0),
                base.getAddress(1),
                base.getAddress(2),
                ratn,
                ratd,
                base.params.getLastRound().add(BigInteger.valueOf(1000)).intValue(),
                minPay,
                2000);
    }

    @When("I fund the contract account")
    public void i_fund_the_contract_account() throws JsonProcessingException, com.algorand.algosdk.kmd.client.ApiException, ApiException {
        base.getParams();

        Transaction txn = new Transaction(
                base.getAddress(0),
                split.address,
                10000000,
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
        Logic.ProgramData data = Logic.readProgram(split.program, null);
        int ratd = data.intBlock.get(5);
        int ratn = data.intBlock.get(6);
        int minTrade = data.intBlock.get(7);
        int amt1 = minTrade * ratn;
        int amt2 = minTrade * ratd;

        byte[] transactions = Split.GetSendFundsTransaction(
                split,
                amt1,
                amt2,
                base.params.getLastRound().intValue(),
                base.params.getLastRound().add(BigInteger.valueOf(500)).intValue(),
                1,
                new Digest(base.params.getGenesishashb64()));

        base.pk = split.address;
        base.txid = base.acl.rawTransaction(transactions).getTxId();
        base.lastRound = base.params.getLastRound();
    }
}
