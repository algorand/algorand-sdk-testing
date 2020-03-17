package main

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"

	"github.com/algorand/go-algorand-sdk/client/indexer"
	"github.com/algorand/go-algorand-sdk/client/indexer/models"

	"github.com/cucumber/godog"
)

func IndexerContext(s *godog.Suite) {
	s.Step(`^we make any LookupAssetBalances call, return mock response "([^"]*)"$`, weMakeAnyLookupAssetBalancesCallReturnMockResponse)
	s.Step(`^the parsed LookupAssetBalances response should be valid on round (\d+), and contain an array of len (\d+) and element number (\d+) should have address "([^"]*)" amount (\d+) and frozen state (\d+)$`, theParsedLookupAssetBalancesResponseShouldBeValidOnRoundAndContainAnArrayOfLenAndElementNumberShouldHaveAddressAmountAndFrozenState)
	s.Step(`^we make any LookupAssetTransactions call, return mock response "([^"]*)"$`, weMakeAnyLookupAssetTransactionsCallReturnMockResponse)
	s.Step(`^the parsed LookupAssetTransactions response should be valid on round (\d+), and contain an array of len (\d+) and element number (\d+) should have sender "([^"]*)"$`, theParsedLookupAssetTransactionsResponseShouldBeValidOnRoundAndContainAnArrayOfLenAndElementNumberShouldHaveSender)
	s.Step(`^we make any LookupAccountTransactions call, return mock response "([^"]*)"$`, weMakeAnyLookupAccountTransactionsCallReturnMockResponse)
	s.Step(`^the parsed LookupAccountTransactions response should be valid on round (\d+), and contain an array of len (\d+) and element number (\d+) should have sender "([^"]*)"$`, theParsedLookupAccountTransactionsResponseShouldBeValidOnRoundAndContainAnArrayOfLenAndElementNumberShouldHaveSender)
	s.Step(`^we make any LookupBlock call, return mock response "([^"]*)"$`, weMakeAnyLookupBlockCallReturnMockResponse)
	s.Step(`^the parsed LookupBlock response should have proposer "([^"]*)"$`, theParsedLookupBlockResponseShouldHaveProposer)
	s.Step(`^we make any LookupAccountByID call, return mock response "([^"]*)"$`, weMakeAnyLookupAccountByIDCallReturnMockResponse)
	s.Step(`^the parsed LookupAccountByID response should have address "([^"]*)"$`, theParsedLookupAccountByIDResponseShouldHaveAddress)
	s.Step(`^we make any LookupAssetByID call, return mock response "([^"]*)"$`, weMakeAnyLookupAssetByIDCallReturnMockResponse)
	s.Step(`^the parsed LookupAssetByID response should have index TODO$`, theParsedLookupAssetByIDResponseShouldHaveIndexTODO)
	s.Step(`^we make any SearchAccounts call, return mock response "([^"]*)"$`, weMakeAnySearchAccountsCallReturnMockResponse)
	s.Step(`^the parsed SearchAccounts response should be valid on round (\d+) and the array should be of len (\d+) and the element at index (\d+) should have address "([^"]*)"$`, theParsedSearchAccountsResponseShouldBeValidOnRoundAndTheArrayShouldBeOfLenAndTheElementAtIndexShouldHaveAddress)
	s.Step(`^we make any SearchForTransactions call, return mock response "([^"]*)"$`, weMakeAnySearchForTransactionsCallReturnMockResponse)
	s.Step(`^the parsed SearchForTransactions response should be valid on round (\d+) and the array should be of len (\d+) and the element at index (\d+) should have sender "([^"]*)"$`, theParsedSearchForTransactionsResponseShouldBeValidOnRoundAndTheArrayShouldBeOfLenAndTheElementAtIndexShouldHaveSender)
	s.Step(`^we make any SearchForAssets call, return mock response "([^"]*)"$`, weMakeAnySearchForAssetsCallReturnMockResponse)
	s.Step(`^the parsed SearchForAssets response should be valid on round (\d+) and the array should be of len (\d+) and the element at index (\d+) should have asset index (\d+)$`, theParsedSearchForAssetsResponseShouldBeValidOnRoundAndTheArrayShouldBeOfLenAndTheElementAtIndexShouldHaveAssetIndex)

	s.BeforeScenario(func(interface{}) {
	})
}

