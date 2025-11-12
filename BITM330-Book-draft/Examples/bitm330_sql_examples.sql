
-- =====================================
-- BITM 330 - SQL Examples (SQLite)
-- Comprehensive Script for Students
-- =====================================

-- ====================
-- CREATE TABLES
-- ====================

CREATE TABLE STUDENT (
    StudentID INTEGER PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    Email TEXT UNIQUE,
    Birthday DATE,
    Grade REAL
);

CREATE TABLE DELIVERABLE (
    DeliverableID INTEGER PRIMARY KEY,
    Type TEXT NOT NULL,
    DeliverableNumber INTEGER,
    DueDate DATE,
    Topic TEXT,
    StudentID INTEGER,
    Score REAL,
    FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID)
);

CREATE TABLE Assignment (
    Type VARCHAR(50),
    Quantity INT,
    Points INT,
    Points_per_one AS (Points / Quantity)
);

ALTER TABLE Assignment ADD COLUMN AssignmentID INTEGER;

CREATE TABLE SCHEDULE (
    ClassNum INTEGER PRIMARY KEY,
    Week INTEGER,
    Date DATE,
    Day TEXT,
    Topic TEXT,
    Format TEXT
);

CREATE TABLE GRADE_SCALE (
    LetterGrade TEXT PRIMARY KEY,
    MinScore INT,
    MaxScore INT
);

CREATE TABLE ATTENDANCE (
    AttendanceID INTEGER PRIMARY KEY,
    ClassNum INTEGER,
    StudentID INTEGER,
    Attended INTEGER,
    FOREIGN KEY (ClassNum) REFERENCES SCHEDULE(ClassNum),
    FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID)
);

CREATE TABLE STUDENT_GRADE (
    GradeID INTEGER PRIMARY KEY,
    StudentID INTEGER NOT NULL,
    DeliverableID INTEGER NOT NULL,
    Score INTEGER NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID),
    FOREIGN KEY (DeliverableID) REFERENCES DELIVERABLE(DeliverableID)
);

-- ====================
-- INSERT VALUES
-- ====================

INSERT INTO STUDENT (StudentID, FirstName, LastName, Email, Birthday, Grade) VALUES
(1, 'Alice', 'Johnson', 'alice.johnson@university.edu', '2001-05-14', 'A'),
(2, 'Bob', 'Smith', 'bob.smith@university.edu', '2000-11-22', 'B+'),
(3, 'Carol', 'Davis', 'carol.davis@university.edu', '2002-02-08', 'A-'),
(4, 'David', 'Lee', 'david.lee@university.edu', '2001-07-19', 'B'),
(5, 'Eve', 'Martinez', 'eve.martinez@university.edu', '1999-09-30', 'C+');

INSERT INTO DELIVERABLE (DeliverableID, Type, DeliverableNumber, DueDate, Topic, StudentID, Score) VALUES
(1, 'Quiz', 1, '2025-09-10', 'Database Basics', 1, 95),
(2, 'Quiz', 1, '2025-09-10', 'Database Basics', 2, 88),
(3, 'Quiz', 1, '2025-09-10', 'Database Basics', 3, 100),
(4, 'Quiz', 2, '2025-09-20', 'Relational Model', 1, 92),
(5, 'Quiz', 2, '2025-09-20', 'Relational Model', 2, 75),
(6, 'Quiz', 2, '2025-09-20', 'Relational Model', 3, 85);

INSERT INTO Assignment (Type, Quantity, Points) VALUES
('Quiz', 4, 80),
('Exam', 2, 100),
('Project', 1, 50);

UPDATE Assignment SET AssignmentID = rowid;

INSERT INTO SCHEDULE (ClassNum, Week, Date, Day, Topic, Format) VALUES
(1, 1, '2025-09-01', 'Monday', 'Introduction to Databases', 'Lecture'),
(2, 1, '2025-09-03', 'Wednesday', 'Relational Model', 'Lecture'),
(3, 2, '2025-09-08', 'Monday', 'Entity Relationship Modeling', 'Lecture'),
(4, 2, '2025-09-10', 'Wednesday', 'Hands-on: ER Diagrams in Access', 'Lab');

