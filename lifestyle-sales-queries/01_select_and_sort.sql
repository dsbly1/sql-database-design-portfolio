/* =============================================================================
   01 - SELECT, DISTINCT, ORDER BY, TOP
   Database : LifeStyleDB (run 00_create_lifestyledb.sql first)
   Author   : Damon Bly
   Origin   : CISS 202 Introduction to Databases, Assignment 3 (Sept 2025),
              revised for this portfolio
   ============================================================================= */

USE LifeStyleDB;
GO

-- 1. Employee phone list: first name, last name, and phone number.   (Example 2.3)
SELECT FirstName, LastName, Phone
FROM HR.Employees;

-- 2. Customer directory: name, email, and country.                     (Exercise 2.3)
SELECT CustomerName, Email, Country
FROM Sales.Customers;

-- 3. Suppliers that currently have products in the catalog.           (Example 2.5)
--    DISTINCT removes repeats, since one supplier can have many products.
SELECT DISTINCT SupplierId
FROM Purchasing.Products;

-- 4. Employees who have made at least one sale.                       (Exercise 2.5)
--    Sales live in Sales.Orders, so that is the table to read from.
--    (Revision: the original read HR.Employees, which lists every employee.)
SELECT DISTINCT EmployeeId
FROM Sales.Orders;

-- 5. Employees sorted from youngest to oldest.                        (Example 2.7)
SELECT FirstName, LastName, BirthDate
FROM HR.Employees
ORDER BY BirthDate DESC;

-- 6. All orders, most recent first.                                   (Exercise 2.7)
--    Columns are listed explicitly instead of SELECT * so the output
--    does not change if the table gains new columns.
SELECT OrderId, CustomerId, EmployeeId, OrderDate
FROM Sales.Orders
ORDER BY OrderDate DESC;

-- 7. The two longest-serving employees.                               (Example 2.9)
SELECT TOP (2) FirstName, LastName
FROM HR.Employees
ORDER BY HireDate;

-- 8. The three most recent deliveries: product ID and quantity.       (Exercise 2.9)
--    (Revision: TOP (3) added; the original returned every delivery.)
SELECT TOP (3) ProductId, Quantity, DeliveryDate
FROM Purchasing.Deliveries
ORDER BY DeliveryDate DESC;

-- 9. Employees sorted by last name, then first name.                  (Example 2.10)
SELECT FirstName, LastName
FROM HR.Employees
ORDER BY LastName, FirstName;

-- 10. Customers and contacts sorted by name, then contact.            (Exercise 2.10)
SELECT CustomerName, Contact
FROM Sales.Customers
ORDER BY CustomerName, Contact;
