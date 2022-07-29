package util

import (
	"TSIMS/model"
	"fmt"
	"github.com/golang-jwt/jwt"
	"github.com/spf13/viper"
	"golang.org/x/crypto/bcrypt"
	"time"
)

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))

	return err == nil
}

func GenerateJWTToken(username string, userType string, userDocumentID string) (string, error) {

	t := jwt.New(jwt.SigningMethodHS512)

	t.Claims = &model.UserJWTMetaData{
		StandardClaims: &jwt.StandardClaims{
			ExpiresAt: time.Now().AddDate(0, 1, 0).Unix(),
		},
		Username:        username,
		UserType:        userType,
		UserDocumentsId: userDocumentID,
	}
	return t.SignedString([]byte(viper.GetString("jwtPrivateKey")))
}

func VerifyJWTToken(tokenString string) (*model.UserJWTMetaData, error) {
	userMetaData := model.UserJWTMetaData{}
	token, err := jwt.ParseWithClaims(tokenString, &userMetaData, func(token *jwt.Token) (interface{}, error) {
		return []byte(viper.GetString("jwtPrivateKey")), nil
	})
	if err != nil {
		return nil, fmt.Errorf("error parse jwt token %+v", err)
	}
	if !token.Valid {
		return nil, fmt.Errorf("token has been expired")
	}

	return &userMetaData, nil
}
func VerifyUserType(token string, userType *string) (*model.UserJWTMetaData, error) {
	userMetadata, err := VerifyJWTToken(token)
	if err != nil {
		return nil, err
	}
	if userType == nil {
		return userMetadata, nil
	} else if userMetadata.UserType != *userType {
		return nil, fmt.Errorf("permission access error")
	}
	return userMetadata, nil
}

func PrintDebugVariables(vars any) {
	fmt.Printf("%+v\n", vars)
}
