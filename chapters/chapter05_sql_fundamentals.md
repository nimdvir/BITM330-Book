# Chapter 5: SQL Fundamentals

## 5.1 Introduction to SQL

**SQL (Structured Query Language)** is the standard language for interacting with relational databases. It's a declarative language - you specify *what* you want, not *how* to get it.

### SQL Components:

1. **DDL (Data Definition Language)**: Define database structure
   - CREATE, ALTER, DROP, TRUNCATE

2. **DML (Data Manipulation Language)**: Manipulate data
   - SELECT, INSERT, UPDATE, DELETE

3. **DCL (Data Control Language)**: Control access
   - GRANT, REVOKE

4. **TCL (Transaction Control Language)**: Manage transactions
   - COMMIT, ROLLBACK, SAVEPOINT

### SQL Characteristics:
- **Case-insensitive** for keywords (SELECT = select = SeLeCt)
- **Standardized** (ANSI/ISO standard)
- **Vendor-specific** extensions (each DBMS has unique features)
- **Declarative** (describe what, not how)

## 5.2 Data Definition Language (DDL)

### 5.2.1 CREATE TABLE

**Syntax:**
```sql
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    ...
    table_constraints
);
```

**Example:**
```sql
CREATE TABLE Students (
    StudentID VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    DateOfBirth DATE,
    GPA DECIMAL(3,2) CHECK (GPA >= 0.0 AND GPA <= 4.0),
    EnrollmentDate DATE DEFAULT CURRENT_DATE
);
```

### Common Data Types:

**Numeric:**
- `INT`, `SMALLINT`, `BIGINT`: Integers
- `DECIMAL(p,s)`, `NUMERIC(p,s)`: Fixed precision
- `FLOAT`, `REAL`, `DOUBLE`: Floating point

**Character:**
- `CHAR(n)`: Fixed-length string
- `VARCHAR(n)`: Variable-length string
- `TEXT`: Large text

**Date/Time:**
- `DATE`: Date (YYYY-MM-DD)
- `TIME`: Time (HH:MM:SS)
- `DATETIME`, `TIMESTAMP`: Date and time

**Other:**
- `BOOLEAN`: True/false
- `BLOB`: Binary data

### 5.2.2 Constraints

**Primary Key:**
```sql
-- Method 1: Column-level
CREATE TABLE Courses (
    CourseID VARCHAR(10) PRIMARY KEY,
    CourseName VARCHAR(100)
);

-- Method 2: Table-level
CREATE TABLE CourseOfferings (
    CourseID VARCHAR(10),
    Semester VARCHAR(20),
    Year INT,
    PRIMARY KEY (CourseID, Semester, Year)
);
```

**Foreign Key:**
```sql
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID VARCHAR(10),
    CourseID VARCHAR(10),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);
```

**Unique:**
```sql
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE,
    Email VARCHAR(100) UNIQUE
);
```

**Check:**
```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Age INT CHECK (Age >= 18 AND Age <= 65),
    Salary DECIMAL(10,2) CHECK (Salary > 0),
    Status VARCHAR(20) CHECK (Status IN ('Active', 'Inactive', 'On Leave'))
);
```

**Not Null:**
```sql
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL
);
```

**Default:**
```sql
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE DEFAULT CURRENT_DATE,
    Status VARCHAR(20) DEFAULT 'Pending'
);
```

### 5.2.3 ALTER TABLE

**Add Column:**
```sql
ALTER TABLE Students
ADD PhoneNumber VARCHAR(15);
```

**Modify Column:**
```sql
-- MySQL/MariaDB
ALTER TABLE Students
MODIFY Email VARCHAR(150);

-- PostgreSQL
ALTER TABLE Students
ALTER COLUMN Email TYPE VARCHAR(150);
```

**Drop Column:**
```sql
ALTER TABLE Students
DROP COLUMN PhoneNumber;
```

**Add Constraint:**
```sql
ALTER TABLE Students
ADD CONSTRAINT chk_gpa CHECK (GPA >= 0.0 AND GPA <= 4.0);
```

### 5.2.4 DROP and TRUNCATE

**DROP TABLE** (deletes table and data):
```sql
DROP TABLE IF EXISTS OldTable;
```

**TRUNCATE TABLE** (removes all data, keeps structure):
```sql
TRUNCATE TABLE Students;
```

## 5.3 Data Manipulation Language (DML)

### 5.3.1 INSERT

**Insert Single Row:**
```sql
INSERT INTO Students (StudentID, FirstName, LastName, Email, GPA)
VALUES ('S001', 'Alice', 'Smith', 'alice@university.edu', 3.8);
```

**Insert Multiple Rows:**
```sql
INSERT INTO Students (StudentID, FirstName, LastName, Email, GPA)
VALUES 
    ('S002', 'Bob', 'Johnson', 'bob@university.edu', 3.5),
    ('S003', 'Carol', 'Davis', 'carol@university.edu', 3.9),
    ('S004', 'David', 'Wilson', 'david@university.edu', 3.2);
```

