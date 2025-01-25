package store

import (
	"os"
	"testing"

	"github.com/alicebob/miniredis/v2"
	"github.com/stretchr/testify/assert"
)

var mr *miniredis.Miniredis

func TestMain(m *testing.M) {
	// Set up miniredis
	var err error
	mr, err = miniredis.Run()
	if err != nil {
		panic(err)
	}

	// Set Redis host to miniredis address
	os.Setenv("REDIS_HOST", mr.Addr())

	// Run tests
	code := m.Run()

	// Cleanup
	mr.Close()
	os.Exit(code)
}

func TestSaveUrlMapping(t *testing.T) {
	// Initialize store with miniredis
	InitializeStore()

	shortUrl := "abc123"
	originalUrl := "http://example.com"
	userId := "user123"

	// Test saving URL mapping
	SaveUrlMapping(shortUrl, originalUrl, userId)

	// Verify the saved value
	result := RetrieveInitialUrl(shortUrl)
	assert.Equal(t, originalUrl, result)
}

func TestRetrieveInitialUrl(t *testing.T) {
	// Initialize store with miniredis
	InitializeStore()

	shortUrl := "xyz789"
	originalUrl := "http://test.com"
	userId := "user456"

	// Save a URL mapping
	SaveUrlMapping(shortUrl, originalUrl, userId)

	// Test retrieving the URL
	result := RetrieveInitialUrl(shortUrl)
	assert.Equal(t, originalUrl, result)
}
