---------------------------------------------------------------------
-- LAB 13
--
-- Exercise 1
---------------------------------------------------------------------

USE Kharkov;
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_13_PRJ\10774A_13_PRJ.ssmssln and the T-SQL script 51 - Lab Exercise 1.sql. To set your database context to that of the TSQL2012 database, highlight the statement USE TSQL2012; and execute the highlighted code. After executing this statement, the TSQL2012 database should be selected in the Available Databases box. In subsequent exercises, you will simply be instructed to ensure that you are connected to the TSQL2012 database.
--
-- Write a SELECT statement to retrieve the orderid, orderdate, and val columns as well as a calculated
-- column named rowno from the view Sales.OrderValues. Use the ROW_NUMBER function to return rowno. Order
-- the row numbers by the orderdate column.
--
-- Execute the written statement and compare the results that you got with the desired results shown in the file 52 - Lab Exercise 1 - Task 1 Result.txt. 
---------------------------------------------------------------------
select ov.orderid, ov.orderdate, ov.val, ROW_NUMBER() OVER(ORDER BY ov.orderdate ASC) AS rowno 
from Sales.OrderValues as ov
---------------------------------------------------------------------
-- Task 2
-- 
-- Copy the previous T-SQL statement and modify it by including an additional column named rankno.
-- To create rankno, use the RANK function, with the rank order based on the orderdate column.
--
-- Execute the modified statement and compare the results that you got with the desired results shown in
-- the file 53 - Lab Exercise 1 - Task 2 Result.txt. Notice the different values in the rowno and rankno 
-- columns for some of the rows.
--
-- What is the difference between the RANK and ROW_NUMBER functions?
---------------------------------------------------------------------
select ov.orderid, ov.orderdate, ov.val, ROW_NUMBER() OVER(ORDER BY ov.orderdate ASC) AS rowno,
Rank() OVER(ORDER BY ov.orderdate ASC) AS rankno
from Sales.OrderValues as ov
---------------------------------------------------------------------
-- Task 3
-- 
-- Write a SELECT statement to retrieve the orderid, orderdate, custid, and val columns as well as
-- a calculated column named orderrankno from the Sales.OrderValues view. The orderrankno column should
-- display the rank per each customer independently, based on val ordering in descending order. 
--
-- Execute the written statement and compare the results that you got with the desired results shown in the file 54 - Lab Exercise 1 - Task 3 Result.txt. 
---------------------------------------------------------------------
select ov.orderid, ov.orderdate, ov.custid, ov.val, 
Rank() OVER(partition BY ov.custid ORDER BY ov.val desc,ov.custid asc) AS orderrankno 
from Sales.OrderValues as ov
---------------------------------------------------------------------
-- Task 4
-- 
-- Write a SELECT statement to retrieve the custid and val columns from the Sales.OrderValues view. 
--Add two calculated columns: 
--  orderyear as a year of the orderdate column 
--  orderrankno as a rank number, partitioned by the customer and order year, and ordered by the order value 
--in descending order. 
--
-- Execute the written statement and compare the results that you got with the desired results shown in the file 55 - Lab Exercise 1 - Task 4 Result.txt. 
---------------------------------------------------------------------
select ov.custid, ov.val, year(ov.orderdate) as orderyear, 
Rank() OVER(partition BY ov.custid, year(ov.orderdate) ORDER BY ov.val desc,ov.custid asc) AS orderrankno 
from Sales.OrderValues as ov
---------------------------------------------------------------------
-- Task 5
-- 
-- Copy the previous query and modify it to filter only orders with the first two ranks based on
--the orderrankno column.
--
-- Execute the written statement and compare the results that you got with the desired results shown in the file 56 - Lab Exercise 1 - Task 5 Result.txt. 
---------------------------------------------------------------------
select * from (select  ov.custid, year(ov.orderdate) as orderyear, ov.val,  
Rank() OVER(partition BY ov.custid, year(ov.orderdate) ORDER BY ov.val desc,ov.custid asc) AS orderrankno
from Sales.OrderValues as ov ) as t1
where t1.orderrankno<=2