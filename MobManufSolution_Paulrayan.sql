--SQL Advance Case Study - By Paulrayan


--Q1--BEGIN 
	
	--List all the states in which we have customers who have bought cellphones from 2005 till today.
	SELECT A.[State], COUNT(B.IDCustomer) AS No_of_Customers          -- Selecting states and number of customers.
	FROM DIM_LOCATION A												  -- Mapping transactions, locationwise.
	LEFT JOIN FACT_TRANSACTIONS B ON A.IDLocation = B.IDLocation
	WHERE B.[Date] > '2004-12-31'									  -- Filtering records to display no. of customers from 2005 till date.
	GROUP BY A.[State]

--Q1--END

--Q2--BEGIN
	
	--What state in the US is buying the most 'Samsung' cell phones ?
	SELECT TBL_C.[State], SUM(TBL_B.Quantity) AS No_of_Purchases FROM     -- Required summary fields
	(SELECT A.IDModel, A.Model_Name, A.IDManufacturer,B.Manufacturer_Name FROM DIM_MODEL A
	LEFT JOIN DIM_MANUFACTURER B ON A.IDManufacturer = B.IDManufacturer
	WHERE B.Manufacturer_Name = 'Samsung') TBL_A						  -- Mapping model with manufacturer
	LEFT JOIN FACT_TRANSACTIONS TBL_B ON TBL_A.IDModel = TBL_B.IDModel	  -- Extracting customers that have purchased samsung cell phones
	LEFT JOIN DIM_LOCATION TBL_C ON TBL_B.IDLocation = TBL_C.IDLocation   -- Mapping customers with location
	WHERE TBL_C.Country = 'US'											  -- Filtering US customers and aggregating by US states
	GROUP BY TBL_C.[State]												  -- Final result and arranging so as to display highest to lowest
	ORDER BY No_of_Purchases DESC


--Q2--END

--Q3--BEGIN      
	
	--Show the number of transactions for each model per zip code per state.
	SELECT TBL_B.Model_Name, TBL_C.ZipCode, TBL_C.State, COUNT(TBL_A.IDCustomer) AS Num_of_Transactions
	FROM FACT_TRANSACTIONS TBL_A
	LEFT JOIN DIM_MODEL TBL_B ON TBL_A.IDModel = TBL_B.IDModel                -- Mapping model name to transactions
	LEFT JOIN DIM_LOCATION TBL_C ON TBL_A.IDLocation = TBL_C.IDLocation		  -- Mapping demographics to transactions
	GROUP BY TBL_B.Model_Name, TBL_C.ZipCode, TBL_C.State					  -- Aggregating by model name, zipcode and finally by state


--Q3--END

--Q4--BEGIN

	--Show the cheapest cellphone (Output should contain the price also).
	SELECT TOP 1 B.Manufacturer_Name, A.Model_Name, MIN(A.Unit_price) AS Price_of_Phone
	FROM DIM_MODEL A
	LEFT JOIN DIM_MANUFACTURER B ON A.IDManufacturer = B.IDManufacturer       -- Mapping manufacturer to model details
	GROUP BY B.Manufacturer_Name, A.Model_Name								  -- Aggregating by manufacturer and model name and displaying cheapest device by unit cost.
	ORDER BY Price_of_Phone


--Q4--END

--Q5--BEGIN

	--Find out the average price for each model in the top 5 manufacturers in terms of sales 
	--quantity and order by average price.
	SELECT TBL_A.Manufacturer_Name, TBL_B.Model_Name, TBL_B.Average_Price
	FROM (
	SELECT TOP 5 C.Manufacturer_Name, SUM(A.Quantity) AS Units_Sold       -- TBL_A has top 5 manufacturers by units sold.
	FROM FACT_TRANSACTIONS A											  -- TBL_B has average price of each model in top 5 manufacturers
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel						  -- in terms of units sold.
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer   -- TBL_B is mapped to TBL_A and is ordered by desc order of average price.
	GROUP BY C.Manufacturer_Name
	ORDER BY Units_Sold DESC) TBL_A
	LEFT JOIN (
	SELECT C.Manufacturer_Name, B.Model_Name, ROUND(AVG(A.TotalPrice),2) AS Average_Price
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer
	GROUP BY C.Manufacturer_Name, B.Model_Name) TBL_B ON TBL_A.Manufacturer_Name = TBL_B.Manufacturer_Name
	ORDER BY TBL_B.Average_Price DESC


--Q5--END

