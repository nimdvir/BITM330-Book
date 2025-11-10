# Chapter 3: Entity-Relationship (ER) Modeling

## 3.1 Conceptual Data Modeling

**Conceptual data modeling** is the process of creating an abstract representation of data structures needed to support business processes. The Entity-Relationship (ER) model is the most widely used conceptual modeling approach.

### Purpose of Conceptual Modeling:
- **Communication**: Provides a common language between stakeholders and developers
- **Documentation**: Records business rules and data requirements
- **Design Blueprint**: Guides physical database implementation
- **Independence**: Focuses on "what" data is needed, not "how" it's stored

### Levels of Data Modeling:

1. **Conceptual Model** (ER Diagram)
   - High-level, business-focused
   - Technology-independent
   - Shows entities and relationships

2. **Logical Model**
   - Detailed structure
   - Still technology-independent
   - Includes attributes, data types, keys

3. **Physical Model**
   - Implementation-specific
   - Database-specific syntax
   - Includes indexes, partitions, etc.

### Example Scenario: University Database

**Business Requirements:**
- Track students and their enrollments
- Manage courses and instructors
- Record departments and their courses
- Track student grades

This scenario will be modeled throughout this chapter.

## 3.2 Entities and Attributes

### 3.2.1 Entities

An **entity** is a thing or object in the real world that is distinguishable from other objects. Entities represent the main data subjects in your system.

**Examples:**
- Student (a person who attends courses)
- Course (a class offered by the university)
- Department (an academic division)
- Instructor (a person who teaches courses)

**Entity Type vs Entity Instance:**
- **Entity Type**: The general category (e.g., Student)
- **Entity Instance**: A specific occurrence (e.g., Student "Alice Smith", ID S001)

### 3.2.2 Attributes

An **attribute** is a property or characteristic of an entity.

**Example - Student Entity:**
```
Student
- StudentID
- FirstName
- LastName
- DateOfBirth
- Email
- PhoneNumber
- Address
```

### Types of Attributes

#### 1. Simple vs Composite Attributes

**Simple Attribute**: Cannot be divided further
- StudentID
- Age
- GPA

**Composite Attribute**: Can be divided into sub-parts
```
Name
├── FirstName
├── MiddleName
└── LastName

Address
├── Street
├── City
├── State
└── ZipCode
```

#### 2. Single-Valued vs Multi-Valued Attributes

**Single-Valued**: Has one value for each entity
- StudentID (one ID per student)
- DateOfBirth (one birth date)

**Multi-Valued**: Can have multiple values
- PhoneNumber (home, mobile, work)
- Email (personal, university, work)
- Skills (for an employee)

**ER Diagram Notation:**
- Multi-valued attributes are shown in double ovals: {{PhoneNumber}}

#### 3. Stored vs Derived Attributes

**Stored Attribute**: Physically stored in the database
- DateOfBirth
- EnrollmentDate

**Derived Attribute**: Calculated from other attributes
- Age (calculated from DateOfBirth)
- YearsOfService (calculated from HireDate)
- TotalCredits (sum of course credits)

**ER Diagram Notation:**
- Derived attributes are shown in dashed ovals: (Age)

#### 4. Key Attributes

**Key Attribute**: Uniquely identifies an entity
- StudentID (for Student)
- CourseID (for Course)
- ISBN (for Book)

**ER Diagram Notation:**
- Key attributes are underlined: <u>StudentID</u>

### 3.2.3 NULL Values

