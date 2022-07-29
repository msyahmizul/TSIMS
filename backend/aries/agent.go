package aries

import (
	"fmt"
	"github.com/spf13/viper"
	"io"
	"net/http"
)

type Agent struct {
	agentType   AgentType
	client      *http.Client
	ApiKey      string
	Seed        string
	Key         string
	Did         string
	AdminConfig AdminConfig
}
type AdminConfig struct {
	Url string
	Key string
}

func InitAgent(agentType AgentType) Agent {
	client := &http.Client{}
	switch agentType {
	case GovernmentAgent:
		return Agent{
			agentType: GovernmentAgent,
			client:    client,
			ApiKey:    viper.GetString("agent.government.apiKey"),
			Seed:      viper.GetString("agent.government.seed"),
			Key:       viper.GetString("agent.government.key"),
			Did:       viper.GetString("agent.government.did"),
			AdminConfig: AdminConfig{
				Url: viper.GetString("agent.government.admin.url"),
				Key: viper.GetString("agent.government.admin.key"),
			},
		}
	case MultiTenant:
		return Agent{
			agentType: MultiTenant,
			client:    client,
			ApiKey:    viper.GetString("agent.multiTenant.apiKey"),
			Seed:      viper.GetString("agent.multiTenant.seed"),
			Key:       viper.GetString("agent.multiTenant.key"),
			Did:       viper.GetString("agent.multiTenant.did"),
			AdminConfig: AdminConfig{
				Url: viper.GetString("agent.multiTenant.admin.url"),
				Key: viper.GetString("agent.multiTenant.admin.key"),
			},
		}
	default:
		return Agent{}
	}

}

type AgentType string

const (
	GovernmentAgent AgentType = "government"
	MultiTenant               = "multi-tenant"
)

func (c *Agent) SendAPIRequestAdmin(method, path string, body io.Reader, expectedStatus string) (*http.Response, error) {
	req, err := http.NewRequest(method, fmt.Sprintf("%s%s", c.AdminConfig.Url, path), body)
	if err != nil {
		return nil, err
	}
	req.Header = http.Header{
		"X-API-KEY": []string{c.AdminConfig.Key},
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

func (c *Agent) SendRequestAdminParam(method, url, expectedStatus string) (*http.Response, error) {
	req, err := http.NewRequest(method, url, nil)
	if err != nil {
		return nil, err
	}
	req.Header = http.Header{
		"X-API-KEY": []string{c.AdminConfig.Key},
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

func (c *Agent) SendAPIRequestMultiTenantUser(jwtToken, method, path string, body io.Reader, expectedStatus string) (*http.Response, error) {
	if c.agentType == GovernmentAgent {
		return nil, fmt.Errorf("only MultiTenant is supported")
	}
	req, err := http.NewRequest(method, fmt.Sprintf("%s%s", c.AdminConfig.Url, path), body)
	if err != nil {
		return nil, err
	}
	req.Header = http.Header{
		"Authorization": []string{fmt.Sprintf("Bearer %s", jwtToken)},
		"X-API-KEY":     []string{c.AdminConfig.Key},
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
