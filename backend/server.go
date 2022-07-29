package main

import (
	"TSIMS/config"
	"TSIMS/graph"
	"fmt"
	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/go-chi/chi/v5"
	"github.com/rs/cors"
	"log"
	"net/http"
)

const defaultPort = "8080"

func main() {
	err := config.InitConfig()
	if err != nil {
		panic(fmt.Sprintf("cannot load config %+v", err))
	}
	router := chi.NewRouter()
	router.Use(cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowCredentials: true,
		Debug:            false,
	}).Handler)
	schema := graph.NewSchema()
	srv := handler.NewDefaultServer(schema)
	router.Handle("/query", srv)

	println("Server is running on localhost:8080")
	log.Fatal(http.ListenAndServe(":"+defaultPort, router))
}
