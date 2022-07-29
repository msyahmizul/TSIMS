package graph

import (
	"TSIMS/appwrite"
	"TSIMS/aries"
	"TSIMS/graph/generated"
	"github.com/99designs/gqlgen/graphql"
)

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

type Resolver struct {
	APClient               *appwrite.APClient
	MultiTenantAgentClient aries.Agent
	GovAgentClient         aries.Agent
}

func NewSchema() graphql.ExecutableSchema {
	APClient := appwrite.InitAPClient()
	multiTenantAgent := aries.InitAgent(aries.MultiTenant)
	govAgent := aries.InitAgent(aries.GovernmentAgent)

	return generated.NewExecutableSchema(generated.Config{Resolvers: &Resolver{
		APClient, multiTenantAgent, govAgent,
	}})
}
