/* =============================================================================
   06 - INSERT, UPDATE, DELETE inside a transaction
   Database : LifeStyleDB (run 00_create_lifestyledb.sql first)
   Author   : Damon Bly
   Origin   : CISS 202 Introduction to Databases, Assignment 13 (Oct 2025),
              revised for this portfolio

   SAFE TO RUN: everything happens inside one transaction that is rolled back
   at the end, so the sample data is left exactly as it started. Change the
   final ROLLBACK to COMMIT only if you want to keep the changes.

   Revisions from the original assignment:
   - New rows are tracked by remembering the highest existing ID before the
     inserts. The original used "EmployeeId > 7" and "CustomerId > 3", which
     broke when the inserts ran twice and wiped emails from 16 customers.
   - Customer filters now use the inserted customer names (Magic E, E4U,
     Web E). The original listed contact names, so two customers were never
     updated or deleted.
   ============================================================================= */

USE LifeStyleDB;
GO

SET XACT_ABORT ON;   -- any error rolls back the whole transaction
BEGIN TRANSACTION;

-- Remember where the existing data ends, so only new rows are touched.
DECLARE @LastEmployeeId INT = (SELECT MAX(EmployeeId) FROM HR.Employees);
DECLARE @LastCustomerId INT = (SELECT MAX(CustomerId) FROM Sales.Customers);

-- 1. Insert an employee, supplying only the required columns.         (Example 7.2)
INSERT INTO HR.Employees (LastName, FirstName, BirthDate, HireDate)
VALUES (N'Anderson', N'James', '19900312', '20151111');

-- 2. Insert a customer when only the name is known.                   (Exercise 7.2)
INSERT INTO Sales.Customers (CustomerName)
VALUES (N'Magic E');

-- 3. Insert two employees in one statement.                           (Example 7.3)
INSERT INTO HR.Employees (FirstName, LastName, HireDate, BirthDate)
VALUES (N'Adam', N'Smith',   '20160919', '19890201'),
       (N'Kyle', N'Johnson', '20160919', '19881223');

-- 4. Insert two customers with contacts in one statement.             (Exercise 7.3)
INSERT INTO Sales.Customers (CustomerName, Contact)
VALUES (N'E4U',   N'Tom Cornell'),
       (N'Web E', N'Daniel Head');

-- Check: 3 new employees and 3 new customers.
SELECT EmployeeId, FirstName, LastName, HireDate, ManagerId
FROM HR.Employees WHERE EmployeeId > @LastEmployeeId;
SELECT CustomerId, CustomerName, Contact, Email
FROM Sales.Customers WHERE CustomerId > @LastCustomerId;

-- 5. Assign manager 3 to every newly hired employee.                  (Example 7.8)
UPDATE HR.Employees
SET ManagerId = 3
WHERE EmployeeId > @LastEmployeeId;          -- expected: 3 rows

-- 6. Give every newly added customer a shared email.                  (Exercise 7.8)
UPDATE Sales.Customers
SET Email = N'customers@lifestyle.com'
WHERE CustomerName IN (N'Magic E', N'E4U', N'Web E')
  AND CustomerId > @LastCustomerId;          -- expected: 3 rows

-- 7. Remove the manager assignment from the new employees.            (Example 7.9)
UPDATE HR.Employees
SET ManagerId = NULL
WHERE EmployeeId > @LastEmployeeId;          -- expected: 3 rows

-- 8. Remove the shared email from the new customers.                  (Exercise 7.9)
UPDATE Sales.Customers
SET Email = NULL
WHERE CustomerId > @LastCustomerId;          -- expected: 3 rows

-- 9. Delete the new employees.                                        (Example 7.11)
DELETE FROM HR.Employees
WHERE EmployeeId > @LastEmployeeId;          -- expected: 3 rows

-- 10. Delete the new customers.                                       (Exercise 7.11)
DELETE FROM Sales.Customers
WHERE CustomerId > @LastCustomerId;          -- expected: 3 rows

-- Check: back to the original 7 employees and 8 customers.
SELECT COUNT(*) AS EmployeeCount FROM HR.Employees;
SELECT COUNT(*) AS CustomerCount FROM Sales.Customers;

ROLLBACK TRANSACTION;   -- change to COMMIT TRANSACTION to keep the changes
