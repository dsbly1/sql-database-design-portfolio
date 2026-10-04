/* =============================================================================
   05 - Joins: INNER, multi-table, OUTER (LEFT / RIGHT), and self joins
   Database : LifeStyleDB (run 00_create_lifestyledb.sql first)
   Author   : Damon Bly
   Origin   : CISS 202 Introduction to Databases, Assignment 11 and
              Assignment 12 (Oct 2025), revised for this portfolio
   ============================================================================= */

USE LifeStyleDB;
GO

-- 1. Every order with its line items: order date, product, quantity, price. (Example 6.1)
SELECT o.OrderId, o.OrderDate, od.ProductId, od.Quantity, od.Price
FROM Sales.Orders AS o
JOIN Sales.OrderDetails AS od
  ON o.OrderId = od.OrderId;

-- 2. Delivery details per product, with the date only (no time).      (Exercise 6.1)
--    (Revision: CAST to DATE removes the time part the exercise asked to drop.)
SELECT p.ProductName,
       d.DeliveryId,
       d.Quantity,
       d.Price,
       CAST(d.DeliveryDate AS DATE) AS DeliveryDate
FROM Purchasing.Products AS p
JOIN Purchasing.Deliveries AS d
  ON p.ProductId = d.ProductId;

-- 3. Suppliers, their products, and each delivery.                    (Example 6.4)
SELECT s.SupplierName, p.ProductName, d.Quantity, d.Price, d.DeliveryDate
FROM Purchasing.Suppliers AS s
JOIN Purchasing.Products  AS p ON s.SupplierId = p.SupplierId
JOIN Purchasing.Deliveries AS d ON p.ProductId = d.ProductId;

-- 4. Customers, their orders, and every line item,
--    sorted by customer, order, and product.                          (Exercise 6.4)
--    (Revision: rewritten; the original repeated query 3's supplier report.)
SELECT c.CustomerId,
       c.CustomerName,
       o.OrderId,
       o.OrderDate,
       od.ProductId,
       od.Price,
       od.Quantity
FROM Sales.Customers    AS c
JOIN Sales.Orders       AS o  ON c.CustomerId = o.CustomerId
JOIN Sales.OrderDetails AS od ON o.OrderId    = od.OrderId
ORDER BY c.CustomerId, o.OrderId, od.ProductId;

-- 5. Each supplier's products and the most recent delivery date.      (Example 6.6)
SELECT s.SupplierName,
       p.ProductName,
       MAX(d.DeliveryDate) AS MostRecentDelivery
FROM Purchasing.Suppliers AS s
JOIN Purchasing.Products  AS p ON s.SupplierId = p.SupplierId
JOIN Purchasing.Deliveries AS d ON p.ProductId = d.ProductId
GROUP BY s.SupplierName, p.ProductName;

-- 6. Each customer order with its most expensive unit price.          (Exercise 6.6)
--    Expected: 8 rows, one per order.
--    (Revision: the original also joined Deliveries on OrderId = DeliveryId.
--    Those IDs are unrelated, so the join silently dropped 5 of the 8 orders.)
SELECT c.CustomerId,
       c.CustomerName,
       o.OrderId,
       o.OrderDate,
       MAX(od.Price) AS MostExpensiveUnitPrice
FROM Sales.Customers    AS c
JOIN Sales.Orders       AS o  ON c.CustomerId = o.CustomerId
JOIN Sales.OrderDetails AS od ON o.OrderId    = od.OrderId
GROUP BY c.CustomerId, c.CustomerName, o.OrderId, o.OrderDate
ORDER BY c.CustomerId, o.OrderId;

-- 7. All suppliers with their most recent delivery date,
--    showing NULL for suppliers that have never delivered.            (Example 6.9)
SELECT s.SupplierName,
       MAX(d.DeliveryDate) AS MostRecentDeliveryDate
FROM Purchasing.Products AS p
JOIN Purchasing.Deliveries AS d
  ON p.ProductId = d.ProductId
RIGHT JOIN Purchasing.Suppliers AS s
  ON p.SupplierId = s.SupplierId
GROUP BY s.SupplierName;

-- 8. All customers with the highest unit price they have ever ordered,
--    showing NULL for customers with no orders.                       (Exercise 6.9)
SELECT c.CustomerId,
       c.CustomerName,
       MAX(od.Price) AS HighestUnitPrice
FROM Sales.Customers AS c
LEFT JOIN Sales.Orders       AS o  ON c.CustomerId = o.CustomerId
LEFT JOIN Sales.OrderDetails AS od ON o.OrderId    = od.OrderId
GROUP BY c.CustomerId, c.CustomerName;

-- 9. Customers that share a name with another customer.               (Example 6.10)
SELECT DISTINCT c1.CustomerId, c1.CustomerName, c1.Email
FROM Sales.Customers AS c1
JOIN Sales.Customers AS c2
  ON  c1.CustomerId   <> c2.CustomerId
  AND c1.CustomerName =  c2.CustomerName;

-- 10. Employees who share a last name with another employee.          (Exercise 6.10)
--     (Revision: FullName now combines first and last name; the original
--     labeled the last name alone as FullName.)
SELECT e1.EmployeeId,
       CONCAT(e1.FirstName, N' ', e1.LastName) AS FullName,
       e1.BirthDate
FROM HR.Employees AS e1
JOIN HR.Employees AS e2
  ON  e1.LastName   =  e2.LastName
  AND e1.EmployeeId <> e2.EmployeeId
ORDER BY e1.LastName, e1.FirstName;

-- 11. Contact list of customers who have placed at least one order.   (Assignment 12)
--     Grouping by CustomerId keeps two different customers with the
--     same name (like the two "Beyond Electronics") as separate rows.
SELECT DISTINCT c.CustomerId, c.CustomerName, c.Contact, c.Email
FROM Sales.Customers AS c
JOIN Sales.Orders    AS o ON c.CustomerId = o.CustomerId;

-- 12. Every customer order line with contact details.                 (Assignment 12)
--     (Revision: Contact added; the question asked for it.)
SELECT c.CustomerName, c.Contact, c.Email, o.OrderDate, od.Quantity, od.Price
FROM Sales.Customers    AS c
JOIN Sales.Orders       AS o  ON c.CustomerId = o.CustomerId
JOIN Sales.OrderDetails AS od ON o.OrderId    = od.OrderId
ORDER BY c.CustomerName, o.OrderDate;
