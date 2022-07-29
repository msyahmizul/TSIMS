package documentModel

import (
	"encoding/json"
	"fmt"
)

type ResultQuery struct {
	Total    int             `json:"total"`
	Document json.RawMessage `json:"documents"`
}
type FileDocumentObject struct {
	FileID      string `json:"$id"`
	Name        string `json:"name"`
	DateCreated int64  `json:"dateCreated"`
	MimeType    string `json:"mimeType"`
	Size        int64  `json:"sizeOriginal"`
}
type FileUploadDocument struct {
	File     []byte
	Filename string
}

type Document struct {
	DocumentID string      `json:"documentId"`
	Data       interface{} `json:"data"`
}

func NewDocument(data interface{}) Document {
	return Document{
		"unique()", data,
	}
}

func (c *Document) ToJson() ([]byte, error) {
	data, err := json.Marshal(c)
	if err != nil {
		return nil, fmt.Errorf("error convert Data To JSON")
	}
	return data, nil
}