**Insert from SELECT:**
```sql
INSERT INTO HighPerformers (StudentID, Name, GPA)
SELECT StudentID, FirstName || ' ' || LastName, GPA
FROM Students
WHERE GPA >= 3.5;
```

### 5.3.2 UPDATE

**Update Single Row:**
```sql
UPDATE Students
SET GPA = 3.9
WHERE StudentID = 'S001';
```

**Update Multiple Rows:**
```sql
UPDATE Students
SET GPA = GPA + 0.1
WHERE GPA < 3.0;
```

**Update with Calculation:**
```sql
UPDATE Employees
SET Salary = Salary * 1.05
WHERE DepartmentID = 'IT';
```

**Update Multiple Columns:**
```sql
UPDATE Students
SET Email = 'newalice@university.edu',
    PhoneNumber = '555-1234'
WHERE StudentID = 'S001';
```

### 5.3.3 DELETE

**Delete Specific Rows:**
```sql
DELETE FROM Students
WHERE GPA < 2.0;
```

**Delete All Rows** (use TRUNCATE instead):
```sql
DELETE FROM TempTable;
```

**Delete with Subquery:**
```sql
DELETE FROM Enrollments
WHERE StudentID IN (
    SELECT StudentID FROM Students WHERE Status = 'Graduated'
);
```

## 5.4 SELECT Queries

### 5.4.1 Basic SELECT

**Select All Columns:**
```sql
SELECT * FROM Students;
```

**Select Specific Columns:**
```sql
SELECT FirstName, LastName, Email FROM Students;
```

**Select with Alias:**
```sql
SELECT 
    FirstName AS First,
    LastName AS Last,
    GPA AS 'Grade Point Average'
FROM Students;
```

**Select Distinct Values:**
```sql
SELECT DISTINCT Major FROM Students;
```

**Select with Calculation:**
```sql
SELECT 
    ProductName,
    Price,
    Price * 0.9 AS DiscountedPrice
FROM Products;
```

### 5.4.2 String Functions

```sql
-- Concatenation
SELECT FirstName || ' ' || LastName AS FullName FROM Students;
-- or
SELECT CONCAT(FirstName, ' ', LastName) AS FullName FROM Students;

-- Uppercase/Lowercase
SELECT UPPER(Email) FROM Students;
SELECT LOWER(CourseName) FROM Courses;

-- Substring
SELECT SUBSTRING(StudentID, 1, 3) FROM Students;

-- Length
SELECT LENGTH(CourseName) FROM Courses;

-- Trim
SELECT TRIM(ProductName) FROM Products;
```

### 5.4.3 Numeric Functions

```sql
-- Round
SELECT ROUND(Price, 2) FROM Products;

-- Ceiling/Floor
SELECT CEIL(GPA), FLOOR(GPA) FROM Students;

-- Absolute Value
SELECT ABS(Balance) FROM Accounts;

-- Mathematical Operations
SELECT Price * Quantity AS Total FROM OrderItems;
```

### 5.4.4 Date Functions

```sql
-- Current Date/Time
SELECT CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP;

-- Extract Parts
SELECT YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate)
FROM Orders;

-- Date Arithmetic
SELECT OrderDate, OrderDate + INTERVAL 30 DAY AS DueDate
FROM Orders;

-- Age Calculation
SELECT 
    FirstName,
    DateOfBirth,
    YEAR(CURRENT_DATE) - YEAR(DateOfBirth) AS Age
FROM Students;
```

## 5.5 Filtering and Sorting

### 5.5.1 WHERE Clause

**Comparison Operators:**
```sql
-- Equal
SELECT * FROM Students WHERE Major = 'Computer Science';

-- Not Equal
SELECT * FROM Students WHERE Major != 'Mathematics';

-- Greater/Less Than
SELECT * FROM Students WHERE GPA > 3.5;
SELECT * FROM Students WHERE Age < 25;

-- Between
SELECT * FROM Products WHERE Price BETWEEN 10 AND 50;

-- In List
SELECT * FROM Students WHERE Major IN ('CS', 'Math', 'Engineering');

-- Like (Pattern Matching)
SELECT * FROM Students WHERE Email LIKE '%@university.edu';
SELECT * FROM Courses WHERE CourseName LIKE 'Database%';

-- IS NULL / IS NOT NULL
SELECT * FROM Students WHERE PhoneNumber IS NULL;
```

**Wildcards:**
- `%`: Any sequence of characters
- `_`: Single character

```sql
SELECT * FROM Students WHERE LastName LIKE 'S%';  -- Starts with S
SELECT * FROM Students WHERE LastName LIKE '%son'; -- Ends with son
SELECT * FROM Students WHERE LastName LIKE '_mit%'; -- Second char is m
```

### 5.5.2 Logical Operators

**AND:**
```sql
SELECT * FROM Students
WHERE Major = 'Computer Science' AND GPA > 3.5;
```

**OR:**
```sql
SELECT * FROM Students
WHERE Major = 'Computer Science' OR Major = 'Mathematics';
```

**NOT:**
```sql
SELECT * FROM Students
WHERE NOT (GPA < 2.0);
```

