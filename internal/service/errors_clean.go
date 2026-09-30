package service

import "errors"

var (
	ErrInvalidRegistration = errors.New("valid email and password of at least 8 characters required")
	ErrInvalidSync         = errors.New("invalid sync item: id and updatedAt are required")
	ErrInvalidCredentials  = errors.New("invalid credentials")
	ErrEmailTaken          = errors.New("email already registered")
	ErrNotFound            = errors.New("resource not found")
	ErrGoogleNotReady      = errors.New("google sign-in not implemented yet")
)
