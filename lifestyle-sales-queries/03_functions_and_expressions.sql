/* =============================================================================
   03 - LIKE patterns, calculated columns, string and date functions
   Database : LifeStyleDB (run 00_create_lifestyledb.sql first)
   Author   : Damon Bly
   Origin   : CISS 202 Introduction to Databases, Assignment 7 (Sept 2025),
              revised for this portfolio
   ============================================================================= */

USE LifeStyleDB;
GO

-- 1. Customers with "Electronics" in their name, with country.        (Example 4.1)
SELECT CustomerName, Country
FROM Sales.Customers
WHERE CustomerName LIKE N'%electronics%';

-- 2. Products with "LED" in their name.                               (Exercise 4.1)
SELECT ProductId, ProductName
FROM Purchasing.Products
WHERE ProductName LIKE N'%LED%';

-- 3. Employee full names in one readable column.                      (Example 4.4)
SELECT FirstName + N' ' + LastName AS [Full Name]
FROM HR.Employees;

-- 4. Supplier name and country combined in one readable column.       (Exercise 4.4)
--    e.g. "Samsong (South Korea)"
SELECT SupplierName + N' (' + Country + N')' AS [Supplier (Country)]
FROM Purchasing.Suppliers;

-- 5. A 10% supplier discount on Product 1: regular vs. sale price.    (Example 4.6)
SELECT DeliveryId,
       ProductId,
       Price       AS [Regular Price],
       Price * 0.9 AS [Sale Price]
FROM Purchasing.Deliveries
WHERE ProductId = 1;

-- 6. A 20% discount for 3+ units of one product on one order.         (Exercise 4.6)
--    (Revision: the original computed Price * Quantity * 0.20, which is the
--    amount taken off, not the discounted price.)
SELECT OrderId,
       ProductId,
       Price,
       Quantity,
       Price * 0.80            AS [Discounted Unit Price],
       Price * Quantity * 0.80 AS [Discounted Line Total]
FROM Sales.OrderDetails
WHERE Quantity >= 3;

-- 7. The characters between the first two e's in a customer name.     (Example 4.11)
--    e.g. "Cheap Electronics" -> "ap "
SELECT CustomerName,
       SUBSTRING(
           CustomerName,
           CHARINDEX('e', CustomerName) + 1,
           CHARINDEX('e', CustomerName, CHARINDEX('e', CustomerName) + 1)
             - CHARINDEX('e', CustomerName) - 1
       ) AS [Characters Between First Two e's]
FROM Sales.Customers
WHERE CustomerName LIKE N'%e%e%';

-- 8. The first word after the street number in a supplier address.    (Exercise 4.11)
--    e.g. "1 Pine Apple St." -> "Pine"
--    Step 1 strips the street number; step 2 takes text up to the next space.
--    Appending ' ' guarantees CHARINDEX finds a space even on one-word streets.
SELECT StreetAddress,
       SUBSTRING(
           SUBSTRING(StreetAddress, CHARINDEX(' ', StreetAddress) + 1, LEN(StreetAddress)),
           1,
           CHARINDEX(' ',
               SUBSTRING(StreetAddress, CHARINDEX(' ', StreetAddress) + 1, LEN(StreetAddress)) + ' '
           ) - 1
       ) AS [First Word After Street Number]
FROM Purchasing.Suppliers;

-- 9. Months each employee has worked for the company.                 (Example 4.12)
SELECT FirstName,
       LastName,
       HireDate,
       CAST(GETDATE() AS DATE)            AS [Today's Date],
       DATEDIFF(MONTH, HireDate, GETDATE()) AS [Months Worked]
FROM HR.Employees;

-- 10. Age of each order in days.                                      (Exercise 4.12)
SELECT o.OrderId,
       o.CustomerId,
       o.EmployeeId,
       o.OrderDate,
       CAST(GETDATE() AS DATE)              AS [Today's Date],
       DATEDIFF(DAY, o.OrderDate, GETDATE()) AS [Order Age (Days)]
FROM Sales.Orders AS o;
