package service

import "errors"

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrEmailTaken         = errors.New("email already registered")
	ErrNotFound           = errors.New("resource not found")
	ErrGoogleNotReady     = errors.New("google sign-in not implemented yet")
)
