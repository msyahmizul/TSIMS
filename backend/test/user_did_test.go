package test

import (
	"github.com/stretchr/testify/require"
	"testing"
)

func TestUserDIDWorkflow(t *testing.T) {
	_ = UserMock{
		username: "jimmy",
		password: "jiroroji",
		token:    "",
	}
	t.Run("Generate User DID token and sign to the indy network", func(t *testing.T) {
		require.Equal(t, true, false, "TODO")
	})
	t.Run("Verify the DID Exist on the network", func(t *testing.T) {
		require.Equal(t, true, false, "TODO")
	})

}
