USE DBTestPractice 
GO

--1.Требуется написать запрос, который выведет номер, лицевой счет, дату в формате «день.месяц.год» и 
--сумму ближайших по дате двух счетов, у которых день начисления в промежутке от 8 до 12 включительно.
SELECT top(2) b.C_Number,b.F_Subscr as N_Subscr,FORMAT (b.D_Date, 'dd.MM.yyyy'),b.N_Amount  
from dbo.FD_Bills as b 
where day(b.D_Date) BETWEEN 8 AND 12 
order by b.D_Date desc

--2.	Требуется вывести уникальные суммы начислений по услуге ХВС за все время
SELECT b.N_Amount 
FROM dbo.FD_Bills as b 
where b.C_Sale_Items=N'ХВС' 
group by b.N_Amount

--3.Требуется вывести услугу и среднюю сумму начислений за все время, у которой средняя сумма превышает 120 р.
SELECT b.C_Sale_Items, avg(b.N_Amount) 
FROM dbo.FD_Bills as b 
group by b.C_Sale_Items
having avg(b.N_Amount)>120 

--4.	Требуется вывести общие суммы начислений за каждый месяц по каждой услуге за все время 
--с сортировкой по месяцам, с под итогами.
SELECT CONCAT(year(b.D_Date),' ',month(b.D_Date)) as N_Month,b.C_Sale_Items,sum(b.N_Amount) as N_Amoun_Sum
from dbo.FD_Bills as b
group by 
ROLLUP (CONCAT(year(b.D_Date),' ',month(b.D_Date)), b.C_Sale_Items)

--5.	Требуется вывести общие суммы начислений за каждый месяц по каждой услуге за все время,
--так чтобы услуги были строках, месяца в столбцах
SELECT C_Sale_Items,   
  [2018 12], [2019 1], [2019 2]  
FROM  
(
  SELECT C_Sale_Items, CONCAT(year(b.D_Date),' ',month(b.D_Date)) as mont,b.N_Amount   
  FROM dbo.FD_Bills as b
)  as b1
PIVOT  
(  
  sum(N_Amount)  
  FOR mont IN ([2018 12], [2019 1], [2019 2])  
) AS b2;  

--6.	Требуется вывести дату номер и сумму начислений, для которых сумма превышает
--сумму предыдущего по дате начисления
 SELECT *
 from (select D_Date, C_Number,N_Amount, LAG(b.N_Amount, 1) OVER (ORDER BY b.D_Date) as N_Amount_B
   FROM dbo.FD_Bills as b) as b1
   where b1.N_Amount>b1.N_Amount_B or b1.N_Amount_B is null

--7.	Требуется вывести список документов, совершенно летних абонентов, проживающих на проспекте Ленина.
--В формате Фамилия инициал., Номер документа, Дата в формате день.месяц.год 
select CONCAT(s.C_SecondName,' ',SUBSTRING (s.C_FirstName, 1, 1),'.') as C_Fio,
d.C_Number, FORMAT (d.D_Date, 'dd.MM.yyyy') as D_Date
from dbo.SD_Subscrs as s join dbo.DD_Docs as d on   s.LINK=d.F_Subscr
where s.C_Address LIKE N'%пр-кт. Ленина%' and year(getdate())-year(s.D_BirthDate)>=18

--8.	Требуется вывести номер и дату всех родительских документов, документа с номером "4-д/1", 
--с сортировкой по дате 
select d.C_Number,d.D_Date from dbo.DD_Docs as d
where substring(d.C_Number,1,1) <= 4 and substring(d.C_Number,5,1)=1
order by d.D_Date

--9.Требуется написать хранимую процедуру dbo.UI_FP_Payment_Split, которая по внесенным платежам в таблицу
--dbo.FD_Payments будет расщеплять его на оплаты по конкретным счетам и услугам исходя из заполненных строк в 
--таблице dbo.FD_Bills. 
--Хранимая процедура так же должна пересчитывать остатки в таблице dbo.FD_Bills.
--Хранимая процедура будет иметь два параметра, ид платежа и тип расщепления.
--Тип расщепления может принимать значения:
--0	– По дате, начиная с самых старых счетов.
--1	– Пропорционально по каждой услуге в месяце.

--Процедура:

