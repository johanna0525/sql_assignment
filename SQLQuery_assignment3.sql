USE Northwind
GO
--1
SELECT DISTINCT e.City
FROM Employees e JOIN Customers c ON e.City = c.City

--2
--1)Use sub-query
SELECT City
FROM Customers
WHERE City NOT IN (SELECT DISTINCT City FROM Employees)

--2)Not use sub_query
SELECT c.City
FROM Customers c LEFT JOIN Employees e ON c.City = e.City
WHERE e.City IS NULL

--3
SELECT p.ProductID,p.ProductName, ISNULL(SUM(od.Quantity), 0) TotalQuantities
FROM Products p LEFT JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductID,p.ProductName

--4
SELECT c.City, ISNULL(COUNT(DISTINCT od.ProductID),0) TotalProducts
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = O.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City

--5List all Customer cities that at least has 2 customers
--1)Use UNION
SELECT City 
FROM Customers
EXCEPT
(
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) = 1
UNION
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) = 2
)

--2)Use Sub-query and no UNION
SELECT DISTINCT City
FROM Customers
WHERE City IN(SELECT City 
              FROM Customers 
			  GROUP BY City
			  HAVING COUNT(CustomerID) >2)

--6 List all Customer Cities that have ordered at least two different kinds of products.
SELECT City
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City
HAVING COUNT(DISTINCT od.ProductID) >= 2

--7  List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.
SELECT DISTINCT c.CustomerID
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City <> o.ShipCity

--8 List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
WITH cte_Top5_Avg 
AS
(
SELECT p.ProductID, AVG(p.UnitPrice) over() AvgPrice
FROM Products p JOIN (SELECT TOP 5 ProductID, SUM(Quantity) TotalSales
                      FROM [Order Details]
                      GROUP BY ProductID
                      ORDER BY TotalSales DESC) t
    ON p.ProductID = t.ProductID
),

cte2
AS
(
SELECT cte.ProductID, cte.AvgPrice, c.City, SUM(od.Quantity) OVER(PARTITION BY c.City) SumSales
FROM cte_Top5_Avg cte JOIN [Order Details] od ON cte.ProductID = od.ProductID JOIN Orders o ON od.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID
)

SELECT ProductID, AvgPrice, City
FROM (SELECT ProductID, AvgPrice, City,DENSE_RANK() OVER(ORDER BY SumSales DESC ) rnk
      FROM cte2) t2
WHERE rnk <= 5

--9  List all cities that have never ordered something but we have employees there.
--1)Use sub-query
SELECT City
FROM Employees
WHERE City NOT IN (SELECT c.City
                   FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID)

--2）No sub-query
SELECT e.City
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID RIGHT JOIN Employees e ON c.City = e.City
WHERE c.City IS NULL

--10) List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is,
    --and also the city of most total quantity of products ordered from. (tip: join  sub-query)

WITH cte1
AS
(
SELECT c.City, COUNT(o.OrderID) TotalOrders
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.City),

cte2
AS
(
SELECT City
FROM cte1
WHERE TotalOrders =(SELECT MAX(TotalOrders) FROM cte1)
),
cte3 
AS
(
SELECT c.City, SUM(od.Quantity) TotalQuantity
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City
),

cte4
AS
(
SELECT City 
FROM cte3
WHERE TotalQuantity = (SELECT MAX(TotalQuantity) FROM cte3))

SELECT City 
FROM cte2
WHERE City IN (SELECT City FROM cte4)

--11)How do you remove the duplicates record of a table?
--1) Using "select distinct"
--2)Using "Windonw function(row_number()), select...where row_number = 1


