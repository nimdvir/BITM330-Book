# Chapter 2: The Relational Database Model

## 2.1 Relational Data Structure

The **relational model** was introduced by E.F. Codd in 1970 and has become the dominant data model for database applications. In the relational model, data is organized into **relations** (tables), making it intuitive and mathematically rigorous.

### Core Concepts:
- **Relation**: A table with rows and columns
- **Tuple**: A row in a table (a single record)
- **Attribute**: A column in a table (a property)
- **Domain**: The set of allowable values for an attribute

### Example: Students Relation
```
Students
┌───────────┬──────────────┬─────┬────────────────────────┐
│ StudentID │ Name         │ Age │ Email                  │
├───────────┼──────────────┼─────┼────────────────────────┤
│ S001      │ Alice Smith  │ 20  │ alice@university.edu   │
│ S002      │ Bob Johnson  │ 22  │ bob@university.edu     │
│ S003      │ Carol Davis  │ 21  │ carol@university.edu   │
└───────────┴──────────────┴─────┴────────────────────────┘
```

### Properties of Relations:
1. **No Duplicate Rows**: Each tuple is unique
2. **Unordered Rows**: Row order doesn't matter
3. **Atomic Values**: Each cell contains a single value
4. **Unordered Columns**: Column order doesn't affect meaning (though convention exists)
5. **Named Columns**: Each attribute has a unique name within the relation

## 2.2 Tables, Rows, and Columns

### Tables (Relations)
A table represents an entity type (e.g., Students, Courses, Professors) and consists of:
- **Schema**: The table structure (name and attributes)
- **Instance**: The actual data at a given time

**Example Schema:**
```
Courses(CourseID, CourseName, Credits, DepartmentID)
```

### Rows (Tuples/Records)
Each row represents a single instance of the entity.

**Example:**
```
(CS101, Database Design, 3, CS)
```

### Columns (Attributes/Fields)
Each column represents a property of the entity.

**Attribute Characteristics:**
- **Name**: Unique identifier within the table
- **Data Type**: Integer, String, Date, Boolean, etc.
- **Constraints**: Rules that values must follow

### Table Design Example: University Database

**Departments Table:**
```
Departments
┌──────────────┬─────────────────────┬──────────────────┐
│ DepartmentID │ DepartmentName      │ Building         │
├──────────────┼─────────────────────┼──────────────────┤
│ CS           │ Computer Science    │ Engineering Hall │
│ MATH         │ Mathematics         │ Science Center   │
│ ENG          │ English             │ Humanities Bldg  │
└──────────────┴─────────────────────┴──────────────────┘
```

**Courses Table:**
```
Courses
┌──────────┬───────────────────┬─────────┬──────────────┐
│ CourseID │ CourseName        │ Credits │ DepartmentID │
├──────────┼───────────────────┼─────────┼──────────────┤
│ CS101    │ Database Design   │ 3       │ CS           │
│ CS201    │ Data Structures   │ 4       │ CS           │
│ MATH101  │ Calculus I        │ 4       │ MATH         │
└──────────┴───────────────────┴─────────┴──────────────┘
```

## 2.3 Keys: Primary, Foreign, and Candidate

Keys are crucial for identifying records and establishing relationships between tables.

### 2.3.1 Primary Keys

A **primary key** is an attribute (or combination of attributes) that uniquely identifies each row in a table.

**Properties:**
- **Unique**: No two rows can have the same primary key value
- **Not Null**: Primary key values cannot be NULL
- **Immutable**: Should not change over time

**Example:**
```sql
CREATE TABLE Students (
    StudentID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE
);
```

**Choosing a Primary Key:**
- Natural Key: Exists naturally in the data (e.g., SSN, ISBN)
- Surrogate Key: Artificially created (e.g., auto-increment ID)

**Example - Natural vs Surrogate:**
```
Natural Key:
Books(ISBN, Title, Author, Year)

Surrogate Key:
Books(BookID, ISBN, Title, Author, Year)
```

### 2.3.2 Foreign Keys

A **foreign key** is an attribute in one table that references the primary key of another table, establishing relationships between tables.

**Example:**
```sql
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID VARCHAR(10),
    CourseID VARCHAR(10),
    Grade VARCHAR(2),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);
```

**Referential Integrity:**
Foreign keys enforce referential integrity:
- Cannot insert a row with a foreign key value that doesn't exist in the referenced table
- Cannot delete a row if it's referenced by another table (or use CASCADE)

**Example Relationship:**
```
Students (Parent)           Enrollments (Child)
┌───────────┬──────┐       ┌──────────────┬───────────┐
│ StudentID │ Name │       │ EnrollmentID │ StudentID │ ─┐
├───────────┼──────┤       ├──────────────┼───────────┤  │
│ S001      │ ...  │ ◄─────│ E001         │ S001      │ ◄┘
└───────────┴──────┘       └──────────────┴───────────┘
                           Foreign Key Reference
```

### 2.3.3 Candidate Keys

A **candidate key** is an attribute (or minimal set of attributes) that could serve as a primary key.

**Example:**
```
Students Table:
- StudentID (chosen as primary key)
- Email (unique, could be a candidate key)
- SSN (unique, could be a candidate key)
```

All candidate keys are unique, but only one is chosen as the primary key.

### 2.3.4 Composite Keys

A **composite key** uses multiple attributes together to uniquely identify a row.

