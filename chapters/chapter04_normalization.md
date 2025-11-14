# Chapter 4: Normalization

## 4.1 Purpose of Normalization

**Normalization** is the process of organizing data in a database to reduce redundancy and improve data integrity. It involves decomposing tables into smaller, well-structured tables without losing information.

### Goals of Normalization:
1. **Eliminate Redundant Data**: Store each piece of data only once
2. **Ensure Data Dependencies**: Store related data together logically
3. **Reduce Anomalies**: Minimize update, insertion, and deletion anomalies
4. **Improve Data Integrity**: Make data consistent and accurate
5. **Optimize Storage**: Reduce wasted space

### Anomalies in Unnormalized Data:

Consider this poorly designed table:
```
StudentCourses
┌───────────┬──────────┬──────┬──────────┬────────┬─────────────┐
│ StudentID │ Name     │ Addr │ CourseID │ Course │ Instructor  │
├───────────┼──────────┼──────┼──────────┼────────┼─────────────┤
│ S001      │ Alice    │ NYC  │ CS101    │ DB     │ Dr. Smith   │
│ S001      │ Alice    │ NYC  │ CS201    │ DS     │ Dr. Johnson │
│ S002      │ Bob      │ LA   │ CS101    │ DB     │ Dr. Smith   │
└───────────┴──────────┴──────┴──────────┴────────┴─────────────┘
```

**Update Anomaly**: If Alice moves, we must update multiple rows.

**Insertion Anomaly**: Cannot add a course without enrolling a student.

**Deletion Anomaly**: If S002 drops CS101, we lose information about the course.

## 4.2 Functional Dependencies

A **functional dependency** exists when one attribute uniquely determines another attribute.

**Notation**: X → Y (X determines Y)

**Example**:
- StudentID → Name (StudentID determines Name)
- CourseID → CourseName (CourseID determines CourseName)
- StudentID, CourseID → Grade (combination determines Grade)

### Types of Functional Dependencies:

**Trivial Dependency**: Y is a subset of X
- StudentID, Name → StudentID (trivial)

**Non-trivial Dependency**: Y is not a subset of X
- StudentID → Name (non-trivial)

**Full Functional Dependency**: Y depends on all of X, not just part of it
- StudentID, CourseID → Grade (full dependency)

**Partial Dependency**: Y depends on part of X
- StudentID, CourseID → StudentName (partial - depends only on StudentID)

**Transitive Dependency**: X → Y and Y → Z, therefore X → Z
- StudentID → DepartmentID → DepartmentName

## 4.3 First Normal Form (1NF)

**Definition**: A relation is in 1NF if:
1. All attributes contain only atomic (indivisible) values
2. Each column contains values of a single type
3. Each column has a unique name
4. The order of rows doesn't matter

### Violations of 1NF:

**Example 1: Multi-valued Attributes**
```
Students (Not in 1NF)
┌───────────┬──────────┬─────────────────────┐
│ StudentID │ Name     │ PhoneNumbers        │
├───────────┼──────────┼─────────────────────┤
│ S001      │ Alice    │ 555-1234, 555-5678  │ ← Multiple values
└───────────┴──────────┴─────────────────────┘
```

**Converting to 1NF:**
```
Students (1NF)
┌───────────┬──────────┬─────────────┐
│ StudentID │ Name     │ PhoneNumber │
├───────────┼──────────┼─────────────┤
│ S001      │ Alice    │ 555-1234    │
│ S001      │ Alice    │ 555-5678    │
└───────────┴──────────┴─────────────┘
```

**Example 2: Composite Attributes**
```
Not in 1NF:
Students(StudentID, Name, Address)
where Address = "123 Main St, NYC, NY 10001"

In 1NF:
Students(StudentID, Name, Street, City, State, ZipCode)
```

## 4.4 Second Normal Form (2NF)

**Definition**: A relation is in 2NF if:
1. It is in 1NF
2. No non-prime attribute is partially dependent on any candidate key

**Note**: Only applies to tables with composite primary keys.

### Example: Converting to 2NF

**Not in 2NF:**
```
Enrollments(StudentID, CourseID, StudentName, CourseName, Grade)
Primary Key: (StudentID, CourseID)

Partial Dependencies:
- StudentID → StudentName (partial)
- CourseID → CourseName (partial)
```

**Converting to 2NF:**
```sql
-- Separate table for students
Students(StudentID, StudentName)
Primary Key: StudentID

-- Separate table for courses
Courses(CourseID, CourseName)
Primary Key: CourseID

-- Enrollment table with only full dependencies
Enrollments(StudentID, CourseID, Grade)
Primary Key: (StudentID, CourseID)
Foreign Keys: StudentID → Students, CourseID → Courses
```

