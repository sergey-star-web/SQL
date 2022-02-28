---------------------------------------------------------------------
-- LAB 09
--
-- Exercise 2
---------------------------------------------------------------------

USE Kharkov;
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_09_PRJ\10774A_09_PRJ.ssmssln and the T-SQL script 61 - Lab Exercise 2.sql. Ensure that you are connected to the TSQL2012 database.
--
-- Write a SELECT statement to retrieve the orderid column from the Sales.Orders table and the total sales amount per orderid. (Hint: Multiply the qty and unitprice columns from the Sales.OrderDetails table.) Use the alias salesmount for the calculated column. Sort the result by the total sales amount in descending order.
--
-- Execute the written statement and compare the results that you got with the desired results shown in the file 62 - Lab Exercise 2 - Task 1 Result.txt.
---------------------------------------------------------------------
select o.orderid, o.orderdate, sum(od.qty*od.unitprice) as salesamount
from Sales.Orders as o join Sales.OrderDetails as od
on o.orderid=od.orderid 
group by o.orderid,o.orderdate,od.orderid
order by salesamount desc

---------------------------------------------------------------------
-- Task 2
-- 
-- Copy the T-SQL statement in task 1 and modify it to include the total number of order
--lines for each order and the average order line sales amount value within the order. Use 
--the aliases nooforderlines and avgsalesamountperorderline, respectively.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 63 - Lab Exercise 2 - Task 2 Result.txt. 
---------------------------------------------------------------------
select o.orderid, o.orderdate, sum(od.qty*od.unitprice) as salesamount, count(o.orderid) as nooforderlines,
sum(od.qty*od.unitprice)/count(o.orderid) as avgsalesamountperorderline
from Sales.Orders as o join Sales.OrderDetails as od
on o.orderid=od.orderid 
group by o.orderid,o.orderdate,od.orderid
order by salesamount desc

---------------------------------------------------------------------
-- Task 3
-- 
-- Write a select statement to retrieve the total sales amount for each month. The SELECT clause
--should include a calculated column named yearmonthno (YYYYMM notation) based on the orderdate 
--column in the Sales.Orders table and a total sales amount (multiply the qty and unitprice columns
--from the Sales.OrderDetails table). Order the result by the yearmonthno calculated column.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 64 - Lab Exercise 2 - Task 3 Result.txt.
---------------------------------------------------------------------
select str(year(o.orderdate))+right('0'+cast(month(o.orderdate) as varchar(2)),2) as yearmonthno, 
sum(od.qty*od.unitprice) as saleamountpermonth
from Sales.Orders as o, Sales.OrderDetails as od
where o.orderid=od.orderid
group by str(year(o.orderdate))+right('0'+cast(month(o.orderdate) as varchar(2)),2)

---------------------------------------------------------------------
-- Task 4
-- 
-- Write a select statement to retrieve all the customers (including those that did not place any orders) 
--and their total sales amount, maximum sales amount per order line, and number of order lines. 
--
-- The SELECT clause should include the custid and contactname columns from the Sales.Customers table 
--and four calculated columns based on appropriate aggregate functions:
--  totalsalesamount, representing the total sales amount per order
--  maxsalesamountperorderline, representing the maximum sales amount per order line
--  numberofrows, representing the number of rows (use * in the COUNT function)
--  numberoforderlines, representing the number of order lines (use the orderid column in the COUNT function)
--
-- Order the result by the totalsalesamount column.
--
-- Execute the written statement and compare the results that you got with the recommended result
--shown in the file 65 - Lab Exercise 2 - Task 4 Result.txt. 
--
-- Notice that the custid 22 and 57 rows have a NULL in the columns with the SUM and MAX aggregate functions. What are their values in the COUNT columns? Why are they different?
---------------------------------------------------------------------
select c.custid, contactname, sum(od.qty*od.unitprice) as totalsalesamount,
max(od.qty*od.unitprice) as maxsalesamountperorderline, count(*) as numberofrows,
count(o.orderid) as numberoforderlines
from Sales.Customers as c left join Sales.Orders as o on c.custid=o.custid 
left join Sales.OrderDetails as od on  o.orderid=od.orderid 
group by c.custid, c.contactname
order by c.custid

