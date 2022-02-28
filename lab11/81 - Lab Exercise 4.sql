---------------------------------------------------------------------
-- LAB 11
--
-- Exercise 4
---------------------------------------------------------------------

USE Kharkov;
GO

---------------------------------------------------------------------
-- Task 1
-- 
-- Open the project file F:\10774A_Labs\10774A_11_PRJ\10774A_11_PRJ.ssmssln and the T-SQL script 81 - Lab Exercise 4.sql. Ensure that you are connected to the TSQL2012 database.
--
-- Write a SELECT statement against the Sales.OrderValues view and retrieve the custid and totalsalesamount columns as a total of
--the val column. Filter the results to include orders only for the order year 2007.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 82 - Lab Exercise 4 - Task 1 Result.txt. 
--
-- Define an inline table-valued function using the following function header and add your previous query after the RETURN clause.
--
-- Modify the query by replacing the constant year value 2007 in the WHERE clause with the parameter @orderyear.
--
-- Highlight the complete code and execute it. This will create an inline table-valued function named dbo.fnGetSalesByCustomer.
---------------------------------------------------------------------
-- initial SQL statement
select ov.custid, sum(ov.val) as totalsalesamount from  Sales.OrderValues as ov 
where year(ov.orderdate)=2007 
group by custid

CREATE FUNCTION dbo.fnGetSalesByCustomer (@orderyear AS INT)
RETURNS TABLE
AS
RETURN
select ov.custid, sum(ov.val) as totalsalesamount from  Sales.OrderValues as ov 
where year(ov.orderdate)=@orderyear
group by custid

-- copy here the SQL statement

GO


---------------------------------------------------------------------
-- Task 2
-- 
-- Write a SELECT statement to retrieve the custid and totalsalesamount columns from the dbo.fnGetSalesByCustomer inline table-valued function. Use the value 2007 for the needed parameter.
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 83 - Lab Exercise 4 - Task 2 Result.txt. 
---------------------------------------------------------------------
select fn.custid,fn.totalsalesamount from dbo.fnGetSalesByCustomer (2007) as fn;

---------------------------------------------------------------------
-- Task 3
-- 
-- In this task, you will query the Production.Products and Sales.OrderDetails tables. Write a SELECT statement that retrieves the top three sold products based on the total sales value for the customer with ID 1. Return the productid and productname columns from the Production.Products table. Use the qty and unitprice columns from the Sales.OrderDetails table to compute each order line’s value, and return the sum of all values per product, naming the resulting column totalsalesamount. Filter the results to include only the rows where the custid value is equal to 1.
--
-- Execute the T-SQL code and compare the results that you got with the recommended result shown in the file 84 - Lab Exercise 4 - Task 3_1 Result.txt.
--
-- Create an inline table-valued function based on the following function header, using the previous
--SELECT statement. Replace the constant custid value 1 in the query with the function’s input parameter
--@custid:
--
-- Highlight the complete code and execute it. This will create an inline table-valued function named
--dbo.fnGetTop3ProductsForCustomer that excepts a parameter for the customer id.
--
-- Test the created inline table-valued function by writing a SELECT statement against it and use the value 1 for the customer id parameter. Retrieve the productid, productname, and totalsalesamount columns, and use the alias p for the inline table-valued function.
--
-- Execute the T-SQL code and compare the results that you got with the recommended result shown in the file 85 - Lab Exercise 4 - Task 3_2 Result.txt.
---------------------------------------------------------------------

-- initial SQL statement
select top (3) pp.productid, pp.productname, sum(od.qty*od.unitprice) as totalsalesamount from Production.Products as pp join 
Sales.OrderDetails as od on od.productid = pp.productid join Sales.Orders as o
on o.orderid=od.orderid 
where custid = 1
group by pp.productid, pp.productname
order by sum(od.qty*od.unitprice) desc
--GO

CREATE FUNCTION dbo.fnGetTop3ProductsForCustomer (@custid AS INT) RETURNS TABLE
AS
RETURN
-- copy here the SQL statement
select top (3) pp.productid, pp.productname, sum(od.qty*od.unitprice) as totalsalesamount from Production.Products as pp join 
Sales.OrderDetails as od on od.productid = pp.productid join Sales.Orders as o
on o.orderid=od.orderid 
where custid = @custid
group by pp.productid, pp.productname
order by sum(od.qty*od.unitprice) desc
GO

-- write here the SQL statement against the created function
select ft.productid,ft.productname,ft.totalsalesamount from dbo.fnGetTop3ProductsForCustomer(1) as ft;

---------------------------------------------------------------------
-- Task 4
-- 
-- Write a SELECT statement to retrieve the same result as in exercise 3, task 3, but use the created inline table-valued function in task 2 (dbo.fnGetSalesByCustomer).
--
-- Execute the written statement and compare the results that you got with the recommended result shown in the file 86 - Lab Exercise 4 - Task 4 Result.txt.
---------------------------------------------------------------------
select sc.custid, sc.contactname, fn2.totalsalesamount as salesamt2008, fn1.totalsalesamount as salesamt2007,
fn2.totalsalesamount*100/fn1.totalsalesamount - 100 as percentgrowth
from Sales.Customers as sc left join dbo.fnGetSalesByCustomer (2007) as fn1 on sc.custid=fn1.custid left join 
dbo.fnGetSalesByCustomer (2008) as fn2 on fn1.custid=fn2.custid
order by custid

---------------------------------------------------------------------
-- Task 5
-- 
-- Remove the created inline table-valued functions by executing the provided T-SQL statement. Execute this code exactly as written inside a query window.
---------------------------------------------------------------------

IF OBJECT_ID('dbo.fnGetSalesByCustomer') IS NOT NULL
	DROP FUNCTION dbo.fnGetSalesByCustomer;

IF OBJECT_ID('dbo.fnGetTop3ProductsForCustomer') IS NOT NULL
	DROP FUNCTION dbo.fnGetTop3ProductsForCustomer;
GO


