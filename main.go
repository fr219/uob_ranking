package main

import (
	"database/sql"
	"log"
	"os"

	"uob-rankings/db" // Your local db package

	_ "github.com/tursodatabase/libsql-client-go/libsql"
	"github.com/joho/godotenv" // 1. Import godotenv
)

func main() {
	// 2. Load the .env file
	// This looks for a file named ".env" in the current folder
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables only")
	}

	// 3. Now get the variables
	dbUrl := os.Getenv("TURSO_DATABASE_URL")
	authToken := os.Getenv("TURSO_AUTH_TOKEN")

	// 4. Check if they exist
	if dbUrl == "" {
		log.Fatal("❌ TURSO_DATABASE_URL is not set! Check your .env file.")
	}
	if authToken == "" {
		log.Fatal("❌ TURSO_AUTH_TOKEN is not set! Check your .env file.")
	}

	// 5. Connect to Turso
	dsn := dbUrl + "?authToken=" + authToken
	dbConn, err := sql.Open("libsql", dsn)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer dbConn.Close()

	// 6. Test Connection
	if err := dbConn.Ping(); err != nil {
		log.Fatal("Failed to ping database:", err)
	}
	log.Println("✅ Connected to Turso DB successfully!")

	// 7. Initialize Schema
	if err := db.InitDB(dbConn); err != nil {
		log.Fatal("Failed to initialize DB:", err)
	}

	log.Println("🚀 Server ready...")
}