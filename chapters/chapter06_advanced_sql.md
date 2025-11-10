# Chapter 6: Advanced SQL Topics

## 6.1 Subqueries and Nested Queries

A **subquery** is a query nested inside another query. Subqueries can appear in SELECT, FROM, WHERE, and HAVING clauses.

### 6.1.1 Subqueries in WHERE Clause

**Single-value Subquery:**
```sql
-- Find students with GPA above average
SELECT FirstName, LastName, GPA
FROM Students
WHERE GPA > (SELECT AVG(GPA) FROM Students);
```

**IN Subquery:**
```sql
-- Find students enrolled in CS courses
SELECT FirstName, LastName
FROM Students
WHERE StudentID IN (
    SELECT StudentID
    FROM Enrollments
    WHERE CourseID IN (
        SELECT CourseID
        FROM Courses
        WHERE DepartmentID = 'CS'
    )
);
```

**EXISTS Subquery:**
```sql
-- Find students who have enrolled in at least one course
SELECT FirstName, LastName
FROM Students S
WHERE EXISTS (
    SELECT 1
    FROM Enrollments E
    WHERE E.StudentID = S.StudentID
);
```

**NOT EXISTS:**
```sql
-- Find students who haven't enrolled in any course
SELECT FirstName, LastName
FROM Students S
WHERE NOT EXISTS (
    SELECT 1
    FROM Enrollments E
    WHERE E.StudentID = S.StudentID
);
```

**Comparison Operators with Subqueries:**
```sql
-- ANY: at least one row matches
SELECT * FROM Products
WHERE Price > ANY (SELECT Price FROM Products WHERE CategoryID = 1);

-- ALL: all rows must match
SELECT * FROM Products
WHERE Price > ALL (SELECT Price FROM Products WHERE CategoryID = 1);
```

### 6.1.2 Subqueries in FROM Clause (Derived Tables)

```sql
-- Average GPA by department
SELECT DeptName, AvgGPA
FROM (
    SELECT 
        D.DepartmentName AS DeptName,
        AVG(S.GPA) AS AvgGPA
    FROM Students S
    JOIN Departments D ON S.DepartmentID = D.DepartmentID
    GROUP BY D.DepartmentName
) AS DeptAvg
WHERE AvgGPA > 3.5;
```

### 6.1.3 Subqueries in SELECT Clause

```sql
SELECT 
    FirstName,
    LastName,
    GPA,
    (SELECT AVG(GPA) FROM Students) AS AvgGPA,
    GPA - (SELECT AVG(GPA) FROM Students) AS GPADifference
FROM Students;
```

### 6.1.4 Correlated Subqueries

Subqueries that reference columns from the outer query.

```sql
-- Find students with GPA above their department average
SELECT FirstName, LastName, GPA, DepartmentID
FROM Students S1
WHERE GPA > (
    SELECT AVG(GPA)
    FROM Students S2
    WHERE S2.DepartmentID = S1.DepartmentID
);
```

## 6.2 Aggregate Functions and GROUP BY

### 6.2.1 Aggregate Functions

**COUNT:**
```sql
-- Count all rows
SELECT COUNT(*) FROM Students;

-- Count non-null values
SELECT COUNT(PhoneNumber) FROM Students;

-- Count distinct values
SELECT COUNT(DISTINCT Major) FROM Students;
```

**SUM:**
```sql
SELECT SUM(Credits) AS TotalCredits
FROM Courses
WHERE DepartmentID = 'CS';
```

**AVG:**
```sql
SELECT AVG(GPA) AS AverageGPA
FROM Students
WHERE Major = 'Computer Science';
```

**MIN and MAX:**
```sql
SELECT 
    MIN(GPA) AS LowestGPA,
    MAX(GPA) AS HighestGPA
FROM Students;
```

### 6.2.2 GROUP BY

Groups rows with same values into summary rows.

```sql
-- Count students by major
SELECT Major, COUNT(*) AS StudentCount
FROM Students
GROUP BY Major;
```

**Multiple Grouping Columns:**
```sql
SELECT 
    DepartmentID,
    Major,
    COUNT(*) AS StudentCount,
    AVG(GPA) AS AvgGPA
FROM Students
GROUP BY DepartmentID, Major
ORDER BY DepartmentID, Major;
```

### 6.2.3 HAVING Clause

Filters groups (similar to WHERE but for aggregated data).

```sql
-- Find majors with more than 10 students
SELECT Major, COUNT(*) AS StudentCount
FROM Students
GROUP BY Major
HAVING COUNT(*) > 10;
```

**WHERE vs HAVING:**
```sql
-- WHERE filters before grouping, HAVING filters after
SELECT 
    DepartmentID,
    AVG(GPA) AS AvgGPA
FROM Students
WHERE EnrollmentYear >= 2020  -- Filter individual rows
GROUP BY DepartmentID
HAVING AVG(GPA) > 3.0;        -- Filter groups
```

### 6.2.4 Advanced Grouping

**GROUP BY with ROLLUP:**
```sql
-- Provides subtotals and grand totals
SELECT 
    DepartmentID,
    Major,
    COUNT(*) AS StudentCount
FROM Students
GROUP BY DepartmentID, Major WITH ROLLUP;
```

