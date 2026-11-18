package main

import (
	"encoding/base64"
	"fmt"
	"os"
	"path/filepath"
	"regexp"

	"github.com/algorand/go-algorand/crypto"
	"github.com/algorand/go-algorand/data/basics"
	"github.com/algorand/go-algorand/data/bookkeeping"
	"github.com/algorand/go-algorand/data/committee"
	"github.com/algorand/go-algorand/data/transactions"
	"github.com/algorand/go-algorand/data/transactions/logic"
	"github.com/algorand/go-algorand/data/transactions/verify"
	"github.com/algorand/go-algorand/ledger/ledgercore"
	"github.com/algorand/go-algorand/protocol"
)

type DummyLedgerForSignature struct{}

func (d *DummyLedgerForSignature) BlockHdr(rnd basics.Round) (blk bookkeeping.BlockHeader, err error) {
	return createDummyBlockHeader(), nil
}

func (d *DummyLedgerForSignature) GenesisHash() crypto.Digest {
	return crypto.Digest{}
}

func (d *DummyLedgerForSignature) Latest() basics.Round {
	return 0
}

func (d *DummyLedgerForSignature) RegisterBlockListeners([]ledgercore.BlockListener) {}

// Values taken from data/transactions/verify/txn_test.go
var feeSink = basics.Address{0x7, 0xda, 0xcb, 0x4b, 0x6d, 0x9e, 0xd1, 0x41, 0xb1, 0x75, 0x76, 0xbd, 0x45, 0x9a, 0xe6, 0x42, 0x1d, 0x48, 0x6d, 0xa3, 0xd4, 0xef, 0x22, 0x47, 0xc4, 0x9, 0xa3, 0x96, 0xb8, 0x2e, 0xa2, 0x21}
var poolAddr = basics.Address{0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff}

const assetId = basics.AssetIndex(107686045)
const appId = basics.AppIndex(84366825)

func createDummyBlockHeader() bookkeeping.BlockHeader {
	proto := protocol.ConsensusCurrentVersion

	return bookkeeping.BlockHeader{
		Round:       1000,
		GenesisHash: crypto.Hash([]byte{1, 2, 3, 4, 5}),
		UpgradeState: bookkeeping.UpgradeState{
			CurrentProtocol: proto,
		},
		RewardsState: bookkeeping.RewardsState{
			FeeSink:     feeSink,
			RewardsPool: poolAddr,
		},
	}
}

// generateSecrets generates deterministic signature secrets for numAccs accounts
func generateSecrets(numAccs int) []*crypto.SignatureSecrets {
	secrets := make([]*crypto.SignatureSecrets, numAccs)

	for i := range numAccs {
		var seed crypto.Seed
		for j := range len(seed) {
			seed[j] = byte(i + j)
		}
		secret := crypto.GenerateSignatureSecrets(seed)
		secrets[i] = secret

	}
	return secrets
}

func generateMsigAddr(pks [3]crypto.PublicKey) basics.Address {
	addr, err := crypto.MultisigAddrGen(1, 2, pks[:])

	if err != nil {
		panic(err)
	}

	return basics.Address(addr)
}

type TxData struct {
	Signer   Signer                 `codec:"signer"`
	Stxn     transactions.SignedTxn `codec:"stxn"`
	StxnBlob []byte                 `codec:"stxnBlob"`
	TxnBlob  []byte                 `codec:"txnBlob"`
	Id       string                 `codec:"id"`
}

type TxGroupData struct {
	Txns      []string `codec:"txns"`
	TxnBlobs  [][]byte `codec:"txnBlobs"`
	StxnBlobs [][]byte `codec:"stxnBlobs"`
	GroupID   string   `codec:"groupID"`
}

type Signer struct {
	SingleSigner *crypto.SignatureSecrets  `codec:"singleSigner,omitempty"`
	MsigSigners  []crypto.SignatureSecrets `codec:"msigSigners,omitempty"`
	Lsig         []byte                    `codec:"lsig,omitempty"`
}

