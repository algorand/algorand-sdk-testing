package main

import (
	"bytes"
	"encoding/base32"
	"encoding/base64"
	"encoding/gob"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"testing"
	"time"

	"path/filepath"

	"github.com/DATA-DOG/godog"
	"github.com/DATA-DOG/godog/colors"
	"github.com/algorand/go-algorand-sdk/auction"
	"github.com/algorand/go-algorand-sdk/client/algod"
	"github.com/algorand/go-algorand-sdk/client/algod/models"
	"github.com/algorand/go-algorand-sdk/client/kmd"
	"github.com/algorand/go-algorand-sdk/crypto"
	"github.com/algorand/go-algorand-sdk/encoding/msgpack"
	"github.com/algorand/go-algorand-sdk/mnemonic"
	"github.com/algorand/go-algorand-sdk/transaction"
	"github.com/algorand/go-algorand-sdk/types"
)

var txn types.Transaction
var stx []byte
var stxKmd []byte
var stxObj types.SignedTxn
var txid string
var account crypto.Account
var note []byte
var fee uint64
var fv uint64
var lv uint64
var to string
var gh []byte
var close string
var amt uint64
var gen string
var a types.Address
var msig crypto.MultisigAccount
var msigsig types.MultisigSig
var kcl kmd.Client
var acl algod.Client
var walletName string
var walletPswd string
var walletID string
var handle string
var versions []string
var status models.NodeStatus
var statusAfter models.NodeStatus
var msigExp kmd.ExportMultisigResponse
var pk string
var accounts []string
var e bool
var lastRound uint64
var sugParams models.TransactionParams
var sugFee models.TransactionFee
var bid types.Bid
var sbid types.NoteField
var oldBid types.NoteField
var oldPk string
var newMn string
var mdk types.MasterDerivationKey
var microalgos types.MicroAlgos
var bytetxs [][]byte
var votekey string
var selkey string
var votefst uint64
var votelst uint64
var votekd uint64
var num string

var assetTestFixture struct {
	Creator               string
	AssetIndex            uint64
	AssetName             string
	AssetUnitName         string
	Params                types.AssetParams
	QueriedParams         models.AssetParams
	LastTransactionIssued types.Transaction
}

var opt = godog.Options{
	Output: colors.Colored(os.Stdout),
	Format: "progress", // can define default values
}

func init() {
	godog.BindFlags("godog.", flag.CommandLine, &opt)
}

func TestMain(m *testing.M) {
	flag.Parse()
	opt.Paths = flag.Args()

	status := godog.RunWithOptions("godogs", func(s *godog.Suite) {
		FeatureContext(s)
	}, opt)

	if st := m.Run(); st > status {
		status = st
	}
	os.Exit(status)
}

