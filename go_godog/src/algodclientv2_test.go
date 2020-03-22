package main

import (
	"github.com/cucumber/godog"
)

func AlgodClientV2Context(s *godog.Suite) {
	s.Step(`^we make any Shutdown call, return mock response "([^"]*)"$`, weMakeAnyShutdownCallReturnMockResponse)
	s.Step(`^we make any Register Participation Keys call, return mock response "([^"]*)"$`, weMakeAnyRegisterParticipationKeysCallReturnMockResponse)
	s.Step(`^we make any Pending Transaction Information call, return mock response "([^"]*)"$`, weMakeAnyPendingTransactionInformationCallReturnMockResponse)
	s.Step(`^the parsed Pending Transaction Information response should have sender "([^"]*)"$`, theParsedPendingTransactionInformationResponseShouldHaveSender)
	s.Step(`^we make any Send Raw Transaction call, return mock response "([^"]*)"$`, weMakeAnySendRawTransactionCallReturnMockResponse)
	s.Step(`^the parsed Send Raw Transaction response should have txid "([^"]*)"$`, theParsedSendRawTransactionResponseShouldHaveTxid)
	s.Step(`^we make any Pending Transactions By Address call, return mock response "([^"]*)"$`, weMakeAnyPendingTransactionsByAddressCallReturnMockResponse)
	s.Step(`^the parsed Pending Transactions By Address response should contain an array of len (\d+) and element number (\d+) should have sender "([^"]*)"$`, theParsedPendingTransactionsByAddressResponseShouldContainAnArrayOfLenAndElementNumberShouldHaveSender)
	s.Step(`^we make any Node Status call, return mock response "([^"]*)"$`, weMakeAnyNodeStatusCallReturnMockResponse)
	s.Step(`^the parsed Node Status response should have a last round of (\d+)$`, theParsedNodeStatusResponseShouldHaveALastRoundOf)
	s.Step(`^we make any Ledger Supply call, return mock response "([^"]*)"$`, weMakeAnyLedgerSupplyCallReturnMockResponse)
	s.Step(`^the parsed Ledger Supply response should have totalMoney (\d+) onlineMoney (\d+) on round (\d+)$`, theParsedLedgerSupplyResponseShouldHaveTotalMoneyOnlineMoneyOnRound)
	s.Step(`^we make any Status After Block call, return mock response "([^"]*)"$`, weMakeAnyStatusAfterBlockCallReturnMockResponse)
	s.Step(`^the parsed Status After Block response should have a last round of (\d+)$`, theParsedStatusAfterBlockResponseShouldHaveALastRoundOf)
	s.Step(`^we make any Account Information call, return mock response "([^"]*)"$`, weMakeAnyAccountInformationCallReturnMockResponse)
	s.Step(`^the parsed Account Information response should have address "([^"]*)"$`, theParsedAccountInformationResponseShouldHaveAddress)
	s.Step(`^we make any Get Block call, return mock response "([^"]*)"$`, weMakeAnyGetBlockCallReturnMockResponse)
	s.Step(`^the parsed Get Block response should have proposer "([^"]*)"$`, theParsedGetBlockResponseShouldHaveProposer)
	s.Step(`^we make any Suggested Transaction Parameters call, return mock response "([^"]*)"$`, weMakeAnySuggestedTransactionParametersCallReturnMockResponse)
	s.Step(`^the parsed Suggested Transaction Parameters response should have first round valid of (\d+)$`, theParsedSuggestedTransactionParametersResponseShouldHaveFirstRoundValidOf)
	s.BeforeScenario(func(interface{}) {
	})
}

func weMakeAnyShutdownCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func weMakeAnyRegisterParticipationKeysCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func weMakeAnyPendingTransactionInformationCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedPendingTransactionInformationResponseShouldHaveSender(arg1 string) error {
	return godog.ErrPending
}

func weMakeAnySendRawTransactionCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedSendRawTransactionResponseShouldHaveTxid(arg1 string) error {
	return godog.ErrPending
}

func weMakeAnyPendingTransactionsByAddressCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedPendingTransactionsByAddressResponseShouldContainAnArrayOfLenAndElementNumberShouldHaveSender(arg1, arg2 int, arg3 string) error {
	return godog.ErrPending
}

func weMakeAnyNodeStatusCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedNodeStatusResponseShouldHaveALastRoundOf(arg1 int) error {
	return godog.ErrPending
}

func weMakeAnyLedgerSupplyCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedLedgerSupplyResponseShouldHaveTotalMoneyOnlineMoneyOnRound(arg1, arg2, arg3 int) error {
	return godog.ErrPending
}

func weMakeAnyStatusAfterBlockCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedStatusAfterBlockResponseShouldHaveALastRoundOf(arg1 int) error {
	return godog.ErrPending
}

func weMakeAnyAccountInformationCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedAccountInformationResponseShouldHaveAddress(arg1 string) error {
	return godog.ErrPending
}

func weMakeAnyGetBlockCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedGetBlockResponseShouldHaveProposer(arg1 string) error {
	return godog.ErrPending
}

func weMakeAnySuggestedTransactionParametersCallReturnMockResponse(arg1 string) error {
	return godog.ErrPending
}

func theParsedSuggestedTransactionParametersResponseShouldHaveFirstRoundValidOf(arg1 int) error {
	return godog.ErrPending
}
