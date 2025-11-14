# Chapter 7: Database Design Best Practices

## 7.1 Naming Conventions

Consistent naming conventions improve readability, maintainability, and collaboration.

### 7.1.1 General Principles

**Be Descriptive:**
- Use meaningful names that clearly describe the purpose
- ✓ `CustomerOrders` ✗ `CO` or `Table1`

**Be Consistent:**
- Choose a convention and stick to it throughout the database
- Decide on singular vs plural (e.g., `Student` vs `Students`)

**Use Standard Casing:**
- **PascalCase**: `CustomerOrder`, `ProductCategory`
- **snake_case**: `customer_order`, `product_category`
- **camelCase**: `customerOrder`, `productCategory`

**Avoid Reserved Words:**
- Don't use SQL keywords as names: `SELECT`, `ORDER`, `TABLE`, etc.

### 7.1.2 Table Naming

**Recommendations:**
```sql
-- Good: Descriptive, clear purpose
Students
CourseEnrollments
DepartmentBudgets

-- Avoid: Too generic or cryptic
Data
Info
Tbl1
```

**Prefixes/Suffixes:**
```sql
-- Some organizations use prefixes
tbl_Students
dim_Products  (for data warehouses)
fact_Sales    (for data warehouses)

-- Junction/linking tables
Student_Course
Enrollment (if it has its own meaning)
```

### 7.1.3 Column Naming

**Be Specific:**
```sql
-- Good
FirstName, LastName
EmailAddress
PhoneNumber
RegistrationDate

-- Avoid
Name (which name?)
Email
Phone
Date (which date?)
```

**Primary Keys:**
```sql
-- Option 1: ID suffix
StudentID
CourseID

-- Option 2: Just 'ID'
ID (less descriptive but shorter)

-- Option 3: Descriptive
StudentIdentifier
```

**Foreign Keys:**
```sql
-- Match the referenced primary key name
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT,  -- Matches Students.StudentID
    CourseID INT,   -- Matches Courses.CourseID
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);
```

**Boolean Columns:**
```sql
-- Use Is, Has, Can prefixes
IsActive
HasGraduated
CanEnroll
IsDeleted
```

**Date/Time Columns:**
```sql
-- Include temporal context
CreatedDate, CreatedAt
UpdatedDate, UpdatedAt
EnrollmentDate
ExpirationDate
BirthDate
```

### 7.1.4 Constraint Naming

**Primary Keys:**
```sql
-- PK_TableName
CONSTRAINT PK_Students PRIMARY KEY (StudentID)
```

**Foreign Keys:**
```sql
-- FK_ChildTable_ParentTable
CONSTRAINT FK_Enrollments_Students 
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)

-- Or FK_ChildTable_Column
CONSTRAINT FK_Enrollments_StudentID
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
```

**Check Constraints:**
```sql
-- CHK_TableName_ColumnName
CONSTRAINT CHK_Students_GPA 
    CHECK (GPA >= 0.0 AND GPA <= 4.0)
```

**Unique Constraints:**
```sql
-- UQ_TableName_ColumnName
CONSTRAINT UQ_Students_Email UNIQUE (Email)
```

**Indexes:**
```sql
-- IDX_TableName_ColumnName
CREATE INDEX IDX_Students_LastName ON Students(LastName);

-- For composite indexes
CREATE INDEX IDX_Enrollments_StudentCourse 
    ON Enrollments(StudentID, CourseID);
```

## 7.2 Data Types Selection

Choosing appropriate data types is crucial for performance, storage efficiency, and data integrity.

### 7.2.1 Numeric Types

**Integers:**
```sql
-- Choose based on range
TINYINT      -- -128 to 127 (1 byte)
SMALLINT     -- -32,768 to 32,767 (2 bytes)
INT          -- -2 billion to 2 billion (4 bytes)
BIGINT       -- Very large numbers (8 bytes)

-- Examples
Age TINYINT
StudentCount SMALLINT
Population INT
NationalDebt BIGINT
```

**Decimals:**
```sql
-- Use DECIMAL for exact precision (money, measurements)
Price DECIMAL(10,2)      -- 10 total digits, 2 after decimal
GPA DECIMAL(3,2)         -- 0.00 to 9.99
TaxRate DECIMAL(5,4)     -- 0.0000 to 9.9999

-- Use FLOAT/DOUBLE for scientific calculations
Temperature FLOAT
Coordinates DOUBLE
```

**Money:**
```sql
-- Best practice: Use DECIMAL for currency
Amount DECIMAL(19,4)  -- Handles most currencies accurately

-- Avoid FLOAT/DOUBLE for money (rounding errors)
```

### 7.2.2 String Types

**Character Types:**
```sql
-- CHAR: Fixed-length (padded with spaces)
StateCode CHAR(2)           -- Always 2 characters
CountryCode CHAR(3)         -- ISO country codes

-- VARCHAR: Variable-length (more common)
FirstName VARCHAR(50)
Email VARCHAR(100)
Description VARCHAR(500)

-- TEXT: Large text (use sparingly)
BlogPost TEXT
Comments TEXT
```

