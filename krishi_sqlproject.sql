-- Changing name and data Type of Bank DOJ column
alter table customerinfo rename column `Bank DOJ` to BankDOJ;

update customerinfo
set BankDOJ= STR_TO_DATE(BankDOJ,"%d-%m-%Y");

-- changing data type
alter table customerinfo
modify BankDOJ date;

-- OBJECTIVE QUESTIONS

-- 2.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. 
select customerID,Surname,EstimatedSalary as Salary,BankDOJ
from customerinfo
where quarter(BankDOJ )=4
order by Salary desc
limit 5;

-- 3. Calculate the average number of products used by customers who have a credit card.
select avg(NumOfProducts) as averageProducts
from bankchurn 
where HasCrCard=1;

-- 5. Compare the average credit score of customers who have exited and those who remain. 
select avg(CreditScore)as averageCreditScore,ExitCategory 
from bankchurn b join exitcustomer e on b.Exited=e.ExitID
group by ExitCategory;

-- 6. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts?
 select c.GenderID,g.GenderCategory as Gender, 
 avg(c.EstimatedSalary) as AVG_Estimated_Salary,
 count(distinct case when b.IsActiveMember=1 then c.CustomerID else NULL end) as Count_of_Active_accounts
 from bankchurn b 
 join customerinfo as c ON b.CustomerId=c.CustomerId
 join gender g on c.genderID=g.GenderID
 group by genderID,g.GenderCategory
 order by AVG_Estimated_Salary desc;

-- 7. Segment the customers based on their credit score and identify the segment with the highest exit rate. 
with category as (select (case when CreditScore between 800 and 850 then "Excellent"
			when CreditScore between 740 and 799 then "Very Good"
            when CreditScore between 670 and 739 then "Good"
            when CreditScore between 580 and 669 then "Fair"
            when CreditScore between 300 and 579 then "Poor"
            else null end ) as CreditCategory,sum(case when Exited=1 then 1 else 0 end) as exitRate 
            from bankchurn group by CreditCategory)

select CreditCategory,exitRate from category where exitRate=(select max(exitRate) from category);

-- 8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years.

select GeographyID,count(c.CustomerID) as activeCustomers 
from customerinfo c join bankchurn b on c.CustomerID=b.CustomerId
where IsActiveMember=1 and Tenure>5 
group by GeographyID
order by activeCustomers desc 
limit 1;

-- 11.Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly).
-- Prepare the data through SQL and then visualize it.
select date_format(BankDOJ,"%Y") as y,count(*) as  customersJoined
from customerinfo
group by y
order by y;

select date_format(BankDOJ,"%Y") as y,date_format(BankDOJ,"%m") as ym,count(*) as  customersJoined
from customerinfo
group by y,ym
order by y,ym;

-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. 
-- Also, rank the gender according to the average value. 
with cte as ( select g.GenderCategory as Gender,go.GeographyID as GeographyID,go.GeographyLocation as Geography,
avg(c.EstimatedSalary) as Avg_income
from bankchurn b 
join customerinfo c ON b.CustomerId=c.CustomerId
join Gender g ON c.GenderID=g.GenderID
join Geography go ON c.GeographyID=go.GeographyID
group by go.GeographyID,go.GeographyLocation,g.GenderCategory
)
select Gender,GeographyID,Geography,Avg_income,rank() Over(Partition by Geography order by Avg_income desc) as Ranking
from cte order by GeographyID,Geography;

-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

select (case 
	when c.age between 18 and 30 then "18-30"
    when c.age between 30 and 50 then "30-50"
    when c.age >50 then "50+"
    Else "NULL"
END ) ageBracket,
AVG(b.Tenure) as avgTenure
from bankchurn b 
join customerinfo as c ON b.CustomerId=c.CustomerId
where b.Exited=1
group by ageBracket
order by ageBracket;

-- 19.	Rank each bucket of credit score as per the number of customers who have churned the bank.

with Credit as (
select case 
	when CreditScore >=300 and CreditScore<=500 then "300-500"
	when CreditScore >= 501 and CreditScore<=700 then "501-700"
	when CreditScore >= 701 then "700+"
end as creditScoreBucket,count(*) as customersChurned
from bankchurn
where Exited=1 Group by creditScoreBucket
)
select creditScoreBucket,customersChurned,
rank() over(order by customersChurned desc) as creditRrank 
from Credit;

-- 23.Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? 
-- If yes do this using SQL.

select *,
 (select ExitCategory from exitcustomer where b.Exited=exitcustomer.ExitID) as ExitCategory
 from bankchurn b;
 
 -- 25.	Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.

select c.CustomerId,Surname as lastName,b.IsActiveMember
 from customerinfo c
 join bankchurn b on c.CustomerId=b.CustomerId
 where c.Surname like '%on';
 
 -- SUBJECTIVE QUESTION
 
 -- 9.Utilize SQL queries to segment customers based on demographics and account details.
 
select g.GeographyLocation,count(b.CustomerID) as Customers,count(case when b.HasCrCard=1 then b.HasCrCard end) as HasCrCard,
count(case when b.IsActiveMember=1 then b.IsActiveMember end) as ActiveMember,
count(case when b.Exited=1 then b.Exited end) as Exited,
count(case when b.Exited=0 then b.Exited end) as Retained
from bankchurn b join customerinfo c ON b.customerID=c.customerID
join Geography g ON c.GeographyID=g.GeographyID
group by g.GeographyLocation ;

-- 14.	In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?

alter table bankchurn rename column HasCrCard to Has_creditcard;