func makeTxData(txType protocol.TxType, fields any, signer Signer) TxData {
	ghB64 := "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="

	ghBytes, err := base64.StdEncoding.DecodeString(ghB64)
	if err != nil {
		panic(err)
	}

	var gh [32]byte
	copy(gh[:], ghBytes)

	stxn := transactions.SignedTxn{}

	switch txType {
	case protocol.PaymentTx:
		stxn.Txn = transactions.Transaction{
			PaymentTxnFields: fields.(transactions.PaymentTxnFields),
		}
	case protocol.AssetTransferTx:
		stxn.Txn = transactions.Transaction{
			AssetTransferTxnFields: fields.(transactions.AssetTransferTxnFields),
		}
	case protocol.ApplicationCallTx:
		stxn.Txn = transactions.Transaction{
			ApplicationCallTxnFields: fields.(transactions.ApplicationCallTxnFields),
		}
	case protocol.AssetConfigTx:
		stxn.Txn = transactions.Transaction{
			AssetConfigTxnFields: fields.(transactions.AssetConfigTxnFields),
		}
	case protocol.AssetFreezeTx:
		stxn.Txn = transactions.Transaction{
			AssetFreezeTxnFields: fields.(transactions.AssetFreezeTxnFields),
		}
	case protocol.KeyRegistrationTx:
		stxn.Txn = transactions.Transaction{
			KeyregTxnFields: fields.(transactions.KeyregTxnFields),
		}
	case protocol.HeartbeatTx:
		stxn.Txn = transactions.Transaction{
			HeartbeatTxnFields: fields.(*transactions.HeartbeatTxnFields),
		}
	default:
		panic("Unsupported transaction type")
	}

	stxn.Txn.Type = txType
	stxn.Txn.Header = transactions.Header{
		Sender:      addr(signer),
		FirstValid:  50659540,
		LastValid:   50660540,
		GenesisHash: gh,
		GenesisID:   "testnet-v1.0",
		Fee:         basics.MicroAlgos{Raw: 1000},
	}

	if len(signer.Lsig) > 0 {
		program := logic.Program(signer.Lsig)
		stxn.Lsig.Logic = signer.Lsig

		if signer.SingleSigner != nil {
			stxn.Lsig.Sig = signer.SingleSigner.Sign(program)
		} else if len(signer.MsigSigners) > 0 {
			var pks [3]crypto.PublicKey
			for i := range signer.MsigSigners {
				pks[i] = signer.MsigSigners[i].SignatureVerifier
			}

			toBeSigned := logic.MultisigProgram{Addr: crypto.Digest(stxn.Txn.Sender), Program: program}

			stxn.Lsig.LMsig.Threshold = 2
			stxn.Lsig.LMsig.Version = 1
			stxn.Lsig.LMsig.Subsigs = make([]crypto.MultisigSubsig, len(pks))

			for i := range signer.MsigSigners {
				sig := signer.MsigSigners[i].Sign(toBeSigned)
				stxn.Lsig.LMsig.Subsigs[i].Key = pks[i]
				stxn.Lsig.LMsig.Subsigs[i].Sig = sig
			}

		}
	} else if signer.SingleSigner != nil {
		stxn.Sig = signer.SingleSigner.Sign(stxn.Txn)
	} else if len(signer.MsigSigners) > 0 {
		var pks [3]crypto.PublicKey
		for i := range signer.MsigSigners {
			pks[i] = signer.MsigSigners[i].SignatureVerifier
		}

		stxn.Msig = crypto.MultisigSig{
			Version:   1,
			Threshold: 2,
			Subsigs:   make([]crypto.MultisigSubsig, len(pks)),
		}

		var sigs [][]byte
		for i := range signer.MsigSigners {
			sig := signer.MsigSigners[i].Sign(stxn.Txn)
			sigs = append(sigs, sig[:])
			stxn.Msig.Subsigs[i].Key = pks[i]
			stxn.Msig.Subsigs[i].Sig = sig
		}

	}
	stxns := make([]transactions.SignedTxn, 1)
	stxns[0] = stxn

	blkHdr := createDummyBlockHeader()
	ledger := DummyLedgerForSignature{}

	_, err = verify.TxnGroup(stxns, &blkHdr, nil, &ledger)
	if err != nil {
		panic(err)
	}

	return TxData{
		Signer:   signer,
		Stxn:     stxn,
		StxnBlob: protocol.Encode(&stxn),
		TxnBlob:  protocol.Encode(&stxn.Txn),
		Id:       stxn.Txn.ID().String(),
	}
}

func addr(signer Signer) basics.Address {
	if signer.SingleSigner != nil {
		return basics.Address(signer.SingleSigner.SignatureVerifier)
	} else if len(signer.MsigSigners) > 0 {
		var pks [3]crypto.PublicKey
		for i := range signer.MsigSigners {
			pks[i] = signer.MsigSigners[i].SignatureVerifier
		}
		return generateMsigAddr(pks)
	} else {
		program := logic.Program(signer.Lsig)
		return basics.Address(crypto.HashObj(program))
	}
}

