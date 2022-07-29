package model

type JsonUtil interface {
	ToJson() (string, error)
}