**GROUP BY with CUBE:**
```sql
-- All possible combinations of grouping
SELECT 
    DepartmentID,
    Major,
    COUNT(*) AS StudentCount
FROM Students
GROUP BY CUBE(DepartmentID, Major);
```

## 6.3 Views

A **view** is a virtual table based on a SELECT query. It doesn't store data itself but presents data from underlying tables.

### 6.3.1 Creating Views

**Simple View:**
```sql
CREATE VIEW ActiveStudents AS
SELECT StudentID, FirstName, LastName, Email, GPA
FROM Students
WHERE Status = 'Active';
```

**Complex View with Joins:**
```sql
CREATE VIEW StudentEnrollmentDetails AS
SELECT 
    S.StudentID,
    S.FirstName || ' ' || S.LastName AS StudentName,
    C.CourseID,
    C.CourseName,
    E.Grade,
    E.Semester
FROM Students S
INNER JOIN Enrollments E ON S.StudentID = E.StudentID
INNER JOIN Courses C ON E.CourseID = C.CourseID;
```

**View with Aggregation:**
```sql
CREATE VIEW DepartmentStats AS
SELECT 
    D.DepartmentID,
    D.DepartmentName,
    COUNT(S.StudentID) AS StudentCount,
    AVG(S.GPA) AS AvgGPA
FROM Departments D
LEFT JOIN Students S ON D.DepartmentID = S.DepartmentID
GROUP BY D.DepartmentID, D.DepartmentName;
```

### 6.3.2 Using Views

```sql
-- Query a view like a regular table
SELECT * FROM ActiveStudents WHERE GPA > 3.5;

SELECT StudentName, CourseName, Grade
FROM StudentEnrollmentDetails
WHERE Semester = 'Fall 2024';
```

### 6.3.3 Updatable Views

Some views allow INSERT, UPDATE, DELETE operations.

**Requirements for Updatable Views:**
- Single table (no joins)
- No GROUP BY, HAVING, DISTINCT
- No aggregate functions

```sql
-- Updatable view
CREATE VIEW CSStudents AS
SELECT StudentID, FirstName, LastName, GPA
FROM Students
WHERE Major = 'Computer Science';

-- Can update through the view
UPDATE CSStudents
SET GPA = 3.9
WHERE StudentID = 'S001';
```

### 6.3.4 Modifying and Dropping Views

**Modify View:**
```sql
CREATE OR REPLACE VIEW ActiveStudents AS
SELECT StudentID, FirstName, LastName, Email, GPA, Major
FROM Students
WHERE Status = 'Active';
```

**Drop View:**
```sql
DROP VIEW IF EXISTS ActiveStudents;
```

### 6.3.5 Advantages of Views

1. **Security**: Hide sensitive columns
2. **Simplification**: Hide complex queries
3. **Logical Independence**: Changes to base tables don't affect views
4. **Reusability**: Use same logic in multiple queries

## 6.4 Indexes

An **index** is a database object that improves query performance by providing fast access to rows.

### 6.4.1 Creating Indexes

**Single-Column Index:**
```sql
CREATE INDEX idx_students_email ON Students(Email);
```

**Multi-Column (Composite) Index:**
```sql
CREATE INDEX idx_enrollments_student_course 
ON Enrollments(StudentID, CourseID);
```

**Unique Index:**
```sql
CREATE UNIQUE INDEX idx_students_email_unique 
ON Students(Email);
```

### 6.4.2 Types of Indexes

**B-Tree Index** (Default):
- Balanced tree structure
- Good for range queries
- Most common type

**Hash Index:**
- Fast equality searches
- Not good for range queries

**Full-Text Index:**
```sql
CREATE FULLTEXT INDEX idx_courses_description 
ON Courses(Description);

-- Use in queries
SELECT * FROM Courses
WHERE MATCH(Description) AGAINST('database design');
```

### 6.4.3 When to Use Indexes

**Use indexes for:**
- Primary keys (automatic)
- Foreign keys
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY

**Avoid indexes for:**
- Small tables
- Columns with many duplicate values
- Tables with frequent INSERT/UPDATE/DELETE
- Columns rarely used in queries

### 6.4.4 Index Performance

**Check Query Execution Plan:**
```sql
EXPLAIN SELECT * FROM Students WHERE Email = 'alice@university.edu';
```

### 6.4.5 Managing Indexes

**List Indexes:**
```sql
-- MySQL
SHOW INDEX FROM Students;

-- PostgreSQL
\d Students
```

**Drop Index:**
```sql
DROP INDEX idx_students_email;
```

## 6.5 Stored Procedures and Functions

**Stored Procedures** and **Functions** are reusable SQL code blocks stored in the database.

### 6.5.1 Stored Procedures

