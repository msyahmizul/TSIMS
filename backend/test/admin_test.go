package test

import (
	"TSIMS/model/userModel"
	"TSIMS/util"
	"fmt"
	"github.com/stretchr/testify/require"
	"testing"
)

//Admin
func TestAdminWorkflow(t *testing.T) {
	admin := UserMock{
		username: "admin",
		password: "admin",
		token:    "",
	}
	//user := UserMock{
	//	username:  "msyahmizul",
	//	password:  "msyahmizul",
	//	firstName: "Muhammad Syahmi",
	//	lastNamse: "Zulkifli",
	//	token:     "",
	//}
	_, cGraph := InitClient(t)
	t.Run("Login user role as admin", func(t *testing.T) {
		var Data struct {
			LoginUser string
		}
		//loginUser(username: String!, password: String!):String! # Give JWT Token
		query := fmt.Sprintf(`
	{
		loginUser(username: "%s", password: "%s")
	}
	`, admin.username, admin.password)
		cGraph.MustPost(query, &Data)
		require.NotEmpty(t, Data.LoginUser)
		admin.token = Data.LoginUser

		// check Token if it's admin
		userMetaData, err := util.VerifyJWTToken(admin.token)
		require.NoError(t, err)
		require.Equal(t, userModel.UserTypeAdmin, userMetaData.UserType, "User Role must be admin")

	})
	t.Run("Get All User ApplicationStatus Brief", func(t *testing.T) {
		var Data struct {
			GetAllUserApplications []struct {
				Username        string  `json:"username"`
				ApplicantStatus string  `json:"applicantStatus"`
				Did             *string `json:"did"`
			}
		}
		query := fmt.Sprintf(`{
		getAllUserApplications(token: "%s"){
username
applicantStatus
}
	}`, admin.token)
		cGraph.MustPost(query, &Data)
		require.GreaterOrEqual(t, len(Data.GetAllUserApplications), 1, "Contain at least one or more user in list")
		require.NotEmpty(t, Data.GetAllUserApplications[0].ApplicantStatus, "Contain The status of user")
		if Data.GetAllUserApplications[0].ApplicantStatus == "PENDING" {
			require.Empty(t, Data.GetAllUserApplications[0].Did, "Verify the did value is empty since it's not being verify by admin")
		} else {
			require.NotEmpty(t, Data.GetAllUserApplications[0].Did, "Verify the did value is not empty since it's not being verify by admin")
		}

	})
	//	t.Run("Update user application Status", func(t *testing.T) {
	//		//updateApplicationStatus(token: String!,username: String!,status: ApplicationStatus!):User!
	//		var Data struct {
	//			UpdateApplicationStatus struct {
	//				ApplicantStatus string
	//			}
	//		}
	//		query := fmt.Sprintf(`
	//mutation{
	//		updateApplicationStatus(token: "%s", username: "%s", status: %s){
	//		applicantStatus
	//}
	//	}`, admin.token, user.username, "REJECTED")
	//		cGraph.MustPost(query, &Data)
	//		require.Equal(t, "REJECTED", Data.UpdateApplicationStatus.ApplicantStatus)
	//
	//		//	Change back to old one
	//		query = fmt.Sprintf(`
	//mutation{
	//		updateApplicationStatus(token: "%s", username: "%s", status: %s){
	//		applicantStatus
	//}
	//	}`, admin.token, user.username, "PENDING")
	//		cGraph.MustPost(query, &Data)
	//		require.Equal(t, "PENDING", Data.UpdateApplicationStatus.ApplicantStatus)
	//	})
	//	t.Run("Get User Application Detail", func(t *testing.T) {
	//		var Data struct {
	//			GetUserApplication struct {
	//				UserDetail struct {
	//					FirstName string
	//					LastName  string
	//				}
	//			}
	//		}
	//		query := fmt.Sprintf(`{
	//			getUserApplication(token: "%s",username: "%s"){
	//					userDetail{
	//						firstName
	//						lastName
	//				}}}`, admin.token, user.username)
	//		cGraph.MustPost(query, &Data)
	//		require.Equal(t, user.firstName, Data.GetUserApplication.UserDetail.FirstName)
	//		require.Equal(t, user.lastNamse, Data.GetUserApplication.UserDetail.LastName)
	//	})

	//t.Run("Delete User Data with document uploaded", func(t *testing.T) {
	//	require.Equal(t, true, false, "TODO")
	//})
}
