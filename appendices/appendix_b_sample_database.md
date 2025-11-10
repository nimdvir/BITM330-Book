# Appendix B: Sample Database - University Management System

This appendix provides a complete sample database schema that you can use for practicing SQL queries and database design concepts.

## Database Schema Overview

The University Management System tracks:
- Students and their academic information
- Courses and course offerings
- Instructors and departments
- Student enrollments and grades
- Prerequisites and academic requirements

## Entity-Relationship Diagram

```
┌─────────────┐         ┌──────────────┐         ┌──────────┐
│ Department  │         │  Instructor  │         │  Course  │
├─────────────┤    1:N  ├──────────────┤   1:N   ├──────────┤
│ DeptID (PK) │◄────────│ InstructorID │────────►│CourseID  │
│ DeptName    │         │ FirstName    │         │CourseName│
│ Building    │         │ LastName     │         │ Credits  │
│ Budget      │         │ Email        │         │ DeptID   │
└─────────────┘         │ DeptID (FK)  │         └────┬─────┘
                        │ HireDate     │              │
                        └──────────────┘              │
                                                      │M:N
       ┌──────────┐                             ┌─────┴──────┐
       │ Student  │                             │Prerequisite│
       ├──────────┤                             ├────────────┤
       │StudentID │                             │ CourseID   │
       │FirstName │          ┌─────────────┐    │ PrereqID   │
       │LastName  │     M:N  │ Enrollment  │    └────────────┘
       │Email     │◄─────────├─────────────┤
       │Major     │          │ StudentID   │
       │GPA       │          │ CourseID    │
       │EnrollYear│          │ Semester    │
       └──────────┘          │ Year        │
                             │ Grade       │
                             └─────────────┘
```

## SQL DDL Scripts

### Create Database

```sql
CREATE DATABASE UniversityDB;
USE UniversityDB;
```

### Table: Departments

```sql
CREATE TABLE Departments (
    DeptID VARCHAR(10) PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL,
    Building VARCHAR(100),
    Budget DECIMAL(12,2),
    CreatedDate DATE DEFAULT CURRENT_DATE
);
```

### Table: Instructors

```sql
CREATE TABLE Instructors (
    InstructorID VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    DeptID VARCHAR(10),
    HireDate DATE,
    Salary DECIMAL(10,2),
    FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
```

### Table: Students

```sql
CREATE TABLE Students (
    StudentID VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    DateOfBirth DATE,
    Major VARCHAR(10),
    GPA DECIMAL(3,2) CHECK (GPA >= 0.0 AND GPA <= 4.0),
    EnrollmentYear INT,
    Status VARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Inactive', 'Graduated')),
    FOREIGN KEY (Major) REFERENCES Departments(DeptID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
```

### Table: Courses

