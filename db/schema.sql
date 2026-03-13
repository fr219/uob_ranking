-- ============================================================
--  UoB Rankings Data Collection System — Schema v3.0
--  Supports Multiple Ranking Systems (QS, THE, ARWU, etc.)
-- ============================================================
PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. DEPARTMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    email TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. USERS (password_hash merged here)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    password_hash TEXT NOT NULL,
    role TEXT DEFAULT 'department_user' CHECK(role IN ('admin', 'department_user')),
    department_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    FOREIGN KEY(department_id) REFERENCES departments(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================================
-- 3. SESSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    session_token TEXT UNIQUE NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(session_token);

-- ============================================================
-- 4. RANKINGS (NEW: Filter key for multiple systems)
-- ============================================================
CREATE TABLE IF NOT EXISTS rankings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,           -- e.g., "QS Sustainability", "THE Impact"
    description TEXT,
    website_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 5. RANKING_CYCLES (Now has ranking_id + interval period)
-- ============================================================
CREATE TABLE IF NOT EXISTS ranking_cycles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ranking_id INTEGER NOT NULL,         -- ✅ Which ranking system?
    name TEXT NOT NULL,                  -- e.g., "QS Sustainability 2025"
    year INTEGER NOT NULL,               -- e.g., 2025
    start_date DATETIME,                 -- ✅ Interval start
    deadline DATETIME,                   -- ✅ Interval end
    status TEXT DEFAULT 'draft' CHECK(status IN ('draft', 'active', 'closed', 'archived')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(ranking_id) REFERENCES rankings(id) ON DELETE CASCADE,
    UNIQUE(ranking_id, year)             -- Prevent duplicate cycles
);
CREATE INDEX IF NOT EXISTS idx_cycles_ranking ON ranking_cycles(ranking_id);
CREATE INDEX IF NOT EXISTS idx_cycles_status ON ranking_cycles(status);

-- ============================================================
-- 6. QUESTIONS (WITH definition column for tooltips)
-- ============================================================
CREATE TABLE IF NOT EXISTS questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ranking_cycle_id INTEGER NOT NULL,
    theme TEXT,
    sub_theme TEXT,
    code TEXT,
    title TEXT NOT NULL,                 -- The actual question
    definition TEXT,                     -- ✅ Help text for ⓘ tooltip
    timeframe TEXT,
    data_provider TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(ranking_cycle_id) REFERENCES ranking_cycles(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_questions_cycle ON questions(ranking_cycle_id);
CREATE INDEX IF NOT EXISTS idx_questions_code ON questions(code);

-- ============================================================
-- 7. QUESTION_ITEMS
-- ============================================================
CREATE TABLE IF NOT EXISTS question_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    item_number TEXT NOT NULL,
    label TEXT NOT NULL,
    answer_type TEXT NOT NULL CHECK(answer_type IN ('url','text','number','yesno','checkbox','year','select','file')),
    max_words INTEGER,
    is_required INTEGER DEFAULT 0,
    parent_item_number TEXT,
    sort_order INTEGER DEFAULT 0,
    FOREIGN KEY(question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- ============================================================
-- 8. TASK_ASSIGNMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS task_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    ranking_cycle_id INTEGER NOT NULL,
    deadline DATETIME,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','in_progress','submitted','overdue','exempt')),
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    submitted_at DATETIME,
    UNIQUE(question_id, department_id, ranking_cycle_id),
    FOREIGN KEY(question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY(department_id) REFERENCES departments(id) ON DELETE CASCADE,
    FOREIGN KEY(ranking_cycle_id) REFERENCES ranking_cycles(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_assignments_dept ON task_assignments(department_id);
CREATE INDEX IF NOT EXISTS idx_assignments_status ON task_assignments(status);

-- ============================================================
-- 9. ANSWERS
-- ============================================================
CREATE TABLE IF NOT EXISTS answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_assignment_id INTEGER NOT NULL,
    question_item_id INTEGER NOT NULL,
    answer_url TEXT,
    answer_text TEXT,
    answer_number REAL,
    answer_bool INTEGER,
    answer_file_url TEXT,
    submitted_by INTEGER,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(task_assignment_id, question_item_id),
    FOREIGN KEY(task_assignment_id) REFERENCES task_assignments(id) ON DELETE CASCADE,
    FOREIGN KEY(question_item_id) REFERENCES question_items(id) ON DELETE CASCADE,
    FOREIGN KEY(submitted_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- 10. ANSWER_HISTORY
-- ============================================================
CREATE TABLE IF NOT EXISTS answer_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_assignment_id INTEGER NOT NULL,
    question_item_id INTEGER NOT NULL,
    answer_url TEXT,
    answer_text TEXT,
    answer_number REAL,
    answer_bool INTEGER,
    submitted_by INTEGER,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(task_assignment_id) REFERENCES task_assignments(id) ON DELETE CASCADE,
    FOREIGN KEY(question_item_id) REFERENCES question_items(id) ON DELETE CASCADE
);

-- ============================================================
-- 11. REMINDERS
-- ============================================================
CREATE TABLE IF NOT EXISTS reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_assignment_id INTEGER NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('email','in_app','both')),
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    sent_by INTEGER,
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_read INTEGER DEFAULT 0,
    delivery_status TEXT DEFAULT 'sent' CHECK(delivery_status IN ('sent','delivered','failed')),
    FOREIGN KEY(task_assignment_id) REFERENCES task_assignments(id) ON DELETE CASCADE,
    FOREIGN KEY(sent_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- SEED DATA — CORRECT ORDER (Parents FIRST!)
-- ============================================================

-- 1️⃣ RANKINGS (MUST BE FIRST — cycles reference this)
INSERT OR IGNORE INTO rankings (id, name, description, website_url) VALUES 
(1, 'QS Sustainability Rankings', 'QS World University Rankings: Sustainability Edition', 'https://www.topuniversities.com/qs-sustainability-rankings'),
(2, 'THE Impact Rankings', 'Times Higher Education Impact Rankings', 'https://www.timeshighereducation.com/impact-rankings'),
(3, 'ARWU Global Ranking', 'Academic Ranking of World Universities', 'http://www.shanghairanking.com'),
(4, 'GreenMetric UI', 'UI GreenMetric World University Rankings', 'https://greenmetric.ui.ac.id');

-- 2️⃣ RANKING_CYCLES (Now with ranking_id + interval period)
INSERT OR IGNORE INTO ranking_cycles (id, ranking_id, name, year, start_date, deadline, status) VALUES 
(2, 1, 'QS Sustainability 2025', 2025, '2025-01-15', '2025-06-30', 'active'),
(3, 1, 'QS Sustainability 2026', 2026, '2026-01-15', '2026-06-30', 'draft'),
(4, 2, 'THE Impact 2025', 2025, '2025-02-01', '2025-07-15', 'active'),
(5, 3, 'ARWU 2025', 2025, '2025-03-01', '2025-08-31', 'draft'),
(6, 4, 'GreenMetric 2025', 2025, '2025-01-01', '2025-09-30', 'active');

-- 3️⃣ DEPARTMENTS
INSERT OR IGNORE INTO departments (name, email) VALUES 
('Research & Graduate Studies', 'research@uob.bh'),
('Human Resources', 'hr@uob.bh'),
('IT & Digital Services', 'it@uob.bh'),
('Registrar Office', 'registrar@uob.bh'),
('Quality Assurance', 'qa@uob.bh'),
('Finance & Accounts', 'finance@uob.bh'),
('College of Science', 'science@uob.bh'),
('Sustainability Office', 'sustainability@uob.bh'),
('Deanship of Student Affairs', 'studentaffairs@uob.bh'),
('Deanship of Graduate Studies', 'gradstudies@uob.bh'),
('Deanship of Admission and Registration', 'admissions@uob.bh');

-- 4️⃣ USERS (password_hash merged — NO separate credentials table)
-- bcrypt: admin123 → $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
--         dept123  → $2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2

INSERT OR IGNORE INTO users (email, full_name, password_hash, role, department_id) VALUES 
('admin@uob.bh', 'System Administrator', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin', NULL),
('it@uob.bh', 'IT Department', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'IT & Digital Services')),
('hr@uob.bh', 'Human Resources', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Human Resources')),
('sustainability@uob.bh', 'Sustainability Office', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Sustainability Office')),
('qa@uob.bh', 'Quality Assurance', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Quality Assurance')),
('finance@uob.bh', 'Finance & Accounts', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Finance & Accounts')),
('research@uob.bh', 'Research & Graduate Studies', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Research & Graduate Studies')),
('studentaffairs@uob.bh', 'Deanship of Student Affairs', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Deanship of Student Affairs')),
('gradstudies@uob.bh', 'Deanship of Graduate Studies', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Deanship of Graduate Studies')),
('admissions@uob.bh', 'Deanship of Admission and Registration', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Deanship of Admission and Registration')),
('registrar@uob.bh', 'Registrar Office', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'Registrar Office')),
('science@uob.bh', 'College of Science', '$2a$10$Xv7S5K8qJ9mZ3pL2nR4tOeYhB6wC1dF8gH0iJ2kL4mN6oP8qR0sT2', 'department_user', (SELECT id FROM departments WHERE name = 'College of Science'));

-- 5️⃣ QUESTIONS (WITH definition — NOW ranking_cycle_id=2 exists!)
INSERT OR IGNORE INTO questions (ranking_cycle_id, theme, sub_theme, code, title, definition, timeframe, data_provider, sort_order) VALUES
((SELECT id FROM ranking_cycles WHERE ranking_id=1 AND year=2025), 'Annual Report', 'Annual Report', 'AR', 
 'Does your institution publish an annual report?',
 'An annual report is a comprehensive document published yearly that details the institution''s activities and financial performance.',
 'Previous reporting year', 'Quality Assurance', 10),
((SELECT id FROM ranking_cycles WHERE ranking_id=1 AND year=2025), 'Environmental Impact', 'Environmental Sustainability', 'ES4',
 'Link to your institution''s sustainability/climate action policy.',
 'Provide a direct URL to your official sustainability or climate action policy document (must be approved by leadership and <3 years old).',
 'Current (up to 3 years old)', 'Sustainability Office', 20);

-- 6️⃣ QUESTION_ITEMS (use subquery for question_id)
INSERT OR IGNORE INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT id FROM questions WHERE code='AR' AND ranking_cycle_id=(SELECT id FROM ranking_cycles WHERE ranking_id=1 AND year=2025)), 
 '1', 'If yes, please provide a URL or file as evidence', 'url', 1, 10),
((SELECT id FROM questions WHERE code='ES4' AND ranking_cycle_id=(SELECT id FROM ranking_cycles WHERE ranking_id=1 AND year=2025)), 
 '1', 'Please provide URL evidence', 'url', 1, 10);

-- 7️⃣ TASK_ASSIGNMENTS (auto-assign based on data_provider)
INSERT OR IGNORE INTO task_assignments (question_id, department_id, ranking_cycle_id, status)
SELECT q.id, d.id, rc.id, 'pending'
FROM questions q
JOIN ranking_cycles rc ON q.ranking_cycle_id = rc.id
JOIN departments d ON 
    (q.data_provider = d.name) OR
    (q.data_provider = 'Green Metric Committee' AND d.name = 'Sustainability Office') OR
    (q.data_provider = 'QAAC' AND d.name = 'Quality Assurance') OR
    (q.data_provider = 'UTEL' AND d.name = 'IT & Digital Services') OR
    (q.data_provider = 'HR' AND d.name = 'Human Resources') OR
    (q.data_provider = 'Finance' AND d.name = 'Finance & Accounts')
WHERE rc.ranking_id = 1 AND rc.year = 2025
AND q.data_provider IS NOT NULL;