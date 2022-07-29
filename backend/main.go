package main

import "TSIMS/util"

func main() {
	password, err := util.HashPassword("password")
	if err != nil {
		return
	}
	println(password)
	//err := config.InitConfig()
	//if err != nil {
	//	util.PrintDebugVariables(err)
	//	return
	//}
	//username := "jimmy"
	//APClient := appwrite.InitAPClient()
	//multiTenantAgent := aries.InitAgent(aries.MultiTenant)
	//govAgent := aries.InitAgent(aries.GovernmentAgent)
	//if err != nil {
	//	util.PrintDebugVariables(err)
	//}
	//u, err := aries.GenerateUserWallet(APClient, username, multiTenantAgent)
	//if err != nil {
	//	util.PrintDebugVariables(err)
	//}
	//u, err = aries.GenerateUserDID(APClient, username, multiTenantAgent)
	//if err != nil {
	//	util.PrintDebugVariables(err)
	//}
	//err = aries.PostDIDToLedger(username, APClient, multiTenantAgent, govAgent)
	//if err != nil {
	//	util.PrintDebugVariables(err)
	//}
	//err = aries.SetAsMainWallet(username, APClient, multiTenantAgent)
	//if err != nil {
	//	util.PrintDebugVariables(err)
	//}
	//
	//util.PrintDebugVariables(u)

}
