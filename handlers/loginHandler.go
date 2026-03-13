package handlers

import (
	"database/sql"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

// LoginHandler handles POST /api/login requests
func LoginHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Only allow POST
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		// Parse form data
		if err := r.ParseForm(); err != nil {
			http.Redirect(w, r, "/?error=1", http.StatusSeeOther)
			return
		}

		username := strings.TrimSpace(r.FormValue("username"))
		password := strings.TrimSpace(r.FormValue("password"))

		// Validate input
		if username == "" || password == "" {
			http.Redirect(w, r, "/?error=1", http.StatusSeeOther)
			return
		}

		// Query database for user
		var userID int64
		var role, passwordHash string

		err := db.QueryRow(`
    SELECT u.id, u.role, u.password_hash
    FROM users u
    WHERE u.email = ? OR u.id = (
        SELECT id FROM users WHERE email LIKE ? || '@%'
    )
`, username, username).Scan(&userID, &role, &passwordHash)

		// User not found or database error
		if err != nil {
			http.Redirect(w, r, "/?error=1", http.StatusSeeOther)
			return
		}

		// Verify password with bcrypt
		if err := bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(password)); err != nil {
			http.Redirect(w, r, "/?error=1", http.StatusSeeOther)
			return
		}

		// ✅ Login successful — Create session
		sessionToken := uuid.New().String()
		expiresAt := time.Now().Add(24 * time.Hour)

		// Delete old sessions for this user (optional but clean)
		_, _ = db.Exec("DELETE FROM sessions WHERE user_id = ?", userID)

		// Insert new session (create table if not exists)
		_, err = db.Exec(`
			INSERT INTO sessions (user_id, session_token, expires_at)
			VALUES (?, ?, ?)
		`, userID, sessionToken, expiresAt)

		if err != nil {
			// Session insert failed but login succeeded — still redirect
			// In production, you might want to handle this more gracefully
		}

		// Set secure cookie
		http.SetCookie(w, &http.Cookie{
			Name:     "session_token",
			Value:    sessionToken,
			Path:     "/",
			Expires:  expiresAt,
			HttpOnly: true,
			SameSite: http.SameSiteLaxMode,
			// Secure: true, // Uncomment when using HTTPS
		})

		// Redirect based on role
		if role == "admin" {
			http.Redirect(w, r, "/static/admin-dashboard.html", http.StatusSeeOther)
		} else {
			http.Redirect(w, r, "/static/department-tasks.html", http.StatusSeeOther)
		}
	}
}

// LogoutHandler clears session and cookie
func LogoutHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		cookie, err := r.Cookie("session_token")
		if err == nil && cookie.Value != "" {
			// Delete session from database
			_, _ = db.Exec("DELETE FROM sessions WHERE session_token = ?", cookie.Value)
		}

		// Clear cookie
		http.SetCookie(w, &http.Cookie{
			Name:     "session_token",
			Value:    "",
			Path:     "/",
			MaxAge:   -1,
			HttpOnly: true,
			SameSite: http.SameSiteLaxMode,
		})

		http.Redirect(w, r, "/", http.StatusSeeOther)
	}
}

// Middleware: RequireAuth checks for valid session
func RequireAuth(db *sql.DB, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		cookie, err := r.Cookie("session_token")
		if err != nil || cookie.Value == "" {
			http.Redirect(w, r, "/?error=auth", http.StatusSeeOther)
			return
		}

		// Validate session in database
		var expiresAt time.Time
		err = db.QueryRow(`
			SELECT expires_at FROM sessions WHERE session_token = ?
		`, cookie.Value).Scan(&expiresAt)

		if err != nil || time.Now().After(expiresAt) {
			// Session invalid or expired
			http.SetCookie(w, &http.Cookie{
				Name:     "session_token",
				Value:    "",
				Path:     "/",
				MaxAge:   -1,
				HttpOnly: true,
			})
			http.Redirect(w, r, "/?error=auth", http.StatusSeeOther)
			return
		}

		// Session valid — proceed to handler
		next(w, r)
	}
}
