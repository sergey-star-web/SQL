---------------------------------------------------------------------
-- LAB 14
--
-- Exercise 3
---------------------------------------------------------------------

USE Kharkov;
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_14_PRJ\10774A_14_PRJ.ssmssln and the T-SQL script 71 - Lab Exercise 3.sql. Ensure that you are connected to the TSQL2012 database.
--
-- Write a SELECT statement against the Sales.Customers table and retrieve the country column, the city column, and 
-- a calculated column noofcustomers as a count of customers. Retrieve multiple grouping sets based on the country and
-- city columns, the country column, the city column, and a column with an empty grouping set.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 72 - Lab Exercise 3 - Task 1 Result.txt. 
---------------------------------------------------------------------
select sc.country, sc.city, count(sc.custid) as noofcustomers from Sales.Customers as sc
group by 
GROUPING SETS((sc.country, sc.city),(sc.country),(sc.city),())
---------------------------------------------------------------------
-- Task 2
-- 
-- Write a SELECT statement against the view Sales.OrderValues and retrieve these columns:
--  Year of the orderdate column as orderyear
--  Month of the orderdate column as ordermonth
--  Day of the orderdate column as orderday
--  Total sales value using the val column as salesvalue
-- Return all possible grouping sets based on the orderyear, ordermonth, and orderday columns.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 73 - Lab Exercise 3 - Task 2 Result.txt. Notice the total number of rows in your results.
---------------------------------------------------------------------
select t1.orderyear, t1.ordermonth, t1.orderday, sum(t1.salesvalue) as salesvalue from(
select year(ov.orderdate) as orderyear, month(ov.orderdate) as ordermonth,
day(ov.orderdate) as orderday, ov.val as salesvalue
from Sales.OrderValues as ov) as t1
group by 
grouping sets ( (t1.orderyear, t1.ordermonth, t1.orderday), (t1.ordermonth, t1.orderday), (t1.orderyear, t1.orderday),
(t1.orderyear, t1.ordermonth), (t1.orderyear), (t1.ordermonth), (t1.orderday), ())

select t1.orderyear, t1.ordermonth, t1.orderday, sum(t1.salesvalue) as salesvalue from(
select year(ov.orderdate) as orderyear, month(ov.orderdate) as ordermonth,
day(ov.orderdate) as orderday, ov.val as salesvalue
from Sales.OrderValues as ov) as t1
group by cube (t1.orderyear, t1.ordermonth, t1.orderday)
---------------------------------------------------------------------
-- Task 3
-- 
-- Copy the previous query and modify it to use the ROLLUP subclause instead of the CUBE subclause.
--
-- Execute the modified query and compare the results that you got with the recommended result shown in the file 74 - Lab Exercise 3 - Task 3 Result.txt. Notice the number of rows in your results.
--
-- What is the difference between the ROLLUP and CUBE subclauses?
--
-- Which is the more appropriate subclause to use in this example?
---------------------------------------------------------------------
select t1.orderyear, t1.ordermonth, t1.orderday, sum(t1.salesvalue) as salesvalue from(
select year(ov.orderdate) as orderyear, month(ov.orderdate) as ordermonth,
day(ov.orderdate) as orderday, ov.val as salesvalue
from Sales.OrderValues as ov) as t1
group by rollup ( t1.orderyear, t1.ordermonth, t1.orderday)
---------------------------------------------------------------------
-- Task 4
-- 
-- Write a SELECT statement against the Sales.OrderValues view and retrieve these columns:
--  Calculated column with the alias groupid (use the GROUPING_ID function with the order year and order month as the input parameters)
--  Year of the orderdate column as orderyear
--  Month of the orderdate column as ordermonth
--  Total sales value using the val column as salesvalue.
-- Since year and month form a hierarchy, return all interesting grouping sets based on the orderyear and ordermonth columns
-- and sort the result by groupid, orderyear, and ordermonth.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 75 - Lab Exercise 3 - Task 4 Result.txt. 
---------------------------------------------------------------------
select GROUPING_ID(t1.orderyear, t1.ordermonth) as groupid, t1.orderyear, t1.ordermonth, sum(t1.val) as salesvalue from(
select year(ov.orderdate) as orderyear, month(ov.orderdate) as ordermonth,
ov.val from Sales.OrderValues as ov) as t1
group by rollup (t1.orderyear, t1.ordermonth)
order by GROUPING_ID(t1.orderyear, t1.ordermonth), t1.orderyear, t1.ordermonth