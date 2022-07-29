package admin

import (
	"TSIMS/appwrite"
	user "TSIMS/appwrite/user"
	"TSIMS/model/documentModel"
	"TSIMS/model/userModel"
	"encoding/json"
	"fmt"
	"github.com/spf13/viper"
	"io/ioutil"
	"net/http"
)

func UpdateApplicantStatus(c *appwrite.APClient, status string, username string, rejectMessage string) (*userModel.User, error) {
	u, err := user.QuerySingeUserByUsername(c, username)
	if err != nil {
		return nil, err
	}
	if u.ApplicantStatus == "APPROVE" {
		return nil, fmt.Errorf("user already approve, can't changes")
	}
	u.ApplicantStatus = status
	if rejectMessage != "" {
		u.RejectMessage = rejectMessage
	}
	return user.UpdateUser(c, *u)
}
func GetAllUser(c *appwrite.APClient) (*[]userModel.User, error) {
	url := fmt.Sprintf("/database/collections/%s/documents?queries[]=userType.equal(%s)", viper.GetString("appwrite.UserColId"), "USER")
	res, err := c.SendRequest(http.MethodGet, url, nil, "200 OK")
	if err != nil {
		return nil, err
	}
	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		return nil, readErr
	}
	resData := documentModel.ResultQuery{}
	err = json.Unmarshal(body, &resData)
	if err != nil {
		return nil, err
	}
	if resData.Total == 0 {
		return nil, nil
	}
	var u []userModel.User
	err = json.Unmarshal(resData.Document, &u)
	if err != nil {
		return nil, fmt.Errorf("error Decode Result")
	}
	//util.PrintDebugVariables(u)
	return &u, nil
}
func GetAllUserData(c *appwrite.APClient) (*[]userModel.UserData, error) {
	url := fmt.Sprintf("database/collections/%s/documents", viper.GetString("appwrite.UserDataColId"))
	res, err := c.SendRequest(http.MethodGet, url, nil, "200 OK")
	if err != nil {
		return nil, err
	}
	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		return nil, readErr
	}
	resData := documentModel.ResultQuery{}
	err = json.Unmarshal(body, &resData)
	if err != nil {
		return nil, err
	}
	if resData.Total == 0 {
		return nil, nil
	}
	var u []userModel.UserData
	err = json.Unmarshal(resData.Document, &u)
	if err != nil {
		return nil, fmt.Errorf("error Decode Result")
	}
	return &u, nil

}

//func GetUserBriefApplicant(c *appwrite.APClient) (*[]model.ApplicationResult, error) {
//	url := fmt.Sprintf("database/collections/%s/documents", viper.GetString("appwrite.UserColId"))
//	res, err := c.SendRequest(http.MethodGet, url, nil, "200 OK")
//	if err != nil {
//		return nil, err
//	}
//	body, readErr := ioutil.ReadAll(res.Body)
//	if readErr != nil {
//		return nil, readErr
//	}
//	resData := documentModel.ResultQuery{}
//	err = json.Unmarshal(body, &resData)
//	if err != nil {
//		return nil, err
//	}
//	if resData.Total == 0 {
//		return nil, nil
//	}
//	var userData []userModel.User
//
//	err = json.Unmarshal(resData.Document, &userData)
//	if err != nil {
//		return nil, fmt.Errorf("error Decode Result")
//	}
//
//	return nil, nil
//}