--Q6--BEGIN

	--List the names of the customers and the average amount spent in 2009, where the average is higher than 500.
	SELECT B.Customer_Name, (SELECT SUM(TotalPrice) FROM FACT_TRANSACTIONS WHERE [Date] BETWEEN '2009-01-01' AND '2009-12-31') /SUM(A.TotalPrice) AS Average_amount_Spent   -- calculating average amount spent in 2009
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_CUSTOMER B ON A.IDCustomer = B.IDCustomer
	WHERE (A.Date BETWEEN '2009-01-01' AND '2009-12-31')   -- filtering dataset to year 2009
	GROUP BY B.Customer_Name
	HAVING (SELECT SUM(TotalPrice) FROM FACT_TRANSACTIONS WHERE [Date] BETWEEN '2009-01-01' AND '2009-12-31') /SUM(A.TotalPrice) > 500  -- extracting customers with avg spend GT 500


--Q6--END
	
--Q7--BEGIN  
	
	--List if there is any model that was in the top 5 in terms of quantity,
	--simultaneoulsy in 2008,2009 and 2010.	
	SELECT Manufacturer_Name, Model_Name    -- Creating lists for each year and picking top 5 models, then intersecting the data sets to get common values
	FROM (
	SELECT TOP 5 '2008' AS Year_of_Sales, C.Manufacturer_Name, B.Model_Name, SUM(A.Quantity) AS Units_Sold
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer
	WHERE ([Date] BETWEEN '2007-12-31' AND '2009-01-01')
	GROUP BY C.Manufacturer_Name, B.Model_Name
	ORDER BY UNITS_SOLD DESC) tbl_E    -- List for the year 2008

	INTERSECT

	SELECT Manufacturer_Name, Model_Name
	FROM(
	SELECT TOP 5 '2009' AS Year_of_Sales, C.Manufacturer_Name, B.Model_Name, SUM(A.Quantity) AS Units_Sold
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer
	WHERE ([Date] BETWEEN '2008-12-31' AND '2010-01-01')
	GROUP BY C.Manufacturer_Name, B.Model_Name
	ORDER BY UNITS_SOLD DESC) TBL_F   -- List for the year 2009

	INTERSECT

	SELECT Manufacturer_Name, Model_Name
	FROM (
	SELECT TOP 5 '2010' AS Year_of_Sales, C.Manufacturer_Name, B.Model_Name, SUM(Quantity) AS Units_Sold
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer
	WHERE ([Date] BETWEEN '2009-12-31' AND '2011-01-01')
	GROUP BY C.Manufacturer_Name, B.Model_Name
	ORDER BY UNITS_SOLD DESC) TBL_G   -- List for the year 2010


--Q7--END

--Q8--BEGIN

	--Show the manufacturer with the 2nd top sales in the year of 2009 and the 
    --manufacturer with the 2nd top sales in the year of 2010.
	SELECT '2009' AS Year_of_Sales, Manufacturer_Name, Sum_of_Sales  -- creating lists for each year and extracting 2nd best manufacturer in each year
	FROM(
	SELECT C.Manufacturer_Name, SUM(A.TotalPrice) AS Sum_of_Sales, RANK() OVER (ORDER BY SUM(A.TotalPrice) DESC) AS Position
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer
	WHERE A.Date BETWEEN '2008-12-31' AND '2010-01-01'
	GROUP BY C.Manufacturer_Name) TBL_X   -- List having 2nd top sales in year 2009
	WHERE Position = 2
	UNION ALL
	SELECT '2010' AS Year_of_Sales, Manufacturer_Name, Sum_of_Sales
	FROM(
	SELECT C.Manufacturer_Name, SUM(A.TotalPrice) AS Sum_of_Sales, RANK() OVER (ORDER BY SUM(A.TotalPrice) DESC) AS Position
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer
	WHERE A.Date BETWEEN '2009-12-31' AND '2011-01-01'
	GROUP BY C.Manufacturer_Name) TBL_Y  -- List having 2nd top sales in year 2010
	WHERE Position = 2


--Q8--END

--Q9--BEGIN
	
	--Show the manufacturers that sold cellphones in 2010 but did not in 2009.
	SELECT Manufacturer_Name FROM (     -- Taking sales of the 2 years and removing the common values to get the required value
	SELECT C.Manufacturer_Name
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer
	WHERE A.Date BETWEEN '2009-12-31' AND '2011-01-01'
	GROUP BY C.Manufacturer_Name) TBL_Y   -- List of manufacturers sold in 2010

	EXCEPT

	SELECT Manufacturer_Name FROM (
	SELECT C.Manufacturer_Name
	FROM FACT_TRANSACTIONS A
	LEFT JOIN DIM_MODEL B ON A.IDModel = B.IDModel
	LEFT JOIN DIM_MANUFACTURER C ON B.IDManufacturer = C.IDManufacturer
	WHERE A.Date BETWEEN '2008-12-31' AND '2010-01-01'
	GROUP BY C.Manufacturer_Name) TAL_X   -- List of manufacturers sold in 2009


