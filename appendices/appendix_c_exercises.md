# Appendix C: Exercises and Solutions

This appendix provides exercises for each chapter with detailed solutions to help reinforce the concepts covered in this textbook.

## Chapter 1: Introduction to Databases

### Exercises

**Exercise 1.1**: Compare and contrast databases with file-based systems. List at least three advantages of using a database.

**Exercise 1.2**: Research and identify which type of database (relational, document, key-value, graph) would be most appropriate for:
- a) A social media platform like Facebook
- b) A banking system
- c) A simple user session management
- d) A recommendation engine

**Exercise 1.3**: Describe three different roles in database management and their responsibilities.

### Solutions

**Solution 1.1**:
Advantages of databases over file-based systems:
1. **Data Independence**: Application logic is separated from data storage. Changes to data structure don't require changes to applications.
2. **Reduced Redundancy**: Data is stored once and referenced from multiple locations, reducing duplication.
3. **Data Integrity**: Constraints and rules ensure data accuracy and consistency across the system.
4. **Concurrent Access**: Multiple users can access data simultaneously without conflicts.
5. **Security**: Centralized access control and user authentication protect sensitive data.

**Solution 1.2**:
- a) **Graph database** (e.g., Neo4j): Social networks are naturally graph-structured with users (nodes) and relationships (edges)
- b) **Relational database** (e.g., PostgreSQL): Banking requires ACID compliance, complex transactions, and structured data
- c) **Key-value store** (e.g., Redis): Fast access to session data using session ID as key
- d) **Document database** (e.g., MongoDB): Flexible schema for diverse product attributes and user preferences

**Solution 1.3**:
1. **Database Administrator (DBA)**: Installs and configures DBMS, manages security and permissions, performs backups, monitors performance
2. **Data Architect**: Designs database schemas, defines standards and naming conventions, ensures data quality
3. **Application Developer**: Writes queries and stored procedures, integrates database with applications, optimizes query performance

## Chapter 2: The Relational Database Model

### Exercises

**Exercise 2.1**: Design a relational schema for a library system with the following requirements:
- Track books (ISBN, title, author, publication year)
- Track library members (member ID, name, email, join date)
- Track book loans (which member borrowed which book, when, due date)
- Identify all primary and foreign keys

**Exercise 2.2**: Given the following table, identify all candidate keys:
```
Employees(EmployeeID, SSN, Email, PhoneNumber, Name, DepartmentID)
```
Assume all of EmployeeID, SSN, and Email are unique.

**Exercise 2.3**: Write SQL statements with appropriate constraints to create tables from Exercise 2.1.

### Solutions

**Solution 2.1**:
```
Books(ISBN, Title, Author, PublicationYear)
- Primary Key: ISBN

Members(MemberID, Name, Email, JoinDate)
- Primary Key: MemberID

Loans(LoanID, ISBN, MemberID, LoanDate, DueDate, ReturnDate)
- Primary Key: LoanID
- Foreign Keys: ISBN → Books(ISBN), MemberID → Members(MemberID)
```

**Solution 2.2**:
Candidate keys are attributes that could uniquely identify a row:
- EmployeeID (chosen as primary key typically)
- SSN (Social Security Number is unique)
- Email (unique per employee)

PhoneNumber might not be unique (shared phones, NULL values), and Name is definitely not unique.

**Solution 2.3**:
```sql
CREATE TABLE Books (
    ISBN VARCHAR(13) PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Author VARCHAR(100) NOT NULL,
    PublicationYear INT CHECK (PublicationYear >= 1000 AND PublicationYear <= YEAR(CURRENT_DATE))
);

CREATE TABLE Members (
    MemberID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    JoinDate DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    ISBN VARCHAR(13) NOT NULL,
    MemberID VARCHAR(10) NOT NULL,
    LoanDate DATE DEFAULT CURRENT_DATE,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE RESTRICT,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE RESTRICT,
    CHECK (DueDate > LoanDate),
    CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate)
);
```

## Chapter 3: Entity-Relationship Modeling

### Exercises

**Exercise 3.1**: Create an ER diagram for an online shopping system with:
- Customers (customer ID, name, email, address)
- Products (product ID, name, description, price, stock quantity)
- Orders (order ID, order date, status)
- Order items (which products in which quantities per order)

**Exercise 3.2**: Identify the cardinality for these relationships:
- a) Author → Books
- b) Student → Dormitory Room
- c) Doctor → Patient
- d) Employee → Project