func loadMockJson(filename string) ([]byte, error) {
	// TODO EJR where should the mockjsons be stored? or should the feature file just hold the full path somehow
	return nil, nil
}

func buildMockIndexerAndClient(jsonfile string) (*httptest.Server, indexer.Client, error) {
	jsonBytes, err := loadMockJson(jsonfile)
	if err != nil {
		return nil, indexer.Client{}, err
	}
	mockIndexer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write(jsonBytes)
	}))
	noToken := ""
	indexerClient, err := indexer.MakeClient(mockIndexer.URL, noToken)
	return mockIndexer, indexerClient, err
}

var validRound uint64
var assetHolders []models.MiniAssetHolding

func weMakeAnyLookupAssetBalancesCallReturnMockResponse(jsonfile string) error {
	mockIndexer, indexerClient, err := buildMockIndexerAndClient(jsonfile)
	if mockIndexer != nil {
		defer mockIndexer.Close()
	}
	if err != nil {
		return err
	}
	// make the call
	validRound, assetHolders, err = indexerClient.LookupAssetBalances(context.Background(), 0, models.LookupAssetBalancesParams{}, nil)
	return err
}

func theParsedLookupAssetBalancesResponseShouldBeValidOnRoundAndContainAnArrayOfLenAndElementNumberShouldHaveAddressAmountAndFrozenState(roundNum, length, idx int, address string, amount, frozenState int) error {
	if uint64(roundNum) != validRound {
		return fmt.Errorf("roundNum %d mismatched with validRound %d", roundNum, validRound)
	}
	if len(assetHolders) != length {
		return fmt.Errorf("len(assetHolders) %d mismatched with length %d", len(assetHolders), length)
	}
	examinedHolder := assetHolders[idx]
	var expectedFrozenState bool
	if frozenState == 0 {
		expectedFrozenState = false
	} else {
		expectedFrozenState = true
	}
	if examinedHolder.IsFrozen != expectedFrozenState {
		return fmt.Errorf("examinedHolder.IsFrozen %v mismatched with expectedFrozenState %v", examinedHolder.IsFrozen, expectedFrozenState)
	}
	if examinedHolder.Address != address {
		return fmt.Errorf("examinedHolder.Address %s mismatched with expected address %s", examinedHolder.Address, address)
	}
	if examinedHolder.Amount != uint64(amount) {
		return fmt.Errorf("examinedHolder.Amount %d mismatched with expected amount %s", examinedHolder.Amount, uint64(amount))
	}
	return nil
}

func weMakeAnyLookupAssetTransactionsCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedLookupAssetTransactionsResponseShouldBeValidOnRoundAndContainAnArrayOfLenAndElementNumberShouldHaveSender(arg1, arg2, arg3 int, arg4 string) error {
	return godog.ErrPending
}

func weMakeAnyLookupAccountTransactionsCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedLookupAccountTransactionsResponseShouldBeValidOnRoundAndContainAnArrayOfLenAndElementNumberShouldHaveSender(arg1, arg2, arg3 int, arg4 string) error {
	return godog.ErrPending
}

func weMakeAnyLookupBlockCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedLookupBlockResponseShouldHaveProposer(arg1 string) error {
	return godog.ErrPending
}

func weMakeAnyLookupAccountByIDCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedLookupAccountByIDResponseShouldHaveAddress(arg1 string) error {
	return godog.ErrPending
}

func weMakeAnyLookupAssetByIDCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedLookupAssetByIDResponseShouldHaveIndexTODO() error {
	return godog.ErrPending
}

func weMakeAnySearchAccountsCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedSearchAccountsResponseShouldBeValidOnRoundAndTheArrayShouldBeOfLenAndTheElementAtIndexShouldHaveAddress(arg1, arg2, arg3 int, arg4 string) error {
	return godog.ErrPending
}

func weMakeAnySearchForTransactionsCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedSearchForTransactionsResponseShouldBeValidOnRoundAndTheArrayShouldBeOfLenAndTheElementAtIndexShouldHaveSender(arg1, arg2, arg3 int, arg4 string) error {
	return godog.ErrPending
}

func weMakeAnySearchForAssetsCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedSearchForAssetsResponseShouldBeValidOnRoundAndTheArrayShouldBeOfLenAndTheElementAtIndexShouldHaveAssetIndex(arg1, arg2, arg3, arg4 int) error {
	return godog.ErrPending
}