func FeatureContext(s *godog.Suite) {
	s.Step("I create a wallet", createWallet)
	s.Step("the wallet should exist", walletExist)
	s.Step("I get the wallet handle", getHandle)
	s.Step("I can get the master derivation key", getMdk)
	s.Step("I rename the wallet", renameWallet)
	s.Step("I can still get the wallet information with the same handle", getWalletInfo)
	s.Step("I renew the wallet handle", renewHandle)
	s.Step("I release the wallet handle", releaseHandle)
	s.Step("the wallet handle should not work", tryHandle)
	s.Step(`payment transaction parameters (\d+) (\d+) (\d+) "([^"]*)" "([^"]*)" "([^"]*)" (\d+) "([^"]*)" "([^"]*)"`, txnParams)
	s.Step(`mnemonic for private key "([^"]*)"`, mnForSk)
	s.Step("I create the payment transaction", createTxn)
	s.Step(`multisig addresses "([^"]*)"`, msigAddresses)
	s.Step("I create the multisig payment transaction", createMsigTxn)
	s.Step("I sign the multisig transaction with the private key", signMsigTxn)
	s.Step("I sign the transaction with the private key", signTxn)
	s.Step(`the signed transaction should equal the golden "([^"]*)"`, equalGolden)
	s.Step(`the multisig transaction should equal the golden "([^"]*)"`, equalMsigGolden)
	s.Step(`the multisig address should equal the golden "([^"]*)"`, equalMsigAddrGolden)
	s.Step("I get versions with algod", aclV)
	s.Step("v1 should be in the versions", v1InVersions)
	s.Step("I get versions with kmd", kclV)
	s.Step("I get the status", getStatus)
	s.Step(`^I get status after this block`, statusAfterBlock)
	s.Step("I can get the block info", block)
	s.Step("I import the multisig", importMsig)
	s.Step("the multisig should be in the wallet", msigInWallet)
	s.Step("I export the multisig", expMsig)
	s.Step("the multisig should equal the exported multisig", msigEq)
	s.Step("I delete the multisig", deleteMsig)
	s.Step("the multisig should not be in the wallet", msigNotInWallet)
	s.Step("I generate a key using kmd", genKeyKmd)
	s.Step("the key should be in the wallet", keyInWallet)
	s.Step("I delete the key", deleteKey)
	s.Step("the key should not be in the wallet", keyNotInWallet)
	s.Step("I generate a key", genKey)
	s.Step("I import the key", importKey)
	s.Step("the private key should be equal to the exported private key", skEqExport)
	s.Step("a kmd client", kmdClient)
	s.Step("an algod client", algodClient)
	s.Step("wallet information", walletInfo)
	s.Step(`default transaction with parameters (\d+) "([^"]*)"`, defaultTxn)
	s.Step(`default multisig transaction with parameters (\d+) "([^"]*)"`, defaultMsigTxn)
	s.Step("I get the private key", getSk)
	s.Step("I send the transaction", sendTxn)
	s.Step("I send the multisig transaction", sendMsigTxn)
	s.Step("the transaction should go through", checkTxn)
	s.Step("the transaction should not go through", txnFail)
	s.Step("I sign the transaction with kmd", signKmd)
	s.Step("the signed transaction should equal the kmd signed transaction", signBothEqual)
	s.Step("I sign the multisig transaction with kmd", signMsigKmd)
	s.Step("the multisig transaction should equal the kmd signed multisig transaction", signMsigBothEqual)
	s.Step(`I read a transaction "([^"]*)" from file "([^"]*)"`, readTxn)
	s.Step("I write the transaction to file", writeTxn)
	s.Step("the transaction should still be the same", checkEnc)
	s.Step("I do my part", createSaveTxn)
	s.Step(`^the node should be healthy`, nodeHealth)
	s.Step(`^I get the ledger supply`, ledger)
	s.Step(`^I get transactions by address and round`, txnsByAddrRound)
	s.Step(`^I get pending transactions`, txnsPending)
	s.Step(`^I get the suggested params`, suggestedParams)
	s.Step(`^I get the suggested fee`, suggestedFee)
	s.Step(`^the fee in the suggested params should equal the suggested fee`, checkSuggested)
	s.Step(`^I create a bid`, createBid)
	s.Step(`^I encode and decode the bid`, encDecBid)
	s.Step(`^the bid should still be the same`, checkBid)
	s.Step(`^I decode the address`, decAddr)
	s.Step(`^I encode the address`, encAddr)
	s.Step(`^the address should still be the same`, checkAddr)
	s.Step(`^I convert the private key back to a mnemonic`, skToMn)
	s.Step(`^the mnemonic should still be the same as "([^"]*)"`, checkMn)
	s.Step(`^mnemonic for master derivation key "([^"]*)"`, mnToMdk)
	s.Step(`^I convert the master derivation key back to a mnemonic`, mdkToMn)
	s.Step(`^I create the flat fee payment transaction`, createTxnFlat)
	s.Step(`^encoded multisig transaction "([^"]*)"`, encMsigTxn)
	s.Step(`^I append a signature to the multisig transaction`, appendMsig)
	s.Step(`^encoded multisig transactions "([^"]*)"`, encMtxs)
	s.Step(`^I merge the multisig transactions`, mergeMsig)
	s.Step(`^I convert (\d+) microalgos to algos and back`, microToAlgos)
	s.Step(`^it should still be the same amount of microalgos (\d+)`, checkAlgos)
	s.Step(`I get account information`, accInfo)
	s.Step("I sign the bid", signBid)
	s.Step("I get transactions by address only", txnsByAddrOnly)
	s.Step("I get transactions by address and date", txnsByAddrDate)
	s.Step(`key registration transaction parameters (\d+) (\d+) (\d+) "([^"]*)" "([^"]*)" "([^"]*)" (\d+) (\d+) (\d+) "([^"]*)" "([^"]*)`, keyregTxnParams)
	s.Step("I create the key registration transaction", createKeyregTxn)
	s.Step(`^I get recent transactions, limited by (\d+) transactions$`, getTxnsByCount)
	s.Step(`^I can get account information`, newAccInfo)
	s.Step(`^I can get the transaction by ID$`, txnbyID)
	s.Step("asset test fixture", createAssetTestFixture)
	s.Step(`^default asset creation transaction with total issuance (\d+)$`, defaultAssetCreateTxn)
	s.Step(`^I get the asset info$`, getAssetInfo)
	s.Step(`^the asset info should match the creation transaction$`, matchAssetInfoToCreationTxn)

	s.BeforeScenario(func(interface{}) {
		stxObj = types.SignedTxn{}
	})
}

