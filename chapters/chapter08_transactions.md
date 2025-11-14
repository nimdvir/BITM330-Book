# Chapter 8: Transactions and Concurrency

## 8.1 ACID Properties

**ACID** is an acronym for the four key properties that guarantee database transactions are processed reliably.

### 8.1.1 Atomicity

**Definition**: A transaction is an atomic unit of work - either all operations succeed, or all fail.

**Analogy**: Transferring money between bank accounts:
- Debit account A
- Credit account B
- Both must succeed or both must fail (no partial completion)

**Example:**
```sql
START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A001';
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'A002';

COMMIT;  -- Both updates succeed
-- OR
ROLLBACK;  -- Both updates are undone
```

**Without Atomicity:**
- Money could be deducted from one account but never added to the other
- Data would be in an inconsistent state

### 8.1.2 Consistency

**Definition**: A transaction brings the database from one valid state to another, maintaining all defined rules and constraints.

**Rules Include:**
- Data type constraints
- Check constraints
- Foreign key constraints
- Triggers
- Business logic

**Example:**
```sql
-- Before transaction
Total Balance in all accounts: $10,000

START TRANSACTION;
-- Transfer $100 from Account A to Account B
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A001';
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'A002';
COMMIT;

-- After transaction
Total Balance in all accounts: $10,000 (still consistent)
```

**Violation Example:**
```sql
START TRANSACTION;

-- This would violate a CHECK constraint
UPDATE Students SET GPA = 5.0 WHERE StudentID = 'S001';  -- Invalid (GPA > 4.0)

-- Transaction would fail, maintaining consistency
```

### 8.1.3 Isolation

**Definition**: Concurrent transactions execute independently without interfering with each other.

**Problem Without Isolation:**
```sql
-- User 1 reads balance
SELECT Balance FROM Accounts WHERE AccountID = 'A001';  -- Gets $1000

-- User 2 reads balance (simultaneously)
SELECT Balance FROM Accounts WHERE AccountID = 'A001';  -- Gets $1000

-- User 1 withdraws $100
UPDATE Accounts SET Balance = 900 WHERE AccountID = 'A001';

-- User 2 withdraws $100 (based on old read)
UPDATE Accounts SET Balance = 900 WHERE AccountID = 'A001';

-- Result: Balance is $900, but should be $800!
```

**With Proper Isolation:**
- One transaction completes before the other sees the changes
- Or locking prevents conflicting operations

### 8.1.4 Durability

**Definition**: Once a transaction is committed, the changes are permanent, even in case of system failure.

**Mechanisms:**
- Write-ahead logging (WAL)
- Transaction logs
- Backup and recovery systems

**Example:**
```sql
START TRANSACTION;
INSERT INTO Orders (OrderID, CustomerID, Amount) VALUES (1001, 'C001', 250.00);
COMMIT;

-- Even if power fails immediately after COMMIT,
-- the order will be in the database when system restarts
```

## 8.2 Transaction Management

### 8.2.1 Starting Transactions

**Explicit Transaction:**
```sql
-- MySQL/PostgreSQL
START TRANSACTION;
-- or
BEGIN;

-- SQL Server
BEGIN TRANSACTION;
```

**Implicit Commit:**
```sql
-- Most databases auto-commit by default
INSERT INTO Students VALUES ('S001', 'Alice', 'Smith');  -- Auto-committed

-- Disable auto-commit
SET autocommit = 0;  -- MySQL
```

### 8.2.2 Committing Transactions

**COMMIT** makes all changes permanent:
```sql
START TRANSACTION;

INSERT INTO Students (StudentID, FirstName, LastName) 
VALUES ('S005', 'Emma', 'Davis');

UPDATE Students SET GPA = 3.9 WHERE StudentID = 'S005';

COMMIT;  -- Changes are permanent
```

### 8.2.3 Rolling Back Transactions

**ROLLBACK** undoes all changes since the transaction started:
```sql
START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 1000 WHERE AccountID = 'A001';

-- Oops, wrong amount!
ROLLBACK;  -- Undo the update

-- Account balance is unchanged
```

### 8.2.4 Savepoints