**NULL** represents:
- Unknown value (we don't know the value)
- Not applicable (attribute doesn't apply to this entity)
- Missing value (value exists but not recorded)

**Example:**
- Student's MiddleName might be NULL (not everyone has a middle name)
- Employee's EndDate is NULL for current employees

## 3.3 Relationships and Cardinality

### 3.3.1 Relationships

A **relationship** is an association between two or more entities.

**Examples:**
- Students **enroll in** Courses
- Instructors **teach** Courses
- Courses **belong to** Departments
- Students **major in** Departments

### 3.3.2 Relationship Attributes

Relationships can have their own attributes.

**Example:**
```
Student ──(enrolls)── Course

Enrollment Relationship Attributes:
- EnrollmentDate
- Grade
- Semester
```

These attributes don't belong to Student or Course individually, but to the relationship between them.

### 3.3.3 Cardinality Ratios

**Cardinality** specifies how many instances of one entity relate to instances of another entity.

#### One-to-One (1:1)

One instance of Entity A relates to one instance of Entity B.

**Example:** Employee ← manages → Department
- Each employee manages at most one department
- Each department is managed by one employee

```
Employee ──1──manages──1── Department
```

**Real-World Examples:**
- Person ↔ Passport (one person has one passport)
- Country ↔ Capital City
- Student ↔ StudentIDCard

#### One-to-Many (1:N)

One instance of Entity A relates to many instances of Entity B.

**Example:** Department → offers → Course
- Each department offers many courses
- Each course is offered by one department

```
Department ──1────offers────N── Course
```

**Real-World Examples:**
- Customer → Orders (one customer places many orders)
- Author → Books (one author writes many books)
- Teacher → Students (one teacher teaches many students)

#### Many-to-Many (M:N)

Many instances of Entity A relate to many instances of Entity B.

**Example:** Student ↔ enrolls ↔ Course
- Each student enrolls in many courses
- Each course has many students enrolled

```
Student ──M────enrolls────N── Course
```

**Real-World Examples:**
- Students ↔ Courses
- Authors ↔ Books (some books have multiple authors)
- Employees ↔ Projects
- Products ↔ Suppliers

### 3.3.4 Participation Constraints

#### Total Participation (Mandatory)

Every entity must participate in the relationship.

**Notation:** Double line (═)

**Example:** Student ═══ enrolls ─── Course
- Every student **must** be enrolled in at least one course

#### Partial Participation (Optional)

Entities may or may not participate in the relationship.

**Notation:** Single line (─)

**Example:** Employee ─── manages ─── Department
- Not every employee manages a department

### 3.3.5 Structural Constraints

Combining cardinality and participation:

**Example:** Employee works_for Department
```
Employee ──(1,1)─── works_for ──(1,N)─── Department
```
- Each employee works for exactly one department (1,1)
- Each department has one or more employees (1,N)

**Min-Max Notation:**
- (0,1): Optional, at most one
- (1,1): Mandatory, exactly one
- (0,N): Optional, any number
- (1,N): Mandatory, at least one
- (5,10): At least 5, at most 10

## 3.4 ER Diagrams

### 3.4.1 ER Diagram Notation

**Chen Notation:**
```
┌─────────────┐
│   Entity    │  (Rectangle)
└─────────────┘

     Attribute  (Oval)
        ○

   ◇  Relationship  (Diamond)

──────  Relationship Line

══════  Total Participation (Double Line)
```

**Crow's Foot Notation:**
```
│  One
├─ One (mandatory)
○  Zero or one
├< One or many
○< Zero or many
```

### 3.4.2 Sample ER Diagram: University System

```
┌───────────┐                              ┌────────────┐
│  Student  │                              │   Course   │
├───────────┤                              ├────────────┤
│ StudentID │─────────────┐    ┌──────────│  CourseID  │
│ Name      │             │    │          │ CourseName │
│ Email     │             │    │          │ Credits    │
│ Major     │         ┌───┴────┴───┐      └─────┬──────┘
└───────────┘         │  Enrolls   │            │
                      ├────────────┤            │
                      │ Grade      │            │ (N)
                      │ Semester   │            │
                      └────────────┘            │
                           (M)                  │
                                                │
                                           ┌────┴─────┐
                                           │Department│
                                           ├──────────┤
                                           │  DeptID  │
                                           │ DeptName │
                                           └──────────┘
```

### 3.4.3 Converting ER to Relational Schema

#### Converting Entities:
Each entity becomes a table with its attributes as columns.

**Example:**
```
Entity: Student (StudentID, Name, Email, Major)

SQL Table:
CREATE TABLE Student (
    StudentID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Major VARCHAR(50)
);
```

#### Converting One-to-Many Relationships:
Add foreign key to the "many" side.

**Example:** Department (1) → (N) Course

```sql
CREATE TABLE Course (
    CourseID VARCHAR(10) PRIMARY KEY,
    CourseName VARCHAR(100),
    Credits INT,
    DepartmentID VARCHAR(10),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DeptID)
);
```

#### Converting Many-to-Many Relationships:
Create a junction (linking) table.

**Example:** Student (M) ↔ (N) Course

```sql
CREATE TABLE Enrollment (
    StudentID VARCHAR(10),
    CourseID VARCHAR(10),
    Grade VARCHAR(2),
    Semester VARCHAR(20),
    PRIMARY KEY (StudentID, CourseID, Semester),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);
```

#### Converting One-to-One Relationships:
Two options:

**Option 1:** Merge into one table (if participation is total)

**Option 2:** Use foreign key in either table
```sql
CREATE TABLE Employee (
    EmployeeID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100),
    DepartmentID VARCHAR(10),
    ...
);

CREATE TABLE Department (
    DepartmentID VARCHAR(10) PRIMARY KEY,
    DeptName VARCHAR(100),
    ManagerID VARCHAR(10) UNIQUE,
    FOREIGN KEY (ManagerID) REFERENCES Employee(EmployeeID)
);
```

## 3.5 Extended ER Features

### 3.5.1 Generalization and Specialization

**Generalization**: Combining similar entities into a higher-level entity (bottom-up)

**Specialization**: Dividing an entity into sub-entities (top-down)

**Example:**
```
           ┌─────────┐
           │ Person  │ (Superclass)
           ├─────────┤
           │ PersonID│
           │ Name    │
           │ Address │
           └────┬────┘
                │
        ┌───────┴───────┐
        │               │
   ┌────┴────┐     ┌────┴────┐
   │ Student │     │ Faculty │ (Subclasses)
   ├─────────┤     ├─────────┤
   │ Major   │     │ Rank    │
   │ GPA     │     │ Salary  │
   └─────────┘     └─────────┘
```

**Inheritance**: Subclasses inherit attributes from the superclass.

### 3.5.2 Disjoint vs Overlapping

**Disjoint** (Exclusive): Entity can belong to only one subclass
- Example: Person can be either Student OR Faculty, not both
- Notation: 'd' in the diagram

**Overlapping**: Entity can belong to multiple subclasses
- Example: Person can be both Student AND Employee
- Notation: 'o' in the diagram

### 3.5.3 Total vs Partial Specialization

**Total**: Every superclass entity must belong to at least one subclass
- Example: Every Vehicle must be either Car, Truck, or Motorcycle

**Partial**: Superclass entity may not belong to any subclass
- Example: Some Persons might not be Students or Faculty

### 3.5.4 Weak Entities

A **weak entity** cannot be uniquely identified by its own attributes alone; it depends on another entity.

**Example:** Dependents of an Employee
```
┌──────────┐        ┌───────────┐
│ Employee │═══════◇│ Dependent │
├──────────┤  has   ├───────────┤
│ EmpID    │        │ Name      │ (partial key)
│ Name     │        │ BirthDate │
└──────────┘        └───────────┘
  (Strong)            (Weak)
```

**Notation:**
- Weak entity: Double rectangle
- Identifying relationship: Double diamond
- Partial key: Dashed underline

**Composite Key:**
The weak entity's primary key is a combination of:
- The strong entity's primary key (foreign key)
- The weak entity's partial key

```sql
CREATE TABLE Dependent (
    EmployeeID VARCHAR(10),
    DependentName VARCHAR(100),
    BirthDate DATE,
    PRIMARY KEY (EmployeeID, DependentName),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmpID)
);
```

### 3.5.5 Aggregation

**Aggregation** treats a relationship as a higher-level entity.

**Example:** Interview for a Job Application
```
A candidate applies for a job, and then has an interview about that application.
```

## Summary

Entity-Relationship modeling is a powerful technique for database design:
- **Entities** represent real-world objects with **attributes**
- **Relationships** connect entities with defined **cardinality**
- **ER diagrams** provide visual representation of data structures
- **Extended ER features** handle complex scenarios

Mastering ER modeling enables you to design databases that accurately reflect business requirements.

## Review Questions

1. What is the difference between an entity type and an entity instance?
2. Explain the difference between a composite attribute and a multi-valued attribute.
3. What are the three main cardinality ratios? Give an example of each.
4. What is the difference between total and partial participation?
5. How do you convert a many-to-many relationship into relational tables?

## Exercises

1. Create an ER diagram for a library system with entities: Book, Author, Borrower, and Loan. Include appropriate attributes and relationships.

2. Identify the cardinality for these relationships:
   - Hospital ↔ Patient
   - Doctor ↔ Patient
   - Order ↔ Product

3. Convert the following ER design to SQL tables:
   ```
   Employee (EmpID, Name, Salary)
   Department (DeptID, DeptName)
   Relationship: Employee works_for Department (1:N)
   ```

4. Design an ER diagram for a university system including Student, Course, Instructor, and Department. Show specialization with Undergraduate and Graduate students.

---
[← Previous Chapter: The Relational Database Model](chapter02_relational_model.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Next Chapter: Normalization →](chapter04_normalization.md)