**Complex Conditions:**
```sql
SELECT * FROM Students
WHERE (Major = 'CS' AND GPA > 3.5)
   OR (Major = 'Math' AND GPA > 3.7);
```

### 5.5.3 ORDER BY

**Ascending (Default):**
```sql
SELECT * FROM Students ORDER BY LastName;
SELECT * FROM Students ORDER BY LastName ASC;
```

**Descending:**
```sql
SELECT * FROM Students ORDER BY GPA DESC;
```

**Multiple Columns:**
```sql
SELECT * FROM Students
ORDER BY Major ASC, GPA DESC;
```

**Order by Calculation:**
```sql
SELECT FirstName, LastName, GPA
FROM Students
ORDER BY GPA * Credits DESC;
```

### 5.5.4 LIMIT/OFFSET

**Limit Results:**
```sql
-- MySQL/PostgreSQL
SELECT * FROM Students ORDER BY GPA DESC LIMIT 10;

-- SQL Server
SELECT TOP 10 * FROM Students ORDER BY GPA DESC;
```

**Pagination:**
```sql
-- Page 1 (rows 1-10)
SELECT * FROM Students ORDER BY StudentID LIMIT 10 OFFSET 0;

-- Page 2 (rows 11-20)
SELECT * FROM Students ORDER BY StudentID LIMIT 10 OFFSET 10;

-- Page 3 (rows 21-30)
SELECT * FROM Students ORDER BY StudentID LIMIT 10 OFFSET 20;
```

## 5.6 Joins

### 5.6.1 INNER JOIN

Returns rows when there's a match in both tables.

```sql
SELECT 
    S.StudentID,
    S.FirstName,
    S.LastName,
    E.CourseID,
    E.Grade
FROM Students S
INNER JOIN Enrollments E ON S.StudentID = E.StudentID;
```

### 5.6.2 LEFT JOIN (LEFT OUTER JOIN)

Returns all rows from left table, matching rows from right table.

```sql
SELECT 
    S.StudentID,
    S.FirstName,
    E.CourseID,
    E.Grade
FROM Students S
LEFT JOIN Enrollments E ON S.StudentID = E.StudentID;
-- Shows all students, even those not enrolled in any course
```

### 5.6.3 RIGHT JOIN (RIGHT OUTER JOIN)

Returns all rows from right table, matching rows from left table.

```sql
SELECT 
    C.CourseID,
    C.CourseName,
    E.StudentID
FROM Enrollments E
RIGHT JOIN Courses C ON E.CourseID = C.CourseID;
-- Shows all courses, even those with no enrollments
```

### 5.6.4 FULL OUTER JOIN

Returns all rows when there's a match in either table.

```sql
SELECT 
    S.StudentID,
    S.FirstName,
    E.CourseID
FROM Students S
FULL OUTER JOIN Enrollments E ON S.StudentID = E.StudentID;
-- Shows all students and all enrollments
```

### 5.6.5 CROSS JOIN

Returns Cartesian product of both tables.

```sql
SELECT 
    S.StudentID,
    C.CourseID
FROM Students S
CROSS JOIN Courses C;
-- Every student paired with every course
```

### 5.6.6 Self Join

Joining a table with itself.

```sql
SELECT 
    E1.EmployeeName AS Employee,
    E2.EmployeeName AS Manager
FROM Employees E1
LEFT JOIN Employees E2 ON E1.ManagerID = E2.EmployeeID;
```

### 5.6.7 Multiple Joins

```sql
SELECT 
    S.FirstName,
    S.LastName,
    C.CourseName,
    D.DepartmentName,
    E.Grade
FROM Students S
INNER JOIN Enrollments E ON S.StudentID = E.StudentID
INNER JOIN Courses C ON E.CourseID = C.CourseID
INNER JOIN Departments D ON C.DepartmentID = D.DepartmentID
WHERE E.Grade = 'A';
```

## Summary

SQL fundamentals provide the foundation for database interaction:
- **DDL** creates and modifies database structure
- **DML** manipulates data (SELECT, INSERT, UPDATE, DELETE)
- **Filtering** with WHERE and pattern matching
- **Sorting** with ORDER BY
- **Joins** combine data from multiple tables

Mastering these concepts enables you to effectively query and manage relational databases.

## Review Questions

1. What's the difference between DROP and TRUNCATE?
2. What does the DISTINCT keyword do?
3. Explain the difference between INNER JOIN and LEFT JOIN.
4. What wildcard characters are used with the LIKE operator?
5. How do you limit query results to the top 10 rows?

## Exercises

1. Write SQL to create a Products table with ProductID, Name, Price, and CategoryID.

2. Write a query to find all students with GPA above 3.5, ordered by GPA descending.

3. Write a query to join Students and Enrollments tables, showing student names and their course IDs.

4. Write a query to find all products with names starting with 'A' and price between 10 and 100.

---
[← Previous Chapter: Normalization](chapter04_normalization.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Next Chapter: Advanced SQL →](chapter06_advanced_sql.md)
