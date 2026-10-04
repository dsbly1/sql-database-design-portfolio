/* =============================================================================
   LifeStyleDB - setup script
   Builds the LifeStyle LLC sample database used by every query file in this
   folder: an electronics wholesaler with HR, Sales, and Purchasing schemas.

   Source: course-provided sample database from Scott, L. (2022), Relational
   Database and SQL (3rd ed.), used in CISS 202 at Columbia College.
   Reformatted for readability; table definitions and data are unchanged.

   Run first. Safe to re-run: it drops and rebuilds the database.
   ============================================================================= */

USE master;
GO

IF DB_ID(N'LifeStyleDB') IS NOT NULL
BEGIN
    ALTER DATABASE LifeStyleDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LifeStyleDB;
END;
GO

CREATE DATABASE LifeStyleDB;
GO

USE LifeStyleDB;
GO

CREATE SCHEMA HR AUTHORIZATION dbo;
GO
CREATE SCHEMA Sales AUTHORIZATION dbo;
GO
CREATE SCHEMA Purchasing AUTHORIZATION dbo;
GO

/* ---------- Tables ---------- */

CREATE TABLE Sales.Customers
(
    CustomerId     INT           NOT NULL IDENTITY,
    CustomerName   NVARCHAR(50)  NOT NULL,
    StreetAddress  NVARCHAR(50)  NULL,
    City           NVARCHAR(20)  NULL,
    [State]        NVARCHAR(20)  NULL,
    PostalCode     NVARCHAR(10)  NULL,
    Country        NVARCHAR(20)  NULL,
    Contact        NVARCHAR(50)  NULL,
    Email          NVARCHAR(50)  NULL,
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerId)
);

CREATE TABLE HR.Employees
(
    EmployeeId   INT           NOT NULL IDENTITY,
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    BirthDate    DATE          NOT NULL,
    HireDate     DATE          NOT NULL,
    HomeAddress  NVARCHAR(50)  NULL,
    City         NVARCHAR(20)  NULL,
    [State]      NVARCHAR(20)  NULL,
    PostalCode   NVARCHAR(10)  NULL,
    Phone        NVARCHAR(20)  NULL,
    ManagerId    INT           NULL,
    CONSTRAINT PK_Employees PRIMARY KEY (EmployeeId),
    CONSTRAINT FK_Employees_Employees FOREIGN KEY (ManagerId)
        REFERENCES HR.Employees (EmployeeId),
    CONSTRAINT CHK_BirthDate CHECK (BirthDate <= CAST(SYSDATETIME() AS DATE)),
    CONSTRAINT CHK_HireDate  CHECK (BirthDate < HireDate)
);

CREATE TABLE Purchasing.Suppliers
(
    SupplierId     INT           NOT NULL IDENTITY,
    SupplierName   NVARCHAR(50)  NOT NULL,
    StreetAddress  NVARCHAR(50)  NULL,
    City           NVARCHAR(20)  NULL,
    [State]        NVARCHAR(20)  NULL,
    PostalCode     NVARCHAR(10)  NULL,
    Country        NVARCHAR(20)  NULL,
    CONSTRAINT PK_Supplier PRIMARY KEY (SupplierId)
);

CREATE TABLE Purchasing.Products
(
    ProductId    INT           NOT NULL IDENTITY,
    ProductName  NVARCHAR(40)  NOT NULL,
    SupplierId   INT           NOT NULL,
    CONSTRAINT PK_Products PRIMARY KEY (ProductId),
    CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierId)
        REFERENCES Purchasing.Suppliers (SupplierId)
);

CREATE TABLE Purchasing.Deliveries
(
    DeliveryId    INT        NOT NULL IDENTITY,
    ProductId     INT        NOT NULL,
    Quantity      INT        NOT NULL,
    Price         MONEY      NOT NULL CONSTRAINT DF_Deliveries_Price DEFAULT (0),
    DeliveryDate  DATETIME2  NOT NULL CONSTRAINT DF_Deliveries_DeliveryDate DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_Deliveries PRIMARY KEY (DeliveryId),
    CONSTRAINT FK_Deliveries_Products FOREIGN KEY (ProductId)
        REFERENCES Purchasing.Products (ProductId),
    CONSTRAINT CHK_Deliveries_Price CHECK (Price >= 0)
);

