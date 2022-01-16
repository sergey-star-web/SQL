---------------------------------------------------------------------
-- LAB 09
--
-- Exercise 3
---------------------------------------------------------------------

USE Kharkov
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_09_PRJ\10774A_09_PRJ.ssmssln and the T-SQL script 71 - Lab Exercise 3.sql. Ensure that you are connected to the TSQL2012 database.
--
-- A junior analyst prepared a T-SQL statement to retrieve the number of orders and the number of customers for each order year. Observe the provided T-SQL statement and execute it:
--
-- Observe the result and notice that the number of orders is the same as the number of customers. Why?
--
-- Correct the T-SQL statement to show the correct number of customers that placed an order for each year.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 72 - Lab Exercise 3 - Task 1 Result.txt. 
---------------------------------------------------------------------

SELECT
	YEAR(orderdate) AS orderyear, 
	COUNT(orderid) AS nooforders, 
	count(DISTINCT o.custid) AS noofcustomers
FROM Sales.Orders as o
GROUP BY YEAR(orderdate)
order by YEAR(orderdate)
---------------------------------------------------------------------
-- Task 2
-- 
-- Write a SELECT statement to retrieve the number of customers based on the first letter
--of the values in the contactname column from the Sales.Customers table. Add an additional
--column to show the total number of orders placed by each group of customers. Use the aliases
--firstletter, noofcustomers and nooforders. Order the result by the firstletter column.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 73 - Lab Exercise 3 - Task 2 Result.txt.
---------------------------------------------------------------------
select substring(contactname,1,1) as firstletter, count(DISTINCT c.custid) AS noofcustomers,
COUNT(o.orderid) AS nooforders
from Sales.Customers as c left join Sales.Orders as o on c.custid=o.custid
group by substring(contactname,1,1)
order by substring(contactname,1,1)

---------------------------------------------------------------------
-- Task 3
-- 
-- Copy the T-SQL statement in exercise 1, task 4, and modify to include the following information about for
--each product category: total sales amount, number of orders, and average sales amount per order. Use the aliases
--totalsalesamount, nooforders, and avgsalesamountperorder, respectively.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 74 - Lab Exercise 3 - Task 3 Result.txt. 
---------------------------------------------------------------------
------------------------------------------------------------------------

select c.categoryid, c.categoryname, SUM(od.unitprice*od.qty) as totalsalesamount
 ,COUNT(distinct od.orderid) as nooforders ,SUM(od.unitprice*od.qty)/COUNT(distinct od.orderid) 
 as avgsalesamountperorder
from Production.Categories c inner join Production.Products p
on c.categoryid = p.categoryid
inner join Sales.OrderDetails od on p.productid = od.productid
inner join Sales.Orders o on o.orderid = od.orderid
where YEAR(o.orderdate) = '2008'
group by c.categoryid, c.categoryname
order by c.categoryid