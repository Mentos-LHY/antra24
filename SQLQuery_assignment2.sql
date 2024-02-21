USE AdventureWorks2019
GO
-- 1. How many products can you find in the Production.Product table?
--504
SELECT COUNT(DISTINCT ProductID)
FROM Production.Product

-- 2. Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory. 
--The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.

SELECT ProductSubcategoryID, COUNT(ProductID) AS SUM
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID

--3. How many Products reside in each SubCategory? Write a query to display the results with the following titles.

ProductSubcategoryID CountedProducts

-------------------- ---------------

SELECT ProductSubcategoryID, COUNT(ProductID) AS CountedProducts
FROM Production.Product
--WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID


--4. How many products that do not have a product subcategory.
--209

--5. Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT SUM(Quantity) as Sum
SELECT *
FROM Production.ProductInventory

--6. Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100.

              ProductID    TheSum

              -----------        ----------

SELECT ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100

-- 7. Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100

    Shelf      ProductID    TheSum

    ----------   -----------        -----------
SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100


-- 8. Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table.
SELECT AVG(Quantity)
FROM Production.ProductInventory
WHERE LocationID = 10


-- 9. Write query  to see the average quantity  of  products by shelf  from the table Production.ProductInventory

    ProductID   Shelf      TheAvg

    ----------- ---------- -----------
SELECT ProductID, shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, shelf


-- 10. Write query  to see the average quantity  of  products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory

    ProductID   Shelf      TheAvg

    ----------- ---------- -----------
SELECT ProductID, shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE shelf != 'N/A'
GROUP BY ProductID, shelf


-- 11. List the members (rows) and average list price in the Production.Product table. This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.

    Color                        Class              TheCount          AvgPrice

    --------------------    -----------            ---------------------
SELECT *
FROM Production.ProductInventory
SELECT *
FROM Production.Product

SELECT Color, Class, SUM(Quantity) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.ProductInventory p1 INNER JOIN Production.Product p2 ON p1.ProductID = p2.ProductID
WHERE Color IS NOT NULL
AND Class IS NOT NULL
GROUP BY Color, Class

-- how to write it in subquery
SELECT Color, Class, SUM(Quantity) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.ProductInventory p1 INNER JOIN 
(SELECT ProductID, Color, Class, ListPrice
FROM Production.Product
WHERE Color IS NOT NULL 
AND Class IS NOT NULL
) p2 ON p1.ProductID = p2.ProductID
GROUP BY Color, Class

Joins:

-- 12. Write a query that lists the country and province names from person.CountryRegion and person.StateProvince tables. Join them and produce a result set similar to the following.

    Country                        Province

    ---------                      ----------------------
SELECT *
FROM Person.CountryRegion
SELECT *
FROM Person.StateProvince

SELECT c.Name AS Country, s.Name AS Province
FROM Person.CountryRegion c INNER JOIN Person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode

-- 13. Write a query that lists the country and province names from person.CountryRegion and person.StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.

    Country                        Province

    ---------                          ----------------------

SELECT c.Name AS Country, s.Name AS Province
FROM Person.CountryRegion c INNER JOIN Person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')
ORDER BY Country, Province


--Using Northwnd Database: (Use aliases for all the Joins)
USE Northwind
GO
-- 14. List all Products that has been sold at least once in last 26 years.
SELECT *
FROM Products
SELECT *
FROM Orders
SELECT *
FROM [Order Details]

1.
SELECT DISTINCT p.ProductName AS Name
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON od.ProductID = p.ProductID
WHERE o.OrderDate >= DATEADD(YEAR, -26, GETDATE())

2.
WITH O_date AS (
    SELECT OrderID
    FROM Orders
    WHERE OrderDate >= DATEADD(YEAR, -26, GETDATE())
)

SELECT DISTINCT p.ProductName AS Name
FROM O_date o JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON od.ProductID = p.ProductID

-- 15. List top 5 locations (Zip Code) where the products sold most.

SELECT TOP 5 o.ShipPostalCode, SUM(od.Quantity) AS ProductSum
FROM (
SELECT OrderID, ShipPostalCode
FROM Orders
WHERE ShipPostalCode IS NOT NULL
) o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.ShipPostalCode
ORDER BY ProductSum DESC

-- 16. List top 5 locations (Zip Code) where the products sold most in last 26 years.