func createWallet() error {
	walletName = "Walletgo"
	walletPswd = ""
	resp, err := kcl.CreateWallet(walletName, walletPswd, "sqlite", types.MasterDerivationKey{})
	if err != nil {
		return err
	}
	walletID = resp.Wallet.ID
	return nil
}

func walletExist() error {
	wallets, err := kcl.ListWallets()
	if err != nil {
		return err
	}
	for _, w := range wallets.Wallets {
		if w.Name == walletName {
			return nil
		}
	}
	return fmt.Errorf("Wallet not found")
}

func getHandle() error {
	h, err := kcl.InitWalletHandle(walletID, walletPswd)
	if err != nil {
		return err
	}
	handle = h.WalletHandleToken
	return nil
}

func getMdk() error {
	_, err := kcl.ExportMasterDerivationKey(handle, walletPswd)
	return err
}

func renameWallet() error {
	walletName = "Walletgo_new"
	_, err := kcl.RenameWallet(walletID, walletPswd, walletName)
	return err
}

func getWalletInfo() error {
	resp, err := kcl.GetWallet(handle)
	if resp.WalletHandle.Wallet.Name != walletName {
		return fmt.Errorf("Wallet name not equal")
	}
	return err
}

func renewHandle() error {
	_, err := kcl.RenewWalletHandle(handle)
	return err
}

func releaseHandle() error {
	_, err := kcl.ReleaseWalletHandle(handle)
	return err
}

func tryHandle() error {
	_, err := kcl.RenewWalletHandle(handle)
	if err == nil {
		return fmt.Errorf("should be an error; handle was released")
	}
	return nil
}

func txnParams(ifee, ifv, ilv int, igh, ito, iclose string, iamt int, igen, inote string) error {
	var err error
	if inote != "none" {
		note, err = base64.StdEncoding.DecodeString(inote)
		if err != nil {
			return err
		}
	} else {
		note, err = base64.StdEncoding.DecodeString("")
		if err != nil {
			return err
		}
	}
	gh, err = base64.StdEncoding.DecodeString(igh)
	if err != nil {
		return err
	}
	to = ito
	fee = uint64(ifee)
	fv = uint64(ifv)
	lv = uint64(ilv)
	if iclose != "none" {
		close = iclose
	} else {
		close = ""
	}
	amt = uint64(iamt)
	if igen != "none" {
		gen = igen
	} else {
		gen = ""
	}
	if err != nil {
		return err
	}
	return nil
}

func mnForSk(mn string) error {
	sk, err := mnemonic.ToPrivateKey(mn)
	if err != nil {
		return err
	}
	account.PrivateKey = sk
	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)
	err = enc.Encode(sk.Public())
	if err != nil {
		return err
	}
	addr := buf.Bytes()[4:]

	n := copy(a[:], addr)
	if n != 32 {
		return fmt.Errorf("wrong address bytes length")
	}
	return err
}

func createTxn() error {
	var err error
	txn, err = transaction.MakePaymentTxn(a.String(), to, fee, amt, fv, lv, note, close, gen, gh)
	if err != nil {
		return err
	}
	return err
}

func msigAddresses(addresses string) error {
	var err error
	addrlist := strings.Fields(addresses)

	var addrStructs []types.Address
	for _, a := range addrlist {
		addr, err := types.DecodeAddress(a)
		if err != nil {
			return err
		}

		addrStructs = append(addrStructs, addr)
	}
	msig, err = crypto.MultisigAccountWithParams(1, 2, addrStructs)

	return err
}

func createMsigTxn() error {
	var err error

	msigaddr, _ := msig.Address()
	txn, err = transaction.MakePaymentTxn(msigaddr.String(), to, fee, amt, fv, lv, note, close, gen, gh)
	if err != nil {
		return err
	}
	return err

}

func signMsigTxn() error {
	var err error
	txid, stx, err = crypto.SignMultisigTransaction(account.PrivateKey, msig, txn)

	return err
}

func signTxn() error {
	var err error
	_, _ = fmt.Fprintf(os.Stderr, "\n signing transaction from %v with key relating to %v \n", txn.Sender, account.Address.String())
	txid, stx, err = crypto.SignTransaction(account.PrivateKey, txn)
	if err != nil {
		return err
	}
	return nil
}

