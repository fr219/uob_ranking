-- ============================================================
--  UoB QS Sustainability Rankings — Complete Schema
-- ============================================================
PRAGMA foreign_keys = ON;

-- ============================================================
-- BASE TABLES (Required foundation tables)
-- ============================================================

-- 1. Departments Table
CREATE TABLE IF NOT EXISTS departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Users Table
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'department_user',
    department_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(department_id) REFERENCES departments(id)
);

-- 3. Ranking Cycles Table
CREATE TABLE IF NOT EXISTS ranking_cycles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    year INTEGER NOT NULL,
    deadline DATETIME,
    status TEXT DEFAULT 'draft',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- QS SUSTAINABILITY TABLES
-- ============================================================

-- 4. Questions Table (parent questions)
CREATE TABLE IF NOT EXISTS questions (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    ranking_cycle_id    INTEGER NOT NULL,
    theme               TEXT,
    sub_theme           TEXT,
    code                TEXT,
    title               TEXT    NOT NULL,
    timeframe           TEXT,
    data_provider       TEXT,
    sort_order          INTEGER DEFAULT 0,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(ranking_cycle_id) REFERENCES ranking_cycles(id) ON DELETE CASCADE
);

-- 5. Question Items Table (sub-items/answer fields)
CREATE TABLE IF NOT EXISTS question_items (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id     INTEGER NOT NULL,
    item_number     TEXT    NOT NULL,
    label           TEXT    NOT NULL,
    answer_type     TEXT    NOT NULL CHECK(answer_type IN ('url','text','number','yesno','checkbox','year','select')),
    max_words       INTEGER,
    is_required     INTEGER DEFAULT 0,
    parent_item_number TEXT,
    sort_order      INTEGER DEFAULT 0,
    FOREIGN KEY(question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- 6. Task Assignments Table
CREATE TABLE IF NOT EXISTS task_assignments (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id         INTEGER NOT NULL,
    department_id       INTEGER NOT NULL,
    ranking_cycle_id    INTEGER NOT NULL,
    deadline            DATETIME,
    notes               TEXT,
    status              TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','submitted','overdue')),
    assigned_at         DATETIME DEFAULT CURRENT_TIMESTAMP,
    submitted_at        DATETIME,
    UNIQUE(question_id, department_id),
    FOREIGN KEY(question_id)      REFERENCES questions(id)       ON DELETE CASCADE,
    FOREIGN KEY(department_id)    REFERENCES departments(id)     ON DELETE CASCADE,
    FOREIGN KEY(ranking_cycle_id) REFERENCES ranking_cycles(id)  ON DELETE CASCADE
);

-- 7. Answers Table
CREATE TABLE IF NOT EXISTS answers (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    task_assignment_id  INTEGER NOT NULL,
    question_item_id    INTEGER NOT NULL,
    answer_url          TEXT,
    answer_text         TEXT,
    answer_number       REAL,
    answer_bool         INTEGER,
    submitted_by        INTEGER,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(task_assignment_id, question_item_id),
    FOREIGN KEY(task_assignment_id) REFERENCES task_assignments(id) ON DELETE CASCADE,
    FOREIGN KEY(question_item_id)   REFERENCES question_items(id)   ON DELETE CASCADE,
    FOREIGN KEY(submitted_by)       REFERENCES users(id)            ON DELETE SET NULL
);

-- 8. Answer History Table
CREATE TABLE IF NOT EXISTS answer_history (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    task_assignment_id  INTEGER NOT NULL,
    question_item_id    INTEGER NOT NULL,
    answer_url          TEXT,
    answer_text         TEXT,
    answer_number       REAL,
    answer_bool         INTEGER,
    submitted_by        INTEGER,
    submitted_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(task_assignment_id) REFERENCES task_assignments(id) ON DELETE CASCADE,
    FOREIGN KEY(question_item_id)   REFERENCES question_items(id)   ON DELETE CASCADE
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_q_cycle       ON questions(ranking_cycle_id);
CREATE INDEX IF NOT EXISTS idx_q_theme       ON questions(theme);
CREATE INDEX IF NOT EXISTS idx_qi_question   ON question_items(question_id);
CREATE INDEX IF NOT EXISTS idx_ans_task      ON answers(task_assignment_id);
CREATE INDEX IF NOT EXISTS idx_ta_dept       ON task_assignments(department_id);
CREATE INDEX IF NOT EXISTS idx_ta_cycle      ON task_assignments(ranking_cycle_id);
CREATE INDEX IF NOT EXISTS idx_ta_status     ON task_assignments(status);

-- ============================================================
-- SEED DATA - BASE TABLES
-- ============================================================

-- Insert Ranking Cycle (QS Sustainability 2025)
INSERT OR IGNORE INTO ranking_cycles (id, name, year, status) VALUES 
(2, 'QS Sustainability Rankings', 2025, 'active');

-- Insert Departments
INSERT OR IGNORE INTO departments (name) VALUES 
('Research & Graduate Studies'),
('Human Resources'),
('IT & Digital Services'),
('Registrar Office'),
('Quality Assurance'),
('Finance & Accounts'),
('College of Science'),
('Sustainability Office'),
('Green Metric Committee'),
('UTEL'),
('Deanship of Student Affairs'),
('Deanship of Graduate Studies'),
('Deanship of Admission and Registration'),
('Director-General'),
('Equal Opportunities Committee'),
('Sustainability Committee'),
('Investment Committee'),
('Purchasing'),
('Communication Directorate'),
('President Office/Colleges'),
('Finance'),
('HR'),
('College of Health and Sport Sciences');

-- ============================================================
-- QS SUSTAINABILITY 2025 QUESTIONS - SEED DATA
-- ============================================================

-- THEME: Annual Report
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Annual Report', 'Annual Report', 'AR',
'Does your institution publish an annual report?',
'Previous reporting year', 'QAAC', 10);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'If yes, please provide a URL or file as evidence', 'url', 1, 10);

-- THEME: Environmental Impact > Environmental Sustainability
-- ES4 — Sustainability/Climate Action Policy
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES4',
'Link to your institution''s sustainability/climate action policy.',
'Current (up to 3 years old)', 'Green Metric Committee', 20);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Please provide URL evidence', 'url', 1, 10);