--Q9--END

--Q10--BEGIN
	
	--Find top 100 customers and their average spend, average quantity by each year. 
    --Also find the percentage of change in their spend.
	SELECT TBL_TOP10.IDCustomer,   -- as there are only 50 customers, top 100 is not possible. I've considered top 10 and displayed average spend then avg items bought and finally %diff in spend
	TBL_SUMM.AVGY_2003 AS AVG_2003, TBL_SUMM.AVGY_2004 AS AVG_2004, TBL_SUMM.AVGY_2005 AS AVG_2005, TBL_SUMM.AVGY_2006 AS AVG_2006,
	TBL_SUMM.AVGY_2007 AS AVG_2007, TBL_SUMM.AVGY_2008 AS AVG_2008, TBL_SUMM.AVGY_2009 AS AVG_2009, TBL_SUMM.AVGY_2010 AS AVG_2010,     -- Selecting fleids for display
	TBL_SUMM.ITEY_2003 AS ITEM_2003, TBL_SUMM.ITEY_2004 AS ITEM_2004, TBL_SUMM.ITEY_2005 AS ITEM_2005, TBL_SUMM.ITEY_2006 AS ITEM_2006,
	TBL_SUMM.ITEY_2007 AS ITEM_2007, TBL_SUMM.ITEY_2008 AS ITEM_2008, TBL_SUMM.ITEY_2009 AS ITEM_2009, TBL_SUMM.ITEY_2010 AS ITEM_2010,
	TBL_DIFFSUMM.DIFF_2004 AS DIFF_03_04, TBL_DIFFSUMM.DIFF_2005 AS DIFF_04_05, TBL_DIFFSUMM.DIFF_2006 AS DIFF_05_06,
	TBL_DIFFSUMM.DIFF_2007 AS DIFF_06_07, TBL_DIFFSUMM.DIFF_2008 AS DIFF_07_08, TBL_DIFFSUMM.DIFF_2009 AS DIFF_08_09,
	TBL_DIFFSUMM.DIFF_2010 AS DIFF_09_10
	FROM
	(
	SELECT TOP 10 IDCustomer, SUM(TotalPrice) AS Total_Amount_Spent    -- Table of top 10 customers according to their spend
	FROM FACT_TRANSACTIONS
	GROUP BY IDCustomer
	ORDER BY Total_Amount_Spent DESC) TBL_TOP10
	LEFT JOIN 
	(SELECT T.IDCustomer,
	SUM(CASE WHEN YEAR_AGG = 2003 THEN AVG_SPEND ELSE 0 END) AS AVGY_2003,   -- Table of aggregated fields displaying average spend of each customer in a year
	SUM(CASE WHEN YEAR_AGG = 2004 THEN AVG_SPEND ELSE 0 END) AS AVGY_2004,   -- Table also displays average items purchased during each year
	SUM(CASE WHEN YEAR_AGG = 2005 THEN AVG_SPEND ELSE 0 END) AS AVGY_2005,
	SUM(CASE WHEN YEAR_AGG = 2006 THEN AVG_SPEND ELSE 0 END) AS AVGY_2006,
	SUM(CASE WHEN YEAR_AGG = 2007 THEN AVG_SPEND ELSE 0 END) AS AVGY_2007,
	SUM(CASE WHEN YEAR_AGG = 2008 THEN AVG_SPEND ELSE 0 END) AS AVGY_2008,
	SUM(CASE WHEN YEAR_AGG = 2009 THEN AVG_SPEND ELSE 0 END) AS AVGY_2009,
	SUM(CASE WHEN YEAR_AGG = 2010 THEN AVG_SPEND ELSE 0 END) AS AVGY_2010,
	SUM(CASE WHEN YEAR_AGG = 2003 THEN AVG_ITEMS ELSE 0 END) AS ITEY_2003,
	SUM(CASE WHEN YEAR_AGG = 2004 THEN AVG_ITEMS ELSE 0 END) AS ITEY_2004,
	SUM(CASE WHEN YEAR_AGG = 2005 THEN AVG_ITEMS ELSE 0 END) AS ITEY_2005,
	SUM(CASE WHEN YEAR_AGG = 2006 THEN AVG_ITEMS ELSE 0 END) AS ITEY_2006,
	SUM(CASE WHEN YEAR_AGG = 2007 THEN AVG_ITEMS ELSE 0 END) AS ITEY_2007,
	SUM(CASE WHEN YEAR_AGG = 2008 THEN AVG_ITEMS ELSE 0 END) AS ITEY_2008,
	SUM(CASE WHEN YEAR_AGG = 2009 THEN AVG_ITEMS ELSE 0 END) AS ITEY_2009,
	SUM(CASE WHEN YEAR_AGG = 2010 THEN AVG_ITEMS ELSE 0 END) AS ITEY_2010
	FROM
	(SELECT IDCustomer, YEAR([Date]) AS YEAR_AGG, AVG(TotalPrice) AS AVG_SPEND, AVG(Quantity) AS AVG_ITEMS  
	FROM FACT_TRANSACTIONS         -- inner table where aggregations are done per year for each customer that has transacted that year.
	GROUP BY  YEAR([Date]), IDCustomer) T
	group by T.IDCustomer) TBL_SUMM ON TBL_TOP10.IDCustomer = TBL_SUMM.IDCustomer  -- joining table of avgspend and avgitem to the top ten customers table
	LEFT JOIN
	(
	SELECT TBL_SMRY.IDCustomer,   -- selecting percentage diff of spend per year for each customer
	SUM(CASE WHEN TOTY_2003 != 0 THEN (TOTY_2004 - TOTY_2003) / TOTY_2003 * 100 ELSE 0 END) AS DIFF_2004,
	SUM(CASE WHEN TOTY_2004 != 0 THEN (TOTY_2005 - TOTY_2004) / TOTY_2004 * 100 ELSE 0 END) AS DIFF_2005,
	SUM(CASE WHEN TOTY_2005 != 0 THEN (TOTY_2006 - TOTY_2005) / TOTY_2005 * 100 ELSE 0 END) AS DIFF_2006,
	SUM(CASE WHEN TOTY_2006 != 0 THEN (TOTY_2007 - TOTY_2006) / TOTY_2006 * 100 ELSE 0 END) AS DIFF_2007,
	SUM(CASE WHEN TOTY_2007 != 0 THEN (TOTY_2008 - TOTY_2007) / TOTY_2007 * 100 ELSE 0 END) AS DIFF_2008,
	SUM(CASE WHEN TOTY_2008 != 0 THEN (TOTY_2009 - TOTY_2008) / TOTY_2008 * 100 ELSE 0 END) AS DIFF_2009,
	SUM(CASE WHEN TOTY_2009 != 0 THEN (TOTY_2010 - TOTY_2009) / TOTY_2009 * 100 ELSE 0 END) AS DIFF_2010

	FROM (
	SELECT T.IDCustomer,    -- this table has the aggregated fields of annual spend of each customer on which we are calculating the %diff
	SUM(CASE WHEN YEAR_AGG = 2003 THEN TOTAL_SPEND ELSE 0 END) AS TOTY_2003,
	SUM(CASE WHEN YEAR_AGG = 2004 THEN TOTAL_SPEND ELSE 0 END) AS TOTY_2004,
	SUM(CASE WHEN YEAR_AGG = 2005 THEN TOTAL_SPEND ELSE 0 END) AS TOTY_2005,
	SUM(CASE WHEN YEAR_AGG = 2006 THEN TOTAL_SPEND ELSE 0 END) AS TOTY_2006,
	SUM(CASE WHEN YEAR_AGG = 2007 THEN TOTAL_SPEND ELSE 0 END) AS TOTY_2007,
	SUM(CASE WHEN YEAR_AGG = 2008 THEN TOTAL_SPEND ELSE 0 END) AS TOTY_2008,
	SUM(CASE WHEN YEAR_AGG = 2009 THEN TOTAL_SPEND ELSE 0 END) AS TOTY_2009,
	SUM(CASE WHEN YEAR_AGG = 2010 THEN TOTAL_SPEND ELSE 0 END) AS TOTY_2010
	FROM
	(SELECT IDCustomer, YEAR([Date]) AS YEAR_AGG, SUM(TotalPrice) AS TOTAL_SPEND
	FROM FACT_TRANSACTIONS   -- the inner summary of spend of each customer per year.
	GROUP BY  YEAR([Date]), IDCustomer) T
	group by T.IDCustomer ) TBL_SMRY
	GROUP BY TBL_SMRY.IDCustomer) TBL_DIFFSUMM  ON TBL_TOP10.IDCustomer = TBL_DIFFSUMM.IDCustomer  -- joining the %diff table to top 10 customer table to display %diff
	ORDER BY TBL_TOP10.Total_Amount_Spent DESC


--Q10--END
	