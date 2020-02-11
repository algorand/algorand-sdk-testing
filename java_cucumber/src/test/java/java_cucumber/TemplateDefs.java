package java_cucumber;

import com.algorand.algosdk.algod.client.ApiException;
import com.algorand.algosdk.crypto.Digest;
import com.algorand.algosdk.kmd.client.model.SignTransactionRequest;
import com.algorand.algosdk.templates.*;
import com.algorand.algosdk.transaction.SignedTransaction;
import com.algorand.algosdk.transaction.Transaction;
import com.algorand.algosdk.util.Encoder;
import com.fasterxml.jackson.core.JsonProcessingException;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;

import java.io.IOException;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class TemplateDefs {
    Stepdefs base;

    ContractTemplate contract;

    Integer splitNumerator;
    Integer splitDenominator;
    Integer splitMinPay;

    String htlcPreImage;

    Integer periodicPayWindow;
    Integer periodicPayPeriod;

    Integer limitRatN;
    Integer limitRatD;
    Integer limitMinTrade;

    Long contractFundAmount = 100000000L;


    public TemplateDefs(Stepdefs base) {
        this.base = base;
    }

    // Shared across contracts.
    @When("I fund the contract account")
    public void i_fund_the_contract_account() throws JsonProcessingException, com.algorand.algosdk.kmd.client.ApiException, ApiException, InterruptedException {
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

        // the transaction should go through
        base.checkTxn();
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
        splitNumerator = ratn;
        splitDenominator = ratd;
        splitMinPay = minPay;
        contractFundAmount = Math.round(2.0 * Double.valueOf(minPay) * (Double.valueOf(ratn + ratd) / Double.valueOf(ratn)));
    }

    @When("I send the split transactions")
    public void i_send_the_split_transactions() throws IOException, NoSuchAlgorithmException, ApiException {
        base.getParams();

        int amt1 = splitMinPay * splitNumerator;
        int amt2 = splitMinPay * splitDenominator;

        byte[] transactions = Split.GetSplitTransactions(
                contract,
                amt1 + amt2,
                base.params.getLastRound().intValue(),
                base.params.getLastRound().add(BigInteger.valueOf(500)).intValue(),
                1,
                new Digest(base.params.getGenesishashb64()));

        base.pk = contract.address;
        base.txid = base.acl.rawTransaction(transactions).getTxId();
    }

    @Given("an HTLC contract with hash preimage {string}")
    public void an_HTLC_contract_with_hash_preimage(String preImage) throws NoSuchAlgorithmException {
        htlcPreImage = preImage;
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] computedImage = digest.digest(preImage.getBytes());

        contract = HTLC.MakeHTLC(
                base.getAddress(0),
                base.getAddress(1),
                "sha256",
                Encoder.encodeToBase64(computedImage),
                100,
                1000000);
        contractFundAmount = 1000000L;
    }

    @When("I claim the algos")
    public void i_claim_the_algos() throws IOException, ApiException, NoSuchAlgorithmException {
        base.getParams();

        SignedTransaction stx = HTLC.GetHTLCTransaction(
                contract,
                Encoder.encodeToBase64(htlcPreImage.getBytes()),
                base.params.getLastRound().intValue(),
                base.params.getLastRound().intValue() + 1000,
                new Digest(base.params.getGenesishashb64()),
                0);

        base.pk = contract.address;
        base.txid = base.acl.rawTransaction(Encoder.encodeToMsgPack(stx)).getTxId();
    }

    @Given("a periodic payment contract with withdrawing window {int} and period {int}")
    public void a_periodic_payment_contract_with_withdrawing_window_and_period(Integer window, Integer period) throws NoSuchAlgorithmException {
        base.getParams();

        contract = PeriodicPayment.MakePeriodicPayment(
                base.getAddress(0),
                12345,
                window,
                period,
                2000,
                base.params.getLastRound().intValue() + 1000);

        periodicPayWindow = window;
        periodicPayPeriod = period;
    }

    @When("I claim the periodic payment")
    public void i_claim_the_periodic_payment() throws IOException, NoSuchAlgorithmException, ApiException {
        base.getParams();

        BigInteger txnFirstValid = base.params.getLastRound();
        BigInteger remainder = txnFirstValid.mod(BigInteger.valueOf(periodicPayPeriod));
        txnFirstValid = txnFirstValid.add(remainder);
        SignedTransaction stx = PeriodicPayment.MakeWithdrawalTransaction(
                contract,
                txnFirstValid.intValue(),
                new Digest(base.params.getGenesishashb64()),
                base.params.getFee().intValue());
        base.pk = contract.address;
        base.txid = base.acl.rawTransaction(Encoder.encodeToMsgPack(stx)).getTxId();
    }

    @Given("a limit order contract with parameters {int} {int} {int}")
    public void a_limit_order_contract_with_parameters(Integer ratn, Integer ratd, Integer minTrade) throws NoSuchAlgorithmException, com.algorand.algosdk.kmd.client.ApiException {
        base.getParams();

        limitRatN = ratn;
        limitRatD = ratd;
        limitMinTrade = minTrade;
        contract = LimitOrder.MakeLimitOrder(
                base.getAddress(1),
                base.assetID.intValue(),
                ratn,
                ratd,
                base.params.getLastRound().intValue() + 1000,
                minTrade,
                2000);
        contractFundAmount = 2L * minTrade * 100000;

        base.setExportKey(base.getAddress(0));
    }

    @When("I swap assets for algos")
    public void i_swap_assets_for_algos() throws IOException, NoSuchAlgorithmException, ApiException {
        base.getParams();

        byte[] txns = LimitOrder.MakeSwapAssetsTransaction(
                contract,
                limitMinTrade * limitRatN,
                limitMinTrade * limitRatD,
                base.account,
                base.params.getLastRound().intValue(),
                base.params.getLastRound().intValue() + 3,
                new Digest(base.params.getGenesishashb64()),
                0);
       base.pk = contract.address;
       //base.pk = base.account.getAddress();
       base.txid = base.acl.rawTransaction(txns).getTxId();
    }
}