**Exercise 3.3**: Convert the ER design from Exercise 3.1 into relational tables with SQL CREATE statements.

### Solutions

**Solution 3.1**:
```
┌──────────┐         ┌──────────┐         ┌─────────┐
│ Customer │         │  Order   │         │ Product │
├──────────┤    1:N  ├──────────┤   M:N   ├─────────┤
│CustID(PK)│────────►│OrderID   │◄────────│ProdID   │
│Name      │         │CustID(FK)│         │Name     │
│Email     │         │OrderDate │         │Price    │
│Address   │         │Status    │         │Stock    │
└──────────┘         └────┬─────┘         └─────────┘
                          │
                          │
                     ┌────┴─────┐
                     │OrderItems│
                     ├──────────┤
                     │OrderID   │
                     │ProdID    │
                     │Quantity  │
                     │Price     │
                     └──────────┘
```

**Solution 3.2**:
- a) **One-to-Many (1:N)**: One author can write many books (assuming single-author books)
- b) **Many-to-One (N:1)** or **Many-to-Many (M:N)**: Depends on policy. If private rooms: Many-to-One. If shared rooms: Many-to-Many.
- c) **Many-to-Many (M:N)**: A doctor treats many patients, a patient can see many doctors
- d) **Many-to-Many (M:N)**: An employee can work on multiple projects, a project has multiple employees

**Solution 3.3**:
```sql
CREATE TABLE Customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Address TEXT
);

CREATE TABLE Products (
    ProductID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    StockQuantity INT DEFAULT 0 CHECK (StockQuantity >= 0)
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID VARCHAR(10) NOT NULL,
    OrderDate DATE DEFAULT CURRENT_DATE,
    Status VARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
    OrderID INT,
    ProductID VARCHAR(10),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
```

## Chapter 4: Normalization

### Exercises

**Exercise 4.1**: Normalize the following table to 3NF:
```
StudentCourses(StudentID, StudentName, StudentEmail, CourseID, CourseName, 
               InstructorID, InstructorName, Grade)
```

**Exercise 4.2**: Identify all functional dependencies in this table:
```
Orders(OrderID, CustomerID, CustomerName, ProductID, ProductName, 
       Quantity, Price, OrderDate)
```

**Exercise 4.3**: Is this design in BCNF? If not, convert it:
```
Consultations(PatientID, DoctorID, Date, DoctorSpecialty)
Given: DoctorID → DoctorSpecialty
```

### Solutions

**Solution 4.1**:

**Step 1: Identify functional dependencies**
- StudentID → StudentName, StudentEmail
- CourseID → CourseName
- InstructorID → InstructorName
- CourseID → InstructorID (assuming one instructor per course)
- StudentID, CourseID → Grade

**Step 2: Convert to 3NF**
```sql
Students(StudentID, StudentName, StudentEmail)
Primary Key: StudentID

Courses(CourseID, CourseName, InstructorID)
Primary Key: CourseID
Foreign Key: InstructorID

Instructors(InstructorID, InstructorName)
Primary Key: InstructorID

Enrollments(StudentID, CourseID, Grade)
Primary Key: (StudentID, CourseID)
Foreign Keys: StudentID, CourseID
```

**Solution 4.2**:

Functional dependencies:
- OrderID → CustomerID, OrderDate
- CustomerID → CustomerName
- ProductID → ProductName
- OrderID, ProductID → Quantity, Price

**Normalized (3NF)**:
```sql
Customers(CustomerID, CustomerName)
Products(ProductID, ProductName)
Orders(OrderID, CustomerID, OrderDate)
OrderItems(OrderID, ProductID, Quantity, Price)
```

**Solution 4.3**:

The current design is **NOT in BCNF** because DoctorID → DoctorSpecialty, but DoctorID is not a superkey of the table (the primary key is PatientID, DoctorID, Date).

**Convert to BCNF**:
```sql
-- Separate the violating dependency
Doctors(DoctorID, DoctorSpecialty)
Primary Key: DoctorID

-- Main table without the dependent attribute
Consultations(PatientID, DoctorID, Date)
Primary Key: (PatientID, DoctorID, Date)
Foreign Key: DoctorID → Doctors(DoctorID)
```

## Chapter 5: SQL Fundamentals

### Exercises

**Exercise 5.1**: Write SQL queries using the University database from Appendix B:
- a) Find all students with GPA above 3.5, ordered by GPA descending
- b) List all courses offered by the Computer Science department
- c) Count how many students are enrolled in each course for Fall 2023

