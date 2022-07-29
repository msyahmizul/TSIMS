package model

import "github.com/golang-jwt/jwt"

type UserJWTMetaData struct {
	*jwt.StandardClaims
	Username        string
	UserType        string
	UserDocumentsId string
}
