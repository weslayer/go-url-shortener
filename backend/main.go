package main

import (
	"fmt"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/weslayer/go-url-shortener/handler"
	"github.com/weslayer/go-url-shortener/store"
	"os"
)

func main() {
	r := gin.Default()

	corsOrigin := os.Getenv("CORS_ORIGIN")
	if corsOrigin == "" {
		corsOrigin = "http://localhost:5173"
	}

	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{corsOrigin},
		AllowMethods:     []string{"POST", "GET"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	r.GET("/", func(c *gin.Context) {
		c.File("../frontend/index.html")
	})

	r.POST("/create-short-url", handler.CreateShortUrl)

	r.GET("/:shortUrl", handler.HandleShortUrlRedirect)

	// Add health check endpoint
	r.GET("/health", handler.HealthCheck)

	store.InitializeStore()

	err := r.Run(":9808")
	if err != nil {
		panic(fmt.Sprintf("Failed to start the web server - Error: %v", err))
	}
}
