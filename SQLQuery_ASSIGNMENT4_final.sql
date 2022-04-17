USE Northwind
GO

--1  Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product
CREATE VIEW view_product_order_wang
AS
SELECT p.ProductID, p.ProductName,t.TotalQuantity
FROM Products p JOIN (SELECT pd.ProductID, ISNULL(SUM(Quantity) , 0)TotalQuantity
                      FROM Products pd LEFT JOIN [Order Details] od ON pd.ProductID = od.ProductID
					  GROUP BY pd.ProductID) t
    ON p.ProductID = t.ProductID

--2 Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter

CREATE PROC sp_product_order_quantity_wang
@id int,
@total int out
AS
BEGIN
SELECT @total = t.TotalOrders
FROM (SELECT ProductID,COUNT(OrderID) TotalOrders
      FROM [Order Details]
	  GROUP BY ProductID) t
WHERE t.ProductID = @id
END

BEGIN
declare @to int
exec sp_product_order_quantity_wang 11,@to out
print @to
END


--3 Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and 
-----top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
------ for city
CREATE PROC sp_product_order_city_wang_citytest
@name varchar(20)
AS
BEGIN
SELECT t3.ProductID,t3.ProductName,t3.City, t3.TotalQuantity
FROM(SELECT t2.City, t2.ProductID,t2.ProductName, t2.TotalQuantity
     FROM (SELECT t.City, t.ProductID, t.ProductName, t.TotalQuantity, DENSE_RANK() OVER(PARTITION BY ProductID ORDER BY TotalQuantity DESC) rnk
	       FROM (SELECT c.City, p.ProductID, p.ProductName, SUM(od.Quantity) TotalQuantity
		         FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID Join Products p 
				     ON od.ProductID = p.ProductID
				 GROUP BY c.City, p.ProductID,p.ProductName) t) t2
	 WHERE rnk <= 5) t3
WHERE ProductName = @name
END

--test
exec sp_product_order_city_wang_citytest 'Chai'


--4 Create 2 new tables “people_your_last_name” “city_your_last_name”. City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. 
-----People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}
----- Remove city of Seattle. If there was anyone from Seattle, put them into a new city “Madison”. Create a view “Packers_your_name” lists all people 
------from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
--create city table
CREATE TABLE City_wang1(
Id int PRIMARY KEY,
City varchar(20))

INSERT INTO City_wang1
VALUES
(1, 'Seattle'), (2, 'Green Bay')

SELECT * FROM City_wang1

---Create people table

CREATE TABLE People_wang1(
id int PRIMARY KEY,
Name varchar(20),
City int FOREIGN KEY REFERENCES City_wang1(Id) ON DELETE SET NULL)

INSERT INTO People_wang1
VALUES
(1, 'Aaron Rodgers', 2), (2,'Russel Wilson', 1), (3, 'Jody Nelson', 2)

SELECT * FROM People_wang1
---Remove city of Seattle
DELETE FROM City_wang1
WHERE City = 'Seattle'

SELECT * FROM City_wang1
SELECT * FROM People_wang1
---set null(which was 'Seattle' before beding deleted from parent table) to Madison
---INSERT INTO city table new value(3, 'Madison')
INSERT INTO City_wang1
VALUES
(3, 'Madison')
SELECT * FROM City_wang1
UPDATE People_wang1
SET City = 3
WHERE City IS NULL

SELECT *FROM People_wang1

--create view which lists all people from Green Bay
CREATE VIEW Packers_hw
AS
SELECT p.id, p.Name
FROM People_wang1 p JOIN City_wang1 c ON p.City = c.Id
WHERE c.City = 'Green Bay'

SELECT * FROM Packers_hw
---drop table and view
---1)drop table
DROP TABLE City_wang1
SELECT * FROM City_wang1

DROP TABLE People_wang1
SELECT *FROM People_wang1
---2)drop view 
DROP VIEW Packers_hw
SELECT * FROM Packers _hw

--5 Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and 
----fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected
CREATE PROC sp_birthday_employees_wang
AS
BEGIN
SELECT *
FROM Employees
WHERE MONTH(BirthDate) = '02'
END

EXEC sp_birthday_employees_wang 

CREATE TABLE birth_day_employees_wang
(EmployeeID INT PRIMARY KEY,
LastName nvarchar(20) not null,
FirstName  nvarchar(20) not null,
Title  nvarchar(30)  null,
TitleOfCourtesy  nvarchar(25) null,
BirthDate datetime null,
HireDate datetime null,
Address  nvarchar(60) null,
City  nvarchar(15) null,
Region  nvarchar(15) null,
PostalCode  nvarchar(10) null,
Country  nvarchar(15) null,
HomePhone  nvarchar(24) null,
Extension  nvarchar(4) null,
Photo image null,
Notes ntext null,
ReportsTo int null,
photoPath  nvarchar(255) null)

INSERT INTO birth_day_employees_wang
EXEC sp_birthday_employees_wang

SELECT * FROM birth_day_employees_wang




--6 How do you make sure two tables have the same data?
--1)method 1
----We can use except and union together. For example, we have two tables A and B. we can use the query below. After executing the query,
----if there is no record in the result, it means A and B are the same; or else it means A is different from B.
----------(SELECT * FROM A
--------------EXCEPT
---------- SELECT * FROM B)
--------------UNION
-----------(SELECT * FROM B
--------------EXCEPT
------------SELECT * FROM A)
----2)method 2
----We can also use left join and union together .For example,we have two tables A and B. We can use the query below.After excecuting the query, 
----if there is no record in the result, it means A and B are the same; or esle it means A is different from B.
-----------(SELECT * 
-----------FROM A LEFT JOIN B ON A.Column_x = B.Column_y
-----------WHERE B.Column_y IS NULL)
---------------UNION
------------(SELECT *
-------------FROM B LEFT JOIN A ON B.Column_y = A.Colunm_x
-------------WHERE A.Column_x IS NULL)      

--