**SAVEPOINT** allows partial rollback within a transaction:
```sql
START TRANSACTION;

INSERT INTO Orders (OrderID, CustomerID) VALUES (1001, 'C001');
SAVEPOINT sp1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity) 
VALUES (1001, 'P001', 5);
SAVEPOINT sp2;

INSERT INTO OrderItems (OrderID, ProductID, Quantity) 
VALUES (1001, 'P002', 3);

-- Oops, wrong product for second item
ROLLBACK TO SAVEPOINT sp2;  -- Undo only the last insert

-- Add correct item
INSERT INTO OrderItems (OrderID, ProductID, Quantity) 
VALUES (1001, 'P003', 3);

COMMIT;  -- Order and both items are saved
```

### 8.2.5 Transaction Example: Bank Transfer

```sql
START TRANSACTION;

-- Check sufficient balance
DECLARE @balance DECIMAL(10,2);
SELECT @balance = Balance FROM Accounts WHERE AccountID = 'A001';

IF @balance >= 100 THEN
    -- Debit sender
    UPDATE Accounts 
    SET Balance = Balance - 100 
    WHERE AccountID = 'A001';
    
    -- Credit receiver
    UPDATE Accounts 
    SET Balance = Balance + 100 
    WHERE AccountID = 'A002';
    
    -- Log the transaction
    INSERT INTO TransactionLog (FromAccount, ToAccount, Amount, TransactionDate)
    VALUES ('A001', 'A002', 100, CURRENT_TIMESTAMP);
    
    COMMIT;
ELSE
    ROLLBACK;
    -- Insufficient funds
END IF;
```

## 8.3 Concurrency Control

**Concurrency control** manages simultaneous access to the database by multiple users.

### 8.3.1 Concurrency Problems

**Lost Update:**
```sql
-- User 1 reads quantity
SELECT Quantity FROM Inventory WHERE ProductID = 'P001';  -- Gets 10

-- User 2 reads quantity
SELECT Quantity FROM Inventory WHERE ProductID = 'P001';  -- Gets 10

-- User 1 updates (sells 2)
UPDATE Inventory SET Quantity = 8 WHERE ProductID = 'P001';

-- User 2 updates (sells 3)
UPDATE Inventory SET Quantity = 7 WHERE ProductID = 'P001';

-- Lost update! Should be 5, but is 7
```

**Dirty Read:**
Reading uncommitted changes from another transaction.
```sql
-- Transaction 1
START TRANSACTION;
UPDATE Products SET Price = 100 WHERE ProductID = 'P001';
-- Not committed yet

-- Transaction 2
SELECT Price FROM Products WHERE ProductID = 'P001';  -- Reads 100 (dirty read)

-- Transaction 1
ROLLBACK;  -- Price goes back to original

-- Transaction 2 saw data that never existed!
```

**Non-Repeatable Read:**
Same query returns different results within a transaction.
```sql
-- Transaction 1
START TRANSACTION;
SELECT Price FROM Products WHERE ProductID = 'P001';  -- Gets $50

-- Transaction 2
UPDATE Products SET Price = 60 WHERE ProductID = 'P001';
COMMIT;

-- Transaction 1 (same transaction)
SELECT Price FROM Products WHERE ProductID = 'P001';  -- Gets $60

-- Same query, different result!
```

**Phantom Read:**
New rows appear in repeated queries.
```sql
-- Transaction 1
START TRANSACTION;
SELECT COUNT(*) FROM Orders WHERE Status = 'Pending';  -- Gets 10

-- Transaction 2
INSERT INTO Orders (OrderID, Status) VALUES (1011, 'Pending');
COMMIT;

-- Transaction 1
SELECT COUNT(*) FROM Orders WHERE Status = 'Pending';  -- Gets 11

-- A "phantom" row appeared!
```

### 8.3.2 Isolation Levels

SQL defines four isolation levels to control concurrency problems:

**1. READ UNCOMMITTED** (Lowest isolation)
- Can read uncommitted changes (dirty reads)
- Fastest but least safe
- Allows: Dirty reads, non-repeatable reads, phantom reads

```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
-- Can see uncommitted changes from other transactions
SELECT * FROM Products;
COMMIT;
```

