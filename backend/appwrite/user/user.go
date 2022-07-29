package user

import (
	"TSIMS/appwrite"
	"TSIMS/model"
	"TSIMS/model/documentModel"
	"TSIMS/model/userModel"
	"TSIMS/util"
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/spf13/viper"
	"io/ioutil"
	"net/http"
)

func CreateNewLogin(c *appwrite.APClient, username string, password string) (string, error) {
	url := fmt.Sprintf("/database/collections/%s/documents", viper.GetString("appwrite.UserColId"))
	hashPass, err := util.HashPassword(password)
	if err != nil {
		return "", fmt.Errorf("error Hashing the UserType")
	}
	doc := documentModel.NewDocument(userModel.User{
		Username: username, Password: hashPass, UserType: userModel.UserTypeRegular,
	})
	jsonPostData, err := doc.ToJson()

	if err != nil {
		return "", err
	}
	_, err = c.SendRequest(http.MethodPost, url, bytes.NewBuffer(jsonPostData), "201 Created")

	if err != nil {
		return "", err
	}
	d, err := QuerySingeUserByUsername(c, username)
	if err != nil {
		return "", err
	}
	token, err := util.GenerateJWTToken(username, userModel.UserTypeRegular, d.DocumentID)
	if err != nil {
		return "", fmt.Errorf("error Generating JWT token")
	}

	return token, nil
}

func QuerySingeUserByUsername(c *appwrite.APClient, username string) (*userModel.User, error) {
	url := fmt.Sprintf("/database/collections/%s/documents?queries[]=username.equal(\"%s\")", viper.GetString("appwrite.UserColId"), username)
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
	var userData []userModel.User

	err = json.Unmarshal(resData.Document, &userData)
	if err != nil {
		return nil, fmt.Errorf("error Decode Result")
	}

	return &userData[0], nil
}

func DeleteSingleUserByUsername(c *appwrite.APClient, username string) error {
	userData, err := QuerySingeUserByUsername(c, username)
	if userData == nil {
		return nil
	}
	url := fmt.Sprintf("/database/collections/%s/documents/%s", viper.GetString("appwrite.UserColId"), userData.DocumentID)
	_, err = c.SendRequest(http.MethodDelete, url, nil, "204 No Content")
	return err
}

func QuerySingleUserDataByUsername(c *appwrite.APClient, username string) (*userModel.UserData, error) {
	url := fmt.Sprintf("/database/collections/%s/documents?queries[]=userID.equal(\"%s\")", viper.GetString("appwrite.UserDataColId"), username)

	res, err := c.SendRequest(http.MethodGet, url, nil, "200 OK")
	if err != nil {
		return nil, err
	}
	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		return nil, fmt.Errorf("error Decode Result")

	}

	resData := documentModel.ResultQuery{}
	err = json.Unmarshal(body, &resData)
	if err != nil {
		return nil, fmt.Errorf("error Decode Result ResData")
	}
	if resData.Total == 0 {
		return nil, nil
	}
	var userData []userModel.UserData

	err = json.Unmarshal(resData.Document, &userData)

	if err != nil {
		return nil, fmt.Errorf("error Decode Result")
	}

	return &userData[0], nil
}

func CreateUserData(c *appwrite.APClient, username string, userData userModel.UserData) (*userModel.UserData, error) {
	u, err := QuerySingeUserByUsername(c, username)
	if err != nil {
		return nil, err
	}

	// if not null, meaning user are re-uploaded same doc,
	// clear it back to re-upload the doc
	if u != nil {
		err := DeleteUserData(c, username)

		if err != nil {
			return nil, err
		}

		// empty back the array of file
		// TODO delete the user file on the appwrite
		u.FileID = nil
		u.RejectMessage = ""
		u.ApplicantStatus = userModel.ApplicantStatusPending
		_, err = UpdateUser(c, *u)
		if err != nil {
			return nil, err
		}
	}
	url := fmt.Sprintf("/database/collections/%s/documents", viper.GetString("appwrite.UserDataColId"))
	doc := documentModel.NewDocument(userData)
	jsonPostData, err := doc.ToJson()
	if err != nil {
		return nil, err
	}

	_, err = c.SendRequest(http.MethodPost, url, bytes.NewBuffer(jsonPostData), "201 Created")
	if err != nil {
		return nil, err
	}
	return QuerySingleUserDataByUsername(c, userData.UserID)
}

func DeleteUserData(c *appwrite.APClient, username string) error {
	data, err := QuerySingleUserDataByUsername(c, username)
	if data == nil {
		return nil
	}
	url := fmt.Sprintf("/database/collections/%s/documents/%s", viper.GetString("appwrite.UserDataColId"), data.ID)
	_, err = c.SendRequest(http.MethodDelete, url, nil, "204 No Content")
	return err
}

func VerifyUserJWTToken(token string, c *appwrite.APClient) (*model.UserJWTMetaData, error) {
	userMetaData, err := util.VerifyJWTToken(token)
	if err != nil {
		return nil, err
	}
	userData, err := QuerySingeUserByUsername(c, userMetaData.Username)
	if err != nil {
		return nil, err
	}

	if userData == nil {
		return nil, fmt.Errorf("user not Exist")
	}
	return userMetaData, nil
}

func UpdateUser(c *appwrite.APClient, user userModel.User) (*userModel.User, error) {
	url := fmt.Sprintf("/database/collections/%s/documents/%s", viper.GetString("appwrite.UserColId"), user.DocumentID)
	var data struct {
		Data userModel.User `json:"data"`
	}
	data.Data = user
	jsonPostData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	_, err = c.SendRequest(http.MethodPatch, url, bytes.NewBuffer(jsonPostData), "200 OK")

	if err != nil {
		return nil, err
	}
	return QuerySingeUserByUsername(c, user.Username)
}
func LoginUser(c *appwrite.APClient, username string, password string) (*string, error) {
	user, err := QuerySingeUserByUsername(c, username)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, fmt.Errorf("error incorrect username or password")
	}
	if !util.CheckPasswordHash(password, user.Password) {
		return nil, fmt.Errorf("error incorrect username or password")
	}
	token, err := util.GenerateJWTToken(user.Username, user.UserType, user.DocumentID)

	return &token, nil
}
