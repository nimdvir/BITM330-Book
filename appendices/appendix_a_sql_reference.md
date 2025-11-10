# Appendix A: SQL Quick Reference

## Data Definition Language (DDL)

### CREATE TABLE
```sql
CREATE TABLE table_name (
    column1 datatype [constraints],
    column2 datatype [constraints],
    ...
    [table_constraints]
);

-- Example
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    GPA DECIMAL(3,2) CHECK (GPA >= 0.0 AND GPA <= 4.0)
);
```

### ALTER TABLE
```sql
-- Add column
ALTER TABLE table_name ADD column_name datatype;

-- Modify column
ALTER TABLE table_name MODIFY column_name new_datatype;

-- Drop column
ALTER TABLE table_name DROP COLUMN column_name;

-- Add constraint
ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition;
```

### DROP TABLE
```sql
DROP TABLE [IF EXISTS] table_name;
```

### TRUNCATE TABLE
```sql
TRUNCATE TABLE table_name;
```

## Data Manipulation Language (DML)

### SELECT
```sql
-- Basic select
SELECT column1, column2 FROM table_name;

-- Select all
SELECT * FROM table_name;

-- With WHERE
SELECT column1, column2 
FROM table_name 
WHERE condition;

-- With ORDER BY
SELECT column1, column2 
FROM table_name 
ORDER BY column1 [ASC|DESC];

-- With LIMIT
SELECT column1, column2 
FROM table_name 
LIMIT n;

-- With OFFSET (pagination)
SELECT column1, column2 
FROM table_name 
LIMIT n OFFSET m;
```

### INSERT
```sql
-- Insert single row
INSERT INTO table_name (column1, column2) 
VALUES (value1, value2);

-- Insert multiple rows
INSERT INTO table_name (column1, column2) 
VALUES 
    (value1a, value2a),
    (value1b, value2b),
    (value1c, value2c);

-- Insert from SELECT
INSERT INTO table_name (column1, column2)
SELECT column1, column2 FROM other_table WHERE condition;
```

### UPDATE
```sql
UPDATE table_name 
SET column1 = value1, column2 = value2 
WHERE condition;
```

### DELETE
```sql
DELETE FROM table_name WHERE condition;
```

## Constraints

```sql
-- Primary Key
column_name datatype PRIMARY KEY

-- Foreign Key
FOREIGN KEY (column_name) REFERENCES other_table(column_name)

-- Unique
column_name datatype UNIQUE

-- Not Null
column_name datatype NOT NULL

-- Check
column_name datatype CHECK (condition)

-- Default
column_name datatype DEFAULT value
```

## Joins

```sql
-- INNER JOIN
SELECT * FROM table1 
INNER JOIN table2 ON table1.column = table2.column;

-- LEFT JOIN
SELECT * FROM table1 
LEFT JOIN table2 ON table1.column = table2.column;

-- RIGHT JOIN
SELECT * FROM table1 
RIGHT JOIN table2 ON table1.column = table2.column;

-- FULL OUTER JOIN
SELECT * FROM table1 
FULL OUTER JOIN table2 ON table1.column = table2.column;

-- CROSS JOIN
SELECT * FROM table1 CROSS JOIN table2;
```

## Aggregate Functions

```sql
-- COUNT
SELECT COUNT(*) FROM table_name;
SELECT COUNT(column_name) FROM table_name;
SELECT COUNT(DISTINCT column_name) FROM table_name;

-- SUM
SELECT SUM(column_name) FROM table_name;

-- AVG
SELECT AVG(column_name) FROM table_name;

-- MIN/MAX
SELECT MIN(column_name), MAX(column_name) FROM table_name;

-- GROUP BY
SELECT column1, COUNT(*) 
FROM table_name 
GROUP BY column1;

-- HAVING
SELECT column1, COUNT(*) 
FROM table_name 
GROUP BY column1 
HAVING COUNT(*) > 5;
```

## String Functions

```sql
-- Concatenation
CONCAT(string1, string2)
string1 || string2  -- PostgreSQL

-- Uppercase/Lowercase
UPPER(string)
LOWER(string)

-- Substring
SUBSTRING(string, start, length)

-- Length
LENGTH(string)
CHAR_LENGTH(string)

-- Trim
TRIM(string)
LTRIM(string)
RTRIM(string)

-- Replace
REPLACE(string, old_substring, new_substring)
```

## Date Functions

```sql
-- Current date/time
CURRENT_DATE
CURRENT_TIME
CURRENT_TIMESTAMP
NOW()

-- Extract parts
YEAR(date)
MONTH(date)
DAY(date)
HOUR(time)
MINUTE(time)

-- Date arithmetic
DATE_ADD(date, INTERVAL value unit)
DATE_SUB(date, INTERVAL value unit)
DATEDIFF(date1, date2)
```

## Subqueries

```sql
-- In WHERE clause
SELECT * FROM table1 
WHERE column1 IN (SELECT column1 FROM table2);

-- With EXISTS
SELECT * FROM table1 t1
WHERE EXISTS (SELECT 1 FROM table2 t2 WHERE t2.id = t1.id);

-- In FROM clause
SELECT * FROM (
    SELECT column1, column2 FROM table_name WHERE condition
) AS subquery;

-- In SELECT clause
SELECT column1, 
       (SELECT MAX(column2) FROM table2) AS max_value
FROM table1;
```

## Set Operations