**Exercise 5.2**: Write UPDATE statements to:
- a) Increase all instructor salaries in the CS department by 5%
- b) Change the status of all students who graduated before 2020 to 'Graduated'

**Exercise 5.3**: Write a query with multiple joins to show student names, course names, and instructor names for all enrollments in Spring 2024.

### Solutions

**Solution 5.1**:
```sql
-- a)
SELECT StudentID, FirstName, LastName, GPA
FROM Students
WHERE GPA > 3.5
ORDER BY GPA DESC;

-- b)
SELECT C.CourseID, C.CourseName, C.Credits
FROM Courses C
JOIN Departments D ON C.DeptID = D.DeptID
WHERE D.DeptName = 'Computer Science';

-- c)
SELECT 
    C.CourseID,
    C.CourseName,
    COUNT(E.StudentID) AS EnrollmentCount
FROM Courses C
LEFT JOIN Enrollments E ON C.CourseID = E.CourseID 
    AND E.Semester = 'Fall' 
    AND E.Year = 2023
GROUP BY C.CourseID, C.CourseName
HAVING COUNT(E.StudentID) > 0
ORDER BY EnrollmentCount DESC;
```

**Solution 5.2**:
```sql
-- a)
UPDATE Instructors
SET Salary = Salary * 1.05
WHERE DeptID = 'CS';

-- b)
UPDATE Students
SET Status = 'Graduated'
WHERE EnrollmentYear < 2020 AND Status != 'Graduated';
```

**Solution 5.3**:
```sql
SELECT 
    S.FirstName || ' ' || S.LastName AS StudentName,
    C.CourseName,
    I.FirstName || ' ' || I.LastName AS InstructorName,
    E.Grade
FROM Enrollments E
JOIN Students S ON E.StudentID = S.StudentID
JOIN Courses C ON E.CourseID = C.CourseID
LEFT JOIN Instructors I ON E.InstructorID = I.InstructorID
WHERE E.Semester = 'Spring' AND E.Year = 2024
ORDER BY S.LastName, C.CourseName;
```

## Chapter 6: Advanced SQL Topics

### Exercises

**Exercise 6.1**: Write a subquery to find students with GPA above their department average.

**Exercise 6.2**: Create a view that shows course enrollment statistics (course name, enrollment count, average grade).

**Exercise 6.3**: Write a query using GROUP BY and HAVING to find courses with more than 5 enrollments.

### Solutions

**Solution 6.1**:
```sql
SELECT 
    S.StudentID,
    S.FirstName,
    S.LastName,
    S.Major,
    S.GPA,
    (SELECT AVG(GPA) FROM Students WHERE Major = S.Major) AS DeptAvg
FROM Students S
WHERE S.GPA > (
    SELECT AVG(GPA)
    FROM Students S2
    WHERE S2.Major = S.Major
)
ORDER BY S.Major, S.GPA DESC;
```

**Solution 6.2**:
```sql
CREATE VIEW CourseEnrollmentStats AS
SELECT 
    C.CourseID,
    C.CourseName,
    COUNT(E.StudentID) AS EnrollmentCount,
    ROUND(AVG(
        CASE E.Grade
            WHEN 'A' THEN 4.0
            WHEN 'A-' THEN 3.7
            WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0
            WHEN 'B-' THEN 2.7
            WHEN 'C+' THEN 2.3
            WHEN 'C' THEN 2.0
            WHEN 'C-' THEN 1.7
            WHEN 'D+' THEN 1.3
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ), 2) AS AverageGrade
FROM Courses C
LEFT JOIN Enrollments E ON C.CourseID = E.CourseID
WHERE E.Grade IS NOT NULL
GROUP BY C.CourseID, C.CourseName;

-- Use the view
SELECT * FROM CourseEnrollmentStats WHERE EnrollmentCount > 3;
```

**Solution 6.3**:
```sql
SELECT 
    C.CourseID,
    C.CourseName,
    COUNT(E.StudentID) AS EnrollmentCount
FROM Courses C
JOIN Enrollments E ON C.CourseID = E.CourseID
GROUP BY C.CourseID, C.CourseName
HAVING COUNT(E.StudentID) > 5
ORDER BY EnrollmentCount DESC;
```

## Chapter 7: Database Design Best Practices

### Exercises

**Exercise 7.1**: Review this table design and identify naming and data type issues:
```sql
CREATE TABLE tbl1 (
    id INT,
    nm VARCHAR(1000),
    dt VARCHAR(50),
    f FLOAT,
    b INT
);
```