func equalGolden(golden string) error {
	goldenDecoded, err := base64.StdEncoding.DecodeString(golden)
	if err != nil {
		return err
	}

	if !bytes.Equal(goldenDecoded, stx) {
		return fmt.Errorf(base64.StdEncoding.EncodeToString(stx))
	}
	return nil
}

func equalMsigAddrGolden(golden string) error {
	msigAddr, err := msig.Address()
	if err != nil {
		return err
	}
	if golden != msigAddr.String() {
		return fmt.Errorf("NOT EQUAL")
	}
	return nil
}

func equalMsigGolden(golden string) error {
	goldenDecoded, err := base64.StdEncoding.DecodeString(golden)
	if err != nil {
		return err
	}
	if !bytes.Equal(goldenDecoded, stx) {
		return fmt.Errorf("NOT EQUAL")
	}
	return nil
}

func aclV() error {
	v, err := acl.Versions()
	if err != nil {
		return err
	}
	versions = v.Versions
	return nil
}

func v1InVersions() error {
	for _, b := range versions {
		if b == "v1" {
			return nil
		}
	}
	return fmt.Errorf("v1 not found")
}

func kclV() error {
	v, err := kcl.Version()
	versions = v.Versions
	return err
}

func getStatus() error {
	var err error
	status, err = acl.Status()
	lastRound = status.LastRound
	return err
}

func statusAfterBlock() error {
	var err error
	statusAfter, err = acl.StatusAfterBlock(lastRound)
	if err != nil {
		return err
	}
	return nil
}

func block() error {
	_, err := acl.Block(status.LastRound)
	return err
}

func importMsig() error {
	_, err := kcl.ImportMultisig(handle, msig.Version, msig.Threshold, msig.Pks)
	return err
}

func msigInWallet() error {
	msigs, err := kcl.ListMultisig(handle)
	if err != nil {
		return err
	}
	addrs := msigs.Addresses
	for _, a := range addrs {
		addr, err := msig.Address()
		if err != nil {
			return err
		}
		if a == addr.String() {
			return nil
		}
	}
	return fmt.Errorf("msig not found")

}

func expMsig() error {
	addr, err := msig.Address()
	if err != nil {
		return err
	}
	msigExp, err = kcl.ExportMultisig(handle, walletPswd, addr.String())

	return err
}

func msigEq() error {
	eq := true

	if (msig.Pks == nil) != (msigExp.PKs == nil) {
		eq = false
	}

	if len(msig.Pks) != len(msigExp.PKs) {
		eq = false
	}

	for i := range msig.Pks {

		if !bytes.Equal(msig.Pks[i], msigExp.PKs[i]) {
			eq = false
		}
	}

	if !eq {
		return fmt.Errorf("exported msig not equal to original msig")
	}
	return nil
}

func deleteMsig() error {
	addr, err := msig.Address()
	kcl.DeleteMultisig(handle, walletPswd, addr.String())
	return err
}

func msigNotInWallet() error {
	msigs, err := kcl.ListMultisig(handle)
	if err != nil {
		return err
	}
	addrs := msigs.Addresses
	for _, a := range addrs {
		addr, err := msig.Address()
		if err != nil {
			return err
		}
		if a == addr.String() {
			return fmt.Errorf("msig found unexpectedly; should have been deleted")
		}
	}
	return nil

}

func genKeyKmd() error {
	p, err := kcl.GenerateKey(handle)
	if err != nil {
		return err
	}
	pk = p.Address
	return nil
}

func keyInWallet() error {
	resp, err := kcl.ListKeys(handle)
	if err != nil {
		return err
	}
	for _, a := range resp.Addresses {
		if pk == a {
			return nil
		}
	}
	return fmt.Errorf("key not found")
}

func deleteKey() error {
	_, err := kcl.DeleteKey(handle, walletPswd, pk)
	return err
}

func keyNotInWallet() error {
	resp, err := kcl.ListKeys(handle)
	if err != nil {
		return err
	}
	for _, a := range resp.Addresses {
		if pk == a {
			return fmt.Errorf("key found unexpectedly; should have been deleted")
		}
	}
	return nil
}

func genKey() error {
	account = crypto.GenerateAccount()
	a = account.Address
	pk = a.String()
	return nil
}

func importKey() error {
	_, err := kcl.ImportKey(handle, account.PrivateKey)
	return err
}

func skEqExport() error {
	exp, err := kcl.ExportKey(handle, walletPswd, a.String())
	if err != nil {
		return err
	}
	kcl.DeleteKey(handle, walletPswd, a.String())
	if bytes.Equal(exp.PrivateKey.Seed(), account.PrivateKey.Seed()) {
		return nil
	}
	return fmt.Errorf("private keys not equal")
}

