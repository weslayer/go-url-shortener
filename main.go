package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
)

func main(){
	r := gin.Default()
	r.GET("/", func(c *gin.Context){
		c.JSON(200, gin.H{
			"message": "this is da message!",
		})
	})

	err := r.Run(":8002")
	if err != nil{
		panic(fmt.Sprintf("Failed to start web server - Error: %v", err))
	}
}