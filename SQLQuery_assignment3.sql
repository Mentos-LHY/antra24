--All scenarios are based on Database NORTHWIND.

--1.      List all cities that have both Employees and Customers.

SELECT c.city, c.Country
FROM
(
SELECT DISTINCT City, Country
FROM Customers
) c INNER JOIN Employees e ON c.City = e.City AND c.Country = e.Country
--WHERE e.City IS NOT NULL -- for LEFT JOIN

--2.      List all cities that have Customers but no Employee.

--a.      Use sub-query

--1.
SELECT DISTINCT City, Country
FROM Customers
WHERE City + Country NOT IN (
    SELECT DISTINCT City + Country
    FROM Employees
)

--2.
SELECT DISTINCT c.City, c.Country
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM Employees e
    WHERE e.City = c.City AND e.Country = c.Country
)

--b.      Do not use sub-query

SELECT DISTINCT c.City, c.Country
FROM Customers c LEFT JOIN Employees e ON c.City = e.City AND c.Country = e.Country
WHERE e.City IS NULL AND e.Country IS NULL
;

--3.      List all products and their total order quantities throughout all orders.

SELECT p.ProductName, od.[Total Order Quantities]
FROM
(
SELECT ProductID, SUM(Quantity) AS [Total Order Quantities]
FROM [Order Details]
GROUP BY ProductID
) od JOIN Products p on od.ProductID = p.ProductID

--4.      List all Customer Cities and total products ordered by that city.

SELECT c.City, ct.[Total Products Ordered]
FROM
(
SELECT o.CustomerID, SUM(od.quantity) AS [Total Products Ordered]
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
) ct JOIN Customers c ON ct.CustomerID = c.CustomerID

--5.      List all Customer Cities that have at least two customers.

--a.      Use union

-- I don't understand the meaning to use UNION here
-- how to do that?


--b.      Use sub-query and no union

SELECT n.City
FROM
(
SELECT City, COUNT(CustomerID) AS NumOfCustomer
FROM Customers
GROUP BY City
) n
WHERE n.NumOfCustomer >= 2

--6.      List all Customer Cities that have ordered at least two different kinds of products.

SELECT c.City, COUNT(od.ProductID) AS ProductKinds
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City
HAVING COUNT(od.ProductID) > 1

--7.      List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.

SELECT DISTINCT c.CustomerID, c.CompanyName
FROM Orders o JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.ShipCity != c.City 

--8.      List 5 most popular products, their average price, and the customer city that ordered most quantity of it.

SELECT p.ProductName, dt.City, dt.AvePrice
FROM
(
SELECT od.ProductID, p5.AvePrice, c.City, SUM(od.Quantity) AS Quan, 
        RANK() OVER (PARTITION BY od.ProductID ORDER BY SUM(od.Quantity) DESC) AS RNK
FROM [Order Details] od 
JOIN (
    SELECT TOP 5 ProductID, AVG(UnitPrice) AS AvePrice
    FROM [Order Details]
    GROUP BY ProductID
    ORDER BY SUM(Quantity) DESC
) p5 ON od.ProductID = p5.ProductID 
JOIN Orders o ON od.OrderID = o.OrderID 
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY od.ProductID, p5.AvePrice, c.City
) dt
JOIN Products p ON dt.ProductID = p.ProductID
WHERE dt.RNK = 1

--9.      List all cities that have never ordered something but we have employees there.

--a.      Use sub-query

SELECT DISTINCT City
FROM Employees
WHERE City NOT IN
(   
    SELECT DISTINCT c1.City
    FROM Orders o
    JOIN Customers c1
    ON o.CustomerID = c1.CustomerID
)

--b.      Do not use sub-query

SELECT DISTINCT e.city
FROM Employees e
LEFT JOIN
Customers c ON e.City = c.City 
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL

--10.  List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)

-- I don't understand this question

SELECT co.ShipCity as City
FROM
(
SELECT TOP 1 ShipCity
FROM Orders
GROUP BY ShipCity
ORDER BY COUNT(OrderID) DESC
) co 
JOIN
(
SELECT TOP 1 ShipCity
FROM Orders o 
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY ShipCity
ORDER BY SUM(od.Quantity) DESC
) cp
ON co.ShipCity = cp.ShipCity

--11. How do you remove the duplicates record of a table?

--1 use temp table

SELECT DISTINCT * INTO #temp_table FROM original_table;

TRUNCATE TABLE original_table;
INSERT INTO original_table SELECT * FROM temp_table;
DROP TABLE temp_table;

--2 use a CTE

WITH DuplicateRecords AS (
    SELECT
        ID,
        ROW_NUMBER() OVER (
            PARTITION BY column1, column2, column3...
            ORDER BY ID
        ) AS RowNum
    FROM original_table
)
DELETE o
FROM original_table o
INNER JOIN DuplicateRecords d ON o.ID = d.ID
WHERE d.RowNum > 1;