## 4.5 Third Normal Form (3NF)

**Definition**: A relation is in 3NF if:
1. It is in 2NF
2. No non-prime attribute is transitively dependent on the primary key

### Example: Converting to 3NF

**Not in 3NF:**
```
Employees(EmpID, Name, DeptID, DeptName, DeptLocation)
Primary Key: EmpID

Transitive Dependency:
EmpID → DeptID → DeptName
EmpID → DeptID → DeptLocation
```

**Converting to 3NF:**
```sql
-- Separate table for departments
Departments(DeptID, DeptName, DeptLocation)
Primary Key: DeptID

-- Employee table without transitive dependencies
Employees(EmpID, Name, DeptID)
Primary Key: EmpID
Foreign Key: DeptID → Departments
```

## 4.6 Boyce-Codd Normal Form (BCNF)

**Definition**: A relation is in BCNF if:
1. It is in 3NF
2. For every functional dependency X → Y, X is a superkey

BCNF is a stronger version of 3NF that handles certain anomalies.

### Example: Converting to BCNF

**In 3NF but not BCNF:**
```
CourseInstructor(StudentID, Course, Instructor)
Functional Dependencies:
- StudentID, Course → Instructor
- Instructor → Course (each instructor teaches only one course)

Problem: Instructor is not a superkey but determines Course
```

**Converting to BCNF:**
```sql
-- Separate the dependency where Instructor determines Course
InstructorCourse(Instructor, Course)
Primary Key: Instructor

-- Student enrollment
StudentInstructor(StudentID, Instructor)
Primary Key: (StudentID, Instructor)
Foreign Key: Instructor → InstructorCourse
```

## 4.7 Higher Normal Forms

### Fourth Normal Form (4NF)

**Definition**: A relation is in 4NF if:
1. It is in BCNF
2. It has no multi-valued dependencies

**Example:**
```
Not in 4NF:
Student(StudentID, Major, Activity)
- A student can have multiple majors
- A student can have multiple activities
- Majors and activities are independent

In 4NF:
StudentMajor(StudentID, Major)
StudentActivity(StudentID, Activity)
```

### Fifth Normal Form (5NF)

**Definition**: A relation is in 5NF if it cannot be decomposed into smaller tables without loss of information.

5NF deals with join dependencies and is rarely needed in practice.

## 4.8 Denormalization

**Denormalization** is the intentional introduction of redundancy to improve query performance.

### When to Denormalize:

1. **Read-Heavy Applications**: More reads than writes
2. **Performance Critical**: Query speed is essential
3. **Reporting**: Complex queries joining many tables
4. **Calculated Fields**: Storing computed values

### Example:

**Normalized (3NF):**
```sql
Orders(OrderID, CustomerID, OrderDate)
OrderItems(OrderID, ProductID, Quantity, Price)

-- To get order total, must calculate from OrderItems
SELECT OrderID, SUM(Quantity * Price) as Total
FROM OrderItems
GROUP BY OrderID;
```

**Denormalized:**
```sql
Orders(OrderID, CustomerID, OrderDate, TotalAmount)
OrderItems(OrderID, ProductID, Quantity, Price)

-- Total is pre-calculated and stored
-- Faster reads, but must update Orders when OrderItems change
```

### Trade-offs:
- **Pros**: Faster queries, simpler SQL
- **Cons**: Data redundancy, update complexity, potential inconsistencies

## Summary

Normalization is essential for database design:
- **1NF**: Atomic values only
- **2NF**: No partial dependencies (for composite keys)
- **3NF**: No transitive dependencies
- **BCNF**: Stricter version of 3NF
- **4NF/5NF**: Handle multi-valued and join dependencies

Most databases target 3NF or BCNF. Denormalization is a strategic decision for performance optimization.

## Review Questions

1. What are the three types of anomalies that normalization helps prevent?
2. What is a functional dependency? Give an example.
3. What is the difference between 2NF and 3NF?
4. When might you choose to denormalize a database?
5. Explain the difference between 3NF and BCNF.

## Exercises

1. Normalize the following table to 3NF:
   ```
   Orders(OrderID, CustomerName, CustomerAddress, ProductID, 
          ProductName, Quantity, Price)
   ```

2. Identify functional dependencies in this table:
   ```
   Courses(CourseID, CourseName, InstructorID, InstructorName, 
           DepartmentID, DepartmentName)
   ```

3. Is this table in BCNF? If not, convert it:
   ```
   BookLoans(BookID, LibraryBranch, MemberID, DueDate)
   Given: LibraryBranch → BookID (each branch has different books)
   ```

---
[← Previous Chapter: ER Modeling](chapter03_er_modeling.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Next Chapter: SQL Fundamentals →](chapter05_sql_fundamentals.md)