func makeSimplePayment(signer Signer) TxData {
	payFields := transactions.PaymentTxnFields{}

	return makeTxData(protocol.PaymentTx, payFields, signer)
}

func makeOptInAssetTransfer(signer Signer) TxData {
	optInFields := transactions.AssetTransferTxnFields{
		XferAsset:     assetId,
		AssetAmount:   0,
		AssetReceiver: addr(signer),
	}

	return makeTxData(protocol.AssetTransferTx, optInFields, signer)
}

func makeAppCreate(signer Signer, program []byte) TxData {
	appCreateFields := transactions.ApplicationCallTxnFields{
		ApplicationID:     0,
		OnCompletion:      transactions.NoOpOC,
		ApprovalProgram:   program,
		ClearStateProgram: program,
		GlobalStateSchema: basics.StateSchema{
			NumUint:      0,
			NumByteSlice: 1,
		},
		LocalStateSchema: basics.StateSchema{
			NumUint:      2,
			NumByteSlice: 3,
		},
		ExtraProgramPages: 3,
	}

	return makeTxData(protocol.ApplicationCallTx, appCreateFields, signer)
}

func makeAppUpdate(signer Signer, program []byte) TxData {
	appUpdateFields := transactions.ApplicationCallTxnFields{
		ApplicationID:     appId,
		OnCompletion:      transactions.UpdateApplicationOC,
		ApprovalProgram:   program,
		ClearStateProgram: program,
	}

	return makeTxData(protocol.ApplicationCallTx, appUpdateFields, signer)
}

func makeAppDelete(signer Signer) TxData {
	appDeleteFields := transactions.ApplicationCallTxnFields{
		ApplicationID: appId,
		OnCompletion:  transactions.DeleteApplicationOC,
	}

	return makeTxData(protocol.ApplicationCallTx, appDeleteFields, signer)
}

func makeAppCall(signer Signer) TxData {
	appCallFields := transactions.ApplicationCallTxnFields{
		ApplicationID: appId,
		OnCompletion:  transactions.NoOpOC,
	}

	return makeTxData(protocol.ApplicationCallTx, appCallFields, signer)
}

func makeSimpleAssetTransfer(signer Signer) TxData {
	transferFields := transactions.AssetTransferTxnFields{
		XferAsset:     assetId,
		AssetAmount:   1000,
		AssetReceiver: addr(signer),
	}

	return makeTxData(protocol.AssetTransferTx, transferFields, signer)
}

func makeAssetCreate(signer Signer) TxData {
	assetCreateFields := transactions.AssetConfigTxnFields{
		ConfigAsset: 0, // 0 for asset creation
		AssetParams: basics.AssetParams{
			Total:         10000000000,
			Decimals:      0,
			DefaultFrozen: false,
			UnitName:      "TEST",
			AssetName:     "Test Asset",
			URL:           "https://example.com",
			Manager:       addr(signer),
			Reserve:       addr(signer),
			Freeze:        addr(signer),
			Clawback:      addr(signer),
		},
	}

	return makeTxData(protocol.AssetConfigTx, assetCreateFields, signer)
}

func makeAssetDestroy(signer Signer) TxData {
	assetDestroyFields := transactions.AssetConfigTxnFields{
		ConfigAsset: assetId,
		// Empty AssetParams signals asset destruction
	}

	return makeTxData(protocol.AssetConfigTx, assetDestroyFields, signer)
}

func makeAssetConfig(signer Signer) TxData {
	assetConfigFields := transactions.AssetConfigTxnFields{
		ConfigAsset: assetId,
		AssetParams: basics.AssetParams{
			Manager:  addr(signer),
			Reserve:  addr(signer),
			Freeze:   addr(signer),
			Clawback: addr(signer),
		},
	}

	return makeTxData(protocol.AssetConfigTx, assetConfigFields, signer)
}

func makeOnlineKeyRegistration(signer Signer) TxData {
	var voteKey [32]byte
	var selectionKey [32]byte
	var stateProofKey [64]byte

	// Fill with deterministic test values
	for i := range 32 {
		voteKey[i] = byte(i + 1)
		selectionKey[i] = byte(i + 33)
	}
	for i := range 64 {
		stateProofKey[i] = byte(i + 65)
	}

	keyregFields := transactions.KeyregTxnFields{
		VotePK:           crypto.OneTimeSignatureVerifier(voteKey),
		SelectionPK:      crypto.VRFVerifier(selectionKey),
		StateProofPK:     stateProofKey,
		VoteFirst:        basics.Round(50659540),
		VoteLast:         basics.Round(53659540),
		VoteKeyDilution:  1733,
		Nonparticipation: false,
	}

	return makeTxData(protocol.KeyRegistrationTx, keyregFields, signer)
}