func kmdClient() error {
	dataDirPath := os.Getenv("NODE_DIR") + "/" + os.Getenv("KMD_DIR") + "/"
	tokenBytes, err := ioutil.ReadFile(dataDirPath + "kmd.token")
	if err != nil {
		return err
	}
	kmdToken := strings.TrimSpace(string(tokenBytes))
	addressBytes, err := ioutil.ReadFile(dataDirPath + "kmd.net")
	if err != nil {
		return err
	}
	kmdAddress := strings.TrimSpace(string(addressBytes))
	arr := strings.Split(kmdAddress, ":")
	kmdAddress = "http://localhost:" + arr[1]

	kcl, err = kmd.MakeClient(kmdAddress, kmdToken)

	return err
}

func algodClient() error {
	dataDirPath := os.Getenv("NODE_DIR") + "/"
	tokenBytes, err := ioutil.ReadFile(dataDirPath + "algod.token")
	if err != nil {
		return err
	}
	algodToken := strings.TrimSpace(string(tokenBytes))

	addressBytes, err := ioutil.ReadFile(dataDirPath + "algod.net")
	if err != nil {
		return err
	}
	algodAddress := strings.TrimSpace(string(addressBytes))
	arr := strings.Split(algodAddress, ":")
	algodAddress = "http://localhost:" + arr[1]

	acl, err = algod.MakeClient(algodAddress, algodToken)
	_, err = acl.StatusAfterBlock(1)
	return err
}

func walletInfo() error {
	walletName = "unencrypted-default-wallet"
	walletPswd = ""
	wallets, err := kcl.ListWallets()
	if err != nil {
		return err
	}
	for _, w := range wallets.Wallets {
		if w.Name == walletName {
			walletID = w.ID
		}
	}
	h, err := kcl.InitWalletHandle(walletID, walletPswd)
	if err != nil {
		return err
	}
	handle = h.WalletHandleToken
	accs, err := kcl.ListKeys(handle)
	accounts = accs.Addresses
	return err
}

func defaultTxn(iamt int, inote string) error {
	var err error
	if inote != "none" {
		note, err = base64.StdEncoding.DecodeString(inote)
		if err != nil {
			return err
		}
	} else {
		note, err = base64.StdEncoding.DecodeString("")
		if err != nil {
			return err
		}
	}

	amt = uint64(iamt)
	pk = accounts[0]
	params, err := acl.SuggestedParams()
	if err != nil {
		return err
	}
	lastRound = params.LastRound
	txn, err = transaction.MakePaymentTxn(accounts[0], accounts[1], params.Fee, amt, params.LastRound, params.LastRound+1000, note, "", params.GenesisID, params.GenesisHash)
	return err
}

func defaultMsigTxn(iamt int, inote string) error {
	var err error
	if inote != "none" {
		note, err = base64.StdEncoding.DecodeString(inote)
		if err != nil {
			return err
		}
	} else {
		note, err = base64.StdEncoding.DecodeString("")
		if err != nil {
			return err
		}
	}

	amt = uint64(iamt)
	pk = accounts[0]

	var addrStructs []types.Address
	for _, a := range accounts {
		addr, err := types.DecodeAddress(a)
		if err != nil {
			return err
		}

		addrStructs = append(addrStructs, addr)
	}

	msig, err = crypto.MultisigAccountWithParams(1, 1, addrStructs)
	if err != nil {
		return err
	}
	params, err := acl.SuggestedParams()
	if err != nil {
		return err
	}
	lastRound = params.LastRound
	addr, err := msig.Address()
	if err != nil {
		return err
	}
	txn, err = transaction.MakePaymentTxn(addr.String(), accounts[1], params.Fee, amt, params.LastRound, params.LastRound+1000, note, "", params.GenesisID, params.GenesisHash)
	if err != nil {
		return err
	}
	return nil
}

func getSk() error {
	sk, err := kcl.ExportKey(handle, walletPswd, pk)
	if err != nil {
		return err
	}
	account.PrivateKey = sk.PrivateKey
	return nil
}

func sendTxn() error {
	tx, err := acl.SendRawTransaction(stx)
	if err != nil {
		return err
	}
	txid = tx.TxID
	return nil
}

func sendMsigTxn() error {
	_, err := acl.SendRawTransaction(stx)

	if err != nil {
		e = true
	}

	return nil
}

