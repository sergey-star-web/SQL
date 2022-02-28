---------------------------------------------------------------------
-- LAB 11
--
-- Exercise 3
---------------------------------------------------------------------

USE Kharkov;
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_11_PRJ\10774A_11_PRJ.ssmssln and the T-SQL script 71 - Lab Exercise 3.sql. Ensure that you are connected to the TSQL2012 database.
--
-- Write a SELECT statement like that in exercise 2, task 1, but use a CTE instead of a derived table.
--Use inline column aliasing in the CTE query and name the CTE ProductBeverages.
--
-- Execute the T-SQL code and compare the results that you got with the recommended result shown in the file 72 - Lab Exercise 3 - Task 1 Result.txt. 
---------------------------------------------------------------------

with CTE_ProductBeverages   AS  
(  
  SELECT productid, productname
  FROM Production.Products
  WHERE categoryid = 1 and unitprice>100
)  
SELECT productid, productname
FROM CTE_ProductBeverages;
---------------------------------------------------------------------
-- Task 2
-- 
-- Write a SELECT statement against Sales.OrderValues to retrieve each customer�s ID and total sales 
--amount for the year 2008. Define a CTE named c2008 based on this query using the external aliasing form
--to name the CTE columns custid and salesamt2008. Join the Sales.Customers table and the c2008 CTE,
--returning the custid and contactname columns from the Sales.Customers table and the salesamt2008 column 
--from the c2008 CTE.
--
-- Execute the T-SQL code and compare the results that you got with the recommended result shown in the file 73 - Lab Exercise 3 - Task 2 Result.txt. 
---------------------------------------------------------------------
with CTE_c2008   AS  
(  
  SELECT o.custid, sum(od.val) as salesamt2008
  FROM  Sales.Orders as o join Sales.OrderValues as od on od.orderid=o.orderid
  WHERE year(o.orderdate)=2008 
 group by o.custid
)  
SELECT c.custid,c.contactname, salesamt2008
FROM CTE_c2008 as e right join Sales.Customers as c on c.custid=e.custid
order by c.custid;
---------------------------------------------------------------------
-- Task 3
-- 
-- Write a SELECT statement to retrieve the custid and contactname columns from the Sales.Customers table.
--Also retrieve the following calculated columns:
--  salesamt2008, representing the total sales amount for the year 2008
--  salesamt2007, representing the total sales amount for the year 2007 
--  percentgrowth, representing the percentage of sales growth between the year 2007 and 2008 
-- If percentgrowth is NULL, then display the value 0.
--
-- You can use the CTE from the previous task and add another CTE for the year 2007. Then join both of them with the Sales.Customers table. Order the result by the percentgrowth column.
--
-- Execute the T-SQL code and compare the results that you got with the recommended result shown in the file 74 - Lab Exercise 3 - Task 3 Result.txt.
---------------------------------------------------------------------
with CTE_c2008   AS  
(  
  SELECT o.custid, sum(od.val) as salesamt2008
  FROM  Sales.Orders as o join Sales.OrderValues as od on od.orderid=o.orderid
  WHERE year(o.orderdate)=2008 
 group by o.custid
)     ,
 CTE_c2007   AS  
(  
  SELECT o.custid, sum(od.val) as salesamt2007
  FROM  Sales.Orders as o join Sales.OrderValues as od on od.orderid=o.orderid
  WHERE year(o.orderdate)=2007 
 group by o.custid
)

select * from(
select c.custid,c.contactname, c8.salesamt2008, c7.salesamt2007,
case when c8.salesamt2008*100/c7.salesamt2007 - 100 is null then 0 else c8.salesamt2008*100/c7.salesamt2007 - 100 end as percentgrowth
from Sales.Customers as c left join CTE_c2008 as c8 on c8.custid=c.custid left join CTE_c2007 as c7
on c8.custid=c7.custid 
) as t1
order by t1.percentgrowth desc