-- ES* — Dedicated Training on Environment Aspects
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES*',
'Does your institution provide dedicated training on Environment aspects of Sustainability?',
'Current', 'UTEL', 30);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'How many hours of training on these Environment aspects per employee?', 'number',   1, 10),
((SELECT qid FROM q), '2',   'Which of the following groups receive this training?',                  'text',     0, 20),
((SELECT qid FROM q), '2.1', 'Students',                                                             'checkbox', 0, 21),
((SELECT qid FROM q), '2.2', 'Staff',                                                                'checkbox', 0, 22),
((SELECT qid FROM q), '2.3', 'Both',                                                                 'checkbox', 0, 23),
((SELECT qid FROM q), '3',   'Please provide evidence to support your answers (max 200 words)',       'text',     1, 30);

UPDATE question_items SET parent_item_number = '2' 
WHERE question_id = (SELECT id FROM questions WHERE code='ES*' AND title LIKE '%dedicated training on Environment%') 
AND item_number IN ('2.1','2.2','2.3');

-- ES* — Sustainability Literacy Tool for Staff
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES*',
'Does your institution have an assessment tool for assessing sustainability literacy and knowledge of all staff (academic and professional)?',
'Current', NULL, 40);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'If yes, is this tool Sulitest TASK?',                                           'yesno', 0, 10),
((SELECT qid FROM q), '2',   'If no, please provide evidence of the assessment tool used (max 100 words)',     'text',  0, 20);

UPDATE question_items SET max_words = 100 
WHERE question_id = (SELECT id FROM questions WHERE title LIKE '%sustainability literacy%staff%') 
AND item_number = '2';

-- ES* — Sustainability Literacy Tool for Students
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES*',
'Does your institution have an assessment tool for assessing sustainability literacy and knowledge of all students?',
'Current', NULL, 50);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'If yes, is this tool Sulitest TASK?',                                           'yesno', 0, 10),
((SELECT qid FROM q), '2',   'If no, please provide evidence of the assessment tool used (max 100 words)',     'text',  0, 20);

UPDATE question_items SET max_words = 100 
WHERE question_id = (SELECT id FROM questions WHERE title LIKE '%sustainability literacy%students%') 
AND item_number = '2';