USE [DBTestPractice]
GO
/****** Object:  StoredProcedure [dbo].[UI_FP_Payment_Split]    Script Date: 03.03.2022 16:06:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UI_FP_Payment_Split] (@LINK  INT, @N_Type INT )
AS 
BEGIN 
declare @mon int
declare @yea int
declare @sum_amount real
declare @sum_amount_R real
declare @link_pd int
declare @amount_R int
declare @F_sub int

  select top(1) @F_sub = p.F_Subscr from dbo.FD_Payments as p order by p.LINK desc

  select top(1) @link_pd=pd.F_Payments from dbo.FD_Payment_Details as pd order by pd.F_Payments desc
		if @link_pd = @LINK
		begin
		select  @sum_amount=p.N_Amount from dbo.FD_Payments as p
		where p.LINK=@LINK 
		select @sum_amount=@sum_amount - pd.N_Amount from dbo.FD_Payment_Details as pd
		where pd.F_Payments=@LINK
		end
		else begin
        select  @sum_amount=p.N_Amount from dbo.FD_Payments as p
		where p.LINK=@LINK 
		end

  if @N_Type=1
  begin
		select top(1) @mon=month(b.D_Date),@yea=year(b.D_Date) from dbo.FD_Bills as b 
        where b.N_Amount_Rest>0 and  F_Subscr = @F_sub

		select @sum_amount_R=sum(b.N_Amount_Rest)
		from dbo.FD_Bills as b
		where month(b.D_Date)=@mon and year(b.D_Date)=@yea and 
		F_Subscr = @F_sub and b.N_Amount_Rest>0
		group by month(b.D_date)

		if @sum_amount<@sum_amount_R

		begin
		INSERT INTO dbo.FD_Payment_Details
        select @LINK as F_Payments,b.LINK as F_Bills, b.C_Sale_Items, b.N_Amount_Rest/@sum_amount_R*@sum_amount as N_Amount
		from dbo.FD_Bills as b
		where month(b.D_Date)=@mon and year(b.D_Date)=@yea and 
		F_Subscr = @F_sub and b.N_Amount_Rest>0  and b.N_Amount/@sum_amount_R*@sum_amount>0
		
		UPDATE dbo.FD_Bills 
        SET N_Amount_Rest = CASE WHEN N_Amount_Rest - pd.N_Amount > 0 THEN
		N_Amount_Rest - pd.N_Amount ELSE 0 END   
        FROM dbo.FD_Payment_Details  as pd join dbo.FD_Bills as b on b.LINK=pd.F_Bills
        WHERE month(D_Date)=@mon and year(D_Date)=@yea and 
		F_Subscr = @F_sub and b.N_Amount_Rest>0 and pd.F_Payments=@LINK 
		end

		else
		begin

		INSERT INTO dbo.FD_Payment_Details
        select @LINK as F_Payments,b.LINK as F_Bills, b.C_Sale_Items,b.N_Amount_Rest as N_Amount
		from dbo.FD_Bills as b
		where month(b.D_Date)=@mon and year(b.D_Date)=@yea and 
		F_Subscr = @F_sub and b.N_Amount_Rest>0
		group by month(b.D_date),b.C_Sale_Items,b.LINK,b.N_Amount,b.N_Amount_Rest

		UPDATE dbo.FD_Bills 
        SET N_Amount_Rest = CASE WHEN N_Amount_Rest - pd.N_Amount > 0 THEN
		N_Amount_Rest - pd.N_Amount ELSE 0 END   
        FROM dbo.FD_Payment_Details  as pd join dbo.FD_Bills as b on b.LINK=pd.F_Bills
        WHERE month(D_Date)=@mon and year(D_Date)=@yea and 
		F_Subscr = @F_sub and b.N_Amount_Rest>0 and pd.F_Payments=@LINK

		EXEC dbo.UI_FP_Payment_Split @LINK = @LINK, @N_Type = 1
		end
end

 if @N_Type=0
  begin

select top(1) @amount_R=b.N_Amount_Rest
from dbo.FD_Bills as b
where F_Subscr = @F_sub and b.N_Amount_Rest>0

if @amount_R>@sum_amount
begin
INSERT INTO dbo.FD_Payment_Details
        select top(1) @LINK as F_Payments,b.LINK as F_Bills, b.C_Sale_Items,@sum_amount as N_Amount
		from dbo.FD_Bills as b
		where F_Subscr = @F_sub  and b.N_Amount_Rest>0

UPDATE top(1) dbo.FD_Bills 
        SET N_Amount_Rest =  N_Amount_Rest - @sum_amount 
        FROM  dbo.FD_Bills as b
        WHERE F_Subscr = @F_sub  and b.N_Amount_Rest>0 

end
else begin
        INSERT INTO dbo.FD_Payment_Details
        select top(1) @LINK as F_Payments,b.LINK as F_Bills, b.C_Sale_Items, b.N_Amount_Rest as N_Amount
		from dbo.FD_Bills as b
		where  F_Subscr = @F_sub  and b.N_Amount_Rest>0

		UPDATE top(1) dbo.FD_Bills 
        SET N_Amount_Rest =  0
        FROM  dbo.FD_Bills as b 
        WHERE F_Subscr = @F_sub  and b.N_Amount_Rest>0 

		EXEC dbo.UI_FP_Payment_Split @LINK = @LINK, @N_Type = 0
end
  end
END


BEGIN TRAN 

    DECLARE @LINK INT 

    INSERT dbo.FD_Payments
    SELECT 'П-123', 2, '20190105', 235 

    SET @LINK = SCOPE_IDENTITY()

    EXEC dbo.UI_FP_Payment_Split @LINK = @LINK, @N_Type = 0

    INSERT dbo.FD_Payments
    SELECT 'П-124', 2, '20190105', 255 

    SET @LINK = SCOPE_IDENTITY()
  
    EXEC dbo.UI_FP_Payment_Split @LINK = @LINK, @N_Type = 0

    SELECT * FROM dbo.FD_Bills WHERE F_Subscr = 2
    SELECT * FROM dbo.FD_Payment_Details as pd where pd.N_Amount>0

ROLLBACK


