package db

// User represents a system user (admin or department staff)
type User struct {
	ID           int64  `json:"id"`
	Email        string `json:"email"`
	FullName     string `json:"full_name"`
	Role         string `json:"role"` // "admin" or "department_user"
	DepartmentID *int64 `json:"department_id,omitempty"`
}

// Department represents a university department
type Department struct {
	ID   int64  `json:"id"`
	Name string `json:"name"`
}

// RankingCycle represents a ranking submission cycle (e.g., QS 2025)
type RankingCycle struct {
	ID       int64  `json:"id"`
	Name     string `json:"name"`
	Year     int    `json:"year"`
	Deadline string `json:"deadline,omitempty"` // RFC3339 format
	Status   string `json:"status"`             // "draft", "active", "closed"
}

// Question represents a parent QS question
type Question struct {
	ID             int64  `json:"id"`
	RankingCycleID int64  `json:"ranking_cycle_id"`
	Theme          string `json:"theme"`
	SubTheme       string `json:"sub_theme"`
	Code           string `json:"code"`
	Title          string `json:"title"`
	Timeframe      string `json:"timeframe"`
	DataProvider   string `json:"data_provider"`
	SortOrder      int    `json:"sort_order"`
}

// QuestionItem represents a sub-item/answer field under a Question
type QuestionItem struct {
	ID             int64  `json:"id"`
	QuestionID     int64  `json:"question_id"`
	ItemNumber     string `json:"item_number"` // "1", "2.1", etc.
	Label          string `json:"label"`
	AnswerType     string `json:"answer_type"` // "url", "text", "number", "yesno", "checkbox", "year"
	MaxWords       *int   `json:"max_words,omitempty"`
	IsRequired     bool   `json:"is_required"`
	ParentItemNumber *string `json:"parent_item_number,omitempty"`
	SortOrder      int    `json:"sort_order"`
}

// TaskAssignment links a Question to a Department for a Cycle
type TaskAssignment struct {
	ID              int64  `json:"id"`
	QuestionID      int64  `json:"question_id"`
	DepartmentID    int64  `json:"department_id"`
	RankingCycleID  int64  `json:"ranking_cycle_id"`
	Deadline        string `json:"deadline,omitempty"`
	Notes           string `json:"notes,omitempty"`
	Status          string `json:"status"` // "pending", "submitted", "overdue"
	AssignedAt      string `json:"assigned_at"`
	SubmittedAt     *string `json:"submitted_at,omitempty"`
}

// Answer represents a submitted answer for a QuestionItem
type Answer struct {
	ID                int64   `json:"id"`
	TaskAssignmentID  int64   `json:"task_assignment_id"`
	QuestionItemID    int64   `json:"question_item_id"`
	AnswerURL         *string `json:"answer_url,omitempty"`
	AnswerText        *string `json:"answer_text,omitempty"`
	AnswerNumber      *float64 `json:"answer_number,omitempty"`
	AnswerBool        *bool   `json:"answer_bool,omitempty"`
	SubmittedBy       *int64  `json:"submitted_by,omitempty"`
	UpdatedAt         string  `json:"updated_at"`
}

// Session represents an active user session
type Session struct {
	ID           int64  `json:"id"`
	UserID       int64  `json:"user_id"`
	SessionToken string `json:"session_token"`
	ExpiresAt    string `json:"expires_at"` // RFC3339
	CreatedAt    string `json:"created_at"`
}