-- ES4 — Sustainable Procurement Policy
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES4',
'Link to your institution''s sustainable procurement / purchasing policy.',
'Current (up to 3 years old)', 'Purchasing', 60);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'If yes, provide URL', 'url', 1, 10);

-- ES4 — Sustainable Investment Policy
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES4',
'Link to your institution''s sustainable investment policy.',
'Current (up to 3 years old)', 'Investment Committee', 70);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'If yes, provide URL', 'url', 1, 10);

-- ES5 — Student-led Sustainability Society
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES5',
'Link to student-led society whose purpose is to engage with sustainability.',
'Current', 'Deanship of Student Affairs', 80);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'If yes, provide URL', 'url', 1, 10);

-- ES7 — Carbon Emissions Reporting
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES7',
'Does your university report its carbon emissions in line with the GHG Protocol Corporate Standard or another commonly used standard?',
'Current', 'Green Metric Committee', 90);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Please provide URL evidence', 'url', 1, 10);

-- ES7.1 — Carbon Emissions Figures
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES7.1',
'Please provide the total Scope 1 and 2 carbon emissions in tCO2e.',
'Previous reporting year', NULL, 100);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Total Scope 1 & 2 emissions in tCO2e',                                    'number', 1, 10),
((SELECT qid FROM q), '2', 'If you also report on Scope 3 emissions, estimate here in tCO2e',         'number', 0, 20),
((SELECT qid FROM q), '3', 'Please provide a URL that supports the above figures',                    'url',    1, 30);

-- ES9 — Baseline Year for Emissions
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES9',
'Please enter the year you began recording your emissions to GHG standards.',
'The year you started measuring (2005 earliest)', NULL, 110);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Baseline year (earliest: 2005)',                                     'year',   1, 10),
((SELECT qid FROM q), '2', 'Total Scope 1 & 2 emissions for the baseline year in tCO2e',         'number', 0, 20);

-- ES9 — Carbon Reduction Target
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES9',
'Does your university have a carbon reduction target covering Scope 1 & 2 emissions by at least 2050?',
'Current', NULL, 120);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Please provide URL evidence (leave blank if no target)', 'url', 0, 10);

-- ES8 — Renewable Energy
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES8',
'Please add the amount of energy generated on campus through renewable sources in kWh.',
'Previous reporting year', NULL, 130);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Total energy from renewables in kWh', 'number', 1, 10);

-- ES7.2 — Campus Building Footprint
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES7.2',
'Please submit your total campus building footprint.',
'Previous reporting year', NULL, 140);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Total campus building footprint in square meters (m²)', 'number', 1, 10);

-- ES6 — Net-Zero Commitment Year
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Sustainability', 'ES6',
'Please provide the year your institution has publicly committed to reaching net-zero.',
'Current', NULL, 150);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Please provide URL evidence (leave blank if not committed)', 'url', 0, 10);

-- THEME: Environmental Impact > Environmental Education
-- EE3 — Climate Science Courses
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Education', 'EE3',
'Do you offer courses that teach specifically on climate science and/or environmental sustainability?',
'Current', 'Deanship of Graduate Studies', 160);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'We offer these courses linked to officially recognised credits (e.g. ECTS)',                                         'checkbox', 0, 10),
((SELECT qid FROM q), '2', 'They lead to an officially recognised qualification specifically referring to climate science/environmental sustainability', 'checkbox', 0, 20),
((SELECT qid FROM q), '3', 'Please provide URL evidence',                                                                                        'url',      1, 30);

-- THEME: Environmental Impact > Environmental Research
-- ER3 — Research Centre for Environmental Sustainability
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Environmental Impact', 'Environmental Research', 'ER3',
'Presence of a Research Centre with a specific focus on environmental sustainability.',
'Current', NULL, 170);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'The Research Centre has dedicated FTE staff',                                                                              'checkbox', 0, 10),
((SELECT qid FROM q), '2', 'This Research Centre contributes to the teaching of UG and/or PG programmes',                                             'checkbox', 0, 20),
((SELECT qid FROM q), '3', 'Please provide evidence or supporting statement (max 100 words)',                                                          'text',     1, 30);

