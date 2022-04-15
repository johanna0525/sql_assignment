USE AdventureWorks2019
GO

--1
SELECT count(ProductID)
FROM Production.Product

--504 products totally.

--2
--1)
SELECT COUNT(*)
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
--2)
SELECT COUNT(ProductSubcategoryID)
FROM Production.Product

--answer:295

--3
SELECT ProductSubcategoryID, COUNT(*) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID

--4
SELECT COUNT(*)
FROM Production.Product
WHERE Product.ProductSubcategoryID IS NULL
--answer:209

--5
SELECT SUM(Quantity) 
FROM Production.ProductInventory
--answer:335974

--6
SELECT ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductId
HAVING SUM(Quantity) < 100

--7
SELECT p.Shelf, p.ProductID, t.TheSum
FROM Production.ProductInventory  AS p JOIN (SELECT ProductID, SUM(Quantity) AS TheSum
                                                   FROM Production.ProductInventory
                                                   WHERE LocationID = 40
                                                   GROUP BY ProductId
                                                   HAVING SUM(Quantity) < 100) AS t
    ON p.ProductID = t.ProductID 


--8
SELECT AVG(Quantity) 
FROM Production.ProductInventory
WHERE LocationID = 10 

--9
SELECT p.ProductID, P.Shelf, t.TheAvg
FROM Production.ProductInventory p JOIN  (SELECT Shelf, AVG(Quantity) as TheAvg
                                          FROM Production.ProductInventory
                                          GROUP BY Shelf) as t
    ON p.Shelf = t.Shelf
--10
SELECT p.ProductID, P.Shelf, t.TheAvg
FROM Production.ProductInventory p JOIN  (SELECT Shelf, AVG(Quantity) as TheAvg
                                          FROM Production.ProductInventory
                                          WHERE Shelf IS NOT NULL
                                          GROUP BY Shelf) as t
    ON p.Shelf = t.Shelf

--11
SELECT Color, Class, COUNT(Color) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product 
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class

--12
SELECT c.Name as Country, p.Name as Province
FROM person.CountryRegion c JOIN person.StateProvince p ON c.CountryRegionCode = p.CountryRegionCode

--13
SELECT c.Name as Country, p.Name as Province
FROM person.CountryRegion c JOIN person.StateProvince p ON c.CountryRegionCode = p.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')

USE Northwind
GO
--14
SELECT p.ProductID,ProductName
FROM Products p JOIN [Order Details] od ON P.ProductID = od.ProductID JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate > DATEADD(year, -25, GETDATE())

--15
SELECT TOP 5 o.ShipPostalCode AS ZipCode,SUM(od.UnitPrice*od.Quantity) AS TotalSales
FROM Products p JOIN [Order Details] od ON P.ProductID = od.ProductID JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY  o.ShipPostalCode
ORDER BY SUM(od.UnitPrice*od.Quantity) DESC

--16
SELECT TOP 5 o.ShipPostalCode AS ZipCode,SUM(od.UnitPrice*od.Quantity) AS TotalSales
FROM Products p JOIN [Order Details] od ON P.ProductID = od.ProductID JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate > DATEADD(year, -25, GETDATE())
GROUP BY  o.ShipPostalCode
ORDER BY SUM(od.UnitPrice*od.Quantity) DESC

--17
SELECT City, COUNT(CustomerID) as NumberOfCustomer
FROM dbo.Customers
GROUP BY City

--18
SELECT City, COUNT(CustomerID) as NumberOfCustomer
FROM dbo.Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2

--19
SELECT c.CompanyName
FROM dbo.Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE CONVERT(VARCHAR, o.OrderDate, 23) > 1998-01-01

--20
SELECT c.CompanyName
FROM dbo.Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate =(SELECT MIN(CONVERT(VARCHAR, OrderDate, 23)) FROM Orders)

--21
SELECT c.CompanyName, COUNT(DISTINCT od.ProductID) 
FROM dbo.Customers c JOIN  Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName

--22
SELECT c.CompanyName, COUNT(DISTINCT od.ProductID) 
FROM dbo.Customers c JOIN  Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName
HAVING COUNT(DISTINCT od.ProductID) > 100

--23
SELECT s.CompanyName [Supplier Company Name], sh.CompanyName [Shipping Company Name]
FROM Suppliers s JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN [Order Details] od ON p.ProductID = od.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Shippers sh ON o.ShipVia = sh.ShipperID
ORDER BY [Supplier Company Name]

--24
SELECT DISTINCT p.ProductName, CONVERT(VARCHAR, o.OrderDate, 23) AS OrderDate
FROM Products p JOIN [Order Details] od ON P.ProductID = od.ProductID JOIN Orders o ON od.OrderID = o.OrderID
ORDER BY OrderDATE DESC

--25

SELECT e1.EmployeeID,  e2.EmployeeID
FROM dbo.Employees e1 JOIN dbo.Employees e2 ON e1.Title = e2.Title
WHERE e1.EmployeeID != e2.EmployeeID
    AND e1.EmployeeID < e2.EmployeeID

--26
SELECT e.EmployeeID, e.FirstName, e.LastName
FROM dbo.Employees  e JOIN (SELECT ReportsTo 
                            FROM dbo.Employees
                            GROUP BY ReportsTo
                            HAVING COUNT(ReportsTo) > 2) AS t
    ON e.EmployeeID = t.ReportsTo

--27
SELECT City, CompanyName AS Name, ContactName AS [Contact Name], 'Customer' AS Type
FROM dbo.Customers

UNION

SELECT City, CompanyName AS Name, ContactName AS [Contact Name], 'Supplier' AS Type
FROM Suppliers
