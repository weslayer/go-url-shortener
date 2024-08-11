package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/weslayer/go-url-shortener/handler"
	"github.com/weslayer/go-url-shortener/store"
)

func main() {
	r := gin.Default()

	r.Static("/static", "./static")

	r.GET("/", func(c *gin.Context) {
		c.File("./static/index.html")
	})

	r.POST("/create-short-url", handler.CreateShortUrl)

	r.GET("/:shortUrl", handler.HandleShortUrlRedirect)

	store.InitializeStore()
	
	err := r.Run(":9808")
	if err != nil {
		panic(fmt.Sprintf("Failed to start the web server - Error: %v", err))
	}
}
