PRAGMA foreign_keys = ON;

-- Departments
CREATE TABLE departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Users
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('admin','department')),
    department_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(department_id) REFERENCES departments(id)
);

-- Ranking Cycle (QS Sustainability 2026)
CREATE TABLE ranking_cycles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    year INTEGER NOT NULL,
    deadline DATETIME NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('active','closed')) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Questions (from QS Sustainability)
CREATE TABLE questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ranking_cycle_id INTEGER NOT NULL,
    code TEXT, -- optional: QS code reference
    title TEXT NOT NULL,
    description TEXT,
    question_type TEXT NOT NULL CHECK(question_type IN ('text','number','file','percentage')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(ranking_cycle_id) REFERENCES ranking_cycles(id)
);

-- Task Assignments
CREATE TABLE task_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('pending','submitted','overdue')) DEFAULT 'pending',
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    submitted_at DATETIME,
    FOREIGN KEY(question_id) REFERENCES questions(id),
    FOREIGN KEY(department_id) REFERENCES departments(id),
    UNIQUE(question_id, department_id)
);

-- Answers
CREATE TABLE answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_assignment_id INTEGER NOT NULL,
    answer_text TEXT,
    answer_number REAL,
    file_path TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(task_assignment_id) REFERENCES task_assignments(id)
);