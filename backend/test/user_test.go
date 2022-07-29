package test

import (
	user2 "TSIMS/appwrite/user"
	"TSIMS/util"
	"encoding/json"
	"fmt"
	"github.com/stretchr/testify/require"
	"io/ioutil"
	"net/http"
	"testing"
)

func TestUserWorkflow(t *testing.T) {
	username := "karim"
	password := "karimBlueFox"
	token := ""
	apClient, cGraph := InitClient(t)
	t.Run("Sign Up User Data ", func(t *testing.T) {
		//signUpUser(user:InputUserLogin)
		var Data struct {
			SignUpUser string
		}
		query := fmt.Sprintf(`
	mutation{
		signUpUser(user: {
		username: "%s",
	 password: "%s",
	})
	}
	`, username, password)
		cGraph.MustPost(query, &Data)
		require.NotEmpty(t, Data.SignUpUser, "User Receive the JWT Token")
		token = Data.SignUpUser

	})

	t.Run("Add user data to the database of user id", func(t *testing.T) {
		//token, err := util.GenerateJWTToken("msyahmizul", userModel.UserTypeRegular, "sdfasdf")
		//require.NoError(t, err)
		query := fmt.Sprintf(`
	mutation{
	createDataUser(token:"%s", user: {
icCard: "%s",
firstName:"%s",
lastName:"%s",
gender: %s,
dob: "%s",
address: "%s",
city: "%s",
state: "%s",
postcode: "%s"
}){
	firstName
	gender
}

}
`, token, "980914015927", "Muhammad Syahmi", "Zulkifli", "MALE", "98091401", "26 jalan Pulai 41", "Skudai", "Johor", "81300")
		var Data struct {
			CreateDataUser struct {
				FirstName string
				Gender    string
			}
		}
		cGraph.MustPost(query, &Data)
		require.Equal(t, "Muhammad Syahmi", Data.CreateDataUser.FirstName)
		require.Equal(t, "MALE", Data.CreateDataUser.Gender)
	})
	t.Run("Upload User Document", func(t *testing.T) {
		var Data struct {
			Data struct {
				UploadDocumentUser string
			}
		}

		srv := InitMockServerGraphClient()
		httpClient := http.Client{}
		query := fmt.Sprintf(`{"query":"mutation ($file: Upload!) {uploadDocumentUser(file: $file, token: \"%s\") }","variables":{"file":null}}`, token)
		mapData := `{ "0": ["variables.file"] }`
		b, err := ioutil.ReadFile("./test/file_sample/test.jpg")
		require.NoError(t, err)
		files := []FileMock{
			{
				mapKey:      "0",
				name:        "test.jpg",
				content:     b,
				contentType: "image/jpg",
			},
		}
		req := CreateUploadRequest(t, srv.URL, query, mapData, files)
		resp, err := httpClient.Do(req)
		responseBody, err := ioutil.ReadAll(resp.Body)
		util.PrintDebugVariables(string(responseBody))
		require.NoError(t, err)
		require.NoError(t, json.Unmarshal(responseBody, &Data))
		require.NotEmpty(t, Data.Data.UploadDocumentUser, "Return Image ID for the image")
	})
	t.Run("Check Application User", func(t *testing.T) {
		var Data struct {
			CheckApplicationUser string
		}
		query := fmt.Sprintf(
			`
   {
		checkApplicationUser(token:"%s")
}`, token)
		cGraph.MustPost(query, &Data)
		require.Equal(t, "PENDING", Data.CheckApplicationUser)
	})

	t.Run("Cleanup Data", func(t *testing.T) {
		t.Run("Clean up user uploaded data", func(t *testing.T) {
			require.Nil(t, user2.DeleteUserDocument(apClient, username), "No error on success delete user data ")
		})
		t.Run("Delete User Data ", func(t *testing.T) {

			err := user2.DeleteUserData(apClient, username)
			require.NoError(t, err, "no error when delete user data")
			u, err := user2.QuerySingleUserDataByUsername(apClient, username)
			require.NoError(t, err)
			require.Nil(t, u, "If the variable is nil the user data has been deleted")
		})
		t.Run("Delete User", func(t *testing.T) {
			//reserved clean by the admin, hence it's will run normal function code
			err := user2.DeleteSingleUserByUsername(apClient, username)
			require.NoError(t, err, "Able to delete the user and not return error")

			user, err := user2.QuerySingeUserByUsername(apClient, username)
			require.NoError(t, err, "Able to delete the user and not return error")
			require.Nil(t, user, "User must be nil indicate the data user has been deleted")
		})
	})

}
