package user

import (
	"TSIMS/appwrite"
	"TSIMS/model/documentModel"
	"encoding/json"
	"fmt"
	"github.com/spf13/viper"
	"io/ioutil"
	"net/http"
)

func UploadUserFile(c *appwrite.APClient, username string, file documentModel.FileUploadDocument) (*string, error) {
	user, err := QuerySingeUserByUsername(c, username)
	if err != nil {
		return nil, err
	}
	url := fmt.Sprintf("/storage/buckets/%s/files", viper.GetString("appwrite.UserBucketDataId"))

	resp, err := c.SendFileUploadForm(url, file.File, file.Filename, "201 Created")
	if err != nil {
		return nil, err
	}
	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("error reading response")
	}
	var fileDocument = documentModel.FileDocumentObject{}
	err = json.Unmarshal(data, &fileDocument)
	if err != nil {
		return nil, fmt.Errorf("error decode file document, %+v", err)
	}
	user.FileID = append(user.FileID, fileDocument.FileID)

	_, err = UpdateUser(c, *user)
	if err != nil {
		return nil, err
	}
	return &fileDocument.FileID, nil

}

func DeleteUserDocument(c *appwrite.APClient, username string) error {
	user, err := QuerySingeUserByUsername(c, username)
	if err != nil {
		return err
	}
	if len(user.FileID) == 0 {
		return nil
	}
	for _, file := range user.FileID {
		url := fmt.Sprintf("/storage/buckets/%s/files/%s", viper.GetString("appwrite.UserBucketDataId"), file)
		_, err = c.SendRequest(http.MethodDelete, url, nil, "204 No Content")
		if err != nil {
			return err
		}
	}
	user.FileID = nil
	_, err = UpdateUser(c, *user)
	if err != nil {
		return err
	}
	return nil
}
