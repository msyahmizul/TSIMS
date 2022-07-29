package govermentAgent

import "encoding/json"

type CreateWalletsInput struct {
	Method  string `json:"method"`
	Options struct {
		KeyType string `json:"key_type"`
	} `json:"options"`
}
type WalletInfo struct {
	Did    string
	VerKey string
}
type NewWalletResult struct {
	Result struct {
		Did     string `json:"did"`
		KeyType string `json:"key_type"`
		Method  string `json:"method"`
		Posture string `json:"posture"`
		Verkey  string `json:"verkey"`
	} `json:"result"`
}

func (wi *CreateWalletsInput) ToJson() ([]byte, error) {
	return json.Marshal(wi)
}
func NewCreateWalletsInput() CreateWalletsInput {
	return CreateWalletsInput{
		Method: "sov",
		Options: struct {
			KeyType string `json:"key_type"`
		}{
			KeyType: "ed25519",
		},
	}
}