**Unicode Support:**
```sql
-- For international characters
Name NVARCHAR(100)  -- SQL Server
Name VARCHAR(100) CHARACTER SET utf8mb4  -- MySQL
```

**Best Practices:**
```sql
-- Don't over-allocate
Email VARCHAR(100)     -- ✓ Reasonable
Email VARCHAR(10000)   -- ✗ Wasteful

-- Consider future needs but be realistic
PhoneNumber VARCHAR(20)  -- Handles international formats
```

### 7.2.3 Date and Time Types

```sql
-- DATE: Just the date
BirthDate DATE                    -- 1990-05-15

-- TIME: Just the time
OpenTime TIME                     -- 09:00:00

-- DATETIME/TIMESTAMP: Date and time
CreatedAt DATETIME                -- 2024-01-15 10:30:00
UpdatedAt TIMESTAMP               -- With timezone support

-- Best practices
CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
```

### 7.2.4 Boolean Types

```sql
-- Boolean/Bit
IsActive BOOLEAN          -- PostgreSQL
IsActive BIT             -- SQL Server
IsActive TINYINT(1)      -- MySQL (0 or 1)

-- Or use CHAR(1) with constraints
Status CHAR(1) CHECK (Status IN ('Y', 'N'))
```

### 7.2.5 Binary Types

```sql
-- For files, images, documents
ProfilePhoto BLOB         -- Binary Large Object
Document VARBINARY(MAX)   -- SQL Server
FileData BYTEA            -- PostgreSQL
```

**Note:** Consider storing files outside the database and storing only file paths for better performance.

## 7.3 Performance Considerations

### 7.3.1 Query Optimization

**Use Appropriate Indexes:**
```sql
-- Index columns used in WHERE, JOIN, ORDER BY
CREATE INDEX IDX_Students_LastName ON Students(LastName);
CREATE INDEX IDX_Enrollments_StudentID ON Enrollments(StudentID);
```

**Select Only Needed Columns:**
```sql
-- Good: Select specific columns
SELECT FirstName, LastName, Email FROM Students;

-- Avoid: SELECT * (especially for large tables)
SELECT * FROM Students;
```

**Use LIMIT for Testing:**
```sql
-- When testing queries on large tables
SELECT * FROM Orders LIMIT 100;
```

**Avoid Functions on Indexed Columns in WHERE:**
```sql
-- Bad: Prevents index use
SELECT * FROM Students WHERE UPPER(LastName) = 'SMITH';

-- Good: Index can be used
SELECT * FROM Students WHERE LastName = 'Smith';

-- Or create a functional index
CREATE INDEX IDX_Students_LastName_Upper ON Students(UPPER(LastName));
```

### 7.3.2 Table Design

**Normalize Appropriately:**
- Follow 3NF for most OLTP databases
- Consider denormalization for read-heavy systems

**Use Appropriate Data Types:**
```sql
-- Bad: Wastes space
Age VARCHAR(100)

-- Good: Right-sized
Age TINYINT
```

**Partition Large Tables:**
```sql
-- Partition by date range for historical data
CREATE TABLE Orders (
    OrderID INT,
    OrderDate DATE,
    Amount DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(OrderDate)) (
    PARTITION p_2022 VALUES LESS THAN (2023),
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_2024 VALUES LESS THAN (2025)
);
```

### 7.3.3 Index Strategy

**Create Indexes for:**
- Primary keys (automatic)
- Foreign keys
- Columns frequently used in WHERE, JOIN, ORDER BY
- Columns used in GROUP BY

**Avoid Over-Indexing:**
- Each index requires storage and slows down INSERT/UPDATE/DELETE
- Monitor index usage and remove unused indexes

**Composite Index Order:**
```sql
-- Put most selective column first
CREATE INDEX IDX_Orders_Status_Date 
ON Orders(Status, OrderDate);

-- Use for queries like:
WHERE Status = 'Pending' AND OrderDate > '2024-01-01'
WHERE Status = 'Pending'  -- Index still useful

-- But not useful for:
WHERE OrderDate > '2024-01-01'  -- First column not in query
```

### 7.3.4 Query Best Practices

**Use EXISTS Instead of IN for Subqueries:**
```sql
-- Better performance (stops at first match)
SELECT * FROM Students S
WHERE EXISTS (
    SELECT 1 FROM Enrollments E WHERE E.StudentID = S.StudentID
);

-- Can be slower (evaluates all)
SELECT * FROM Students
WHERE StudentID IN (SELECT StudentID FROM Enrollments);
```

**Use UNION ALL Instead of UNION When Possible:**
```sql
-- UNION removes duplicates (slower)
SELECT * FROM Students2023
UNION
SELECT * FROM Students2024;

-- UNION ALL keeps duplicates (faster)
SELECT * FROM Students2023
UNION ALL
SELECT * FROM Students2024;
```

## 7.4 Security and Access Control

### 7.4.1 User Accounts and Privileges

