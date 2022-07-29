package appwrite

import (
	"bytes"
	"crypto/tls"
	"fmt"
	"github.com/spf13/viper"
	"io"
	"mime/multipart"
	"net/http"
)

func InitAPClient() *APClient {
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}

	client := &http.Client{Transport: tr}

	return &APClient{
		client: client,
	}
}

func (c *APClient) SendRequest(method, path string, body io.Reader, expectedStatus string) (*http.Response, error) {
	req, err := http.NewRequest(method, fmt.Sprintf("%s%s", viper.GetString("appwrite.endPoint"), path), body)
	if err != nil {
		return nil, err
	}
	req.Header = http.Header{
		"X-Appwrite-Project": []string{viper.GetString("appwrite.projectID")},
		"X-Appwrite-key":     []string{viper.GetString("appwrite.apiKey")},
		"Content-Type":       []string{"application/json"},
	}
	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("error sending request, %+v", err)
	}
	if resp.Status != expectedStatus {
		return resp, fmt.Errorf("status returned Error %s", resp.Status)
	}
	return resp, nil
}

func (c *APClient) SendFileUploadForm(path string, file []byte, filename string, expectedStatus string) (*http.Response, error) {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)
	part, err := writer.CreateFormFile("file", filename)
	if err != nil {
		return nil, fmt.Errorf("error create part file")
	}
	_, err = part.Write(file)
	if err != nil {
		return nil, fmt.Errorf("error write part file to form")
	}
	err = writer.WriteField("fileId", "unique()")
	if err != nil {
		return nil, fmt.Errorf("error write field form")
	}
	contentType := writer.FormDataContentType()
	err = writer.Close()
	if err != nil {
		return nil, fmt.Errorf("error close the writer")
	}

	req, _ := http.NewRequest(http.MethodPost, fmt.Sprintf("%s%s", viper.GetString("appwrite.endPoint"), path), body)
	req.Header = http.Header{
		"X-Appwrite-Project": []string{viper.GetString("appwrite.projectID")},
		"X-Appwrite-key":     []string{viper.GetString("appwrite.apiKey")},
		"Content-Type":       []string{contentType},
	}
	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("error post request, %+v", err)
	}
	if resp.Status != expectedStatus {
		return resp, fmt.Errorf("status returned Error %s", resp.Status)
	}
	return resp, nil
}

type APClient struct {
	client *http.Client
}
