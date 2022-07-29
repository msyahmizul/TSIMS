package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"TSIMS/appwrite/admin"
	user2 "TSIMS/appwrite/user"
	"TSIMS/aries"
	"TSIMS/graph/generated"
	"TSIMS/graph/model"
	"TSIMS/model/documentModel"
	localModel "TSIMS/model/userModel"
	"TSIMS/util"
	"context"
	"fmt"
	"io/ioutil"

	"github.com/99designs/gqlgen/graphql"
)

// SignUpUser is the resolver for the signUpUser field.
func (r *mutationResolver) SignUpUser(ctx context.Context, user *model.InputUserLogin) (*string, error) {
	token, err := user2.CreateNewLogin(r.APClient, user.Username, user.Password)
	if err != nil {
		if err.Error() == "status returned Error 409 Conflict" {
			return nil, fmt.Errorf("user already exist")
		}
		return nil, err
	}
	return &token, nil
}

// CreateDataUser is the resolver for the createDataUser field.
func (r *mutationResolver) CreateDataUser(ctx context.Context, token string, user model.InputNewUserDataInformation) (*model.UserDataInformation, error) {
	userMetaData, err := user2.VerifyUserJWTToken(token, r.APClient)
	if err != nil {
		return nil, err
	}

	if len(user.IcCard) != 12 {
		return nil, fmt.Errorf("invalid IC card lengt")
	}

	data, err := user2.CreateUserData(r.APClient, userMetaData.Username, localModel.UserData{
		UserID:    userMetaData.Username,
		IcCard:    user.IcCard,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		Gender:    string(user.Gender),
		Dob:       user.Dob,
		Address:   user.Address,
		City:      user.City,
		Postcode:  user.Postcode,
		State:     user.State,
	})
	if err != nil {
		return nil, err
	}
	u := model.UserDataInformation{
		UserID:    data.UserID,
		IcCard:    data.IcCard,
		FirstName: data.FirstName,
		LastName:  data.LastName,
		Gender:    model.Gender(data.Gender),
		Dob:       data.Dob,
		Address:   data.Address,
		City:      data.City,
		State:     data.State,
	}
	return &u, nil
}

// UploadDocumentUser is the resolver for the uploadDocumentUser field.
func (r *mutationResolver) UploadDocumentUser(ctx context.Context, token string, file graphql.Upload) (string, error) {
	userMetaData, err := user2.VerifyUserJWTToken(token, r.APClient)
	if err != nil {
		return "", err
	}
	reader, err := ioutil.ReadAll(file.File)
	fileDocument := documentModel.FileUploadDocument{
		File:     reader,
		Filename: file.Filename,
	}
	for i := 0; i <= 3; i++ {
		fileID, err := user2.UploadUserFile(r.APClient, userMetaData.Username, fileDocument)
		if err != nil {
			continue
		} else {
			return *fileID, nil
		}
	}
	return "", fmt.Errorf("error Uploud User File")
}

// GenerateUserDid is the resolver for the generateUserDID field.
func (r *mutationResolver) GenerateUserDid(ctx context.Context, token string) (*model.User, error) {
	userMetaData, err := user2.VerifyUserJWTToken(token, r.APClient)
	if err != nil {
		return nil, err
	}
	u, err := user2.QuerySingeUserByUsername(r.APClient, userMetaData.Username)
	if err != nil {
		return nil, err
	}
	t := model.ApplicationStatus(u.ApplicantStatus)
	if t != model.ApplicationStatusApprove {
		return nil, fmt.Errorf("user not approve")
	}
	if u.Did != "" {
		return &model.User{
			Username:        u.Username,
			Password:        u.Password,
			UserType:        u.UserType,
			FileID:          nil,
			ApplicantStatus: &t,
			Did:             &u.Did,
			WalletID:        &u.WalletID,
			Data:            nil,
		}, nil

	}
	if u.WalletID == "" {
		u, err = aries.GenerateUserWallet(r.APClient, userMetaData.Username, r.MultiTenantAgentClient)
		if err != nil {
			return nil, err
		}
	}
	if u.Did == "" {
		u, err = aries.GenerateUserDID(r.APClient, userMetaData.Username, r.MultiTenantAgentClient)
		if err != nil {
			return nil, err
		}
	}
	err = aries.PostDIDToLedger(userMetaData.Username, r.APClient, r.MultiTenantAgentClient, r.GovAgentClient)
	if err != nil {
		return nil, err
	}
	err = aries.SetAsMainWallet(userMetaData.Username, r.APClient, r.MultiTenantAgentClient)
	if err != nil {
		return nil, err
	}
	return &model.User{
		Username:        u.Username,
		Password:        u.Password,
		UserType:        u.UserType,
		FileID:          nil,
		ApplicantStatus: &t,
		Did:             &u.Did,
		WalletID:        &u.WalletID,
		Data:            nil,
	}, nil
}

// GetWalletToken is the resolver for the getWalletToken field.
func (r *mutationResolver) GetWalletToken(ctx context.Context, token string) (string, error) {
	panic(fmt.Errorf("not implemented"))
}

// UpdateApplicationStatus is the resolver for the updateApplicationStatus field.
func (r *mutationResolver) UpdateApplicationStatus(ctx context.Context, token string, username string, status model.ApplicationStatus, rejectMessage string) (*model.User, error) {
	t := fmt.Sprintf("%s", localModel.UserTypeAdmin)
	_, err := util.VerifyUserType(token, &t)
	if err != nil {
		return nil, err
	}
	u, err := admin.UpdateApplicantStatus(r.APClient, status.String(), username, rejectMessage)
	if err != nil {
		return nil, err
	}
	e := model.User{
		Username:        u.Username,
		Password:        u.Password,
		UserType:        u.UserType,
		FileID:          u.FileID,
		ApplicantStatus: &status,
		Did:             &u.Did,
		Data:            nil,
	}
	return &e, nil
}

