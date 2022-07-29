package govermentAgent

import (
	"bytes"
	"fmt"
	"github.com/spf13/viper"
	"net/http"
)

func SendAdminRequest(client http.Client, method string, path string, body []byte) (*http.Response, error) {
	req, err := http.NewRequest(method, fmt.Sprintf("%s%s", viper.GetString("agent.goverment.admin.url"), path), bytes.NewBuffer(body))
	if err != nil {
		return nil, err
	}
	req.Header = http.Header{
		"X-API-Key": []string{viper.GetString("agent.goverment.admin.key")},
	}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("error sending request, %+v", err)
	}
	statusOK := resp.StatusCode >= 200 && resp.StatusCode < 300
	if !statusOK {
		return nil, fmt.Errorf("error status from server, %s", resp.Status)
	}
	return resp, nil
}