func makeOfflineKeyRegistration(signer Signer) TxData {
	keyregFields := transactions.KeyregTxnFields{
		// Empty fields for offline key registration
		Nonparticipation: false,
	}

	return makeTxData(protocol.KeyRegistrationTx, keyregFields, signer)
}

func makeNonParticipationKeyRegistration(signer Signer) TxData {
	keyregFields := transactions.KeyregTxnFields{
		Nonparticipation: true,
	}

	return makeTxData(protocol.KeyRegistrationTx, keyregFields, signer)
}

func makeAssetFreeze(signer Signer) TxData {
	freezeFields := transactions.AssetFreezeTxnFields{
		FreezeAccount: addr(signer),
		FreezeAsset:   assetId,
		AssetFrozen:   true,
	}

	return makeTxData(protocol.AssetFreezeTx, freezeFields, signer)
}

func makeAssetUnfreeze(signer Signer) TxData {
	unfreezeFields := transactions.AssetFreezeTxnFields{
		FreezeAccount: addr(signer),
		FreezeAsset:   assetId,
		AssetFrozen:   false,
	}

	return makeTxData(protocol.AssetFreezeTx, unfreezeFields, signer)
}

func makeHeartbeat(signer Signer) TxData {
	const keyDilution = uint64(111)
	// Use the same FirstValid/LastValid as makeTxData
	fv := basics.Round(50659540)
	lv := basics.Round(50660540)

	firstID := basics.OneTimeIDForRound(fv, keyDilution)
	lastID := basics.OneTimeIDForRound(lv, keyDilution)
	numBatches := lastID.Batch - firstID.Batch + 1
	id := basics.OneTimeIDForRound(lv, keyDilution)

	seed := committee.Seed{0x01, 0x02, 0x03}
	prng := crypto.MakePRNG([]byte("heartbeat-test-seed"))
	otss := crypto.GenerateOneTimeSignatureSecretsRNG(firstID.Batch, numBatches, prng)

	heartbeatFields := &transactions.HeartbeatTxnFields{
		HbAddress:     addr(signer),
		HbProof:       otss.Sign(id, seed).ToHeartbeatProof(),
		HbSeed:        seed,
		HbVoteID:      otss.OneTimeSignatureVerifier,
		HbKeyDilution: keyDilution,
	}

	return makeTxData(protocol.HeartbeatTx, heartbeatFields, signer)
}

func computeGroupID(txgroup []transactions.Transaction) (crypto.Digest, error) {
	var group transactions.TxGroup
	for _, tx := range txgroup {
		if !tx.Group.IsZero() {
			return crypto.Digest{}, fmt.Errorf("tx %v already has a group", tx)
		}
		group.TxGroupHashes = append(group.TxGroupHashes, crypto.Digest(tx.ID()))
	}
	return crypto.HashObj(group), nil
}

func makeTxGroup(signer Signer) TxGroupData {
	pay1 := makeSimplePayment(signer)
	pay2 := makeSimplePayment(signer)
	appCall := makeAppCall(signer)

	txGroup := []transactions.Transaction{pay1.Stxn.Txn, pay2.Stxn.Txn, appCall.Stxn.Txn}

	groupID, err := computeGroupID(txGroup)
	if err != nil {
		panic(err)
	}

	for i := range txGroup {
		txGroup[i].Group = groupID
	}

	stxns := make([]transactions.SignedTxn, len(txGroup))
	for i := range txGroup {
		stxns[i] =
			transactions.SignedTxn{
				Txn: txGroup[i],
				Sig: signer.SingleSigner.Sign(txGroup[i]),
			}
	}

	blkHdr := createDummyBlockHeader()
	ledger := DummyLedgerForSignature{}

	_, err = verify.TxnGroup(stxns, &blkHdr, nil, &ledger)
	if err != nil {
		panic(err)
	}

	stxnBlobs := make([][]byte, len(stxns))
	txnBlobs := make([][]byte, len(stxns))
	for i := range stxns {
		stxnBlobs[i] = protocol.Encode(&stxns[i])
		txnBlobs[i] = protocol.Encode(&stxns[i].Txn)
	}

	return TxGroupData{
		Txns:      []string{"simplePayment", "simplePayment", "appCall"},
		TxnBlobs:  txnBlobs,
		StxnBlobs: stxnBlobs,
		GroupID:   groupID.String(),
	}

}