// DeleteUser is the resolver for the deleteUser field.
func (r *mutationResolver) DeleteUser(ctx context.Context, token string, username string) (bool, error) {
	panic(fmt.Errorf("not implemented"))
}

// LoginUser is the resolver for the loginUser field.
func (r *queryResolver) LoginUser(ctx context.Context, username string, password string) (string, error) {
	loginUser, err := user2.LoginUser(r.APClient, username, password)
	if err != nil {
		return "", err
	}
	return *loginUser, nil
}

// GetUserData is the resolver for the getUserData field.
func (r *queryResolver) GetUserData(ctx context.Context, token string) (*model.User, error) {
	metaData, err := util.VerifyUserType(token, nil)
	if err != nil {
		return nil, err
	}
	u, err := user2.QuerySingeUserByUsername(r.APClient, metaData.Username)
	if err != nil {
		return nil, err
	}
	ud, err := user2.QuerySingleUserDataByUsername(r.APClient, metaData.Username)
	if err != nil {

		return nil, err
	}
	t := model.ApplicationStatus(u.ApplicantStatus)
	return &model.User{
		Username:        u.Username,
		Password:        "",
		UserType:        "",
		FileID:          nil,
		ApplicantStatus: &t,
		RejectMessage:   u.RejectMessage,
		Did:             &u.Did,
		WalletID:        &u.WalletID,
		Data: &model.UserDataInformation{
			UserID:    u.Username,
			IcCard:    ud.IcCard,
			FirstName: ud.FirstName,
			LastName:  ud.LastName,
			Gender:    model.Gender(ud.Gender),
			Dob:       ud.Dob,
			Address:   ud.Address,
			City:      ud.City,
			State:     ud.State,
			Postcode:  ud.Postcode,
		},
	}, nil
}

// CheckApplicationUser is the resolver for the checkApplicationUser field.
func (r *queryResolver) CheckApplicationUser(ctx context.Context, token string) (*model.UserCurrentApplicationStatus, error) {
	metaData, err := util.VerifyUserType(token, nil)
	if err != nil {
		return nil, err
	}
	u, err := user2.QuerySingeUserByUsername(r.APClient, metaData.Username)
	if err != nil {
		return nil, err
	}

	return &model.UserCurrentApplicationStatus{
		RejectMessage: u.RejectMessage,
		Status:        model.ApplicationStatus(u.ApplicantStatus),
	}, nil
}

// GetUserApplication is the resolver for the getUserApplication field.
func (r *queryResolver) GetUserApplication(ctx context.Context, token string, username string) (*model.UserApplicationDetail, error) {
	t := fmt.Sprintf("%s", localModel.UserTypeAdmin)
	_, err := util.VerifyUserType(token, &t)
	if err != nil {
		return nil, err
	}
	userInfo, err := user2.QuerySingeUserByUsername(r.APClient, username)
	if err != nil {
		return nil, err
	}
	if userInfo == nil {
		return nil, nil
	}
	userDetail, err := user2.QuerySingleUserDataByUsername(r.APClient, username)
	if err != nil {
		return nil, err
	}
	return &model.UserApplicationDetail{
		ApplicantStatus: model.ApplicationStatus(userInfo.ApplicantStatus),
		Username:        username,
		Files:           userInfo.FileID,
		RejectMessage:   userInfo.RejectMessage,
		UserDetail: &model.UserDataInformation{
			UserID:    username,
			IcCard:    userDetail.IcCard,
			FirstName: userDetail.FirstName,
			LastName:  userDetail.LastName,
			Gender:    model.Gender(userDetail.Gender),
			Dob:       userDetail.Dob,
			Address:   userDetail.Address,
			City:      userDetail.City,
			State:     userDetail.State,
		},
	}, nil
}

// GetAllUserApplications is the resolver for the getAllUserApplications field.
func (r *queryResolver) GetAllUserApplications(ctx context.Context, token string) ([]*model.UserApplicantStatus, error) {
	t := fmt.Sprintf("%s", localModel.UserTypeAdmin)
	_, err := util.VerifyUserType(token, &t)
	if err != nil {
		return nil, err
	}
	userList, err := admin.GetAllUser(r.APClient)
	if err != nil {
		return nil, err
	}
	if userList == nil {
		return nil, nil
	}
	var s []*model.UserApplicantStatus
	for _, user := range *userList {
		t, err := user2.QuerySingleUserDataByUsername(r.APClient, user.Username)
		if err != nil {
			return nil, err
		}
		if t == nil {
			continue
		}
		var did *string
		if user.Did == "" {
			did = nil
		} else {
			did = &user.Did
		}
		s = append(s, &model.UserApplicantStatus{
			Username:        user.Username,
			Name:            t.FirstName,
			ApplicantStatus: model.ApplicationStatus(user.ApplicantStatus),
			Did:             did,
		})
	}

	return s, nil
}

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

// Query returns generated.QueryResolver implementation.
func (r *Resolver) Query() generated.QueryResolver { return &queryResolver{r} }

type mutationResolver struct{ *Resolver }
type queryResolver struct{ *Resolver }
