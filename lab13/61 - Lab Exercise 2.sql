---------------------------------------------------------------------
-- LAB 13
--
-- Exercise 2
---------------------------------------------------------------------

USE Kharkov;
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_13_PRJ\10774A_13_PRJ.ssmssln and the T-SQL script 61 - Lab Exercise 2.sql. Ensure that you are connected to the TSQL2012 database.
--
-- Define a CTE named OrderRows based on a query that retrieves the orderid, orderdate, and val columns 
-- from the Sales.OrderValues view. Add a calculated column named rowno using the ROW_NUMBER function, 
-- ordering by the orderdate and orderid columns. 
--
-- Write a SELECT statement against the CTE and use the LEFT JOIN with the same CTE to retrieve the
-- current row and the previous row based on the rowno column. Return the orderid, orderdate, and val 
-- columns for the current row and the val column from the previous row as prevval. Add a calculated 
-- column named diffprev to show the difference between the current val and previous val.
--
-- Execute the T-SQL code and compare the results that you got with the desired results shown in the file 62 - Lab Exercise 2 - Task 1 Result.txt.
---------------------------------------------------------------------
with Cte AS(
select  ov.orderid, ov.orderdate, ov.val,  
ROW_NUMBER() OVER(ORDER BY ov.orderdate, ov.orderid) AS rowno
from Sales.OrderValues as ov) 

select c.orderid,c.orderdate,c.val,ov.val as prevval, c.val-ov.val as diffval
from Cte as c left join Sales.OrderValues as ov on ov.orderid = c.orderid-1
order by c.rowno
---------------------------------------------------------------------
-- Task 2
-- 
-- Write a SELECT statement that uses the LAG function to achieve the same results as the query in the 
-- previous task. The query should not define a CTE.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 63 - Lab Exercise 2 - Task 2 Result.txt. 
---------------------------------------------------------------------
select t1.orderid,t1.orderdate,t1.val,t1.prevval,t1.val-t1.prevval as diffval from(
select ov.orderid,ov.orderdate, ov.val, lag(ov.val,1) over (order by ov.orderid) as prevval
from Sales.OrderValues as ov) as t1
---------------------------------------------------------------------
-- Task 3
-- 
-- Define a CTE named SalesMonth2007 that creates two columns: monthno (the month number of the
-- orderdate column) and val (aggregated val column). Filter the results to include only the order year
--2007 and group by monthno.
--
-- Write a SELECT statement that retrieves the monthno and val columns from the CTE and adds three
--calculated columns:
--  avglast3months. This column should contain the average sales amount for last three months before
--the current month. (Use multiple LAG functions and divide the sum by three.) You can assume that 
--there’s a row for each month in the CTE.
--  diffjanuary. This column should contain the difference between the current val and the January val.
--(Use the FIRST_VALUE function.) 
-- nextval. This column should contain the next month value of the val column.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 64 - Lab Exercise 2 - Task 3 Result.txt. Notice that the average amount for last three months is not correctly computed because the total amount for the first two months is divided by three. You will practice how to do this correctly in the next exercise.
---------------------------------------------------------------------
with SalesMonth2007 AS(
select month(ov.orderdate) as monthno, ov.val
from Sales.OrderValues as ov
where year(ov.orderdate)=2007) 

select sm.monthno,sum(sm.val) as val, Lead(sum(sm.val),1) OVER(ORDER BY sm.monthno) as nextval,

(Case when lag(sum(sm.val),1) OVER(ORDER BY sm.monthno) is null then 0 else 
lag(sum(sm.val),1) OVER(ORDER BY sm.monthno) end

+ Case when lag(sum(sm.val),2) OVER(ORDER BY sm.monthno) is null then 0 else 
lag(sum(sm.val),2) OVER(ORDER BY sm.monthno) end +

Case when lag(sum(sm.val),3) OVER(ORDER BY sm.monthno) is null then 0 else 
lag(sum(sm.val),3) OVER(ORDER BY sm.monthno) end)/3 as avglast3months,

sum(sm.val) - FIRST_VALUE(sum(sm.val)) OVER (ORDER BY sm.monthno) AS diffjanuary
from SalesMonth2007 as sm  
group by sm.monthno