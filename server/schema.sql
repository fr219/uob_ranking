-- 1. Departments
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'user', 'manager')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reset_expires_at TIMESTAMP,
    reset_otp TEXT,
    reset_token TEXT
);

-- 3. Forms (formerly ranking_cycles)
CREATE TABLE forms (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    year INTEGER NOT NULL,
    deadline TIMESTAMP,
    status TEXT DEFAULT 'active' CHECK (status IN ('draft', 'active', 'closed', 'archived')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    start_date DATE,
    description TEXT,
    is_template BOOLEAN DEFAULT FALSE
);

-- 4. Questions
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    form_id INTEGER NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    code TEXT,
    title TEXT NOT NULL,
    description TEXT,
    question_type TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    theme TEXT DEFAULT 'General',
    kpi_index INTEGER,
    is_synced BOOLEAN DEFAULT FALSE,
    gm_category TEXT,
    has_evidence BOOLEAN DEFAULT FALSE
);

-- 5. Question Items
CREATE TABLE question_items (
    id SERIAL PRIMARY KEY,
    question_id INTEGER NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    item_number TEXT,
    label TEXT,
    answer_type TEXT,
    max_words INTEGER,
    options JSONB
);

-- 6. Task Assignments
CREATE TABLE task_assignments (
    id SERIAL PRIMARY KEY,
    question_id INTEGER NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    department_id INTEGER NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'submitted', 'rejected', 'approved')),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP,
    deadline TIMESTAMP
);

-- 7. Answers
CREATE TABLE answers (
    id SERIAL PRIMARY KEY,
    task_assignment_id INTEGER NOT NULL REFERENCES task_assignments(id) ON DELETE CASCADE,
    answer_text TEXT,
    answer_number NUMERIC,
    file_path TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    admin_comment TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'submitted', 'reviewed'))
);

-- 8. Answer History
CREATE TABLE answer_history (
    id SERIAL PRIMARY KEY,
    answer_id INTEGER NOT NULL REFERENCES answers(id) ON DELETE CASCADE,
    task_assignment_id INTEGER NOT NULL REFERENCES task_assignments(id) ON DELETE CASCADE,
    answer_text TEXT,
    answer_number NUMERIC,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- 9. User Sessions
CREATE TABLE user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token TEXT NOT NULL UNIQUE,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- 10. Audit Logs
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id INTEGER,
    details JSONB,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. Reminder History
CREATE TABLE reminder_history (
    id SERIAL PRIMARY KEY,
    form_id INTEGER NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    department_id INTEGER NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    reminder_type TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message_sent TEXT
);

-- INDEXES
CREATE INDEX idx_questions_form ON questions(form_id);
CREATE INDEX idx_task_assignments_question ON task_assignments(question_id);
CREATE INDEX idx_task_assignments_department ON task_assignments(department_id);
CREATE UNIQUE INDEX idx_answers_task ON answers(task_assignment_id);
CREATE INDEX idx_question_items_question ON question_items(question_id);
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
