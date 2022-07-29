package govermentAgent

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

func CreateWalletDID(c *GovAgentClient) (*WalletInfo, error) {
	url := "/wallet/did/create"
	input := NewCreateWalletsInput()
	jsonBody, err := input.ToJson()
	if err != nil {
		return nil, fmt.Errorf("error convert to json")
	}
	resp, err := c.sendRequest(http.MethodPost, url, jsonBody)
	if err != nil {
		return nil, err
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("error reading response body")
	}
	var walletResult NewWalletResult
	err = json.Unmarshal(body, &walletResult)
	if err != nil {
		return nil, fmt.Errorf("error convert json data")
	}

	return &WalletInfo{
		Did:    walletResult.Result.Did,
		VerKey: walletResult.Result.Verkey,
	}, nil
}
