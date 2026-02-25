package db

import (
	"database/sql"
	"log"

	_ "github.com/mattn/go-sqlite3"
)

var DB *sql.DB

func InitDB() {
	var err error
	DB, err = sql.Open("sqlite3", "./qs_sustainability.db")
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	err = DB.Ping()
	if err != nil {
		log.Fatal("Database unreachable:", err)
	}

	log.Println("Database connected successfully")
}