CREATE TABLE Sales.Orders
(
    OrderId     INT   NOT NULL IDENTITY,
    CustomerId  INT   NOT NULL,
    EmployeeId  INT   NOT NULL,
    OrderDate   DATE  NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY (OrderId),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId)
        REFERENCES Sales.Customers (CustomerId),
    CONSTRAINT FK_Orders_Employees FOREIGN KEY (EmployeeId)
        REFERENCES HR.Employees (EmployeeId)
);

CREATE TABLE Sales.OrderDetails
(
    OrderId    INT       NOT NULL,
    ProductId  INT       NOT NULL,
    Price      MONEY     NOT NULL CONSTRAINT DF_OrderDetails_Price DEFAULT (0),
    Quantity   SMALLINT  NOT NULL CONSTRAINT DF_OrderDetails_Qty DEFAULT (1),
    CONSTRAINT PK_OrderDetails PRIMARY KEY (OrderId, ProductId),
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderId)
        REFERENCES Sales.Orders (OrderId),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductId)
        REFERENCES Purchasing.Products (ProductId),
    CONSTRAINT CHK_Quantity CHECK (Quantity > 0),
    CONSTRAINT CHK_Price    CHECK (Price >= 0)
);
GO

/* ---------- Data ---------- */

SET IDENTITY_INSERT Sales.Customers ON;
INSERT INTO Sales.Customers (CustomerId, CustomerName, StreetAddress, City, [State], PostalCode, Country, Contact, Email)
VALUES
    (1, N'Just Electronics',   N'123 Broad way',      N'New York',    N'NY',      N'12012',    N'USA',    N'John White',    N'jwhite@je.com'),
    (2, N'Beyond Electronics', N'45 Cherry Street',   N'Chicago',     N'IL',      N'32302',    N'USA',    N'Scott Green',   N'green@beil.com'),
    (3, N'Beyond Electronics', N'6767 GameOver Blvd', N'Atlanta',     N'GA',      N'43347',    N'USA',    N'Alice Black',   N'black1@be.com'),
    (4, N'E Fun',              N'888  Main Ave.',     N'Seattle',     N'WA',      N'69356',    N'USA',    N'Ben Gold',      N'bgold@efun.com'),
    (5, N'Overstock E',        N'39 Garden Place',    N'Los Angeles', N'CA',      N'32302',    N'USA',    N'Daniel Yellow', N'dy@os.com'),
    (6, N'E Fun',              N'915 Market st.',     N'London',      N'England', N'EC1A 1BB', N'UK',     N'Frank Green',   N'green@ef.com'),
    (7, N'Electronics4U',      N'27 Colmore Row',     N'Birmingham',  N'England', N'B3 2EW',   N'UK',     N'Grace Smith',   N'smith@e4u.com'),
    (8, N'Cheap Electronics',  N'1010 Easy St',       N'Ottawa',      N'Ontario', N'K1A 0B1',  N'Canada', NULL,             NULL);
SET IDENTITY_INSERT Sales.Customers OFF;

SET IDENTITY_INSERT HR.Employees ON;
INSERT INTO HR.Employees (EmployeeId, FirstName, LastName, BirthDate, HireDate, HomeAddress, City, [State], PostalCode, Phone, ManagerId)
VALUES
    (1, N'Alex',      N'Hall',     '19900203', '20150809', N'85 Main Ln',            N'New Canton', N'VA', N'23123', N'(434) 290-3322', NULL),
    (2, N'Dianne',    N'Hart',     '19781203', '20100801', N'209 Social Hall Blvd',  N'New Canton', N'VA', N'23123', N'(434) 290-1122', 1),
    (3, N'Maria',     N'Law',      '19880713', '20120821', N'258 Blinkys St',        N'New Canton', N'VA', N'23123', N'(434) 531-5673', 1),
    (4, N'Alice',     N'Law',      '19881213', '20120422', N'300 Vista Valley Blvd', N'Buckingham', N'VA', N'23123', N'(434) 531-1010', 1),
    (5, N'Black',     N'Hart',     '19821109', '20150412', N'1 Old Fifteen St',      N'Buckingham', N'VA', N'23123', N'(434) 531-1034', 2),
    (6, N'Christina', N'Robinson', '19780713', '20140615', N'217 Chapel St',         N'New Canton', N'VA', N'23123', NULL,              2),
    (7, N'Nicholas',  N'Pinkston', '19771005', '20130522', N'26 N James Madison Rd', N'Buckingham', N'VA', N'23123', NULL,              3);