UPDATE question_items SET max_words = 100 WHERE question_id = (SELECT id FROM questions WHERE code='ER3') AND item_number = '3';

-- THEME: Social Impact > Equality
-- EQ3 — Faculty Staff Gender Breakdown
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Social Impact', 'Equality', 'EQ3',
'Please provide faculty staff numbers by gender.',
'Previous reporting year (academic)', 'HR', 180);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Faculty Staff Male',   'number', 1, 10),
((SELECT qid FROM q), '2', 'Faculty Staff Female', 'number', 1, 20),
((SELECT qid FROM q), '3', 'Faculty Staff Other',  'number', 0, 30);

-- EQ4 — Senior Leadership Gender
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Social Impact', 'Equality', 'EQ4',
'Senior leadership team composition by gender.',
'Previous reporting year (academic)', 'HR', 190);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Total number of members in your senior leadership team',              'number', 1, 10),
((SELECT qid FROM q), '2', 'Number of senior leadership team members who are male',               'number', 1, 20);

-- EQ2 — Student Gender Breakdown
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Social Impact', 'Equality', 'EQ2',
'Please provide student numbers by gender.',
'Previous reporting year (academic)', 'Deanship of Admission and Registration', 200);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Students Female', 'number', 1, 10),
((SELECT qid FROM q), '2', 'Students Other',  'number', 0, 20);

-- EQ5 — EDI Policy
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Social Impact', 'Equality', 'EQ5',
'Does your institution have a current Equality, Diversity and Inclusion (EDI) policy?',
'Current (up to 3 years old)', 'Director-General', 210);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'We have a current EDI policy or equivalent',  'yesno',    1, 10),
((SELECT qid FROM q), '2',   'Please provide evidence (URL)',                'url',      1, 20),
((SELECT qid FROM q), '3',   'Which main protected characteristics are included in this policy?', 'text', 0, 30),
((SELECT qid FROM q), '3.1', 'Age',                               'checkbox', 0, 31),
((SELECT qid FROM q), '3.2', 'Gender or gender reassignment',     'checkbox', 0, 32),
((SELECT qid FROM q), '3.3', 'Disability',                        'checkbox', 0, 33),
((SELECT qid FROM q), '3.4', 'Race',                              'checkbox', 0, 34),
((SELECT qid FROM q), '3.5', 'Religion or belief',                'checkbox', 0, 35),
((SELECT qid FROM q), '3.6', 'Sexual orientation',                'checkbox', 0, 36),
((SELECT qid FROM q), '3.7', 'Marriage and civil partnership',    'checkbox', 0, 37),
((SELECT qid FROM q), '3.8', 'Refugee and asylum seekers',        'checkbox', 0, 38),
((SELECT qid FROM q), '3.9', 'Pregnancy and maternity',           'checkbox', 0, 39);

UPDATE question_items SET parent_item_number = '3'
WHERE question_id = (SELECT id FROM questions WHERE code='EQ5')
AND item_number IN ('3.1','3.2','3.3','3.4','3.5','3.6','3.7','3.8','3.9');

-- EQ7 — Disability Support Services
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Social Impact', 'Equality', 'EQ7',
'Do you offer support services for people with disabilities?',
'Current', 'Deanship of Student Affairs', 220);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'Existence of Disability Support Office',                                                    'yesno',    1, 10),
((SELECT qid FROM q), '1.1', 'Please provide URL evidence for Disability Support Office',                                 'url',      0, 11),
((SELECT qid FROM q), '2',   'Campus is easily accessible by people with disabilities',                                   'yesno',    1, 20),
((SELECT qid FROM q), '2.1', 'Please provide evidence (max 50 words)',                                                    'text',     0, 21),
((SELECT qid FROM q), '3',   'Access schemes for people with disabilities (mentoring or other targeted support)',         'yesno',    0, 30),
((SELECT qid FROM q), '3.1', 'Please provide URL evidence for access schemes',                                           'url',      0, 31),
((SELECT qid FROM q), '4',   'Our university offers on-campus accommodation',                                            'yesno',    0, 40),
((SELECT qid FROM q), '4.1', 'We have a reasonable accommodation policy or strategy for people with disabilities',       'yesno',    0, 41),
((SELECT qid FROM q), '4.2', 'Please provide URL evidence for accommodation policy',                                     'url',      0, 42);