SELECT TOP 5 o.ShipPostalCode, SUM(od.Quantity) AS ProductSum
FROM (
SELECT OrderID, ShipPostalCode
FROM Orders
WHERE ShipPostalCode IS NOT NULL
AND OrderDate >= DATEADD(YEAR, -26, GETDATE())
) o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.ShipPostalCode
ORDER BY ProductSum DESC

-- 17. List all city names and number of customers in that city.

SELECT City, COUNT(CustomerID) AS NumberOfCustomers
FROM Customers
GROUP BY City, Country

-- 18. List city names which have more than 2 customers, and number of customers in that city

SELECT City, COUNT(CustomerID) AS NumberOfCustomers
FROM Customers
GROUP BY City, Country
HAVING COUNT(CustomerID) > 2

-- 19. List the names of customers who placed orders after 1/1/98 with order date.

SELECT c.CompanyName
FROM Customers c
JOIN (
    SELECT DISTINCT CustomerID
    FROM Orders
    WHERE OrderDate > '1998-01-01'
) o ON c.CustomerID = o.CustomerID
ORDER BY c.CompanyName


-- 20. List the names of all customers with most recent order dates

SELECT c.CompanyName, o.MostRecentOrderDate
FROM Customers c
JOIN (
    SELECT CustomerID, MAX(OrderDate) AS MostRecentOrderDate
    FROM Orders
    GROUP BY CustomerID
) o ON c.CustomerID = o.CustomerID
ORDER BY c.CompanyName

-- 21. Display the names of all customers  along with the count of products they bought

SELECT c.CompanyName, t.Count
FROM Customers c
JOIN (
SELECT o.CustomerID, SUM(od.Quantity) AS Count
FROM Orders o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
) t ON c.CustomerID = t.CustomerID
ORDER BY c.CompanyName

-- 22. Display the customer ids who bought more than 100 Products with count of products.

SELECT o.CustomerID, SUM(od.Quantity) AS Count
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
HAVING SUM(od.Quantity) > 100
ORDER BY CustomerID


-- 23. List all of the possible ways that suppliers can ship their products. Display the results as below

    Supplier Company Name                Shipping Company Name

    ---------------------------------            ----------------------------------
---- I don't know what this question is asking for
1---
SELECT su.CompanyName as [Supplier Company Name], sh.CompanyName as [Shipping Company Name]
FROM Suppliers su CROSS JOIN Shippers sh
ORDER BY su.CompanyName

2---
WITH Sup AS
(
SELECT DISTINCT p.SupplierID, s.Shipvia
FROM
(
SELECT od.ProductID, o.ShipVia
FROM Orders o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
) s INNER JOIN Products p ON s.ProductID = p.ProductID
)

SELECT su.CompanyName as [Supplier Company Name], sh.CompanyName as [Shipping Company Name]
FROM Sup s JOIN Suppliers su ON s.SupplierID = su.SupplierID JOIN Shippers sh ON s.ShipVia = sh.ShipperID
ORDER BY [Supplier Company Name]
-- 24. Display the products order each day. Show Order date and Product Name.

SELECT o.OrderDate, p.ProductName
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderDate

-- 25. Displays pairs of employees who have the same job title.

SELECT e1.EmployeeID, e2.EmployeeID
FROM Employees e1 JOIN Employees e2 ON e1.Title = e2.Title
Where e1.EmployeeID < e2.EmployeeID


-- 26. Display all the Managers who have more than 2 employees reporting to them.

SELECT FirstName + ' ' + LastName AS ManagerName
FROM Employees
WHERE EmployeeID in (
SELECT ID
FROM
(
SELECT e1.EmployeeID AS ID, COUNT(e2.EmployeeID) AS SUM
FROM Employees e1 LEFT JOIN Employees e2 ON e1.EmployeeID = e2.ReportsTo
GROUP BY e1.EmployeeID
HAVING COUNT(e2.EmployeeID) > 2
) t
);

----- a revised version
SELECT m.FirstName + ' ' + m.LastName AS ManagerName
FROM Employees e
INNER JOIN Employees m ON e.ReportsTo = m.EmployeeID
GROUP BY m.EmployeeID, m.FirstName, m.LastName
HAVING COUNT(e.EmployeeID) > 2;


-- 27. Display the customers and suppliers by city. The results should have the following columns

City

Name
--
Contact Name

Type (Customer or Supplier)


SELECT City, CompanyName AS Name, ContactName AS [Contact Name], 'Customer' AS Type
FROM Customers
UNION ALL
SELECT City, CompanyName AS Name, ContactName AS [Contact Name], 'Supplier' AS Type
FROM Suppliers
ORDER BY City, Name, [Contact Name]