**2. READ COMMITTED** (Default in many databases)
- Only reads committed changes
- Prevents dirty reads
- Allows: Non-repeatable reads, phantom reads

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
-- Only sees committed data
SELECT * FROM Products;
COMMIT;
```

**3. REPEATABLE READ**
- Ensures same query returns same results
- Prevents dirty reads and non-repeatable reads
- Allows: Phantom reads (in some databases)

```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM Products WHERE Category = 'Electronics';
-- Same query will return same results throughout transaction
COMMIT;
```

**4. SERIALIZABLE** (Highest isolation)
- Complete isolation (as if transactions run serially)
- Prevents all concurrency problems
- Slowest performance

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM Products;
-- Complete isolation from other transactions
COMMIT;
```

**Isolation Level Summary:**

| Level | Dirty Read | Non-Repeatable Read | Phantom Read |
|-------|-----------|--------------------|--------------| 
| READ UNCOMMITTED | Possible | Possible | Possible |
| READ COMMITTED | Prevented | Possible | Possible |
| REPEATABLE READ | Prevented | Prevented | Possible |
| SERIALIZABLE | Prevented | Prevented | Prevented |

## 8.4 Locking Mechanisms

**Locks** control concurrent access to data.

### 8.4.1 Lock Types

**Shared Lock (S-Lock):**
- Allows reading
- Multiple transactions can hold shared locks on same data
- Prevents writing while held

```sql
-- Acquired automatically during SELECT with appropriate isolation level
SELECT * FROM Products WHERE ProductID = 'P001' LOCK IN SHARE MODE;
```

**Exclusive Lock (X-Lock):**
- Allows reading and writing
- Only one transaction can hold exclusive lock
- Prevents all other access

```sql
-- Acquired automatically during UPDATE, DELETE, INSERT
UPDATE Products SET Price = 100 WHERE ProductID = 'P001';

-- Or explicitly
SELECT * FROM Products WHERE ProductID = 'P001' FOR UPDATE;
```

### 8.4.2 Lock Granularity

**Row-Level Locks:**
- Locks individual rows
- Best concurrency
- More overhead

```sql
-- Locks only the selected row
SELECT * FROM Products WHERE ProductID = 'P001' FOR UPDATE;
```

**Table-Level Locks:**
- Locks entire table
- Less concurrency
- Less overhead

```sql
LOCK TABLE Products WRITE;
-- Entire table is locked
UPDATE Products SET Price = Price * 1.1;
UNLOCK TABLES;
```

**Page-Level Locks:**
- Locks a page of data (between row and table)
- Balance of concurrency and overhead

### 8.4.3 Explicit Locking

**MySQL:**
```sql
-- Lock tables for reading
LOCK TABLES Products READ;
SELECT * FROM Products;
UNLOCK TABLES;

-- Lock tables for writing
LOCK TABLES Products WRITE;
UPDATE Products SET Price = Price * 1.1;
UNLOCK TABLES;
```

**PostgreSQL:**
```sql
-- Lock specific rows
BEGIN;
SELECT * FROM Products WHERE ProductID = 'P001' FOR UPDATE;
-- Row is locked until COMMIT or ROLLBACK
UPDATE Products SET Price = 100 WHERE ProductID = 'P001';
COMMIT;
```

**SQL Server:**
```sql
-- Lock with hint
SELECT * FROM Products WITH (UPDLOCK, ROWLOCK)
WHERE ProductID = 'P001';
```

### 8.4.4 Lock Compatibility

| Requested \ Current | No Lock | Shared Lock | Exclusive Lock |
|--------------------|---------|-------------|----------------|
| **Shared Lock** | ✓ | ✓ | ✗ |
| **Exclusive Lock** | ✓ | ✗ | ✗ |

## 8.5 Deadlocks

A **deadlock** occurs when two or more transactions wait for each other to release locks.

### 8.5.1 Deadlock Example

```sql
-- Transaction 1
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A001';
-- Waiting for lock on A002...
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'A002';

-- Transaction 2 (simultaneously)
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 50 WHERE AccountID = 'A002';
-- Waiting for lock on A001...
UPDATE Accounts SET Balance = Balance + 50 WHERE AccountID = 'A001';

-- DEADLOCK! Each transaction waits for the other
```