**Create Specific User Accounts:**
```sql
-- Don't use root/admin for applications
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'strong_password';

-- Grant minimal necessary privileges
GRANT SELECT, INSERT, UPDATE ON university.* TO 'app_user'@'localhost';

-- Read-only user for reporting
CREATE USER 'report_user'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON university.* TO 'report_user'@'localhost';
```

**Principle of Least Privilege:**
```sql
-- Grant only what's needed
GRANT SELECT, INSERT ON Students TO 'registration_app';
GRANT SELECT ON Students TO 'reporting_app';
```

### 7.4.2 Protecting Sensitive Data

**Encrypt Sensitive Columns:**
```sql
-- Store passwords hashed (never plain text)
-- Use application-level hashing (bcrypt, scrypt)

-- For very sensitive data, consider encryption
SSN VARBINARY(256)  -- Store encrypted value
```

**Use Views to Hide Sensitive Data:**
```sql
CREATE VIEW PublicStudentInfo AS
SELECT StudentID, FirstName, LastName, Email
FROM Students;
-- Excludes SSN, DateOfBirth, etc.

GRANT SELECT ON PublicStudentInfo TO 'public_user';
```

### 7.4.3 SQL Injection Prevention

**Use Parameterized Queries:**
```python
# Bad: Vulnerable to SQL injection
query = f"SELECT * FROM Students WHERE StudentID = '{user_input}'"

# Good: Using parameters
query = "SELECT * FROM Students WHERE StudentID = ?"
cursor.execute(query, (user_input,))
```

**Input Validation:**
```sql
-- Use CHECK constraints
CREATE TABLE Students (
    StudentID VARCHAR(10) PRIMARY KEY,
    Email VARCHAR(100) CHECK (Email LIKE '%_@__%.__%')
);
```

### 7.4.4 Audit Logging

**Track Important Changes:**
```sql
CREATE TABLE AuditLog (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(50),
    Operation VARCHAR(10),  -- INSERT, UPDATE, DELETE
    RecordID VARCHAR(50),
    UserName VARCHAR(50),
    ChangeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    OldValue TEXT,
    NewValue TEXT
);

-- Use triggers to populate (see Chapter 6)
```

## 7.5 Backup and Recovery Strategies

### 7.5.1 Backup Types

**Full Backup:**
- Complete copy of the database
- Slowest but simplest to restore
- Schedule: Weekly or monthly

**Incremental Backup:**
- Only changes since last backup
- Faster backups, more complex restore
- Schedule: Daily

**Differential Backup:**
- Changes since last full backup
- Balance between full and incremental

### 7.5.2 Backup Best Practices

**Regular Schedule:**
```bash
# Daily automated backups
mysqldump -u root -p university > university_$(date +%Y%m%d).sql

# With compression
mysqldump -u root -p university | gzip > university_$(date +%Y%m%d).sql.gz
```

**Multiple Locations:**
- On-site backup for quick recovery
- Off-site backup for disaster recovery
- Cloud backup for redundancy

**Test Restores:**
```bash
# Regularly test that backups work
mysql -u root -p university_test < university_20240115.sql
```

### 7.5.3 Point-in-Time Recovery

**Enable Binary Logging:**
```sql
-- MySQL configuration
[mysqld]
log-bin=mysql-bin
binlog_format=ROW
```

**Restore to Specific Time:**
```bash
# Restore last full backup
mysql -u root -p university < full_backup.sql

# Apply binary logs up to specific time
mysqlbinlog --stop-datetime="2024-01-15 10:30:00" mysql-bin.000001 | 
    mysql -u root -p university
```

### 7.5.4 High Availability

**Replication:**
- Master-slave replication for read scaling
- Multi-master replication for write scaling

**Clustering:**
- Database clusters for failover
- Load balancing across nodes

**Monitoring:**
```sql
-- Monitor database health
SHOW STATUS;
SHOW PROCESSLIST;

-- Check table sizes
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM information_schema.TABLES
WHERE table_schema = 'university'
ORDER BY size_mb DESC;
```

## Summary

Database design best practices ensure maintainable, secure, and performant systems:
- **Naming conventions** improve clarity and collaboration
- **Appropriate data types** optimize storage and performance
- **Query optimization** ensures fast response times
- **Security measures** protect sensitive data
- **Backup strategies** prevent data loss

Following these practices leads to robust, professional database implementations.

## Review Questions

1. Why is it important to use consistent naming conventions?
2. When should you use DECIMAL instead of FLOAT for numeric data?
3. What is the principle of least privilege?
4. Why should you avoid using SELECT * in production queries?
5. What are the three main types of database backups?

## Exercises

1. Review a database you've created and identify naming inconsistencies. Create a plan to standardize names.

2. Design a security strategy for a student information system, identifying which data needs encryption and access controls.

3. Write a query to find all indexes in your database and identify any that might be redundant.

---
[← Previous Chapter: Advanced SQL](chapter06_advanced_sql.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Next Chapter: Transactions →](chapter08_transactions.md)
