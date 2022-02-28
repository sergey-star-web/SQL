---------------------------------------------------------------------
-- LAB 13
--
-- Exercise 3
---------------------------------------------------------------------

USE Kharkov;
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_13_PRJ\10774A_13_PRJ.ssmssln and the T-SQL script 71 - Lab Exercise 3.sql. Ensure that you are connected to the TSQL2012 database.
--
-- Write a SELECT statement to retrieve the custid, orderid, orderdate, and val columns from the 
-- Sales.OrderValues view. Add a calculated column named percoftotalcust that contains a percentage
-- value of each order sales amount compared to the total sales amount for that customer. 
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 72 - Lab Exercise 3 - Task 1 Result.txt. 
---------------------------------------------------------------------
select ov.custid, ov.orderid, ov.orderdate, ov.val, ov.val*100/t1.salesamount  as percoftotalcust
from Sales.OrderValues as ov left join (select  ov.custid, sum(ov.val) as salesamount
from Sales.OrderValues as ov
group by ov.custid) as t1 on t1.custid = ov.custid
group by ov.custid, ov.orderid, ov.orderdate, ov.val, t1.salesamount 
order by ov.custid, sum(ov.val) desc
---------------------------------------------------------------------
-- Task 2
-- 
-- Copy the previous SELECT statement and modify it by adding a new calculated column named runval.
-- This column should contain a running sales total for each customer based on order date, using orderid as the tiebreaker.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 73 - Lab Exercise 3 - Task 2 Result.txt. 
---------------------------------------------------------------------
select ov.custid, ov.orderid, ov.orderdate, ov.val, ov.val*100/t1.salesamount  as percoftotalcust
, SUM(ov.val) OVER(PARTITION BY ov.custid
                ORDER BY orderid
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW)  as runval
from Sales.OrderValues as ov left join (select ov.custid, sum(ov.val) as salesamount
from Sales.OrderValues as ov
group by  ov.custid) as t1 on t1.custid = ov.custid
group by ov.custid, ov.orderid, ov.orderdate, ov.val, t1.salesamount
order by ov.custid, ov.orderdate
---------------------------------------------------------------------
-- Task 3
-- 
-- Copy the SalesMonth2007 CTE in the last task in exercise 2. Write a SELECT statement to retrieve the monthno and val columns.
-- Add two calculated columns:
--  avglast3months. This column should contain the average sales amount for last three months before the current month using 
-- a window aggregate function. You can assume that there are no missing months.
--  ytdval. This column should contain the cumulative sales value up to the current month.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 74 - Lab Exercise 3 - Task 3 Result.txt.
---------------------------------------------------------------------
with SalesMonth2007 AS(
select month(ov.orderdate) as monthno, ov.val
from Sales.OrderValues as ov
where year(ov.orderdate)=2007) 

select t2.monthno, t2.val, case when t2.rowno < 5 then t2.ytdval/t2.rowno else 
(t2.ytdval - lag(t2.ytdval,4) over (order by t2.monthno) )/4 
end as avglast3months, t2.ytdval from(
select t1.monthno, t1.salesamount as val,  
(SUM(t1.salesamount) OVER(ORDER BY monthno ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW)) as ytdval, row_number() over (order by t1.monthno) as rowno from 
(select sm1.monthno, sum(sm1.val) as salesamount from SalesMonth2007 as sm1  
group by sm1.monthno ) as t1) as t2