func checkTxn() error {
	_, err := acl.PendingTransactionInformation(txid)
	if err != nil {
		return err
	}
	_, err = acl.StatusAfterBlock(lastRound + 2)
	if err != nil {
		return err
	}
	_, err = acl.TransactionInformation(txn.Sender.String(), txid)
	if err != nil {
		return err
	}
	_, err = acl.TransactionByID(txid)
	return err
}

func txnbyID() error {
	var err error
	_, err = acl.StatusAfterBlock(lastRound + 2)
	if err != nil {
		return err
	}
	_, err = acl.TransactionByID(txid)
	return err
}

func txnFail() error {
	if e {
		return nil
	}
	return fmt.Errorf("sending the transaction should have failed")
}

func signKmd() error {
	s, err := kcl.SignTransaction(handle, walletPswd, txn)
	if err != nil {
		return err
	}
	stxKmd = s.SignedTransaction
	return nil
}

func signBothEqual() error {
	if bytes.Equal(stx, stxKmd) {
		return nil
	}
	return fmt.Errorf("signed transactions not equal")
}

func signMsigKmd() error {
	kcl.ImportMultisig(handle, msig.Version, msig.Threshold, msig.Pks)
	decoded, err := base32.StdEncoding.WithPadding(base32.NoPadding).DecodeString(pk)
	s, err := kcl.MultisigSignTransaction(handle, walletPswd, txn, decoded[:32], types.MultisigSig{})
	if err != nil {
		return err
	}
	msgpack.Decode(s.Multisig, &msigsig)
	stxObj.Msig = msigsig
	stxObj.Sig = types.Signature{}
	stxObj.Txn = txn
	stxKmd = msgpack.Encode(stxObj)
	return nil
}

func signMsigBothEqual() error {
	addr, err := msig.Address()
	if err != nil {
		return err
	}
	kcl.DeleteMultisig(handle, walletPswd, addr.String())
	if bytes.Equal(stx, stxKmd) {
		return nil
	}
	return fmt.Errorf("signed transactions not equal")

}

func readTxn(encodedTxn string, inum string) error {
	encodedBytes, err := base64.StdEncoding.DecodeString(encodedTxn)
	if err != nil {
		return err
	}
	path, err := os.Getwd()
	if err != nil {
		return err
	}
	num = inum
	path = filepath.Dir(filepath.Dir(path)) + "/temp/old" + num + ".tx"
	err = ioutil.WriteFile(path, encodedBytes, 0644)
	data, err := ioutil.ReadFile(path)
	if err != nil {
		return err
	}
	err = msgpack.Decode(data, &stxObj)
	return err
}

func writeTxn() error {
	path, err := os.Getwd()
	if err != nil {
		return err
	}
	path = filepath.Dir(filepath.Dir(path)) + "/temp/raw" + num + ".tx"
	data := msgpack.Encode(stxObj)
	err = ioutil.WriteFile(path, data, 0644)
	return err
}

func checkEnc() error {
	path, err := os.Getwd()
	if err != nil {
		return err
	}
	pathold := filepath.Dir(filepath.Dir(path)) + "/temp/old" + num + ".tx"
	dataold, err := ioutil.ReadFile(pathold)

	pathnew := filepath.Dir(filepath.Dir(path)) + "/temp/raw" + num + ".tx"
	datanew, err := ioutil.ReadFile(pathnew)

	if bytes.Equal(dataold, datanew) {
		return nil
	}
	return fmt.Errorf("should be equal")
}

func createSaveTxn() error {
	var err error

	amt = 100000
	pk = accounts[0]
	params, err := acl.SuggestedParams()
	if err != nil {
		return err
	}
	lastRound = params.LastRound
	txn, err = transaction.MakePaymentTxn(accounts[0], accounts[1], params.Fee, amt, params.LastRound, params.LastRound+1000, note, "", params.GenesisID, params.GenesisHash)
	if err != nil {
		return err
	}

	path, err := os.Getwd()
	if err != nil {
		return err
	}
	path = filepath.Dir(filepath.Dir(path)) + "/temp/txn.tx"
	data := msgpack.Encode(txn)
	err = ioutil.WriteFile(path, data, 0644)
	return err
}

func nodeHealth() error {
	err := acl.HealthCheck()
	return err
}

func ledger() error {
	_, err := acl.LedgerSupply()
	return err
}

func txnsByAddrRound() error {
	lr, err := acl.Status()
	if err != nil {
		return err
	}
	_, err = acl.TransactionsByAddr(accounts[0], 1, lr.LastRound)
	return err
}

func txnsByAddrOnly() error {
	_, err := acl.TransactionsByAddrLimit(accounts[0], 10)
	return err
}

