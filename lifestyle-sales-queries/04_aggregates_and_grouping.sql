/* =============================================================================
   04 - Aggregates, GROUP BY, HAVING, and subqueries
   Database : LifeStyleDB (run 00_create_lifestyledb.sql first)
   Author   : Damon Bly
   Origin   : CISS 202 Introduction to Databases, Assignment 9 (Sept 2025),
              revised for this portfolio
   ============================================================================= */

USE LifeStyleDB;
GO

-- 1. Total sales value of order 3.                                    (Example 5.4)
--    Expected: 2329.92
SELECT SUM(Quantity * Price) AS TotalSalesValue
FROM Sales.OrderDetails
WHERE OrderId = 3;

-- 2. Total delivered value of product 7 across all its deliveries.    (Exercise 5.4)
--    Expected: 12 x 79.99 + 18 x 69.99 = 2219.70
--    (Revision: the original hard-coded the arithmetic; this reads the table,
--    so it stays correct when new deliveries arrive.)
SELECT SUM(Quantity * Price) AS TotalValueProduct7
FROM Purchasing.Deliveries
WHERE ProductId = 7;

-- 3. One of the highest-priced items ever sold.                       (Example 5.7)
SELECT TOP (1) ProductId, MAX(Price) AS HighestPrice
FROM Sales.OrderDetails
GROUP BY ProductId
ORDER BY HighestPrice DESC;

-- 4. One of the highest-priced items ever delivered.                  (Exercise 5.7)
SELECT TOP (1) ProductId, Price
FROM Purchasing.Deliveries
ORDER BY Price DESC;

-- 5. Products over $1,000 per unit with 10+ units delivered in total. (Example 5.11)
--    WHERE filters rows before grouping; HAVING filters the groups after.
SELECT ProductId, SUM(Quantity) AS TotalQuantity
FROM Purchasing.Deliveries
WHERE Price > 1000
GROUP BY ProductId
HAVING SUM(Quantity) >= 10;

-- 6. Orders with 3+ total units of items priced over $150.            (Exercise 5.11)
SELECT OrderId, SUM(Quantity) AS TotalQuantity
FROM Sales.OrderDetails
WHERE Price > 150
GROUP BY OrderId
HAVING SUM(Quantity) >= 3;

-- 7. Products with 10+ units delivered Oct 1-10, 2016,
--    with total units and average price, largest volume first.        (Example 5.13)
--    A half-open range (>= Oct 1, < Oct 11) covers all of Oct 10, including times.
--    (Revision: ORDER BY now uses the alias directly instead of a quoted string.)
SELECT ProductId,
       SUM(Quantity) AS TotalUnits,
       AVG(Price)    AS AveragePrice
FROM Purchasing.Deliveries
WHERE DeliveryDate >= '20161001'
  AND DeliveryDate <  '20161011'
GROUP BY ProductId
HAVING SUM(Quantity) >= 10
ORDER BY TotalUnits DESC;

-- 8. Orders with 3+ units of products 1 or 3: total units and
--    simple (unweighted) average price, highest quantity first.       (Exercise 5.13)
SELECT OrderId,
       SUM(Quantity) AS TotalUnits,
       AVG(Price)    AS AveragePrice
FROM Sales.OrderDetails
WHERE ProductId IN (1, 3)
GROUP BY OrderId
HAVING SUM(Quantity) >= 3
ORDER BY TotalUnits DESC;

-- 9. Customers who have ordered product 1.                            (Example 5.16)
SELECT DISTINCT CustomerId
FROM Sales.Orders
WHERE OrderId IN (SELECT OrderId
                  FROM Sales.OrderDetails
                  WHERE ProductId = 1);

-- 10. Suppliers whose products were delivered Oct 5-10, 2016.         (Exercise 5.16)
--     Expected: suppliers 2, 3, and 5
--     (Revision: the original listed every supplier with a product and
--     never checked delivery dates.)
SELECT DISTINCT SupplierId
FROM Purchasing.Products
WHERE ProductId IN (SELECT ProductId
                    FROM Purchasing.Deliveries
                    WHERE DeliveryDate >= '20161005'
                      AND DeliveryDate <  '20161011');