UPDATE question_items SET max_words = 50
WHERE question_id = (SELECT id FROM questions WHERE code='EQ7') AND item_number = '2.1';

UPDATE question_items SET parent_item_number = '1'  WHERE question_id = (SELECT id FROM questions WHERE code='EQ7') AND item_number = '1.1';
UPDATE question_items SET parent_item_number = '2'  WHERE question_id = (SELECT id FROM questions WHERE code='EQ7') AND item_number = '2.1';
UPDATE question_items SET parent_item_number = '3'  WHERE question_id = (SELECT id FROM questions WHERE code='EQ7') AND item_number = '3.1';
UPDATE question_items SET parent_item_number = '4'  WHERE question_id = (SELECT id FROM questions WHERE code='EQ7') AND item_number IN ('4.1','4.2');

-- EQ* — Social Sustainability Training
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Social Impact', 'Equality', 'EQ*',
'Does your institution provide dedicated training on Social aspects of Sustainability?',
'Current', 'UTEL', 230);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'How many hours of training on Social aspects per employee?', 'number',   1, 10),
((SELECT qid FROM q), '2',   'Which of the following groups receive this training?',       'text',     0, 20),
((SELECT qid FROM q), '2.1', 'Students',                                                   'checkbox', 0, 21),
((SELECT qid FROM q), '2.2', 'Staff',                                                      'checkbox', 0, 22),
((SELECT qid FROM q), '2.3', 'Both',                                                       'checkbox', 0, 23),
((SELECT qid FROM q), '2.4', 'Please provide evidence',                                    'url',      0, 24);

UPDATE question_items SET parent_item_number = '2'
WHERE question_id = (SELECT id FROM questions WHERE code='EQ*')
AND item_number IN ('2.1','2.2','2.3','2.4');

-- THEME: Social Impact > Knowledge Exchange
-- KE2 — Outreach Projects
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Social Impact', 'Knowledge Exchange', 'KE2',
'Do you offer, manage or deliver outreach projects (education, health, information services, community engagement) for the local community?',
'Current', 'Sustainability Committee', 240);

INSERT INTO question_items (question_id, item_number, label, answer_type, max_words, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Please provide evidence (max 200 words)', 'text', 200, 1, 10);

-- THEME: Social Impact > Health and Wellbeing
-- HW2 — Health & Wellbeing Services
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Social Impact', 'Health and Wellbeing', 'HW2',
'Do you provide on-campus or local health and wellbeing services?',
'Current', 'College of Health and Sport Sciences', 250);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'Provision of healthy and affordable food choices for all on campus',                              'yesno', 0, 10),
((SELECT qid FROM q), '1.1', 'Please provide evidence (URL)',                                                                   'url',   0, 11),
((SELECT qid FROM q), '2',   'Access to physical health-care services including information and education services',             'yesno', 0, 20),
((SELECT qid FROM q), '2.1', 'Please provide evidence (URL)',                                                                   'url',   0, 21),
((SELECT qid FROM q), '3',   'Access to sexual and reproductive health-care services including information and education',       'yesno', 0, 30),
((SELECT qid FROM q), '3.1', 'Please provide evidence (URL)',                                                                   'url',   0, 31),
((SELECT qid FROM q), '4',   'Access to mental health support for both staff and students',                                     'yesno', 0, 40),
((SELECT qid FROM q), '4.1', 'Please provide evidence (URL)',                                                                   'url',   0, 41);

UPDATE question_items SET parent_item_number = '1' WHERE question_id = (SELECT id FROM questions WHERE code='HW2') AND item_number = '1.1';
UPDATE question_items SET parent_item_number = '2' WHERE question_id = (SELECT id FROM questions WHERE code='HW2') AND item_number = '2.1';
UPDATE question_items SET parent_item_number = '3' WHERE question_id = (SELECT id FROM questions WHERE code='HW2') AND item_number = '3.1';
UPDATE question_items SET parent_item_number = '4' WHERE question_id = (SELECT id FROM questions WHERE code='HW2') AND item_number = '4.1';

