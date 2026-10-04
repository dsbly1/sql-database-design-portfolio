/* =============================================================================
   02 - Filtering with WHERE: comparisons, BETWEEN, IN, IS NULL, AND/OR
   Database : LifeStyleDB (run 00_create_lifestyledb.sql first)
   Author   : Damon Bly
   Origin   : CISS 202 Introduction to Databases, Assignment 5 (Sept 2025)
              and Assignment 12 (Oct 2025), revised for this portfolio
   ============================================================================= */

USE LifeStyleDB;
GO

-- 1. Products that sold five or more units in a single order.         (Example 3.2)
SELECT DISTINCT ProductId
FROM Sales.OrderDetails
WHERE Quantity >= 5;

-- 2. Deliveries of more than 10 units: product ID and units delivered. (Exercise 3.2)
SELECT ProductId, Quantity
FROM Purchasing.Deliveries
WHERE Quantity > 10;

-- 3. USA customers, sorted alphabetically.                            (Example 3.3)
SELECT CustomerName, Email
FROM Sales.Customers
WHERE Country = N'USA'
ORDER BY CustomerName;

-- 4. UK customers, sorted alphabetically.                             (Exercise 3.3)
SELECT CustomerName, Email
FROM Sales.Customers
WHERE Country = N'UK'
ORDER BY CustomerName;

-- 5. Employees born in the 1980s.                                     (Example 3.4)
SELECT FirstName, LastName, BirthDate
FROM HR.Employees
WHERE BirthDate BETWEEN '19800101' AND '19891231';

-- 6. Deliveries in the first nine days of October 2016.               (Exercise 3.4)
--    DeliveryDate stores a time, so "< Oct 10" captures all of Oct 9.
--    (Revision: the original "<= '2016-10-09'" stopped at midnight on Oct 9.)
SELECT ProductId, Quantity, DeliveryDate
FROM Purchasing.Deliveries
WHERE DeliveryDate >= '20161001'
  AND DeliveryDate <  '20161010';

-- 7. Customers with no contact name on file.                          (Example 3.6)
SELECT CustomerName
FROM Sales.Customers
WHERE Contact IS NULL;

-- 8. Employees with no phone number on file.                          (Exercise 3.6)
--    Checks for NULL and for an empty string, since either means "missing".
SELECT FirstName, LastName
FROM HR.Employees
WHERE Phone IS NULL OR Phone = N'';

-- 9. Order lines with more than 1 unit, priced under $100 or over $1,000. (Example 3.10)
--    AND is evaluated before OR, so the parentheses are required.
--    (Revision: without them, every item over $1,000 matched regardless of quantity.)
SELECT ProductId, Quantity, Price
FROM Sales.OrderDetails
WHERE Quantity > 1
  AND (Price < 100 OR Price > 1000);

-- 10. Deliveries of more than 5 units, supplier price under $100 or over $1,000. (Exercise 3.10)
--     (Revision: the original compared DeliveryId < 100 instead of Price < 100.)
SELECT ProductId, Price, DeliveryDate
FROM Purchasing.Deliveries
WHERE Quantity > 5
  AND (Price < 100 OR Price > 1000);

-- 11. Domestic (USA) customer contact list.                           (Assignment 12)
SELECT CustomerName, Contact, Email
FROM Sales.Customers
WHERE Country = N'USA'
ORDER BY CustomerName;