func makeStateProof() TxData {
	// Rather than constructing a stateproof txn from scratch, read it from a mainnet stateproof txn encoded in JSON.
	// Use get_stateproof.sh to get the latest mainnet stateproof txn from nodely.
	data, err := os.ReadFile("stateproof.json")
	if err != nil {
		panic(err)
	}

	tx := transactions.SignedTxn{}
	err = protocol.DecodeJSON([]byte(data), &tx)
	if err != nil {
		panic(err)
	}

	return TxData{
		Stxn:     tx,
		StxnBlob: protocol.Encode(&tx),
		TxnBlob:  protocol.Encode(&tx.Txn),
		Id:       tx.Txn.ID().String(),
	}
}

// fixNumericKeys fixes unquoted numeric keys in JSON output from protocol.EncodeJSON
// The codec library outputs map keys with integer types without quotes, which is invalid JSON
func fixNumericKeys(jsonData []byte) []byte {
	// Match unquoted numeric keys like `  0: {` or `  123: {`
	re := regexp.MustCompile(`(\s)(\d+)(\s*):`)
	return re.ReplaceAll(jsonData, []byte(`$1"$2"$3:`))
}

// writeTestDataFile writes a single test data item to a JSON file
func writeTestDataFile(name string, data any) {
	filename := filepath.Join("data", name+".json")

	jsonData := protocol.EncodeJSON(data)
	jsonData = fixNumericKeys(jsonData)

	err := os.WriteFile(filename, jsonData, 0644)
	if err != nil {
		panic(err)
	}
	fmt.Println("Test data written to file:", filename)
}

func main() {
	secrets := generateSecrets(3)
	simpleSigner := Signer{
		SingleSigner: secrets[0],
	}
	msigSigner := Signer{
		MsigSigners: []crypto.SignatureSecrets{*secrets[0], *secrets[1], *secrets[2]},
	}

	op, err := logic.AssembleString("int 1")

	if err != nil {
		panic(err)
	}

	lsigSigner := Signer{
		Lsig: op.Program,
	}

	delegatedSigner := Signer{
		SingleSigner: secrets[0],
		Lsig:         op.Program,
	}

	msigDelegatedSigner := Signer{
		MsigSigners: []crypto.SignatureSecrets{*secrets[0], *secrets[1], *secrets[2]},
		Lsig:        op.Program,
	}

	writeTestDataFile("simplePayment", makeSimplePayment(simpleSigner))
	writeTestDataFile("simpleAssetTransfer", makeSimpleAssetTransfer(simpleSigner))
	writeTestDataFile("optInAssetTransfer", makeOptInAssetTransfer(simpleSigner))
	writeTestDataFile("appCreate", makeAppCreate(simpleSigner, op.Program))
	writeTestDataFile("appUpdate", makeAppUpdate(simpleSigner, op.Program))
	writeTestDataFile("appDelete", makeAppDelete(simpleSigner))
	writeTestDataFile("appCall", makeAppCall(simpleSigner))
	writeTestDataFile("assetCreate", makeAssetCreate(simpleSigner))
	writeTestDataFile("assetDestroy", makeAssetDestroy(simpleSigner))
	writeTestDataFile("assetConfig", makeAssetConfig(simpleSigner))
	writeTestDataFile("onlineKeyRegistration", makeOnlineKeyRegistration(simpleSigner))
	writeTestDataFile("offlineKeyRegistration", makeOfflineKeyRegistration(simpleSigner))
	writeTestDataFile("nonParticipationKeyRegistration", makeNonParticipationKeyRegistration(simpleSigner))
	writeTestDataFile("assetFreeze", makeAssetFreeze(simpleSigner))
	writeTestDataFile("assetUnfreeze", makeAssetUnfreeze(simpleSigner))
	writeTestDataFile("heartbeat", makeHeartbeat(simpleSigner))
	writeTestDataFile("msigPayment", makeSimplePayment(msigSigner))
	writeTestDataFile("lsigPayment", makeSimplePayment(lsigSigner))
	writeTestDataFile("singleDelegatedPayment", makeSimplePayment(delegatedSigner))
	writeTestDataFile("msigDelegatedPayment", makeSimplePayment(msigDelegatedSigner))
	writeTestDataFile("stateProof", makeStateProof())
	writeTestDataFile("txGroup", makeTxGroup(simpleSigner))

}
