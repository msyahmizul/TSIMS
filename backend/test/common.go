package test

import (
	"TSIMS/appwrite"
	"TSIMS/config"
	"TSIMS/graph"
	"bytes"
	"fmt"
	"github.com/99designs/gqlgen/client"
	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/stretchr/testify/require"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"net/textproto"
	"testing"
)

type FileMock struct {
	mapKey      string
	name        string
	content     []byte
	contentType string
}
type UserMock struct {
	username  string
	password  string
	firstName string
	lastNamse string
	token     string
}

func InitClient(t *testing.T) (*appwrite.APClient, *client.Client) {
	err := config.InitConfig()
	require.Nil(t, err)
	return appwrite.InitAPClient(), InitGraphClient()
}
func InitGraphClient() *client.Client {
	return client.New(handler.NewDefaultServer(graph.NewSchema()))
}

func InitMockServerGraphClient() *httptest.Server {
	return httptest.NewServer(handler.NewDefaultServer(graph.NewSchema()))
}

func CreateUploadRequest(t *testing.T, url, query, mapData string, files []FileMock) *http.Request {
	bodyBuf := &bytes.Buffer{}
	bodyWriter := multipart.NewWriter(bodyBuf)
	err := bodyWriter.WriteField("operations", query)
	require.NoError(t, err)
	err = bodyWriter.WriteField("map", mapData)
	require.NoError(t, err)

	for i := range files {
		h := make(textproto.MIMEHeader)
		h.Set("Content-Disposition", fmt.Sprintf(`form-data; name="%s"; filename="%s"`, files[i].mapKey, files[i].name))
		h.Set("Content-Type", files[i].contentType)
		ff, err := bodyWriter.CreatePart(h)
		require.NoError(t, err)
		_, err = ff.Write(files[i].content)
		require.NoError(t, err)
	}
	err = bodyWriter.Close()
	require.NoError(t, err)
	req, err := http.NewRequest("POST", fmt.Sprintf("%s/graphql", url), bodyBuf)
	require.NoError(t, err)

	req.Header.Set("Content-Type", bodyWriter.FormDataContentType())
	return req
}
