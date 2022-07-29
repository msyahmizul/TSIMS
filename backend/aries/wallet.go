package aries

import (
	"TSIMS/appwrite"
	"TSIMS/appwrite/user"
	"TSIMS/model/userModel"
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
)

func GenerateWalletTokenMultiTenant(username string, c *appwrite.APClient, multiTenant Agent) (*string, error) {
	u, err := user.QuerySingeUserByUsername(c, username)
	if err != nil {
		return nil, err
	}

	url := fmt.Sprintf("/multitenancy/wallet/%s/token", u.WalletID)
	res, err := multiTenant.SendAPIRequestAdmin(http.MethodPost, url, nil, "200 OK")
	if err != nil {
		return nil, err
	}
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	var msg struct {
		Token string
	}
	err = json.Unmarshal(body, &msg)
	if err != nil {
		return nil, fmt.Errorf("error Decode Result")
	}

	return &msg.Token, nil
}

func GenerateUserWallet(c *appwrite.APClient, username string, multiTenant Agent) (*userModel.User, error) {
	u, err := user.QuerySingeUserByUsername(c, username)
	if err != nil {
		return nil, err
	}
	if u.WalletID != "" {
		return nil, fmt.Errorf("User already has public wallet")
	}
	url := fmt.Sprintf("/multitenancy/wallet")

	if err != nil {
		return nil, err
	}
	if u.ApplicantStatus != userModel.ApplicantStatusApprove {
		return nil, fmt.Errorf("user not approve by admin")
	}
	ud, err := user.QuerySingleUserDataByUsername(c, username)
	if err != nil {
		return nil, err
	}

	jsData, err := json.Marshal(CreateNewSubWallet(ud.FirstName, u.Password, u.Username))
	if err != nil {
		return nil, err
	}
	res, err := multiTenant.SendAPIRequestAdmin(http.MethodPost, url, bytes.NewBuffer(jsData), "200 OK")
	if err != nil {
		return nil, err
	}
	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		return nil, readErr
	}
	var walletData NewWalletResponse
	err = json.Unmarshal(body, &walletData)
	if err != nil {
		return nil, fmt.Errorf("error Decode Result")
	}
	u.WalletID = walletData.WalletID
	up, err := user.UpdateUser(c, *u)
	if err != nil {
		return nil, err
	}
	return up, nil
}

func GenerateUserDID(c *appwrite.APClient, username string, multiTenant Agent) (*userModel.User, error) {
	url := "/wallet/did/create"
	token, err := GenerateWalletTokenMultiTenant(username, c, multiTenant)
	if err != nil {
		return nil, err
	}
	res, err := multiTenant.SendAPIRequestMultiTenantUser(*token, http.MethodPost, url, nil, "200 OK")
	if err != nil {
		return nil, err
	}
	var didData NewDIDResponse
	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		return nil, readErr
	}
	err = json.Unmarshal(body, &didData)
	if err != nil {
		return nil, fmt.Errorf("error Decode Result")
	}
	u, err := user.QuerySingeUserByUsername(c, username)
	if err != nil {
		return nil, err
	}
	u.Did = didData.Result.Did
	updateUser, err := user.UpdateUser(c, *u)
	if err != nil {
		return nil, err
	}
	return updateUser, err
}

func PostDIDToLedger(username string, c *appwrite.APClient, multiTenant Agent, govAgent Agent) error {
	u, err := user.QuerySingeUserByUsername(c, username)
	if err != nil {
		return err
	}
	ud, err := user.QuerySingleUserDataByUsername(c, username)
	if err != nil {
		return err
	}
	token, err := GenerateWalletTokenMultiTenant(username, c, multiTenant)
	if err != nil {
		return err
	}
	ur := fmt.Sprintf("/wallet/did?did=%s", u.Did)
	res, err := multiTenant.SendAPIRequestMultiTenantUser(*token, http.MethodGet, ur, nil, "200 OK")
	if err != nil {
		return err
	}
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return err
	}
	var didData GetAllWalletInfoResponse
	err = json.Unmarshal(body, &didData)
	if err != nil {
		return fmt.Errorf("error unmarshalling data")
	}
	if len(didData.Results) != 1 {
		return fmt.Errorf("unknow error cannot find did data in wallet")
	}
	if didData.Results[0].Posture == "posted" {
		return nil
	}

	urlBuilder, err := url.Parse(fmt.Sprintf("%s%s", govAgent.AdminConfig.Url, "/ledger/register-nym"))
	if err != nil {
		log.Fatal(err)
	}
	q := urlBuilder.Query()
	q.Set("did", didData.Results[0].Did)
	q.Set("verkey", didData.Results[0].Verkey)
	q.Set("alias", fmt.Sprintf("%s Public DID", ud.FirstName))
	urlBuilder.RawQuery = q.Encode()

	_, err = govAgent.SendRequestAdminParam(http.MethodPost, urlBuilder.String(), "200 OK")
	if err != nil {
		return err
	}
	return nil
}
func SetAsMainWallet(username string, c *appwrite.APClient, multiTenant Agent) error {
	u, err := user.QuerySingeUserByUsername(c, username)
	if err != nil {
		return err
	}
	token, err := GenerateWalletTokenMultiTenant(username, c, multiTenant)
	if err != nil {
		return err
	}
	ur := fmt.Sprintf("/wallet/did/public?did=%s", u.Did)
	_, err = multiTenant.SendAPIRequestMultiTenantUser(*token, http.MethodPost, ur, nil, "200 OK")
	if err != nil {
		return err
	}
	ur = fmt.Sprintf("/wallet/did/public")
	res, err := multiTenant.SendAPIRequestMultiTenantUser(*token, http.MethodGet, ur, nil, "200 OK")
	if err != nil {
		return err
	}
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return err
	}
	var pubWall GetCurrentPublicWalletDID
	err = json.Unmarshal(body, &pubWall)
	if err != nil {
		return fmt.Errorf("error unmarshalling data")
	}
	if pubWall.Result.Did != u.Did {
		return fmt.Errorf("error set user wallet to public wallet")
	}

	return nil
}

func CreateNewSubWallet(name string, walletKey string, username string) CreateSubWalletInput {
	return CreateSubWalletInput{
		KeyManagementMode:  "managed",
		Label:              fmt.Sprintf("%s Wallet", name),
		WalletDispatchType: "default",
		WalletKey:          walletKey,
		WalletName:         username,
		WalletType:         "indy",
	}
}
