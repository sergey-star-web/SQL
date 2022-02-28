---------------------------------------------------------------------
-- LAB 10
--
-- Exercise 2
---------------------------------------------------------------------

USE Kharkov;
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_10_PRJ\10774A_10_PRJ.ssmssln and the T-SQL script 61 - Lab Exercise 2.sql. Ensure that you are connected to the TSQL2012 database.
--
-- Write a SELECT statement to retrieve the productid and productname columns from the Production.Products table. 
--Filter the results to include only products that were sold in high quantities (more than 100 products) for a specific order line. 
--
-- Execute the written statement and compare the results that you got with the desired results shown in the file 62 - Lab Exercise 2 - Task 1 Result.txt.
---------------------------------------------------------------------
select p.productid, p.productname from Production.Products as p inner join Sales.OrderDetails as od on od.productid=p.productid inner join Sales.Orders AS o
on o.orderid=od.orderid
where od.qty>100
group by p.productid,p.productname
---------------------------------------------------------------------
-- Task 2
-- 
-- Write a SELECT statement to retrieve the custid and contactname columns from the Sales.Customers table. 
--Filter the results to include only those customers that do not have any placed orders.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 63 - Lab Exercise 2 - Task 2 Result.txt. Remember the number of rows in the result.
---------------------------------------------------------------------
select c.custid, contactname from Sales.Customers as c
WHERE NOT EXISTS (
	SELECT * 
	FROM Sales.Orders AS o
	WHERE c.custid=o.custid)
---------------------------------------------------------------------
-- Task 3
-- 
-- The IT department has written a T-SQL statement that inserts an additional row in the Sales.Orders table. This row has a NULL in the custid column.
--
-- Execute this query exactly as written inside a query window.
--
-- Copy the T-SQL statement you wrote in task 2 and execute it. 
--
-- Observe the result. How many rows are in the result? Why?
--
-- Modify the T-SQL statement to retrieve the same number of rows as in task 2. (Hint: You have to remove the rows with an unknown value in the custid column.)
--
-- Execute the modified statement and compare the results that you got with the recommended result shown in the file 64 - Lab Exercise 2 - Task 3 Result.txt.
---------------------------------------------------------------------

INSERT INTO Sales.Orders (
custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, 
shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
VALUES
(NULL, 1, '20111231', '20111231', '20111231', 1, 0, 
'ShipOne', 'ShipAddress', 'ShipCity', 'RA', '1000', 'USA')

GO

select c.custid, contactname from Sales.Customers as c
WHERE NOT EXISTS (
	SELECT * 
	FROM Sales.Orders AS o
	WHERE c.custid=o.custid)