**Visual Representation:**
```
Transaction 1: Holds lock on A001, wants lock on A002
                    ↓
                [A001] ←---- [Transaction 1] ----→ [A002]
                  ↑                                   ↓
                  |                                   |
            [Transaction 2] ←-------------------------┘
                  ↓
                [A002]

Transaction 2: Holds lock on A002, wants lock on A001
```

### 8.5.2 Deadlock Detection

Databases detect deadlocks and resolve them by:
1. **Detecting** the circular wait condition
2. **Choosing a victim** transaction
3. **Rolling back** the victim
4. **Allowing other transactions** to proceed

**Error Message:**
```
ERROR 1213 (40001): Deadlock found when trying to get lock; 
try restarting transaction
```

### 8.5.3 Preventing Deadlocks

**1. Access Resources in Same Order:**
```sql
-- Bad: Different order
-- Transaction 1: Lock A, then B
-- Transaction 2: Lock B, then A

-- Good: Same order
-- Transaction 1: Lock A, then B
-- Transaction 2: Lock A, then B
```

**2. Keep Transactions Short:**
```sql
-- Bad: Long transaction
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 'A001';
-- Do complex calculation (holds lock for long time)
SLEEP(10);
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 'A002';
COMMIT;

-- Good: Short transaction
-- Do calculation first
DECLARE @amount = ComplexCalculation();
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - @amount WHERE AccountID = 'A001';
UPDATE Accounts SET Balance = Balance + @amount WHERE AccountID = 'A002';
COMMIT;
```

**3. Use Lower Isolation Levels (When Appropriate):**
```sql
-- If dirty reads are acceptable
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

**4. Use Timeouts:**
```sql
-- MySQL
SET innodb_lock_wait_timeout = 5;  -- Wait 5 seconds for lock

-- PostgreSQL
SET lock_timeout = '5s';
```

### 8.5.4 Handling Deadlocks in Application

```python
# Python example with retry logic
import mysql.connector
import time

def transfer_money(from_account, to_account, amount, max_retries=3):
    for attempt in range(max_retries):
        try:
            conn = mysql.connector.connect(...)
            cursor = conn.cursor()
            
            cursor.execute("START TRANSACTION")
            cursor.execute(
                "UPDATE Accounts SET Balance = Balance - %s WHERE AccountID = %s",
                (amount, from_account)
            )
            cursor.execute(
                "UPDATE Accounts SET Balance = Balance + %s WHERE AccountID = %s",
                (amount, to_account)
            )
            conn.commit()
            return True  # Success
            
        except mysql.connector.Error as e:
            if e.errno == 1213:  # Deadlock
                conn.rollback()
                if attempt < max_retries - 1:
                    time.sleep(0.1 * (attempt + 1))  # Exponential backoff
                    continue
                else:
                    raise
            else:
                conn.rollback()
                raise
    
    return False
```

## Summary

Transactions and concurrency control are essential for database reliability:
- **ACID properties** ensure reliable transaction processing
- **Transaction management** provides control over database changes
- **Isolation levels** balance consistency and performance
- **Locking mechanisms** coordinate concurrent access
- **Deadlock handling** prevents and resolves resource conflicts

Understanding these concepts enables building robust, concurrent database applications.

## Review Questions

1. Explain each of the ACID properties with an example.
2. What's the difference between COMMIT and ROLLBACK?
3. What are the four isolation levels, and how do they differ?
4. What is a deadlock, and how can it be prevented?
5. When would you use a savepoint?

## Exercises

1. Write a transaction that transfers credits from one student to another, ensuring the total credits remain constant.

2. Describe a scenario where READ COMMITTED isolation level would be insufficient and REPEATABLE READ would be needed.

3. Design a strategy to prevent deadlocks in an online shopping system where multiple users can purchase the same product.

---
[← Previous Chapter: Best Practices](chapter07_best_practices.md) | [Table of Contents](../TABLE_OF_CONTENTS.md) | [Appendix A →](../appendices/appendix_a_sql_reference.md)
