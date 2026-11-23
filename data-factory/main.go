package main

import (
	"encoding/base64"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"slices"

	"github.com/algorand/go-algorand/crypto"
	"github.com/algorand/go-algorand/crypto/passphrase"
	"github.com/algorand/go-algorand/data/basics"
	"github.com/algorand/go-algorand/data/bookkeeping"
	"github.com/algorand/go-algorand/data/committee"
	"github.com/algorand/go-algorand/data/transactions"
	"github.com/algorand/go-algorand/data/transactions/logic"
	"github.com/algorand/go-algorand/data/transactions/verify"
	"github.com/algorand/go-algorand/ledger/ledgercore"
	"github.com/algorand/go-algorand/protocol"
)

type DummyLedgerForSignature struct {
	proto protocol.ConsensusVersion
}

func (d *DummyLedgerForSignature) BlockHdr(rnd basics.Round) (blk bookkeeping.BlockHeader, err error) {
	return createDummyBlockHeader(d.proto), nil
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

func createDummyBlockHeader(proto protocol.ConsensusVersion) bookkeeping.BlockHeader {
	if proto == "" {
		proto = protocol.ConsensusCurrentVersion
	}

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

// SKsigSigner holds the key pair for a salted-key signature (SKsig) scheme.
// Scheme is the 2-character scheme tag (e.g. "f1"), which is also the suffix of
// the data factory files signed with it.
type SKsigSigner struct {
	Scheme     string                      `codec:"scheme"`
	PublicKey  crypto.Falcon1024PublicKey  `codec:"pk"`
	PrivateKey crypto.Falcon1024PrivateKey `codec:"sk"`
}

// sigScheme returns the protocol tag for the signer's scheme.
func (s *SKsigSigner) sigScheme() protocol.SigScheme {
	if len(s.Scheme) != len(protocol.SigScheme{}) {
		panic(fmt.Sprintf("invalid sksig scheme %q", s.Scheme))
	}
	return protocol.SigScheme([]byte(s.Scheme))
}

// sign signs message with the signer's scheme.
func (s *SKsigSigner) sign(message crypto.Hashable) []byte {
	switch s.sigScheme() {
	case protocol.SigSchemeFalcon1024:
		signer := crypto.Falcon1024Signer{PublicKey: s.PublicKey, PrivateKey: s.PrivateKey}
		sig, err := signer.Sign(message)
		if err != nil {
			panic(err)
		}
		return sig
	default:
		panic(fmt.Sprintf("unsupported sksig scheme %q", s.Scheme))
	}
}

// saltedAddress returns the canonical salt and salted address of the signer.
func (s *SKsigSigner) saltedAddress() (basics.AddressSalt, basics.Address) {
	salt, address, err := basics.CanonicalAddressSalt(s.sigScheme(), slices.Clone(s.PublicKey[:]))
	if err != nil {
		panic(err)
	}
	return salt, address
}

// saltedKeySig signs message and wraps the signature in a SaltedKeySig.
func (s *SKsigSigner) saltedKeySig(message crypto.Hashable) transactions.SaltedKeySig {
	salt, _ := s.saltedAddress()
	return transactions.SaltedKeySig{
		Scheme:    s.sigScheme(),
		Salt:      salt,
		PublicKey: slices.Clone(s.PublicKey[:]),
		Signature: s.sign(message),
	}
}

// generateSKsigSigner generates a deterministic signer for SKsig test data
func generateSKsigSigner(scheme protocol.SigScheme) *SKsigSigner {
	if scheme != protocol.SigSchemeFalcon1024 {
		panic(fmt.Sprintf("unsupported sksig scheme %q", scheme))
	}

	var seed crypto.FalconSeed
	for i := range len(seed) {
		seed[i] = byte(i)
	}

	signer, err := crypto.GenerateFalcon1024Signer(seed)
	if err != nil {
		panic(err)
	}

	return &SKsigSigner{Scheme: scheme.String(), PublicKey: signer.PublicKey, PrivateKey: signer.PrivateKey}
}

// SKsigMnemonicData captures the mnemonic -> seed -> public key -> address chain
// used to exercise mnemonic-based SKsig key derivation without depending on
// the signature scheme in the consuming test suite.
type SKsigMnemonicData struct {
	Scheme    string `codec:"scheme"`
	Mnemonic  string `codec:"mnemonic"`
	Seed      []byte `codec:"seed"`
	PublicKey []byte `codec:"publicKey"`
	Address   string `codec:"address"`
}

// sksig25WordMnemonicToSeed mirrors the algosdk helper that derives a scheme
// seed from a mnemonic: it decodes the 25-word mnemonic to its 32-byte source
// key and derives the seed as genericHash("PQK" || scheme || sourceKey).
// algosdk's genericHash is SHA-512/256, which is exactly crypto.Hash here.
func sksig25WordMnemonicToSeed(mnemonic string, scheme protocol.SigScheme) []byte {
	sourceKey, err := passphrase.MnemonicToKey(mnemonic)
	if err != nil {
		panic(err)
	}

	preimage := append([]byte("PQK"), scheme[:]...)
	preimage = append(preimage, sourceKey...)

	seed := crypto.Hash(preimage)
	return seed[:]
}

// makeSKsigMnemonicData derives the SKsig key chain from the all-zero source key,
// whose 25-word mnemonic is the canonical "abandon ... invest" phrase.
func makeSKsigMnemonicData(scheme protocol.SigScheme) SKsigMnemonicData {
	if scheme != protocol.SigSchemeFalcon1024 {
		panic(fmt.Sprintf("unsupported sksig scheme %q", scheme))
	}

	mnemonic, err := passphrase.KeyToMnemonic(make([]byte, 32))
	if err != nil {
		panic(err)
	}

	seed := sksig25WordMnemonicToSeed(mnemonic, scheme)

	signer, err := crypto.GenerateFalcon1024Signer(crypto.FalconSeed(seed))
	if err != nil {
		panic(err)
	}
	publicKey := slices.Clone(signer.PublicKey[:])

	_, address, err := basics.CanonicalAddressSalt(scheme, publicKey)
	if err != nil {
		panic(err)
	}

	return SKsigMnemonicData{
		Scheme:    scheme.String(),
		Mnemonic:  mnemonic,
		Seed:      seed,
		PublicKey: publicKey,
		Address:   address.String(),
	}
}

// rekeyedSenderAddr returns a deterministic address distinct from any signer,
// used as the Sender of a rekeyed transaction. The account's own keys never
// sign; authorization comes from the AuthAddr the account was rekeyed to.
func rekeyedSenderAddr() basics.Address {
	var seed crypto.Seed
	for j := range len(seed) {
		seed[j] = byte(j + 100)
	}
	return basics.Address(crypto.GenerateSignatureSecrets(seed).SignatureVerifier)
}

const msigVersion = 1
const msigThreshold = 2

func generateMsigAddr(pks [3]crypto.PublicKey) basics.Address {
	addr, err := crypto.MultisigAddrGen(msigVersion, msigThreshold, pks[:])

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
	Signer    Signer   `codec:"signer"`
	Txns      []string `codec:"txns"`
	TxnBlobs  [][]byte `codec:"txnBlobs"`
	StxnBlobs [][]byte `codec:"stxnBlobs"`
	GroupID   string   `codec:"groupID"`
}

type Signer struct {
	SingleSigner  *crypto.SignatureSecrets  `codec:"singleSigner,omitempty"`
	MsigSigners   []crypto.SignatureSecrets `codec:"msigSigners,omitempty"`
	MsigVersion   uint8                     `codec:"msigVersion,omitempty"`
	MsigThreshold uint8                     `codec:"msigThreshold,omitempty"`
	Lsig          []byte                    `codec:"lsig,omitempty"`
	// LsigArgs are passed to Lsig. They are not signed but are part of the signed transaction.
	LsigArgs    [][]byte     `codec:"lsigArgs,omitempty"`
	SKsigSigner *SKsigSigner `codec:"sksigSigner,omitempty"`
	// RekeyedSender, when set, is used as the transaction Sender while the
	// signer authorizes on behalf of it via the AuthAddr field (i.e. the
	// sender account has been rekeyed to the signer's address).
	RekeyedSender *basics.Address `codec:"rekeyedSender,omitempty"`
}

func makeTxData(txType protocol.TxType, fields any, signer Signer) TxData {
	return makeTxDataWithHeader(txType, fields, signer, nil)
}

func makeTxDataWithHeader(txType protocol.TxType, fields any, signer Signer, updateHeader func(*transactions.Header)) TxData {
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

	// authAddr is the address that actually authorizes the transaction. For a
	// rekeyed transaction the Sender is a different account and authAddr is
	// carried in the AuthAddr field; otherwise the Sender authorizes itself.
	authAddr := addr(signer)

	stxn.Txn.Type = txType
	stxn.Txn.Header = transactions.Header{
		Sender:      authAddr,
		FirstValid:  50659540,
		LastValid:   50660540,
		GenesisHash: gh,
		GenesisID:   "testnet-v1.0",
		Fee:         basics.MicroAlgos{Raw: 1000},
	}
	if updateHeader != nil {
		updateHeader(&stxn.Txn.Header)
	}

	if signer.RekeyedSender != nil {
		stxn.Txn.Header.Sender = *signer.RekeyedSender
		stxn.AuthAddr = authAddr
	}

	if len(signer.Lsig) > 0 {
		stxn.Lsig.Args = signer.LsigArgs
	}

	if signer.SKsigSigner != nil && len(signer.Lsig) > 0 {
		// SKsig-delegated logic signature: the salted-address account delegates
		// signing authority to the program by signing an SKsigDelegatedProgram
		// bound to its own (authorizer) address.
		stxn.Lsig.Logic = signer.Lsig

		program := logic.SKsigDelegatedProgram{Addr: authAddr, Program: signer.Lsig}
		stxn.Lsig.SKsig = signer.SKsigSigner.saltedKeySig(program)
	} else if signer.SKsigSigner != nil {
		stxn.SKsig = signer.SKsigSigner.saltedKeySig(stxn.Txn)
	} else if len(signer.Lsig) > 0 {
		program := logic.Program(signer.Lsig)
		stxn.Lsig.Logic = signer.Lsig

		if signer.SingleSigner != nil {
			stxn.Lsig.Sig = signer.SingleSigner.Sign(program)
		} else if len(signer.MsigSigners) > 0 {
			var pks [3]crypto.PublicKey
			for i := range signer.MsigSigners {
				pks[i] = signer.MsigSigners[i].SignatureVerifier
			}

			toBeSigned := logic.MultisigProgram{Addr: crypto.Digest(authAddr), Program: program}

			stxn.Lsig.LMsig.Threshold = msigThreshold
			stxn.Lsig.LMsig.Version = msigVersion
			stxn.Lsig.LMsig.Subsigs = make([]crypto.MultisigSubsig, len(pks))

			// Every key is listed, but only the first msigThreshold sign
			for i := range signer.MsigSigners {
				stxn.Lsig.LMsig.Subsigs[i].Key = pks[i]
				if i < msigThreshold {
					stxn.Lsig.LMsig.Subsigs[i].Sig = signer.MsigSigners[i].Sign(toBeSigned)
				}
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
			Version:   msigVersion,
			Threshold: msigThreshold,
			Subsigs:   make([]crypto.MultisigSubsig, len(pks)),
		}

		// Every key is listed, but only the first msigThreshold sign
		for i := range signer.MsigSigners {
			stxn.Msig.Subsigs[i].Key = pks[i]
			if i < msigThreshold {
				stxn.Msig.Subsigs[i].Sig = signer.MsigSigners[i].Sign(stxn.Txn)
			}
		}

	}
	stxns := make([]transactions.SignedTxn, 1)
	stxns[0] = stxn

	// The f1 (Falcon-1024) SKsig scheme is enabled from consensus v42, so
	// every signer, SKsig included, verifies against the current protocol.
	proto := protocol.ConsensusCurrentVersion

	blkHdr := createDummyBlockHeader(proto)
	ledger := DummyLedgerForSignature{proto: proto}

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
	if signer.SKsigSigner != nil {
		_, saltedAddr := signer.SKsigSigner.saltedAddress()
		return saltedAddr
	} else if signer.SingleSigner != nil {
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

func makePaymentWithAmount(signer Signer) TxData {
	return makeTxData(protocol.PaymentTx, transactions.PaymentTxnFields{
		Receiver: addr(signer),
		Amount:   basics.MicroAlgos{Raw: 1},
	}, signer)
}

func makeLargeNotePayment(signer Signer) TxData {
	return makeTxDataWithHeader(protocol.PaymentTx, transactions.PaymentTxnFields{
		Receiver: addr(signer),
		Amount:   basics.MicroAlgos{Raw: 1},
	}, signer, func(header *transactions.Header) {
		// One charged byte beyond the 1024-byte standard note limit.
		header.Note = make([]byte, 1025)
		header.Fee = basics.MicroAlgos{Raw: 1001}
	})
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

func makeAppResize(signer Signer) TxData {
	program, err := logic.AssembleString("#pragma version 13\nint 1")
	if err != nil {
		panic(err)
	}

	return makeTxData(protocol.ApplicationCallTx, transactions.ApplicationCallTxnFields{
		ApplicationID:     appId,
		OnCompletion:      transactions.UpdateApplicationOC,
		ApprovalProgram:   program.Program,
		ClearStateProgram: program.Program,
		GlobalStateSchema: basics.StateSchema{NumUint: 3, NumByteSlice: 1},
		ExtraProgramPages: 2,
	}, signer)
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
		RejectVersion: 2,
	}

	return makeTxData(protocol.ApplicationCallTx, appCallFields, signer)
}

// makeAppCallWithAccess builds an app call whose resources are named in the
// access list (al) rather than the legacy foreign arrays, exercising every kind
// of ResourceRef. Holding, Locals and Box references are 1-based indices into
// the access list itself, with 0 meaning the sender (address), the current app
// (locals app, box app).
func makeAppCallWithAccess(signer Signer, otherAddr basics.Address) TxData {
	const otherAppId = basics.AppIndex(84366826)

	access := []transactions.ResourceRef{
		{Address: otherAddr}, // 1: address
		{Asset: assetId},     // 2: asset
		{App: otherAppId},    // 3: app
		{Holding: transactions.HoldingRef{Address: 1, Asset: 2}},  // otherAddr's holding of assetId
		{Holding: transactions.HoldingRef{Address: 0, Asset: 2}},  // sender's holding of assetId
		{Locals: transactions.LocalsRef{Address: 1, App: 3}},      // otherAddr's locals in otherAppId
		{Locals: transactions.LocalsRef{Address: 1, App: 0}},      // otherAddr's locals in the current app
		{Box: transactions.BoxRef{Index: 3, Name: []byte("box")}}, // box of otherAppId
		{Box: transactions.BoxRef{Index: 0, Name: []byte("box")}}, // box of the current app
		{}, // empty reference, which only bumps the box read/write quota
	}

	return makeTxData(protocol.ApplicationCallTx, transactions.ApplicationCallTxnFields{
		ApplicationID: appId,
		OnCompletion:  transactions.NoOpOC,
		Access:        access,
	}, signer)
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
			Decimals:      2,
			DefaultFrozen: true,
			UnitName:      "TEST",
			AssetName:     "Test Asset",
			URL:           "https://example.com",
			MetadataHash:  crypto.Hash([]byte("asset metadata")),
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

func makeClosePayment(signer Signer, closeTo basics.Address) TxData {
	return makeTxData(protocol.PaymentTx, transactions.PaymentTxnFields{
		Receiver:         closeTo,
		Amount:           basics.MicroAlgos{Raw: 1},
		CloseRemainderTo: closeTo,
	}, signer)
}

func makeLeasePayment(signer Signer) TxData {
	return makeTxDataWithHeader(protocol.PaymentTx, transactions.PaymentTxnFields{}, signer, func(header *transactions.Header) {
		header.Lease = crypto.Hash([]byte("lease"))
	})
}

// makeRekeyPayment rekeys the sender to rekeyTo (the RekeyTo header field). It
// is distinct from the rekeyed* files, which are signed by an account that was
// previously rekeyed to (the AuthAddr field).
func makeRekeyPayment(signer Signer, rekeyTo basics.Address) TxData {
	return makeTxDataWithHeader(protocol.PaymentTx, transactions.PaymentTxnFields{}, signer, func(header *transactions.Header) {
		header.RekeyTo = rekeyTo
	})
}

// makeAssetClawback is sent by the clawback account to move assets out of
// revokeFrom (AssetSender) to the receiver.
func makeAssetClawback(signer Signer, revokeFrom basics.Address) TxData {
	return makeTxData(protocol.AssetTransferTx, transactions.AssetTransferTxnFields{
		XferAsset:     assetId,
		AssetAmount:   500,
		AssetSender:   revokeFrom,
		AssetReceiver: addr(signer),
	}, signer)
}

// makeAssetCloseOut sends the remaining holding to closeTo and opts out.
func makeAssetCloseOut(signer Signer, closeTo basics.Address) TxData {
	return makeTxData(protocol.AssetTransferTx, transactions.AssetTransferTxnFields{
		XferAsset:     assetId,
		AssetAmount:   1,
		AssetReceiver: closeTo,
		AssetCloseTo:  closeTo,
	}, signer)
}

func makeAppCallWithOnCompletion(signer Signer, oc transactions.OnCompletion) TxData {
	return makeTxData(protocol.ApplicationCallTx, transactions.ApplicationCallTxnFields{
		ApplicationID: appId,
		OnCompletion:  oc,
	}, signer)
}

// makeAppCallWithForeignRefs names its resources in the legacy foreign arrays
// (which cannot be combined with the access list) and passes app args. Box
// references index into ForeignApps, where 0 means the current app.
func makeAppCallWithForeignRefs(signer Signer, otherAddr basics.Address) TxData {
	const otherAppId = basics.AppIndex(84366826)

	return makeTxData(protocol.ApplicationCallTx, transactions.ApplicationCallTxnFields{
		ApplicationID:   appId,
		OnCompletion:    transactions.NoOpOC,
		ApplicationArgs: [][]byte{[]byte("foo"), {0x01, 0x02}, {}},
		Accounts:        []basics.Address{otherAddr},
		ForeignAssets:   []basics.AssetIndex{assetId},
		ForeignApps:     []basics.AppIndex{otherAppId},
		Boxes: []transactions.BoxRef{
			{Index: 0, Name: []byte("box")}, // box of the current app
			{Index: 1, Name: []byte("box")}, // box of ForeignApps[0]
		},
	}, signer)
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
	// The group must contain distinct transactions under current consensus.
	pay2 := makePaymentWithAmount(signer)
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

	blkHdr := createDummyBlockHeader(protocol.ConsensusCurrentVersion)
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
		Signer:    signer,
		Txns:      []string{"simplePayment", "paymentWithAmount", "appCall"},
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

// dataDir is inside features/ so that SDK test harnesses, which copy the features tree, pick it up
const dataDir = "../features/resources/data_factory"

// writeTestDataFile writes a single test data item to a JSON file
func writeTestDataFile(name string, data any) {
	filename := filepath.Join(dataDir, name+".json")

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
		MsigSigners:   []crypto.SignatureSecrets{*secrets[0], *secrets[1], *secrets[2]},
		MsigVersion:   msigVersion,
		MsigThreshold: msigThreshold,
	}

	op, err := logic.AssembleString("int 1")

	if err != nil {
		panic(err)
	}

	// Every logic sig uses this program and args. The program only approves when it receives exactly these
	// args, so verification proves they are passed through.
	lsigOp, err := logic.AssembleString("arg 0\nbyte \"foo\"\n==\narg 1\nbyte 0x0102\n==\n&&")
	if err != nil {
		panic(err)
	}
	lsigProgram := lsigOp.Program
	lsigArgs := [][]byte{[]byte("foo"), {0x01, 0x02}}

	lsigSigner := Signer{
		Lsig:     lsigProgram,
		LsigArgs: lsigArgs,
	}

	delegatedSigner := Signer{
		SingleSigner: secrets[0],
		Lsig:         lsigProgram,
		LsigArgs:     lsigArgs,
	}

	sksigSigner := Signer{
		SKsigSigner: generateSKsigSigner(protocol.SigSchemeFalcon1024),
	}

	sksigDelegatedSigner := Signer{
		SKsigSigner: generateSKsigSigner(protocol.SigSchemeFalcon1024),
		Lsig:        lsigProgram,
		LsigArgs:    lsigArgs,
	}

	msigDelegatedSigner := Signer{
		MsigSigners:   []crypto.SignatureSecrets{*secrets[0], *secrets[1], *secrets[2]},
		MsigVersion:   msigVersion,
		MsigThreshold: msigThreshold,
		Lsig:          lsigProgram,
		LsigArgs:      lsigArgs,
	}

	rekeyedSender := rekeyedSenderAddr()

	rekeyedSigner := Signer{
		SingleSigner:  secrets[0],
		RekeyedSender: &rekeyedSender,
	}

	sksigRekeyedSigner := Signer{
		SKsigSigner:   generateSKsigSigner(protocol.SigSchemeFalcon1024),
		RekeyedSender: &rekeyedSender,
	}

	rekeyedDelegatedSigner := Signer{
		SingleSigner:  secrets[0],
		Lsig:          lsigProgram,
		LsigArgs:      lsigArgs,
		RekeyedSender: &rekeyedSender,
	}

	sksigRekeyedDelegatedSigner := Signer{
		SKsigSigner:   generateSKsigSigner(protocol.SigSchemeFalcon1024),
		Lsig:          lsigProgram,
		LsigArgs:      lsigArgs,
		RekeyedSender: &rekeyedSender,
	}

	rekeyedMsigSigner := Signer{
		MsigSigners:   []crypto.SignatureSecrets{*secrets[0], *secrets[1], *secrets[2]},
		MsigVersion:   msigVersion,
		MsigThreshold: msigThreshold,
		RekeyedSender: &rekeyedSender,
	}

	// The sender is rekeyed to the escrow program's address
	rekeyedLsigSigner := Signer{
		Lsig:          lsigProgram,
		LsigArgs:      lsigArgs,
		RekeyedSender: &rekeyedSender,
	}

	rekeyedMsigDelegatedSigner := Signer{
		MsigSigners:   []crypto.SignatureSecrets{*secrets[0], *secrets[1], *secrets[2]},
		MsigVersion:   msigVersion,
		MsigThreshold: msigThreshold,
		Lsig:          lsigProgram,
		LsigArgs:      lsigArgs,
		RekeyedSender: &rekeyedSender,
	}

	writeTestDataFile("simplePayment", makeSimplePayment(simpleSigner))
	writeTestDataFile("paymentWithAmount", makePaymentWithAmount(simpleSigner))
	writeTestDataFile("largeNotePayment", makeLargeNotePayment(simpleSigner))
	writeTestDataFile("simpleAssetTransfer", makeSimpleAssetTransfer(simpleSigner))
	writeTestDataFile("optInAssetTransfer", makeOptInAssetTransfer(simpleSigner))
	writeTestDataFile("appCreate", makeAppCreate(simpleSigner, op.Program))
	writeTestDataFile("appUpdate", makeAppUpdate(simpleSigner, op.Program))
	writeTestDataFile("appResize", makeAppResize(simpleSigner))
	writeTestDataFile("appDelete", makeAppDelete(simpleSigner))
	writeTestDataFile("appCall", makeAppCall(simpleSigner))
	otherAddr := addr(Signer{SingleSigner: secrets[1]})

	writeTestDataFile("appCallWithAccess", makeAppCallWithAccess(simpleSigner, otherAddr))
	writeTestDataFile("appCallWithForeignRefs", makeAppCallWithForeignRefs(simpleSigner, otherAddr))
	writeTestDataFile("appOptIn", makeAppCallWithOnCompletion(simpleSigner, transactions.OptInOC))
	writeTestDataFile("appCloseOut", makeAppCallWithOnCompletion(simpleSigner, transactions.CloseOutOC))
	writeTestDataFile("appClearState", makeAppCallWithOnCompletion(simpleSigner, transactions.ClearStateOC))
	writeTestDataFile("closePayment", makeClosePayment(simpleSigner, otherAddr))
	writeTestDataFile("leasePayment", makeLeasePayment(simpleSigner))
	writeTestDataFile("rekeyPayment", makeRekeyPayment(simpleSigner, otherAddr))
	writeTestDataFile("assetClawback", makeAssetClawback(simpleSigner, otherAddr))
	writeTestDataFile("assetCloseOut", makeAssetCloseOut(simpleSigner, otherAddr))
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
	writeTestDataFile("sksigPayment_f1", makeSimplePayment(sksigSigner))
	writeTestDataFile("sksigDelegatedPayment_f1", makeSimplePayment(sksigDelegatedSigner))
	writeTestDataFile("rekeyedPayment", makeSimplePayment(rekeyedSigner))
	writeTestDataFile("sksigRekeyedPayment_f1", makeSimplePayment(sksigRekeyedSigner))
	writeTestDataFile("rekeyedDelegatedPayment", makeSimplePayment(rekeyedDelegatedSigner))
	writeTestDataFile("sksigRekeyedDelegatedPayment_f1", makeSimplePayment(sksigRekeyedDelegatedSigner))
	writeTestDataFile("rekeyedMsigPayment", makeSimplePayment(rekeyedMsigSigner))
	writeTestDataFile("rekeyedLsigPayment", makeSimplePayment(rekeyedLsigSigner))
	writeTestDataFile("rekeyedMsigDelegatedPayment", makeSimplePayment(rekeyedMsigDelegatedSigner))
	writeTestDataFile("sksigMnemonic_f1", makeSKsigMnemonicData(protocol.SigSchemeFalcon1024))

}