SET IDENTITY_INSERT HR.Employees OFF;

SET IDENTITY_INSERT Purchasing.Suppliers ON;
INSERT INTO Purchasing.Suppliers (SupplierId, SupplierName, StreetAddress, City, [State], PostalCode, Country)
VALUES
    (1, N'Pine Apple', N'1 Pine Apple St.',       N'Idanha',      N'CA',      N'87201',    N'USA'),
    (2, N'IMB',        N'123 International Blvd', N'Los Angeles', N'CA',      N'89202',    N'USA'),
    (3, N'Lonovo',     N'33 Beijin Square',       N'Beijing',     N'Beijing', N'100201',   N'China'),
    (4, N'Samsong',    N'1 Electronics Road',     N'Yeongtong',   N'Suwon',   N'30174',    N'South Korea'),
    (5, N'Canan',      N'12 Camera St',           N'Ota',         N'Tokyo',   N'100-0121', N'Japan');
SET IDENTITY_INSERT Purchasing.Suppliers OFF;

SET IDENTITY_INSERT Purchasing.Products ON;
INSERT INTO Purchasing.Products (ProductId, ProductName, SupplierId)
VALUES
    (1, N'65-Inch 4K Ultra HD Smart TV',           4),
    (2, N'60-Inch 4K Ultra HD Smart LED TV',       4),
    (3, N'3200 Lumens LED Home Theater Projector', 3),
    (4, N'Wireless Color Photo Printer',           5),
    (5, N'6Wireless Compact Laser Printer',        2),
    (6, N'Color Laser Printer',                    2),
    (7, N'10" 16GB Android Tablet',                4),
    (8, N'GPS Android Tablet PC',                  2),
    (9, N'20.2 MP Digital Camera',                 5);
SET IDENTITY_INSERT Purchasing.Products OFF;

SET IDENTITY_INSERT Purchasing.Deliveries ON;
INSERT INTO Purchasing.Deliveries (DeliveryId, ProductId, Quantity, Price, DeliveryDate)
VALUES
    (1, 1,  2, 1099.99, '20161001 09:30'),
    (2, 1,  5, 1199.99, '20161101 10:20'),
    (3, 2, 10, 1199.99, '20161002 11:10'),
    (4, 3, 10,  129.99, '20161005 09:15'),
    (5, 4, 20,   79.99, '20161007 14:00'),
    (6, 5, 15,  139.99, '20161007 15:30'),
    (7, 6, 25,  169.99, '20161010 10:30'),
    (8, 7, 12,   79.99, '20161011 11:10'),
    (9, 7, 18,   69.99, '20161012 09:50');
SET IDENTITY_INSERT Purchasing.Deliveries OFF;

SET IDENTITY_INSERT Sales.Orders ON;
INSERT INTO Sales.Orders (OrderId, CustomerId, EmployeeId, OrderDate)
VALUES
    (1, 1, 5, '20170103'),
    (2, 1, 3, '20170305'),
    (3, 2, 5, '20170223'),
    (4, 4, 5, '20170413'),
    (5, 1, 4, '20170503'),
    (6, 3, 6, '20170508'),
    (7, 5, 7, '20161108'),
    (8, 7, 2, '20161223');
SET IDENTITY_INSERT Sales.Orders OFF;

INSERT INTO Sales.OrderDetails (OrderId, ProductId, Price, Quantity)
VALUES
    (1, 1, 1499.99, 1), (1, 3,  149.99, 2),
    (2, 1, 1499.99, 1), (2, 4,   99.99, 6), (2, 6, 189.99, 5), (2, 2, 1599.99, 1),
    (3, 6,  199.99, 1), (3, 7,  109.99, 2), (3, 8,  69.99, 2), (3, 3,  159.99, 2), (3, 9, 1449.99, 1),
    (4, 8,   69.99, 1), (4, 4,   99.99, 2),
    (5, 6,  199.99, 3), (5, 3,  149.99, 6),
    (6, 1, 1499.99, 1),
    (7, 2,  999.99, 1),
    (8, 7,   79.99, 1), (8, 8,   59.99, 2);
GO

PRINT 'LifeStyleDB created and loaded.';