INSERT INTO ATTENDANCE (AttendanceID, ClassNum, StudentID, Attended) VALUES
(1, 1, 1, 1),
(2, 1, 2, 0),
(3, 2, 3, 1);

INSERT INTO GRADE_SCALE VALUES
('A', 94, 100),
('A-', 89, 93),
('B+', 85, 88),
('B', 82, 84),
('B-', 79, 81);

INSERT INTO STUDENT_GRADE (GradeID, StudentID, DeliverableID, Score) VALUES
(1, 1, 1, 95),
(2, 2, 1, 88),
(3, 3, 1, 100),
(4, 4, 1, 76),
(5, 5, 1, 82),
(6, 1, 2, 90),
(7, 2, 2, 84),
(8, 3, 2, 92),
(9, 4, 2, 70),
(10, 5, 2, 85);

-- ====================
-- SELECT STATEMENTS
-- ====================

SELECT FirstName, LastName, Grade FROM STUDENT;
SELECT * FROM STUDENT WHERE Birthday < '2000-01-01';
SELECT FirstName || ' ' || LastName AS FullName FROM STUDENT;

-- ====================
-- JOINS
-- ====================

SELECT s.FirstName, s.LastName, d.Type, d.DueDate
FROM STUDENT s
INNER JOIN STUDENT_GRADE sg ON s.StudentID = sg.StudentID
INNER JOIN DELIVERABLE d ON sg.DeliverableID = d.DeliverableID;

SELECT s.FirstName, s.LastName, sg.Score
FROM STUDENT s
LEFT JOIN STUDENT_GRADE sg ON s.StudentID = sg.StudentID;

-- ====================
-- GROUP BY and HAVING
-- ====================

SELECT s.FirstName, s.LastName, AVG(g.Score) AS AverageGrade
FROM STUDENT s
JOIN STUDENT_GRADE g ON s.StudentID = g.StudentID
GROUP BY s.StudentID, s.FirstName, s.LastName;

SELECT s.FirstName, s.LastName, AVG(g.Score) AS AverageGrade
FROM STUDENT s
JOIN STUDENT_GRADE g ON s.StudentID = g.StudentID
GROUP BY s.StudentID, s.FirstName, s.LastName
HAVING AVG(g.Score) > 85;

-- ====================
-- SUBQUERIES
-- ====================

SELECT FirstName, LastName
FROM STUDENT
WHERE StudentID IN (
    SELECT StudentID FROM STUDENT_GRADE WHERE Score > 90
);

-- ====================
-- VIEWS
-- ====================

CREATE VIEW HighPerformers AS
SELECT s.FirstName, s.LastName, g.Score
FROM STUDENT s
JOIN STUDENT_GRADE g ON s.StudentID = g.StudentID
WHERE g.Score >= 90;

CREATE VIEW StudentDeliverables AS
SELECT s.StudentID, s.FirstName, s.LastName, d.Type, d.DeliverableNumber, d.DueDate, sg.Score
FROM STUDENT s
JOIN STUDENT_GRADE sg ON s.StudentID = sg.StudentID
JOIN DELIVERABLE d ON sg.DeliverableID = d.DeliverableID;

-- ====================
-- UNION
-- ====================

SELECT StudentID FROM DELIVERABLE
UNION
SELECT StudentID FROM ATTENDANCE;

-- ====================
-- EXPRESSIONS AND CALCULATIONS
-- ====================

SELECT DeliverableID, StudentID, Score, Score + 5 AS BonusScore
FROM DELIVERABLE;

SELECT FirstName, LastName,
       (strftime('%Y', 'now') - strftime('%Y', Birthday)) AS Age
FROM STUDENT;

SELECT s.FirstName || ' ' || s.LastName AS StudentName,
       ROUND(AVG(d.Score), 2) AS AvgScore,
       CASE
         WHEN AVG(d.Score) >= 90 THEN 'A'
         WHEN AVG(d.Score) >= 80 THEN 'B'
         WHEN AVG(d.Score) >= 70 THEN 'C'
         WHEN AVG(d.Score) >= 60 THEN 'D'
         ELSE 'F'
       END AS FinalGrade
FROM STUDENT s
JOIN DELIVERABLE d ON s.StudentID = d.StudentID
GROUP BY s.StudentID;

-- End of File