**Exercise 7.2**: Rewrite the table from Exercise 7.1 with proper naming conventions and appropriate data types, assuming it's for storing product information.

**Exercise 7.3**: Write a query to find all indexes on the Students table and explain when each might be useful.

### Solutions

**Solution 7.1**:

Issues identified:
1. **Table name** `tbl1`: Not descriptive, uses prefix
2. **Column `id`**: Not specific enough (StudentID? ProductID?)
3. **Column `nm`**: Abbreviated, unclear
4. **Column `dt`**: Could be date or data, ambiguous
5. **Column `f`**: Single letter, meaningless
6. **Column `b`**: Single letter, meaningless
7. **Data types**: VARCHAR(1000) is wasteful, FLOAT for currency is wrong, INT for boolean is unclear

**Solution 7.2**:
```sql
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CreatedDate DATE DEFAULT CURRENT_DATE,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    IsActive BOOLEAN DEFAULT TRUE,
    INDEX IDX_Products_Name (ProductName),
    INDEX IDX_Products_Active (IsActive)
);
```

**Solution 7.3**:
```sql
-- MySQL
SHOW INDEX FROM Students;

-- PostgreSQL
\d Students
```

Common useful indexes:
- **Primary key index** on StudentID: For fast lookups by ID
- **Index on Email**: If frequently searched or used in WHERE clauses
- **Index on Major**: For grouping/filtering by department
- **Index on (Status, GPA)**: For queries filtering active students by GPA
- **Index on LastName**: For sorting and searching by name

## Chapter 8: Transactions and Concurrency

### Exercises

**Exercise 8.1**: Write a transaction that transfers credits from one student to another, ensuring atomicity.

**Exercise 8.2**: Explain what could go wrong with this code without proper isolation:
```sql
-- User 1
SELECT Stock FROM Products WHERE ProductID = 'P001';  -- Gets 10
-- User 2 does the same
UPDATE Products SET Stock = 5 WHERE ProductID = 'P001';  -- Sells 5
```

**Exercise 8.3**: Design a deadlock scenario with two transactions accessing Accounts table, then explain how to prevent it.

### Solutions

**Solution 8.1**:
```sql
START TRANSACTION;

-- Verify source student has enough credits
DECLARE @credits INT;
SELECT @credits = (
    SELECT SUM(C.Credits)
    FROM Enrollments E
    JOIN Courses C ON E.CourseID = C.CourseID
    WHERE E.StudentID = 'S001' AND E.Grade IS NOT NULL
);

IF @credits >= 3 THEN
    -- This is a simplified example
    -- In reality, you'd update enrollment records
    
    -- Log the transfer
    INSERT INTO CreditTransferLog (FromStudent, ToStudent, Credits, TransferDate)
    VALUES ('S001', 'S002', 3, CURRENT_TIMESTAMP);
    
    COMMIT;
ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient credits';
END IF;
```

**Solution 8.2**:

**Problems**:
1. **Lost Update**: Both users read Stock = 10, both update based on that value, resulting in incorrect final stock
2. **Non-Repeatable Read**: If User 1 reads stock again in the same transaction, they'll get a different value

**Solution**: Use appropriate isolation level and locking:
```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

-- Lock the row
SELECT Stock FROM Products WHERE ProductID = 'P001' FOR UPDATE;

-- Now update safely
UPDATE Products SET Stock = Stock - 5 WHERE ProductID = 'P001';

COMMIT;
```

**Solution 8.3**:

**Deadlock Scenario**:
```sql
-- Transaction 1
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A001';
-- ... delay ...
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'A002';
COMMIT;

-- Transaction 2 (simultaneously)
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 50 WHERE AccountID = 'A002';
-- ... delay ...
UPDATE Accounts SET Balance = Balance + 50 WHERE AccountID = 'A001';
COMMIT;
```

**Prevention Strategies**:
1. **Access resources in same order**:
```sql
-- Both transactions should access accounts in alphabetical order
-- Always lock A001 before A002
```

2. **Use shorter transactions**:
```sql
-- Minimize time holding locks
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A001';
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'A002';
COMMIT;  -- No delays between updates
```

3. **Use timeouts and retry**:
```sql
SET innodb_lock_wait_timeout = 5;
-- Implement retry logic in application code
```

---
[← Appendix B: Sample Database](appendix_b_sample_database.md) | [Table of Contents](../TABLE_OF_CONTENTS.md)
