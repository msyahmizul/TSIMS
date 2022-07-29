package aries

import "time"

type CreateSubWalletInput struct {
	KeyManagementMode  string `json:"key_management_mode"`
	Label              string `json:"label"`
	WalletDispatchType string `json:"wallet_dispatch_type"`
	WalletKey          string `json:"wallet_key"`
	WalletName         string `json:"wallet_name"`
	WalletType         string `json:"wallet_type"`
}

type NewWalletResponse struct {
	WalletID          string    `json:"wallet_id"`
	KeyManagementMode string    `json:"key_management_mode"`
	UpdatedAt         time.Time `json:"updated_at"`
	CreatedAt         time.Time `json:"created_at"`
	Settings          struct {
		WalletType         string        `json:"wallet.type"`
		WalletName         string        `json:"wallet.name"`
		WalletWebhookUrls  []interface{} `json:"wallet.webhook_urls"`
		WalletDispatchType string        `json:"wallet.dispatch_type"`
		DefaultLabel       string        `json:"default_label"`
		WalletId           string        `json:"wallet.id"`
	} `json:"settings"`
	Token string `json:"token"`
}

type NewDIDResponse struct {
	Result struct {
		Did     string `json:"did"`
		Verkey  string `json:"verkey"`
		Posture string `json:"posture"`
		KeyType string `json:"key_type"`
		Method  string `json:"method"`
	} `json:"result"`
}
type GetAllWalletInfoResponse struct {
	Results []struct {
		Did     string `json:"did"`
		Verkey  string `json:"verkey"`
		Posture string `json:"posture"`
		KeyType string `json:"key_type"`
		Method  string `json:"method"`
	} `json:"results"`
}

type GetCurrentPublicWalletDID struct {
	Result struct {
		Did     string `json:"did"`
		Verkey  string `json:"verkey"`
		Posture string `json:"posture"`
		KeyType string `json:"key_type"`
		Method  string `json:"method"`
	} `json:"result"`
}