```sql
-- UNION (removes duplicates)
SELECT column1 FROM table1
UNION
SELECT column1 FROM table2;

-- UNION ALL (keeps duplicates)
SELECT column1 FROM table1
UNION ALL
SELECT column1 FROM table2;

-- INTERSECT
SELECT column1 FROM table1
INTERSECT
SELECT column1 FROM table2;

-- EXCEPT/MINUS
SELECT column1 FROM table1
EXCEPT
SELECT column1 FROM table2;
```

## Views

```sql
-- Create view
CREATE VIEW view_name AS
SELECT column1, column2 
FROM table_name 
WHERE condition;

-- Use view
SELECT * FROM view_name;

-- Update view
CREATE OR REPLACE VIEW view_name AS
SELECT column1, column2, column3 
FROM table_name 
WHERE condition;

-- Drop view
DROP VIEW view_name;
```

## Indexes

```sql
-- Create index
CREATE INDEX index_name ON table_name(column_name);

-- Create unique index
CREATE UNIQUE INDEX index_name ON table_name(column_name);

-- Create composite index
CREATE INDEX index_name ON table_name(column1, column2);

-- Drop index
DROP INDEX index_name;
```

## Transactions

```sql
-- Start transaction
START TRANSACTION;
BEGIN;

-- Commit
COMMIT;

-- Rollback
ROLLBACK;

-- Savepoint
SAVEPOINT savepoint_name;
ROLLBACK TO SAVEPOINT savepoint_name;

-- Isolation levels
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

## User Management

```sql
-- Create user
CREATE USER 'username'@'host' IDENTIFIED BY 'password';

-- Grant privileges
GRANT privilege_type ON database.table TO 'username'@'host';
GRANT ALL PRIVILEGES ON database.* TO 'username'@'host';

-- Revoke privileges
REVOKE privilege_type ON database.table FROM 'username'@'host';

-- Drop user
DROP USER 'username'@'host';

-- Show grants
SHOW GRANTS FOR 'username'@'host';
```

## Common Data Types

### Numeric Types
```
TINYINT      - 1 byte (-128 to 127)
SMALLINT     - 2 bytes (-32,768 to 32,767)
INT          - 4 bytes (-2 billion to 2 billion)
BIGINT       - 8 bytes (very large numbers)
DECIMAL(p,s) - Exact precision
FLOAT        - Floating point (approximate)
DOUBLE       - Double precision float
```

### String Types
```
CHAR(n)      - Fixed length string
VARCHAR(n)   - Variable length string
TEXT         - Large text
BLOB         - Binary large object
```

### Date/Time Types
```
DATE         - YYYY-MM-DD
TIME         - HH:MM:SS
DATETIME     - YYYY-MM-DD HH:MM:SS
TIMESTAMP    - Unix timestamp
YEAR         - Year value
```

### Other Types
```
BOOLEAN      - TRUE/FALSE
ENUM         - Enumeration
JSON         - JSON data (MySQL 5.7+, PostgreSQL)
```

## WHERE Clause Operators

```sql
-- Comparison
=, !=, <>, <, >, <=, >=

-- Pattern matching
LIKE '%pattern%'
NOT LIKE '%pattern%'

-- Range
BETWEEN value1 AND value2
NOT BETWEEN value1 AND value2

-- List
IN (value1, value2, ...)
NOT IN (value1, value2, ...)

-- NULL check
IS NULL
IS NOT NULL

-- Logical operators
AND
OR
NOT
```

## Wildcards

```
%  - Matches any sequence of characters
_  - Matches any single character

Examples:
'A%'    - Starts with A
'%on'   - Ends with on
'%or%'  - Contains or
'_im'   - Second and third chars are 'im'
```

## Common Functions

### Numeric Functions
```sql
ABS(x)         - Absolute value
CEIL(x)        - Round up
FLOOR(x)       - Round down
ROUND(x, d)    - Round to d decimals
MOD(x, y)      - Modulo
POWER(x, y)    - x to the power of y
SQRT(x)        - Square root
```

### Conditional Functions
```sql
-- CASE
CASE 
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END

-- COALESCE (return first non-null)
COALESCE(value1, value2, value3)

-- NULLIF (return NULL if equal)
NULLIF(expression1, expression2)

-- IFNULL / ISNULL
IFNULL(expression, replacement)
```

## Window Functions (Advanced)

```sql
-- ROW_NUMBER
ROW_NUMBER() OVER (ORDER BY column)

-- RANK
RANK() OVER (ORDER BY column)

-- LAG/LEAD
LAG(column, offset) OVER (ORDER BY column)
LEAD(column, offset) OVER (ORDER BY column)

-- Partitioning
RANK() OVER (PARTITION BY column1 ORDER BY column2)
```

## Performance Tips

```sql
-- Use EXPLAIN to analyze queries
EXPLAIN SELECT * FROM table_name WHERE condition;

-- Avoid SELECT *
SELECT specific_columns FROM table_name;

-- Use indexes for frequently queried columns
CREATE INDEX idx_name ON table(column);

-- Use LIMIT for large result sets
SELECT * FROM table_name LIMIT 100;

-- Use EXISTS instead of IN for large subqueries
SELECT * FROM table1 WHERE EXISTS (
    SELECT 1 FROM table2 WHERE table1.id = table2.id
);
```

---
[← Chapter 8: Transactions](../chapters/chapter08_transactions.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Next: Sample Database →](appendix_b_sample_database.md)