-- THEME: Governance > Good Governance
-- GG1 — EDI Committee
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG1',
'Do you have an equality, diversity and inclusion committee, office or officer tasked by the administration to advise on and implement policies, programmes and trainings related to diversity, equity, inclusion and human rights on campus?',
'Current (up to 3 years old)', 'Equal Opportunities Committee', 260);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'Existence of committee, office or officer',              'yesno', 1, 10),
((SELECT qid FROM q), '1.1', 'Please provide evidence (URL)',                          'url',   0, 11),
((SELECT qid FROM q), '2',   'Existence of anti-discrimination and anti-harassment policies', 'yesno', 1, 20),
((SELECT qid FROM q), '2.1', 'Please provide evidence URL (first)',                    'url',   0, 21),
((SELECT qid FROM q), '2.2', 'Please provide evidence URL (second)',                   'url',   0, 22);

UPDATE question_items SET parent_item_number = '1' WHERE question_id = (SELECT id FROM questions WHERE code='GG1' AND title LIKE '%equality, diversity%committee%') AND item_number = '1.1';
UPDATE question_items SET parent_item_number = '2' WHERE question_id = (SELECT id FROM questions WHERE code='GG1' AND title LIKE '%equality, diversity%committee%') AND item_number IN ('2.1','2.2');

-- GG7 — Anti-Bribery Policy
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG7',
'Do you have an Anti-bribery and corruption policy?',
'Current (up to 3 years old)', 'Director-General', 270);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Existence of anti-bribery and corruption policy or equivalent', 'yesno', 1, 10),
((SELECT qid FROM q), '2', 'Please provide evidence (URL)',                                  'url',   1, 20),
((SELECT qid FROM q), '3', 'This policy has been reviewed in the last 3 years',              'yesno', 0, 30);

-- GG* — Dedicated Sustainability Staff
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG*',
'Does your institution have a dedicated staff member or team whose sole responsibility is to advance sustainable development at the institution?',
'Current', 'Sustainability Committee', 280);

INSERT INTO question_items (question_id, item_number, label, answer_type, max_words, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Please provide evidence (max 200 words)', 'text', 200, 1, 10);

-- GG1 — Ethical Organisational Culture
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG1',
'Does your organisation support and facilitate a holistic ethical organisational culture?',
'Current (up to 3 years old)', 'Director-General', 290);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'Our organisation develops clear ethical values enshrined in a publicly available strategic document', 'yesno', 1, 10),
((SELECT qid FROM q), '1.1', 'Please provide URL evidence',                                                                         'url',   0, 11),
((SELECT qid FROM q), '2',   'Our university provides training based on those values at all levels',                                'yesno', 0, 20),
((SELECT qid FROM q), '2.1', 'Please provide URL evidence',                                                                         'url',   0, 21),
((SELECT qid FROM q), '3',   'There is an office for ethical compliance with a designated official with oversight on ethical matters', 'yesno', 0, 30),
((SELECT qid FROM q), '3.1', 'Please provide URL evidence',                                                                         'url',   0, 31),
((SELECT qid FROM q), '4',   'Our organisation has an internal reporting system for whistleblowers or a grievance procedure for staff', 'yesno', 0, 40),
((SELECT qid FROM q), '4.1', 'Please provide URL evidence',                                                                         'url',   0, 41);

-- GG5 — Student Union
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG5',
'Does your university have a student union?',
'Current', 'Deanship of Student Affairs', 300);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Our university has a recognised student union representing both UG and PG students', 'yesno',    1, 10),
((SELECT qid FROM q), '2', 'This student union is connected/affiliated to a wider national student union body',  'yesno',    0, 20),
((SELECT qid FROM q), '3', 'The student union elects its leadership, allowing students to vote',                 'yesno',    0, 30),
((SELECT qid FROM q), '4', 'Please provide URL evidence',                                                        'url',      1, 40);

-- GG* — Sustainability Committee
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG*',
'Has your institution formed a sustainability committee?',
'Current', 'Sustainability Committee', 310);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1',   'Does a member of your executive leadership team sit on this committee?', 'yesno', 1, 10),
((SELECT qid FROM q), '1.1', 'Please provide evidence to support your answers (max 200 words)',         'text',  1, 11);