**Creating a Procedure:**
```sql
-- MySQL/MariaDB
DELIMITER //
CREATE PROCEDURE GetStudentsByMajor(IN majorName VARCHAR(50))
BEGIN
    SELECT StudentID, FirstName, LastName, GPA
    FROM Students
    WHERE Major = majorName
    ORDER BY GPA DESC;
END //
DELIMITER ;

-- PostgreSQL
CREATE PROCEDURE GetStudentsByMajor(majorName VARCHAR(50))
LANGUAGE SQL
AS $$
    SELECT StudentID, FirstName, LastName, GPA
    FROM Students
    WHERE Major = majorName
    ORDER BY GPA DESC;
$$;
```

**Calling a Procedure:**
```sql
CALL GetStudentsByMajor('Computer Science');
```

**Procedure with Output Parameter:**
```sql
DELIMITER //
CREATE PROCEDURE GetStudentCount(
    IN majorName VARCHAR(50),
    OUT studentCount INT
)
BEGIN
    SELECT COUNT(*) INTO studentCount
    FROM Students
    WHERE Major = majorName;
END //
DELIMITER ;

-- Call it
CALL GetStudentCount('Computer Science', @count);
SELECT @count;
```

### 6.5.2 Functions

**Creating a Function:**
```sql
-- MySQL
DELIMITER //
CREATE FUNCTION CalculateGrade(score INT)
RETURNS CHAR(1)
DETERMINISTIC
BEGIN
    IF score >= 90 THEN RETURN 'A';
    ELSEIF score >= 80 THEN RETURN 'B';
    ELSEIF score >= 70 THEN RETURN 'C';
    ELSEIF score >= 60 THEN RETURN 'D';
    ELSE RETURN 'F';
    END IF;
END //
DELIMITER ;

-- Use it
SELECT StudentID, Score, CalculateGrade(Score) AS Grade
FROM Exam Results;
```

**PostgreSQL Function:**
```sql
CREATE FUNCTION GetFullName(firstName VARCHAR, lastName VARCHAR)
RETURNS VARCHAR
AS $$
BEGIN
    RETURN firstName || ' ' || lastName;
END;
$$ LANGUAGE plpgsql;

-- Use it
SELECT GetFullName(FirstName, LastName) AS FullName
FROM Students;
```

## 6.6 Triggers

A **trigger** is a stored procedure that automatically executes when a specified event occurs.

### 6.6.1 Creating Triggers

**BEFORE INSERT Trigger:**
```sql
-- MySQL
DELIMITER //
CREATE TRIGGER before_student_insert
BEFORE INSERT ON Students
FOR EACH ROW
BEGIN
    IF NEW.GPA < 0 OR NEW.GPA > 4.0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'GPA must be between 0.0 and 4.0';
    END IF;
END //
DELIMITER ;
```

**AFTER UPDATE Trigger:**
```sql
-- Create audit table first
CREATE TABLE StudentAudit (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID VARCHAR(10),
    OldGPA DECIMAL(3,2),
    NewGPA DECIMAL(3,2),
    ChangeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger
DELIMITER //
CREATE TRIGGER after_gpa_update
AFTER UPDATE ON Students
FOR EACH ROW
BEGIN
    IF OLD.GPA != NEW.GPA THEN
        INSERT INTO StudentAudit (StudentID, OldGPA, NewGPA)
        VALUES (NEW.StudentID, OLD.GPA, NEW.GPA);
    END IF;
END //
DELIMITER ;
```

**BEFORE DELETE Trigger:**
```sql
DELIMITER //
CREATE TRIGGER before_student_delete
BEFORE DELETE ON Students
FOR EACH ROW
BEGIN
    -- Archive the deleted student
    INSERT INTO DeletedStudents
    SELECT * FROM Students WHERE StudentID = OLD.StudentID;
END //
DELIMITER ;
```

### 6.6.2 Trigger Events

- **BEFORE INSERT**: Before a new row is inserted
- **AFTER INSERT**: After a new row is inserted
- **BEFORE UPDATE**: Before a row is updated
- **AFTER UPDATE**: After a row is updated
- **BEFORE DELETE**: Before a row is deleted
- **AFTER DELETE**: After a row is deleted

### 6.6.3 Managing Triggers

**List Triggers:**
```sql
SHOW TRIGGERS;
```

**Drop Trigger:**
```sql
DROP TRIGGER IF EXISTS before_student_insert;
```

## Summary

Advanced SQL features enhance database capabilities:
- **Subqueries** enable complex filtering and calculations
- **Aggregate functions and GROUP BY** summarize data
- **Views** simplify complex queries and enhance security
- **Indexes** improve query performance
- **Stored procedures** encapsulate reusable logic
- **Functions** perform calculations and transformations
- **Triggers** automate database actions

These tools enable sophisticated database applications and efficient data management.

## Review Questions

1. What's the difference between WHERE and HAVING?
2. When would you use a correlated subquery?
3. What are the advantages of using views?
4. When should you create an index?
5. What's the difference between a stored procedure and a function?

## Exercises

1. Write a query using a subquery to find students with GPA above the average.

2. Create a view that shows course enrollment counts by department.

3. Write a query using GROUP BY and HAVING to find courses with more than 20 enrollments.

4. Design a trigger that prevents deleting a student who has active enrollments.

---
[← Previous Chapter: SQL Fundamentals](chapter05_sql_fundamentals.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Next Chapter: Best Practices →](chapter07_best_practices.md)
