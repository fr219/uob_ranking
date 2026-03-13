package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"

	"uob-rankings/db"        // Your db package
	"uob-rankings/handlers"  // Your handlers package

	_ "github.com/tursodatabase/libsql-client-go/libsql"
	"github.com/joho/godotenv"
)

func main() {
	// 1. Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  No .env file found, using system environment variables")
	}

	// 2. Get database credentials from env
	dbURL := os.Getenv("TURSO_DATABASE_URL")
	authToken := os.Getenv("TURSO_AUTH_TOKEN")

	if dbURL == "" {
		log.Fatal("❌ TURSO_DATABASE_URL not set")
	}

	// 3. Connect to Turso (dbConn is now in main() scope)
	dsn := dbURL + "?authToken=" + authToken
	dbConn, err := sql.Open("libsql", dsn)
	if err != nil {
		log.Fatal("❌ Failed to connect to database:", err)
	}
	defer dbConn.Close()

	// 4. Test connection
	if err := dbConn.Ping(); err != nil {
		log.Fatal("❌ Failed to ping database:", err)
	}
	log.Println("✅ Connected to Turso DB")

	// 5. Initialize schema (optional: only run once or in dev)
	if err := db.InitDB(dbConn); err != nil {
		log.Fatal("❌ Failed to initialize DB:", err)
	}

	// 6. Setup HTTP router
	mux := http.NewServeMux()

	// Serve static files (HTML, CSS, JS, images)
	fs := http.FileServer(http.Dir("static"))
	mux.Handle("/static/", http.StripPrefix("/static/", fs))

	// Serve login page at root
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "static/login.html")
	})

	// ✅ API Routes — dbConn is in scope here!
	mux.HandleFunc("/api/login", handlers.LoginHandler(dbConn))
	mux.HandleFunc("/api/logout", handlers.LogoutHandler(dbConn))

	// 7. Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Server starting on http://localhost:%s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}