func txnsByAddrDate() error {
	fromDate := time.Now().Format("2006-01-02")
	_, err := acl.TransactionsByAddrForDate(accounts[0], fromDate, fromDate)
	return err
}

func txnsPending() error {
	_, err := acl.GetPendingTransactions(10)
	return err
}

func suggestedParams() error {
	var err error
	sugParams, err = acl.SuggestedParams()
	return err
}

func suggestedFee() error {
	var err error
	sugFee, err = acl.SuggestedFee()
	return err
}

func checkSuggested() error {
	if sugParams.Fee != sugFee.Fee {
		return fmt.Errorf("suggested fee from params should be equal to suggested fee")
	}
	return nil
}

func createBid() error {
	var err error
	account = crypto.GenerateAccount()
	bid, err = auction.MakeBid(account.Address.String(), 1, 2, 3, account.Address.String(), 4)
	return err
}

func encDecBid() error {
	temp := msgpack.Encode(sbid)
	err := msgpack.Decode(temp, &sbid)
	return err
}

func signBid() error {
	signedBytes, err := crypto.SignBid(account.PrivateKey, bid)
	if err != nil {
		return err
	}
	err = msgpack.Decode(signedBytes, &sbid)
	if err != nil {
		return err
	}
	err = msgpack.Decode(signedBytes, &oldBid)
	return err
}

func checkBid() error {
	if sbid != oldBid {
		return fmt.Errorf("bid should still be the same")
	}
	return nil
}

func decAddr() error {
	var err error
	oldPk = pk
	a, err = types.DecodeAddress(pk)
	return err
}

func encAddr() error {
	pk = a.String()
	return nil
}

func checkAddr() error {
	if pk != oldPk {
		return fmt.Errorf("A decoded and encoded address should equal the original address")
	}
	return nil
}

func skToMn() error {
	var err error
	newMn, err = mnemonic.FromPrivateKey(account.PrivateKey)
	return err
}

func checkMn(mn string) error {
	if mn != newMn {
		return fmt.Errorf("the mnemonic should equal the original mnemonic")
	}
	return nil
}

func mnToMdk(mn string) error {
	var err error
	mdk, err = mnemonic.ToMasterDerivationKey(mn)
	return err
}

func mdkToMn() error {
	var err error
	newMn, err = mnemonic.FromMasterDerivationKey(mdk)
	return err
}

func createTxnFlat() error {
	var err error
	txn, err = transaction.MakePaymentTxnWithFlatFee(a.String(), to, fee, amt, fv, lv, note, close, gen, gh)
	if err != nil {
		return err
	}
	return err
}

func encMsigTxn(encoded string) error {
	var err error
	stx, err = base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return err
	}
	err = msgpack.Decode(stx, &stxObj)
	return err
}

func appendMsig() error {
	var err error
	msig, err = crypto.MultisigAccountFromSig(stxObj.Msig)
	if err != nil {
		return err
	}
	_, stx, err = crypto.AppendMultisigTransaction(account.PrivateKey, msig, stx)
	return err
}

func encMtxs(txs string) error {
	var err error
	enctxs := strings.Split(txs, " ")
	bytetxs = make([][]byte, len(enctxs))
	for i := range enctxs {
		bytetxs[i], err = base64.StdEncoding.DecodeString(enctxs[i])
		if err != nil {
			return err
		}
	}
	return nil
}

func mergeMsig() (err error) {
	_, stx, err = crypto.MergeMultisigTransactions(bytetxs...)
	return
}

func microToAlgos(ma int) error {
	microalgos = types.MicroAlgos(ma)
	microalgos = types.ToMicroAlgos(microalgos.ToAlgos())
	return nil
}

func checkAlgos(ma int) error {
	if types.MicroAlgos(ma) != microalgos {
		return fmt.Errorf("Converting to and from algos should not change the value")
	}
	return nil
}

func accInfo() error {
	_, err := acl.AccountInformation(accounts[0])
	return err
}

func newAccInfo() error {
	_, err := acl.AccountInformation(pk)
	_, _ = kcl.DeleteKey(handle, walletPswd, pk)
	return err
}

func keyregTxnParams(ifee, ifv, ilv int, igh, ivotekey, iselkey string, ivotefst, ivotelst, ivotekd int, igen, inote string) error {
	var err error
	if inote != "none" {
		note, err = base64.StdEncoding.DecodeString(inote)
		if err != nil {
			return err
		}
	} else {
		note, err = base64.StdEncoding.DecodeString("")
		if err != nil {
			return err
		}
	}
	gh, err = base64.StdEncoding.DecodeString(igh)
	if err != nil {
		return err
	}
	votekey = ivotekey
	selkey = iselkey
	fee = uint64(ifee)
	fv = uint64(ifv)
	lv = uint64(ilv)
	votefst = uint64(ivotefst)
	votelst = uint64(ivotelst)
	votekd = uint64(ivotekd)
	if igen != "none" {
		gen = igen
	} else {
		gen = ""
	}
	if err != nil {
		return err
	}
	return nil
}