**Example:**
```sql
CREATE TABLE CourseOfferings (
    CourseID VARCHAR(10),
    Semester VARCHAR(20),
    Year INT,
    InstructorID VARCHAR(10),
    PRIMARY KEY (CourseID, Semester, Year)
);
```

### 2.3.5 Alternate Keys

Candidate keys that are not chosen as the primary key are called **alternate keys**.

## 2.4 Relational Integrity Constraints

Integrity constraints ensure data accuracy and consistency.

### 2.4.1 Entity Integrity
**Rule**: Primary key values must be unique and not NULL.

**Example:**
```sql
-- This will fail (NULL primary key)
INSERT INTO Students (StudentID, Name) VALUES (NULL, 'John Doe');

-- This will fail (duplicate primary key)
INSERT INTO Students (StudentID, Name) VALUES ('S001', 'Jane Doe');
-- if S001 already exists
```

### 2.4.2 Referential Integrity
**Rule**: Foreign key values must either match a primary key value in the referenced table or be NULL.

**Example:**
```sql
-- This will fail if S999 doesn't exist in Students table
INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID)
VALUES (E100, 'S999', 'CS101');
```

**ON DELETE and ON UPDATE Options:**
```sql
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID VARCHAR(10),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

Options:
- **CASCADE**: Automatically delete/update related rows
- **SET NULL**: Set foreign key to NULL
- **SET DEFAULT**: Set foreign key to default value
- **RESTRICT/NO ACTION**: Prevent the operation

### 2.4.3 Domain Integrity
**Rule**: Values must be from a specified domain (data type and range).

**Example:**
```sql
CREATE TABLE Students (
    StudentID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Age INT CHECK (Age >= 16 AND Age <= 100),
    GPA DECIMAL(3,2) CHECK (GPA >= 0.0 AND GPA <= 4.0),
    Status VARCHAR(20) CHECK (Status IN ('Active', 'Inactive', 'Graduated'))
);
```

### 2.4.4 User-Defined Integrity
Custom business rules specific to the application.

**Example:**
```sql
-- Ensure enrollment date is not in the future
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID VARCHAR(10),
    CourseID VARCHAR(10),
    EnrollmentDate DATE CHECK (EnrollmentDate <= CURRENT_DATE)
);
```

## 2.5 Relational Algebra Basics

Relational algebra provides a theoretical foundation for relational databases. It consists of operations that take relations as input and produce relations as output.

### 2.5.1 Selection (σ)
Selects rows that satisfy a condition.

**Notation:** σ<sub>condition</sub>(Relation)

**Example:** σ<sub>Age>20</sub>(Students)
```
Select all students older than 20
```

**SQL Equivalent:**
```sql
SELECT * FROM Students WHERE Age > 20;
```

### 2.5.2 Projection (π)
Selects specific columns.

**Notation:** π<sub>attributes</sub>(Relation)

**Example:** π<sub>Name,Email</sub>(Students)
```
Select only Name and Email columns
```

**SQL Equivalent:**
```sql
SELECT Name, Email FROM Students;
```

### 2.5.3 Union (∪)
Combines two relations with the same schema.

**Notation:** Relation1 ∪ Relation2

**SQL Equivalent:**
```sql
SELECT * FROM Students2024
UNION
SELECT * FROM Students2025;
```

### 2.5.4 Set Difference (−)
Returns rows in first relation but not in second.

**Notation:** Relation1 − Relation2

**SQL Equivalent:**
```sql
SELECT * FROM AllStudents
EXCEPT
SELECT * FROM GraduatedStudents;
```

### 2.5.5 Cartesian Product (×)
Combines every row of one relation with every row of another.

**Notation:** Relation1 × Relation2

**SQL Equivalent:**
```sql
SELECT * FROM Students, Courses;
```

### 2.5.6 Join (⋈)
Combines rows from two relations based on a related column.

**Natural Join Example:**
```
Students ⋈ Enrollments
(joins on common attribute StudentID)
```

**SQL Equivalent:**
```sql
SELECT *
FROM Students S
JOIN Enrollments E ON S.StudentID = E.StudentID;
```

## Summary

The relational database model provides a solid foundation for organizing and managing data:
- Data is organized in tables (relations) with rows and columns
- Keys (primary, foreign, candidate) establish identity and relationships
- Integrity constraints ensure data quality and consistency
- Relational algebra provides theoretical operations for data manipulation

Understanding these concepts is essential for effective database design and querying.

## Review Questions

1. What are the five properties that a relation must satisfy?
2. Explain the difference between a primary key and a foreign key.
3. What is referential integrity, and why is it important?
4. What are the differences between CASCADE and RESTRICT when deleting a row referenced by a foreign key?
5. Name three types of integrity constraints and give an example of each.

## Exercises

1. Design a simple table schema for a library system with Books and Authors tables. Identify primary and foreign keys.

2. Given the following table, identify potential candidate keys:
   ```
   Employees(EmployeeID, SSN, Email, PhoneNumber, Name, DepartmentID)
   ```

3. Write the relational algebra expression and SQL query to:
   - Select all courses with more than 3 credits
   - Project only CourseID and CourseName from the Courses table
   - Find students enrolled in 'CS101'

---
[← Previous Chapter: Introduction to Databases](chapter01_introduction.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Next Chapter: ER Modeling →](chapter03_er_modeling.md)