UPDATE question_items SET max_words = 200 WHERE question_id = (SELECT id FROM questions WHERE code='GG*' AND title LIKE '%sustainability committee%') AND item_number = '1.1';

-- GG4 — Financial Reports
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG4',
'Does your institution publish their financial reports on an annual basis?',
'Previous financial reporting year', 'Finance', 320);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Income',             'yesno', 0, 10),
((SELECT qid FROM q), '2', 'Expenditure',        'yesno', 0, 20),
((SELECT qid FROM q), '3', 'Borrowing',          'yesno', 0, 30),
((SELECT qid FROM q), '4', 'Surplus',            'yesno', 0, 40),
((SELECT qid FROM q), '5', 'Please provide URL evidence', 'url', 1, 50);

-- GG7 — AGM Minutes
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG7',
'Does your institution publicly share the decisions taken in your annual general meeting?',
'Previous reporting year', 'Communication Directorate', 330);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Please provide URL evidence (link to minutes)', 'url', 1, 10);

-- GG6 — Student Representation in Governing Body
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Governance', 'Good Governance', 'GG6',
'Does your university''s governing body have student representation?',
'Current', 'President Office/Colleges', 340);

INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
(last_insert_rowid(), '1', 'Please provide URL evidence (leave blank if not applicable)', 'url', 0, 10);

-- THEME: Additional Information
INSERT INTO questions (ranking_cycle_id, theme, sub_theme, code, title, timeframe, data_provider, sort_order) VALUES
(2, 'Additional Information', 'Additional Information', 'ADD',
'Additional institutional data points.',
'Previous reporting year', 'Green Metric Committee / Finance / Registrar', 350);

WITH q AS (SELECT last_insert_rowid() AS qid)
INSERT INTO question_items (question_id, item_number, label, answer_type, is_required, sort_order) VALUES
((SELECT qid FROM q), '1', 'Water consumption for previous reporting year in cubic meters (m³)',        'number', 1, 10),
((SELECT qid FROM q), '2', 'Energy consumption for previous reporting year in kWh/year',               'number', 1, 20),
((SELECT qid FROM q), '3', 'Number of students receiving a scholarship covering 100% of their fees',   'number', 0, 30),
((SELECT qid FROM q), '4', 'Number of students receiving a scholarship covering at least 50% of fees', 'number', 0, 40);

-- ============================================================
-- TASK ASSIGNMENTS
-- ============================================================
INSERT OR IGNORE INTO task_assignments (question_id, department_id, ranking_cycle_id, status)
SELECT q.id, d.id, 2, 'pending'
FROM questions q
JOIN departments d ON 
    (q.data_provider = d.name) OR
    (q.data_provider = 'Green Metric Committee' AND d.name = 'Sustainability Office') OR
    (q.data_provider = 'QAAC' AND d.name = 'Quality Assurance') OR
    (q.data_provider = 'UTEL' AND d.name = 'IT & Digital Services') OR
    (q.data_provider = 'Deanship of Student Affairs' AND d.name = 'Quality Assurance') OR
    (q.data_provider = 'Deanship of Graduate Studies' AND d.name = 'Research & Graduate Studies') OR
    (q.data_provider = 'Deanship of Admission and Registration' AND d.name = 'Registrar Office') OR
    (q.data_provider = 'Director-General' AND d.name = 'Quality Assurance') OR
    (q.data_provider = 'Equal Opportunities Committee' AND d.name = 'Human Resources') OR
    (q.data_provider = 'Sustainability Committee' AND d.name = 'Sustainability Office') OR
    (q.data_provider = 'Investment Committee' AND d.name = 'Finance & Accounts') OR
    (q.data_provider = 'Purchasing' AND d.name = 'Finance & Accounts') OR
    (q.data_provider = 'Communication Directorate' AND d.name = 'Quality Assurance') OR
    (q.data_provider = 'President Office/Colleges' AND d.name = 'Quality Assurance') OR
    (q.data_provider = 'Finance' AND d.name = 'Finance & Accounts') OR
    (q.data_provider = 'HR' AND d.name = 'Human Resources') OR
    (q.data_provider = 'College of Health and Sport Sciences' AND d.name = 'College of Science')
WHERE q.ranking_cycle_id = 2
AND q.data_provider IS NOT NULL;