func createKeyregTxn() (err error) {
	strGh := base64.StdEncoding.EncodeToString(gh)
	txn, err = transaction.MakeKeyRegTxn(a.String(), fee, fv, lv, note, gen, strGh, votekey, selkey, votefst, votelst, votekd)
	if err != nil {
		return err
	}
	return err
}

func getTxnsByCount(cnt int) error {
	_, err := acl.TransactionsByAddrLimit(accounts[0], uint64(cnt))
	return err
}

func createAssetTestFixture() error {
	assetTestFixture.Creator = ""
	assetTestFixture.AssetIndex = 1
	assetTestFixture.AssetName = "testcoin"
	assetTestFixture.AssetUnitName = "coins"
	assetTestFixture.Params = types.AssetParams{}
	assetTestFixture.QueriedParams = models.AssetParams{}
	assetTestFixture.LastTransactionIssued = types.Transaction{}
	return nil
}

func defaultAssetCreateTxn(issuance int) error {
	_, _ = fmt.Fprintln(os.Stderr, "this is the asset test")
	accountToUse := account.Address.String()
	assetTestFixture.Creator = accountToUse
	creator := assetTestFixture.Creator
	params, err := acl.SuggestedParams()
	if err != nil {
		return err
	}
	firstRound := params.LastRound
	lastRound := firstRound + 1000
	assetNote := []byte(nil)
	assetIssuance := uint64(issuance)
	genesisID := params.GenesisID
	genesisHash := base64.StdEncoding.EncodeToString(params.GenesisHash)
	defaultFrozen := false
	manager := creator
	reserve := creator
	freeze := creator
	clawback := creator
	unitName := assetTestFixture.AssetUnitName
	assetName := assetTestFixture.AssetName
	assetCreateTxn, err := transaction.MakeAssetCreateTxn(creator, 10, firstRound, lastRound, assetNote,
		genesisID, genesisHash, assetIssuance, defaultFrozen, manager, reserve, freeze, clawback, unitName,
		assetName)
	assetTestFixture.LastTransactionIssued = assetCreateTxn
	txn = assetCreateTxn
	copy(assetTestFixture.Params.UnitName[:], []byte(unitName))
	copy(assetTestFixture.Params.AssetName[:], []byte(assetName))
	assetTestFixture.Params.DefaultFrozen = defaultFrozen
	assetTestFixture.Params.Total = assetIssuance
	assetTestFixture.Params.Manager, _ = types.DecodeAddress(manager)
	assetTestFixture.Params.Reserve, _ = types.DecodeAddress(reserve)
	assetTestFixture.Params.Freeze, _ = types.DecodeAddress(freeze)
	assetTestFixture.Params.Clawback, _ = types.DecodeAddress(clawback)
	return err
}

func getAssetInfo() error {
	response, err := acl.AssetInformation(assetTestFixture.Creator, assetTestFixture.AssetIndex)
	assetTestFixture.QueriedParams = response
	return err
}

func matchAssetInfoToCreationTxn() error {
	expectedParams := assetTestFixture.Params
	actualParams := assetTestFixture.QueriedParams
	var nameBuf [32]byte
	copy(nameBuf[:], []byte(actualParams.AssetName))
	nameMatch := expectedParams.AssetName == nameBuf
	var unitBuf [8]byte
	copy(unitBuf[:], []byte(actualParams.UnitName))
	unitMatch := expectedParams.UnitName == unitBuf
	issuanceMatch := expectedParams.Total == actualParams.Total
	defaultFrozenMatch := expectedParams.DefaultFrozen == actualParams.DefaultFrozen
	managerMatch := expectedParams.Manager.String() == actualParams.ManagerAddr
	reserveMatch := expectedParams.Reserve.String() == actualParams.ReserveAddr
	freezeMatch := expectedParams.Freeze.String() == actualParams.FreezeAddr
	clawbackMatch := expectedParams.Clawback.String() == actualParams.ClawbackAddr
	if nameMatch && unitMatch && issuanceMatch && defaultFrozenMatch && managerMatch && reserveMatch && freezeMatch && clawbackMatch {
		return nil
	}
	return fmt.Errorf("queried params %v mismatch with creation params %v", actualParams, expectedParams)
}
