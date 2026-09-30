package auth

import jwt "github.com/golang-jwt/jwt/v5"

type Claims struct {
	UserID string `json:"uid"`
	Email  string `json:"email"`
	jwt.RegisteredClaims

}