```sql
CREATE TABLE Courses (
    CourseID VARCHAR(10) PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    Credits INT CHECK (Credits > 0 AND Credits <= 6),
    DeptID VARCHAR(10),
    Description TEXT,
    FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

### Table: Prerequisites

```sql
CREATE TABLE Prerequisites (
    CourseID VARCHAR(10),
    PrereqID VARCHAR(10),
    PRIMARY KEY (CourseID, PrereqID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (PrereqID) REFERENCES Courses(CourseID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CHECK (CourseID != PrereqID)
);
```

### Table: Enrollments

```sql
CREATE TABLE Enrollments (
    EnrollmentID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID VARCHAR(10),
    CourseID VARCHAR(10),
    InstructorID VARCHAR(10),
    Semester VARCHAR(20) CHECK (Semester IN ('Fall', 'Spring', 'Summer')),
    Year INT CHECK (Year >= 1900 AND Year <= 2100),
    Grade VARCHAR(2) CHECK (Grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F', 'W', 'I', NULL)),
    EnrollmentDate DATE DEFAULT CURRENT_DATE,
    UNIQUE (StudentID, CourseID, Semester, Year),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (InstructorID) REFERENCES Instructors(InstructorID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
```

## Sample Data

### Insert Departments

```sql
INSERT INTO Departments (DeptID, DeptName, Building, Budget) VALUES
('CS', 'Computer Science', 'Engineering Hall', 2500000.00),
('MATH', 'Mathematics', 'Science Center', 1800000.00),
('PHYS', 'Physics', 'Science Center', 2200000.00),
('ENG', 'English', 'Humanities Building', 1200000.00),
('HIST', 'History', 'Humanities Building', 1000000.00);
```

### Insert Instructors

```sql
INSERT INTO Instructors (InstructorID, FirstName, LastName, Email, Phone, DeptID, HireDate, Salary) VALUES
('I001', 'John', 'Smith', 'j.smith@university.edu', '555-0101', 'CS', '2015-08-15', 95000.00),
('I002', 'Emily', 'Johnson', 'e.johnson@university.edu', '555-0102', 'CS', '2017-01-10', 88000.00),
('I003', 'Michael', 'Brown', 'm.brown@university.edu', '555-0103', 'MATH', '2014-09-01', 92000.00),
('I004', 'Sarah', 'Davis', 's.davis@university.edu', '555-0104', 'PHYS', '2016-06-20', 90000.00),
('I005', 'David', 'Wilson', 'd.wilson@university.edu', '555-0105', 'ENG', '2018-08-25', 75000.00);
```

### Insert Students

```sql
INSERT INTO Students (StudentID, FirstName, LastName, Email, DateOfBirth, Major, GPA, EnrollmentYear, Status) VALUES
('S001', 'Alice', 'Anderson', 'alice.a@student.edu', '2002-03-15', 'CS', 3.85, 2020, 'Active'),
('S002', 'Bob', 'Baker', 'bob.b@student.edu', '2001-07-22', 'CS', 3.45, 2019, 'Active'),
('S003', 'Carol', 'Clark', 'carol.c@student.edu', '2002-11-08', 'MATH', 3.92, 2020, 'Active'),
('S004', 'David', 'Davis', 'david.d@student.edu', '2000-05-30', 'PHYS', 3.20, 2018, 'Active'),
('S005', 'Emma', 'Evans', 'emma.e@student.edu', '2003-01-12', 'CS', 3.78, 2021, 'Active'),
('S006', 'Frank', 'Foster', 'frank.f@student.edu', '2002-09-25', 'ENG', 3.55, 2020, 'Active'),
('S007', 'Grace', 'Garcia', 'grace.g@student.edu', '2001-12-03', 'MATH', 3.68, 2019, 'Active'),
('S008', 'Henry', 'Harris', 'henry.h@student.edu', '1999-04-18', 'CS', 3.95, 2017, 'Graduated'),
('S009', 'Iris', 'Ivanov', 'iris.i@student.edu', '2002-08-07', 'HIST', 3.42, 2020, 'Active'),
('S010', 'Jack', 'Jackson', 'jack.j@student.edu', '2003-02-28', 'CS', 3.15, 2021, 'Active');
```

### Insert Courses

```sql
INSERT INTO Courses (CourseID, CourseName, Credits, DeptID, Description) VALUES
('CS101', 'Introduction to Programming', 3, 'CS', 'Basic programming concepts using Python'),
('CS102', 'Data Structures', 4, 'CS', 'Fundamental data structures and algorithms'),
('CS201', 'Database Design', 3, 'CS', 'Relational database design and SQL'),
('CS301', 'Software Engineering', 3, 'CS', 'Software development methodologies'),
('MATH101', 'Calculus I', 4, 'MATH', 'Differential calculus'),
('MATH102', 'Calculus II', 4, 'MATH', 'Integral calculus'),
('MATH201', 'Linear Algebra', 3, 'MATH', 'Matrices and vector spaces'),
('PHYS101', 'Physics I', 4, 'PHYS', 'Mechanics and thermodynamics'),
('ENG101', 'English Composition', 3, 'ENG', 'Academic writing skills'),
('HIST101', 'World History', 3, 'HIST', 'Survey of world civilizations');
```

### Insert Prerequisites

```sql
INSERT INTO Prerequisites (CourseID, PrereqID) VALUES
('CS102', 'CS101'),
('CS201', 'CS102'),
('CS301', 'CS102'),
('MATH102', 'MATH101'),
('MATH201', 'MATH102');
```

### Insert Enrollments

```sql
INSERT INTO Enrollments (StudentID, CourseID, InstructorID, Semester, Year, Grade) VALUES
-- Fall 2023
('S001', 'CS201', 'I001', 'Fall', 2023, 'A'),
('S001', 'MATH201', 'I003', 'Fall', 2023, 'A-'),
('S002', 'CS201', 'I001', 'Fall', 2023, 'B+'),
('S002', 'CS301', 'I002', 'Fall', 2023, 'B'),
('S003', 'MATH201', 'I003', 'Fall', 2023, 'A'),
('S003', 'CS101', 'I001', 'Fall', 2023, 'A'),
('S004', 'PHYS101', 'I004', 'Fall', 2023, 'B-'),
('S005', 'CS102', 'I002', 'Fall', 2023, 'A-'),
('S006', 'ENG101', 'I005', 'Fall', 2023, 'B+'),
('S007', 'MATH102', 'I003', 'Fall', 2023, 'A-'),

-- Spring 2024 (some without grades yet)
('S001', 'CS301', 'I002', 'Spring', 2024, NULL),
('S002', 'MATH201', 'I003', 'Spring', 2024, NULL),
('S003', 'CS102', 'I001', 'Spring', 2024, NULL),
('S005', 'CS201', 'I001', 'Spring', 2024, NULL),
('S010', 'CS101', 'I001', 'Spring', 2024, NULL);
```

## Sample Queries

### Basic Queries

```sql
-- List all students
SELECT * FROM Students ORDER BY LastName, FirstName;

-- Find students with GPA above 3.5
SELECT StudentID, FirstName, LastName, GPA
FROM Students
WHERE GPA > 3.5
ORDER BY GPA DESC;

-- Count students by major
SELECT Major, COUNT(*) AS StudentCount
FROM Students
WHERE Status = 'Active'
GROUP BY Major
ORDER BY StudentCount DESC;
```

### Join Queries

```sql
-- Student enrollments with course names
SELECT 
    S.StudentID,
    S.FirstName || ' ' || S.LastName AS StudentName,
    C.CourseID,
    C.CourseName,
    E.Grade,
    E.Semester,
    E.Year
FROM Students S
JOIN Enrollments E ON S.StudentID = E.StudentID
JOIN Courses C ON E.CourseID = C.CourseID
ORDER BY S.LastName, E.Year, E.Semester;

-- Instructors and their departments
SELECT 
    I.InstructorID,
    I.FirstName || ' ' || I.LastName AS InstructorName,
    D.DeptName,
    D.Building
FROM Instructors I
LEFT JOIN Departments D ON I.DeptID = D.DeptID
ORDER BY D.DeptName, I.LastName;
```

### Aggregate Queries

```sql
-- Average GPA by major
SELECT 
    D.DeptName AS Major,
    COUNT(S.StudentID) AS StudentCount,
    ROUND(AVG(S.GPA), 2) AS AvgGPA,
    MIN(S.GPA) AS MinGPA,
    MAX(S.GPA) AS MaxGPA
FROM Students S
JOIN Departments D ON S.Major = D.DeptID
WHERE S.Status = 'Active'
GROUP BY D.DeptName
ORDER BY AvgGPA DESC;

-- Course enrollment statistics
SELECT 
    C.CourseID,
    C.CourseName,
    COUNT(E.StudentID) AS EnrollmentCount,
    AVG(CASE 
        WHEN E.Grade = 'A' THEN 4.0
        WHEN E.Grade = 'A-' THEN 3.7
        WHEN E.Grade = 'B+' THEN 3.3
        WHEN E.Grade = 'B' THEN 3.0
        WHEN E.Grade = 'B-' THEN 2.7
        WHEN E.Grade = 'C+' THEN 2.3
        WHEN E.Grade = 'C' THEN 2.0
        WHEN E.Grade = 'C-' THEN 1.7
        WHEN E.Grade = 'D+' THEN 1.3
        WHEN E.Grade = 'D' THEN 1.0
        WHEN E.Grade = 'F' THEN 0.0
    END) AS AvgGrade
FROM Courses C
LEFT JOIN Enrollments E ON C.CourseID = E.CourseID
GROUP BY C.CourseID, C.CourseName
HAVING COUNT(E.StudentID) > 0
ORDER BY EnrollmentCount DESC;
```

### Subquery Examples

```sql
-- Students with GPA above department average
SELECT 
    S.StudentID,
    S.FirstName,
    S.LastName,
    S.Major,
    S.GPA,
    (SELECT AVG(GPA) FROM Students S2 WHERE S2.Major = S.Major) AS DeptAvgGPA
FROM Students S
WHERE S.GPA > (
    SELECT AVG(GPA) 
    FROM Students S2 
    WHERE S2.Major = S.Major
)
ORDER BY S.Major, S.GPA DESC;

-- Courses with prerequisites
SELECT 
    C.CourseID,
    C.CourseName,
    (SELECT GROUP_CONCAT(P.PrereqID) 
     FROM Prerequisites P 
     WHERE P.CourseID = C.CourseID) AS Prerequisites
FROM Courses C
ORDER BY C.CourseID;
```

### Complex Queries

```sql
-- Student transcript
SELECT 
    S.FirstName || ' ' || S.LastName AS StudentName,
    S.Major,
    S.GPA,
    C.CourseID,
    C.CourseName,
    C.Credits,
    E.Grade,
    E.Semester || ' ' || E.Year AS Term
FROM Students S
JOIN Enrollments E ON S.StudentID = E.StudentID
JOIN Courses C ON E.CourseID = C.CourseID
WHERE S.StudentID = 'S001'
ORDER BY E.Year, 
         CASE E.Semester 
             WHEN 'Spring' THEN 1 
             WHEN 'Summer' THEN 2 
             WHEN 'Fall' THEN 3 
         END;
```

## Practice Exercises

Use this database to practice:

1. Write a query to find all courses taught by a specific instructor
2. Calculate the total credits earned by each student
3. Find students who haven't enrolled in any courses
4. List courses that have no prerequisites
5. Find the most popular courses (highest enrollment)
6. Calculate department budgets per instructor
7. Find students who are enrolled in courses outside their major
8. List all course prerequisites recursively

---
[← Appendix A: SQL Reference](appendix_a_sql_reference.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Next: Exercises →](appendix_c_exercises.md)
