package db

import (
	"database/sql"
	"embed"
	"fmt"
	"log"
	"strings"

	_ "github.com/tursodatabase/libsql-client-go/libsql"
)

//go:embed schema.sql
var schemaFS embed.FS

// InitDB initializes the database schema and seeds data
func InitDB(db *sql.DB) error {
	log.Println("Initializing database schema...")

	// 1. Read the schema file
	schemaBytes, err := schemaFS.ReadFile("schema.sql")
	if err != nil {
		return fmt.Errorf("failed to read schema.sql: %w", err)
	}

	schema := string(schemaBytes)

	// 2. Enable Foreign Keys (Required for SQLite/Turso)
	_, err = db.Exec("PRAGMA foreign_keys = ON")
	if err != nil {
		return fmt.Errorf("failed to enable foreign keys: %w", err)
	}

	// 3. Split SQL by semicolon to execute statements individually
	statements := strings.Split(schema, ";")

	for _, stmt := range statements {
		// Trim whitespace and skip empty statements
		stmt = strings.TrimSpace(stmt)
		if stmt == "" {
			continue
		}

		// Execute the statement
		_, err := db.Exec(stmt)
		if err != nil {
			// Safe way to get first 50 chars (or less if statement is shorter)
			stmtPreview := stmt
			if len(stmt) > 50 {
				stmtPreview = stmt[:50]
			}

			// Log error but continue (some INSERTs might fail if data exists)
			log.Printf("⚠️  Warning: Executing statement failed: %v\nStatement: %s...\n", err, stmtPreview)

			// If it's a critical table creation error, stop
			if strings.Contains(stmt, "CREATE TABLE") {
				return fmt.Errorf("critical schema error: %w", err)
			}
		}
	}

	log.Println("✅ Database initialization completed successfully!")
	return nil
}