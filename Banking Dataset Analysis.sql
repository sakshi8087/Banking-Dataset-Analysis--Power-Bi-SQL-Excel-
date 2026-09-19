select * from accounts$; --account_id, Customer_id,Branch_id,Account_type,Balance,opening_date

select * from Transactions$; -- transaction_id,Account_id,Transaction_date,Transaction_type, account

select * from ['Customers (1)$'] -- customer_id,Name,Age, Gender,City,Occupation,Anuual_Income, Credit Score

select * from Loans$; -- loan_id,Customer_id,loan_type,loan_amount,interest,loan_status

select * from Branches$ -- branch_id, branch_name,city, Manager_name


--Business Logic Validation 

--Negative Account Balance 

select * from Accounts$
where Balance < 0 ;


--Negative Transaction Amount

select * from Transactions$
where Amount <=0;

--Invalid Customer Age

select * from ['Customers (1)$']
where age <=18 and age >=100;

--Invalid Annual Income
select * from ['Customers (1)$']
where Annual_Income <=0;

--Unrealistic Loan Amounts
select max(loan_amount) as max_loan,
       min(loan_amount) as min_loan,
       avg(loan_amount) as avg_loan
from Loans$;

select * from loans$
where loan_amount > 10000000;

--Invalid Interest Rates
select * from Loans$
where Interest_Rate <=0  OR Interest_Rate >=30;


--Transaction Date Validation
select * from Transactions$ where Transaction_Date > CURRENT_DATE;


-----------Completeness Checks----------------------

--Missing Customer Information
select * from ['Customers (1)$']
where Customer_ID IS NULL
OR name is null
OR city is null
OR Occupation IS NULL;

--Missing Account Information
select * from Accounts$
where Account_ID IS NULL
OR Customer_ID IS NULL
OR Account_Type IS NULL
OR Balance IS NULL;

--Missing Transactions Info
select * from Transactions$
where Transaction_ID IS NULL
OR Transaction_Date IS NULL
OR Transaction_Type IS NULL
OR Amount IS NULL;

--Missing Loans Transaction
select * from loans$
where Loan_ID IS NULL
OR Loan_Amount IS NULL
OR Loan_Type IS NULL;

--------------------Duplicate Record Checks---------------------
select customer_id, count(*) as duplicate_count
from ['Customers (1)$']
group by Customer_ID
having count(*) > 1;

select account_id, count(*) as duplicate_count
from Accounts$
group by Account_ID
having count(*) > 1;

select transaction_id ,count(*) as duplicate_count
from Transactions$
group by Transaction_ID
having COUNT(*) > 1;

select loan_id, count(*) as duplicate_count
from Loans$
group by Loan_ID
having count(*) > 1;


------------------Referential Integrity Checks------------------

--Accounts Without Customers

select a.account_id,
       a.customer_id
from Accounts$ a
JOIN ['Customers (1)$'] c
ON a.Customer_ID=c.Customer_ID
where c.Customer_ID IS NULL;

--Transactions without account

select t.transaction_id,
       t.account_id
from Transactions$ t 
JOIN Accounts$ a
ON t.account_id = a.account_id
where a.Account_ID IS NULL;

--Loans Without customers
select l.loan_id,
       l.customer_id
from Loans$ l
JOIN ['Customers (1)$'] c
ON l.Customer_ID=c.Customer_ID
where c.Customer_ID IS NULL;

--Customer without accounts

select count(*) as customer_without_accounts
from ['Customers (1)$'] c
JOIN Accounts$ a 
ON c.Customer_ID=a.Customer_ID
where a.Account_ID IS NULL;


--Accounts withhout Transactions

select count(*) as Inactive_accounts
from accounts$ a
JOIN Transactions$ t
ON a.Account_ID = t.Account_ID
where t.Transaction_ID IS NULL;


---------------Banking Analysis Queries--------------------

--Account type Distribution

select account_type, count(*) as no_of_accounts
from Accounts$
group by Account_Type;

--Avg Account Balance
select avg(balance) from Accounts$;

--AVg customer Income
select avg(Annual_Income) from ['Customers (1)$'];

--Avg loan size
select avg(loan_amount) from Loans$;

--Avg Transaction Size
select Avg(amount) from Transactions$;

--Branch Deposit Performance
select b.branch_name,
       sum(a.balance) as total_deposits
from Branches$ b
JOIN Accounts$ a
ON a.Branch_ID=b.Branch_ID
group by b.Branch_Name
order by total_deposits DESC;

--Branch Ranking
select b.branch_name,
       sum(a.balance) as total_deposits,
       rank() over(order by sum(a.balance) DESC) as rnk
from Branches$ b
JOIN Accounts$ a
ON a.Branch_ID=b.Branch_ID
group by b.Branch_Name;

--Customer Distribution By city 

select city, count(customer_ID) as cn from ['Customers (1)$']
group by city order by cn DESC;

--Customer Distru by Income

SELECT
    CASE 
        WHEN c.annual_income < 500000 THEN 'Low Income'
        WHEN c.annual_income <= 1000000 THEN 'Middle Income'
        ELSE 'High Income'
    END AS Income_category,
    COUNT(c.customer_id) AS customers,
    sum(a.balance) as bl
FROM ['Customers (1)$'] c
JOIN Accounts$ a
ON c.customer_id = a.Customer_ID
GROUP BY
    CASE 
        WHEN c.annual_income < 500000 THEN 'Low Income'
        WHEN c.annual_income <= 1000000 THEN 'Middle Income'
        ELSE 'High Income'
    END
order by bl DESC;

--customer Inactive KPI

with customers as (
select customer_id from Accounts$ where Balance < 0
)

select count(*) as inactive_cust,
       round(count(*) / (select count(*) from customers), 2) as Inactive_per
from  ['Customers (1)$']

--Customer Loan Risk Analysis

select c.name,
       c.annual_income,
       l.loan_Amount,
       round(l.loan_amount / c.annual_income,2) as Loan_income_ratio
from ['Customers (1)$'] c
JOIN loans$ l
ON c.Customer_ID=l.Customer_ID;

--customer Branch Logic

select c.customer_id, c.city, a.account_id, a.branch_id
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID;

select * from Branches$;


SELECT 
    COUNT(*) AS Incorrect_Matches
FROM
     ['Customers (1)$'] c
        JOIN
    Accounts$ a ON c.Customer_ID = a.Customer_ID
        JOIN
    Branches$ b ON a.Branch_ID = b.Branch_ID
WHERE
    c.City <> b.City;

UPDATE a
SET a.Branch_ID =
    CASE
        WHEN c.City = 'Kolkata' THEN 100
        WHEN c.City = 'Delhi' THEN 101
        WHEN c.City = 'Mumbai' THEN 102
        WHEN c.City = 'Bangalore' THEN 103
        WHEN c.City = 'Chennai' THEN 104
        WHEN c.City = 'Pune' THEN 105
        WHEN c.City = 'Hyderabad' THEN 106
        WHEN c.City = 'Ahmedabad' THEN 107
    END
FROM Accounts$ a
JOIN['Customers (1)$'] c
    ON a.Customer_ID = c.Customer_ID;

    SELECT 
    c.City, b.Branch_Name, COUNT(a.Account_ID) AS Accounts
FROM
    ['Customers (1)$'] c
        JOIN
    Accounts$ a ON c.Customer_ID = a.Customer_ID
        JOIN
    Branches$ b ON a.Branch_ID = b.Branch_ID
GROUP BY c.City , b.Branch_Name;


select count(*) from Accounts$;

select Count(distinct Branch_id) from Accounts$;

SELECT 
    c.City AS Customer_City,
    b.City AS Branch_City,
    COUNT(a.Account_ID) AS Number_of_Accounts
FROM
     ['Customers (1)$'] c
        JOIN
    Accounts$ a ON c.Customer_ID = a.Customer_ID
        JOIN
    Branches$ b ON a.Branch_ID = b.Branch_ID
GROUP BY c.City , b.City;



--customer by branch

select b.Branch_name, count(a.customer_id) 
from Branches$ b
JOIN Accounts$ a
ON a.Branch_ID = b.Branch_ID
group by b.Branch_Name;

--Deposit Vs Withdrawal 

select transaction_type, count(*), sum(amount)
from Transactions$
group by Transaction_Type;

--High Balance Customers

select top 10 c.name, c.city,a.balance
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
Order by a.Balance DESC;


--Inactive Customer Analysis
SELECT

c.Customer_ID,
c.Name,
c.City,
c.Occupation,
c.Annual_Income, a.Account_ID

FROM  ['Customers (1)$'] c
LEFT JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
WHERE a.Account_ID IS NULL;


--Loan Type Popularity

select loan_type, count(*) as no_of_tran
from Loans$
group by Loan_Type
order by no_of_tran DESC;


--Total Deposits in bank

select sum(balance) as total_deposits
from Accounts$;


--total Number of Customers

select count(*) as no_of_cus from ['Customers (1)$'];

--Total Transaction Volume

select sum(amount) from Transactions$;

--Total loan Portfolio

select sum(loan_amount) from Loans$

--Loan Approval Analysis
select loan_status, count(*) from Loans$ group by Loan_Status;


------------CTES-----------------------------------

--1.Customer with above avg account balance

with cust_avg as(
select avg(balance) as avg_balance from Accounts$
)
select c.customer_id, c.name, c.city, a.balance,
round(a.balance - ab.avg_balance,2) as diff_from_avg
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
CROSS JOIN cust_avg ab
where a.balance >ab.avg_balance
order by a.Balance DESC;

--2.Monthly Transaction Analysis

--Order by is imvalid in CTE
with month_transaction as (select year(transaction_date) as  trans_year,month(transaction_date) as transaction_month,count(transaction_id) as total_trans,
       sum(amount) as total_amount
from Transactions$
Group by  year(transaction_date),month(transaction_date))

select * from month_transaction order by trans_year, transaction_month ASC;

--3.Customer Lifetime value Approximation

with cust_tran as (select a.customer_id,
       sum(t.amount) as total_transaction_value
from Accounts$ a
JOIN Transactions$ t
ON a.Account_ID = t.Account_ID
Group by a.Customer_ID)

select top 20 c.name,c.city,ct.total_transaction_value
from ['Customers (1)$'] c 
JOIN cust_tran ct
ON c.Customer_ID=ct.Customer_ID
order by total_transaction_value DESC;


--4.Loan Risk Categorization
CREATE VIEW VW_LOAN_RISK_ANALYSIS_NW AS
with loan_risk as (
select l.Loan_ID,c.customeR_id,c.name,c.city,c.Occupation,c.annual_income,l.Loan_Type,l.loan_Amount,l.interest_rate,l.loan_status,
       round(l.loan_amount / c.annual_income, 2) as loan_income_ratio
from ['Customers (1)$'] c
JOIN Loans$ l
ON c.Customer_ID=l.Customer_ID
)

select *, 
    case when loan_income_ratio >= 10 then 'CRITICAL RISK'
         when loan_income_ratio between 5 and 10 then 'HIGH RISK'
         WHEN loan_income_ratio BETWEEN 2 AND 5 THEN 'MEDIUM RISK'
         else 'LOW RISK'
    end as risk_category
from loan_risk;

SELECT count(distinct loan_id) FROM VW_LOAN_RISK_ANALYSIS_NW where risk_category='HIGH RISK';

--5.Branch Deposit Ranking

with branch_dep as (select b.branch_name,
       sum(a.balance) as total_deposits
from Branches$ b
JOIN Accounts$ a
ON a.Branch_ID = b.Branch_ID
group by b.Branch_Name)

select * from branch_dep
order by total_deposits DESc;


------------Window Function--------------------------

--1.Rank Customers by balance

select c.customer_id,c.name,c.city,sum(a.balance), rank() over(order by sum(a.balance) DESC) as rnk
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID=a.Customer_ID
group by c.customer_id,c.name,c.city

select * from ['Customers (1)$'] where Customer_ID='12037';

select * from Accounts$ where Customer_ID='12037'; 

--2.Branch Deposit Ranking
select b.branch_name, sum(a.balance) as total_dep, rank() OVER(order by sum(a.balance) DESC) as rnk
from Branches$ b
JOIN Accounts$ a
ON b.Branch_ID=a.Branch_ID
Group by b.Branch_Name

--3.Running Transaction Total
select Transaction_ID, transaction_date,amount,  sum(amount) over(order by transaction_date, transaction_id) as running_total
from Transactions$ 
order by Transaction_date, Transaction_ID


--4.Customer Transaction Ranking 

with cust_tran as (select a.customer_id,sum(t.amount) as total_tran_amount
from Accounts$ a
JOIN Transactions$ t
ON a.Account_ID = t.Account_ID
group by a.Customer_ID
)

select c.name,ct.total_tran_amount,
rank() over(order by ct.total_tran_amount DESC) as rnk
from ['Customers (1)$'] c
JOIN cust_tran ct
ON c.Customer_ID = ct.Customer_ID;

--5.Compare Customer Balance with Avg
select a.Account_ID,c.name,a.balance, round(a.balance - avg(a.balance) OVER(),2) as diff_from_avg
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID;



------------Advance Analysis Queries-----------------
--1.Customer Transaction Frequency
select top 20 c.customer_id,
       c.name,
       count(t.transaction_id) as total_trans,
       sum(t.amount) as total_tran_amount
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
JOIN Transactions$ t
ON a.Account_ID = t.Account_ID
Group by  c.customer_id,
       c.name
order by total_trans DESC;

--2.Customer_deposit Behaviour
--count no of accounts
--sum of there balance
--will take avg balance

select top 20 c.customer_id, 
       c.name,
       count(a.account_id) as no_of_acc,
       sum(a.balance) as total_dep_bal,
       round(avg(a.balance),2) as avg_balance
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
Group by c.customer_id, 
       c.name
order by total_dep_bal DESC;


--3.Customer Transaction_beh Segmentation 

select sum(balance) from Accounts$ where Customer_ID=11399;

create view  vw_customer_activity as 
with trans as (select c.customer_id,c.name,
                      c.city, c.occupation,
                      count(distinct a.account_id) as Number_of_accounts,
       count(t.transaction_id) as total_transactions,
       sum(t.amount) as total_value,
       coalesce(sum(distinct a.balance),0) as Total_balance
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
JOIN Transactions$ t 
ON a.Account_ID=t.Account_ID
group by c.Customer_ID,c.name,c.city, c.occupation)

select *, case when total_transactions >=40 then 'High Activity'
               when total_transactions between 15 and 39 then 'Moderate Activity'
               else 'Low Activity'
          end as transaction_activity_category
from trans;

--4.Customer Engagement Score and category

with customer_metrics as (select c.customer_id, c.name,
       count(distinct a.account_id) as no_of_accounts,
       coalesce(sum(a.balance),0) as total_dep_bal,
       count(t.transaction_id) as total_transactions
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
JOIN Transactions$ t 
ON a.Account_ID=t.Account_ID
group by c.Customer_ID,c.name
),
engagement_score as (
select *, (case when total_transactions >=30 then 3
                when total_transactions >=10 then 2
                else 1
           END
           +
           Case when total_dep_bal >=1000000 then 3
                when total_dep_bal >= 200000 then 2
                else 1
           END
           +
           case when no_of_accounts >= 3 then 3 
                when no_of_accounts = 2 then 2
                else 1
           END
           ) as eng_score

from customer_metrics
)

select *, case when eng_score >=8 then 'High Engagement'
               when eng_score between 5 and 7 then 'Moderate Engagement'
               else 'Low Engagement'
               end as Eng_category
 from engagement_score
 order by total_transactions DESC;

 --Customer Lifetime Value Analysis
 --total_balance
 --total_transactions
 --Total_loan_amount

 select max(balance) , min(balance), avg(balance) from Accounts$;

with cte as (select customer_id, sum(loan_amount)  as la
from Loans$ 
group by Customer_ID)

select max(la), min(la), avg(la) from cte;

 with customer_value_base as( select c.customer_id,
        c.name,
        coalesce(sum( distinct a.balance), 0) as total_balance,
        count(distinct t.transaction_id) as total_trans,
        coalesce(sum(distinct l.loan_amount),0) as total_loan_amount
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
JOIN Transactions$ t
ON t.Account_ID = a.Account_ID
JOIN Loans$ l
ON c.Customer_ID = l.Customer_ID
Group by c.Customer_ID, c.name
),
CLV_scoring as (

select *, 
--Deposit score 
case 
     when total_balance >=1000000 then 40
     when total_balance >=200000 then 25
     else 10
     end as deposite_score,
--Transaction_score 
case 
     when total_trans >=30 then 30
     when total_trans >=10 then 20
     else 10
     end as transaction_score,
--Loan Score
case
     when total_loan_amount >= 5000000  then 30 
     when total_loan_amount >= 1000000 then 20
     when total_loan_amount > 0 then 10
     else 0
     end as loan_score
from customer_value_base

),
Customer_CLV as(
select *,deposite_score + transaction_score + loan_score as CLV_score
from CLV_scoring
)

Select case when CLV_score >= 80 then 'High Value Customer'
            when clv_score between 50 and 79 then 'Moderate Value Customer'
            else 'Low Value Customer'
            end as CLV_TIER,
       count(*) as no_of_Customers,
       round(count(*) * 100.0 / (select count(*) from customer_CLV),2) as per_of_cust
from Customer_CLV
group by case when CLV_score >= 80 then 'High Value Customer'
            when clv_score between 50 and 79 then 'Moderate Value Customer'
            else 'Low Value Customer'
            end;


select *,
ROW_NUMBER() OVER(order by clv_score DESC) as rnk
from Customer_CLV
order by rnk;


--Customer Segmentation Analysis

with customer_summary  as (select c.customer_id,c.name,c.annual_income,
       coalesce(sum(distinct a.balance) ,0) as Total_balance,
       count(distinct t.transaction_id) as Total_transactions,
       coalesce(sum(distinct l.loan_amount),0) as Total_loan_amount
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
JOIN Transactions$ t
ON a.Account_ID=t.Account_ID
JOIN Loans$ l
ON c.Customer_ID=l.Customer_ID
group by c.customer_id,c.name,c.annual_income
),
customer_scoring as (

select *,
       case when annual_income >= 2000000 THEN 3
            WHEN Annual_Income >= 800000 THEN 2
            else 1
        end as Income_score,
        case when total_balance >= 1000000 THEN 3
             WHEN Total_Balance >= 200000 THEN 2
             ELSE 1
        END AS Balance_Score,
        CASE WHEN Total_Transactions >= 50 THEN 3
             WHEN Total_Transactions >= 15 THEN 2
             ELSE 1
        END AS Activity_Score
from customer_summary
),
customer_seg as (select *, (income_score + Balance_score + Activity_score) as customer_value_Score,
       case when (income_score + Balance_score + Activity_score) >=7 then 'Premium Customers'
            when (income_score + Balance_score + Activity_score) between 5 and 6 then 'Regular Customer'
            else 'Low Engagement Customer'
       end as customer_segment
from customer_scoring)



select customer_segment, count(*) as no_of_customer,
       round(count(*) * 100.0 / (select count(*) from customer_seg),2) as perc_of_customer
from customer_seg
group by customer_segment;

with CTE as(select customer_id, sum(annual_income) as ai
from ['Customers (1)$'] 
Group by Customer_ID)

select min(ai), max(ai), avg(ai) from cte;

--Loan Risk Analysis


select top 10 * from Loans$;

--Loan Distribution by type

select loan_type,count(*) as no_of_loan_application
from Loans$
group by Loan_Type
order by no_of_loan_application DESC;

--Loan Status Analysis

select loan_status, count(*) as no_of_loans,
       sum(loan_amount) as total_loan_value
from Loans$ 
group by Loan_Status;

--Loan Status Contribution%
select loan_status, count(Loan_ID) as no_of_loans,
       round(count(Loan_ID) * 100.0 / (select count(Loan_ID) from loans$),2) as per_of_total_application
from Loans$ 
group by Loan_Status
order by per_of_total_application DESC;

--Loan Amount Contribution %
select loan_status, count(Loan_ID) as no_of_loans,
       sum(loan_amount) as total_loan_value,
       round(sum(loan_amount) * 100.0 / (select sum(loan_amount) from loans$),2) as per_of_total_application
from Loans$ 
group by Loan_Status
order by per_of_total_application DESC;

-------------Loan Type Analysis------------------------
--Approved Loans

--Approved loan portfolio

select count(*) as total_approved_loans,
       sum(loan_amount) as Actual_loan,
       round(avg(loan_amount),2) as avg_approved_loan_amount,
       max(loan_amount) as largest_loan_amt,
       min(loan_amount)  as smallest_approved_loan
from Loans$
where Loan_Status='Approved';

--Approved loan by loan_type 

SELECT 
Loan_Type,
COUNT(*) AS Approved_Loans,
SUM(Loan_Amount) AS Approved_Loan_Exposure,
ROUND(AVG(Loan_Amount), 2) AS Average_Approved_Loan_Size

FROM Loans$
GROUP BY Loan_Type
ORDER BY Approved_Loan_Exposure DESC;

--

--Product Risk Analysis

--1.Account product Analysis
select account_type, count(*) as no_of_accounts,
       count(distinct customer_Id) as no_of_cust,
       sum(balance) as total_deposit_value,
       round(avg(balance),2) as avg_acc_bal
from Accounts$
group by Account_Type;

--2.Loan Product Analysis
select loan_type, count(*) as no_of_loans,
       sum(loan_amount) total_value,
       round(avg(loan_amount),2) as avg_loan_size,
       round(sum(loan_amount)  *100.0 / (select sum(loan_amount) from loans$),2) as per
from Loans$
group by Loan_Type
Order by total_value DESC;

--3.Customer Product Adoption Analysis

with customer_prod as (select c.customer_id,
       c.name,
       count(distinct a.account_id) as no_of_accounts,
       count(distinct l.loan_id) as no_loan_id
from ['Customers (1)$'] c
LEFT JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
LEFT JOIN Loans$ l
On l.Customer_ID = c.Customer_ID
group by c.Customer_ID, c.name
)
select *, (no_of_accounts + no_loan_id) as total_products
from customer_prod
order by total_products DESC;

--4.Product Contribution Ranking

--Account Product Contr

select 'Account Product' as Product_category,
        Account_type as product_name,
        Count(account_id) as product_count,
        sum(balance) as product_value
from Accounts$
group by Account_Type

UNION ALL

--Loan Product contri
select 'Loan Category' aS prodcut_category,
       Loan_type as product_name,
       count(loan_id) as product_count,
       sum(loan_amount) as product_value
from Loans$
group by Loan_Type
order by product_value DESC;

------------Stored Procedure--------------------


create procedure sp_get_customer_profile
  @cust_id int
AS
Begin 
       set nocount ON;
Select c.customer_id,
       c.name,
       c.city,
       c.occupation,
       c.Annual_income,
       count(Distinct a.account_id) as No_of_accounts,
       coalesce(sum(a.balance),0) as Total_balance,
       Count(distinct l.loan_id) as total_loans,
       coalesce(sum(l.loan_amount),0) as Total_loan_amount,
       case when count(distinct a.account_id) = 0
            AND count(distinct l.loan_id)=0
            then 'Registered But Inactive'
            
            when  count(distinct a.account_id) > 0 
            then 'Actie Banking Customer'

            when count(distinct l.loan_id) > 0
            then 'Loan Customer'
            end as 'Customer Status '
from ['Customers (1)$'] c
LEFT JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
LEFT JOIN Loans$ l
ON c.Customer_ID = l.Customer_ID

where c.customer_id = @cust_id

Group by c.Customer_ID,
         c.name,
         c.city,
         c.Occupation,
         c.Annual_Income;
END;
GO


EXEC sp_get_customer_profile @cust_id=10002;

---Branch Performance Report 
CREATE PROCEDURE sp_get_branch_performance
  @branch_id_input int
AS
BEGIN 

select b.Branch_id,
       b.branch_name,
       b.city,
       count(a.account_id) as total_accounts,
       sum(a.balance) as total_deposits,
       AVG(a.balance) as AVG_Balance
from Branches$ b
JOIN Accounts$ a
ON b.Branch_ID = a.Branch_ID
Where b.Branch_ID = @branch_id_input

Group by b.Branch_ID,
         b.Branch_Name,
         b.city
END;
GO 

EXEC sp_get_branch_performance @branch_id_input = 105;


--Customer Loan Risk Report


CREATE PROCEDURE sp_get_customer_loan_risk
  @cust_id_input int 
AS 
BEGIN

select c.customer_id,
       c.name,
       c.annual_income,
       count(l.loan_id) as no_of_loans,
       coalesce(sum(l.loan_amount), 0) as Total_loan_amount,
       coalesce(AVG(l.loan_amount),0) as AVG_Loan_amount,
       CASE when count(l.loan_id) = 0 then 'NO LOAN'
            when sum(l.loan_amount) / c.annual_income  > 5  then 'HIGH RISK'
            when sum(l.loan_amount) / c.annual_income between 2 and 5 then 'MEDIUM RISK'
            else 'LOW RISK'
       end as Risk_category
FROM ['Customers (1)$'] c
LEFT JOIN Loans$ l
ON c.Customer_ID = l.Customer_ID
WHERE c.Customer_ID = @cust_id_input

GROUP BY
c.Customer_ID,
c.Name,
c.Annual_Income
END;
GO


EXEC sp_get_customer_loan_risk @cust_id_input = 10002;


--Customer Transaction Summary

CREATE PROCEDURE sp_get_transaction_summary
  @cust_id_input int
AS 
BEGIN

select c.customer_id,
       c.name,
       count(t.transaction_id) as Total_transactions,
       coalesce(sum(t.amount),0) as Total_amount,
       Coalesce(avg(t.amount),0) as avg_tran_value
FROM ['Customers (1)$'] c
LEFT JOIN Accounts$ a 
ON c. Customer_ID = a. Customer_ID

LEFT JOIN Transactions$ t
ON a. Account_ID = t. Account_ID
WHERE c. Customer_ID = @cust_id_input

GROUP BY
c. Customer_ID,
c. Name
END;
GO
EXEC sp_get_transaction_summary @cust_id_input = 10002;

------------Indexing--------------------------------

CREATE INDEX idx_transaction_date
on Transactions$(transaction_date);

SELECT *
FROM Transactions$
WHERE Transaction_Date = '2023-06-16'

EXEC sp_helpindex 'Transactions$';


EXEC sp_helpindex 'Accounts$';

-------------Views-------------------------------

--View 1 : High Value Customers

CREATE VIEW High_value_customer AS
Select
      c.customer_id,
      c.name,
      c.city,
      a.Account_id,
      a.balance
from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
where a.Balance > 1000000

select * from High_value_customer
order by balance DESC;

--View 2
--Branch Performance

CREATE VIEW Branch_performance AS
select 
      b.branch_id,
      b.branch_name,
      count(a.account_id) as no_of_accounts,
      sum(a.balance) as total_balance,
      avg(a.balance) as AVG_Balance
from Branches$ b
JOIN Accounts$ a
ON b.Branch_ID = a.Branch_ID
group by b.branch_id,
      b.branch_name;

select * from Branch_performance;

--Branch Performance view

CREATE VIEW vw_customer_primary_branch AS
SELECT
    a.Customer_ID,
    a.Account_ID,
    a.Branch_ID,
    a.Opening_Date
FROM Accounts$ a
WHERE a.Opening_Date =
(
    SELECT MIN(a2.Opening_Date)
    FROM Accounts$ a2
    WHERE a2.Customer_ID = a.Customer_ID
);

create view vw_branch_performance AS

select 
      b.branch_id,
      b.branch_name,
      b.city,
      b.manager_name,
      coalesce(a.number_of_accounts,0) as number_of_accounts,
      coalesce(a.number_of_customers,0) as number_of_customers,
      coalesce(a.total_deposits, 0) as total_deposits,

      coalesce(t.total_transactions,0) as total_transactions,
      coalesce(t.total_transaction_value, 0) as total_transaction_value, 

      coalesce(l.Total_Approved_loans,0) as Total_Approved_loans,
      coalesce(l.Total_loan_exposure,0) as Total_loan_exposure

from Branches$ b 

LEFT JOIN 
(
   select Branch_ID,
          count(account_id) as number_of_accounts,
          count(distinct customer_id) as number_of_customers,
          sum(balance) as total_deposits
from Accounts$ 
Group by Branch_ID
) a
ON b.branch_id= a.branch_id
LEFT JOIN 
(
  select ac.branch_id,
         count(t.transaction_id) as total_transactions,
         sum(t.amount) as total_transaction_value
  from Transactions$ t
  JOIN Accounts$ ac
  ON t.Account_ID=ac.Account_ID

  group by ac.branch_id
  ) t
  ON b.branch_id=t.branch_id
  LEFT JOIN
  (
     select 
           cpb.branch_id,
           count(distinct l.loan_id) as Total_Approved_loans,
           sum(l.loan_amount) as Total_loan_exposure
     from Approved_loan_portfolio l
     JOIN vw_customer_primary_branch cpb
     ON l.Customer_ID = cpb.Customer_ID
  group by cpb.Branch_ID
  ) l
  ON b.branch_id = l.branch_id;


 drop view vw_branch_performance;

--View 3
--Customer Account Summary

CREATE VIEW Customer_Account_Summary AS
Select 
      c.customer_id,
      c.name,
      c.city,
      c.Occupation,
      c.annual_income,

      a.account_id,
      a.account_type,
      a.balance

from ['Customers (1)$'] c
JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID


select * from Customer_Account_Summary


--View 4 
--Loan Portfolio Summary
create view Loan_Portfolio_summary AS
select l.loan_id,
       c.name,
       c.city,
       l.loan_type,
       l.loan_amount,
       l.loan_status
from ['Customers (1)$'] c
JOIN Loans$ l
ON c.Customer_ID = l.Customer_ID;



select * from Loans$

--View 5 
--Customer Risk View
CREATE VIEW Customer_risk_view AS
select c.customer_id,
       c.name,
       c.annual_income,
       l.loan_amount,
       round(l.loan_amount / c.annual_income, 2) as Loan_income_ratio
from ['Customers (1)$'] c
JOIN Loans$ l
ON c.Customer_ID = l.Customer_ID;



--View 6 
--Inactive Customer Summary

CREATE VIEW Inactive_Customers AS
select c.customer_id,
       c.name,
       c.city,
       c.occupation,
       c.annual_income
from ['Customers (1)$'] c
LEFT JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID
where a.Account_ID IS NULL;

--View 7
--Customer Status View

CREATE VIEW Customer_status_Analysis AS 
select c.customer_id,
       c.name,
       case when a.account_id IS null then 'Inactive Customer'
       else 'Active Customer'
       end as Customer_Status
from ['Customers (1)$'] c
LEFT JOIN Accounts$ a
ON c.Customer_ID = a.Customer_ID;

--View 8
--Approved Loan Portfolio
Create View Approved_loan_portfolio AS 
select * from Loans$ 
where Loan_Status='Approved';

--View 9 
--Executive KPIs
--Total Customer, Total Accounts, Total Deposits, Total Transactions, Total Loan Applications, approved loan portfolio, AVG Account Balance
CREATE OR ALTER VIEW vw_executive_kpis
AS
SELECT
    -- Total Customers
    (SELECT COUNT(*)
     FROM ['Customers (1)$']) AS Total_Customers,

    -- Total Accounts
    (SELECT COUNT(*)
     FROM Accounts$) AS Total_Accounts,

    -- Total Deposits
    (SELECT COALESCE(SUM(Balance), 0)
     FROM Accounts$) AS Total_Deposits,

    -- Total Transactions
    (SELECT COUNT(*)
     FROM Transactions$) AS Total_Transactions,

    -- Total Loan Applications
    (SELECT COUNT(*)
     FROM Loans$) AS Total_Loan_Applications,

    -- Approved Loan Portfolio
    (SELECT COUNT(*)
     FROM Loans$
     WHERE Loan_Status = 'Approved') AS Approved_Loan_Portfolio,

    -- Average Account Balance
    (SELECT ROUND(AVG(Balance), 2)
     FROM Accounts$) AS Average_Account_Balance;
GO


select * from vw_executive_kpis;


--Account Product Analysis 

CREATE view vw_account_product_analysis AS
select account_type, 
       count(account_id) as Number_of_accounts,
       count(distinct customer_id) as number_of_customers,
       sum(balance) as Total_deposit_balance,
       round(avg(balance),2) as Avg_Account_balance,
       round(count(account_id) * 100.0 / (select count(*) from Accounts$),2) as Account_distribution_per
from Accounts$ 
group by Account_Type;


---Loan Product Analysis

create view vw_loan_product_analysis as 
select loan_type,
       count(loan_id) as number_of_approved_loans,
       sum(loan_Amount) as total_loan_exposure,
       round(avg(loan_amount),2) as avg_loan_size,
       round(sum(loan_amount) * 100.0 / (select sum(loan_amount)  from approved_loan_portfolio),2) as Portfolio_contribution_per
from Approved_loan_portfolio
group by Loan_Type;



--View Customer 360
create view vw_customer_details_360 AS
select c.customer_id,
       c.name,
       c.city,
       c.occupation,
       c.Annual_income,

       --Account Metrix
       coalesce(a.no_of_accounts, 0) as Number_of_accounts,
       coalesce(a.total_balance, 0) as Total_Balance,

       --Transaction Metrix
       coalesce(t.Total_transactions, 0) as Total_transactions,
       coalesce(t.total_transaction_value, 0) as Total_transaction_value,


       --Loan Metrix
       coalesce(l.total_approved_loans,0) as Total_Approved_loans,
       coalesce(l.Total_Loan_exposure, 0) as Total_Loan_exposure
from ['Customers (1)$'] c
--Account Summary
LEFT JOIN (
 select customer_id,
        count(account_id) as no_of_accounts,
        sum(balance) as total_balance
from Accounts$
group by Customer_ID
) a
On c.Customer_ID = a.Customer_ID
--Transaction Summary
LEFT JOIN (
  select ac.customer_id,
         count(t.transaction_id) as Total_transactions,
         sum(t.amount) as total_transaction_value
  from Transactions$ t 
  JOIN Accounts$ ac
  ON t.Account_ID = ac.Account_ID
  Group by ac.Customer_ID
) t 
ON c.Customer_ID = t.Customer_ID
LEFT JOIN (
 select customer_id,
        count(loan_id) as total_approved_loans,
        sum(loan_amount) as Total_Loan_exposure
  from Loans$
  group by Customer_ID
) l
ON c.Customer_ID = l.Customer_ID;



--view Transaction Activity
Create view vw_transaction_activity AS 
select 
       format(transaction_date, 'yyyy-MM') as Transaction_month,
       transaction_type,
       count(transaction_id) as number_of_transactions,
       sum(amount) as total_transaction_value,
       avg(amount) as avg_transaction_amount,
       count(distinct account_id) as active_accounts,
       count(distinct customer_id) as Active_customers

from 
(
    select 
           t.transaction_id,
           t.account_id,
           a.customer_id,
           t.transaction_date,
           t.transaction_type,
           t.amount
    from transactions$ t
    JOIN Accounts$ a
    ON t.account_id = a.account_id
) x 
Group by  format(transaction_date, 'yyyy-MM'),
          transaction_type;

--view Transaction KPIs

Create view Vw_transaction_kpis AS 
select count(distinct t.account_id) as Active_accounts,
       count(distinct a.customer_id) as Active_customers,
       count(t.transaction_id) as Total_transactions,
       sum(t.amount) as Total_transaction_value,
       Avg(t.amount) as Avg_transaction_value
from Transactions$ t
JOIN Accounts$ a
ON t.Account_ID = a.Account_ID;



ALTER TABLE Accounts$
ADD CONSTRAINT FK_Accounts_Customers
FOREIGN KEY (Customer_ID)
REFERENCES ['Customers (1)$'](Customer_ID);

SELECT
    Customer_ID,
    COUNT(*) AS Duplicate_Count
FROM ['Customers (1)$']
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

SELECT *
FROM ['Customers (1)$']
WHERE Customer_ID IS NULL;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers (1)$'
  AND COLUMN_NAME = 'Customer_ID';

alter table ['Customers (1)$']
alter column customer_id float not null;

ALTER TABLE ['Customers (1)$']
ADD CONSTRAINT PK_Customers
PRIMARY KEY (Customer_ID);

ALTER TABLE Loans$
ADD CONSTRAINT FK_Loans_Customers
FOREIGN KEY (Customer_ID)
REFERENCES ['Customers (1)$'](Customer_ID);

Alter table accounts$
alter column account_id float not null;

ALTER TABLE Accounts$
ADD CONSTRAINT PK_Accounts
PRIMARY KEY (Account_ID);

ALTER TABLE Transactions$
ADD CONSTRAINT FK_Transactions_Accounts
FOREIGN KEY (Account_ID)
REFERENCES Accounts$(Account_ID);

alter table branches$
alter column branch_id float not null;

alter table branches$
add constraint pk_branch_id
Primary Key(branch_id);

alter table accounts$
add CONSTRAINT fk_branchID
foreign KEY(branch_id)
references Branches$(branch_id);


CREATE VIEW customer_segmentation_view AS

WITH account_summary AS
(
    SELECT
        a.Customer_ID,
        COALESCE(SUM(a.balance), 0) AS Total_Balance
    FROM Accounts$ a
    GROUP BY a.Customer_ID
),

transaction_summary AS
(
    SELECT
        a.Customer_ID,
        COUNT(DISTINCT t.Transaction_ID) AS Total_Transactions,
        sum(t.amount) as Total_transaction_value
    FROM Accounts$ a
    JOIN Transactions$ t
        ON a.Account_ID = t.Account_ID
    GROUP BY a.Customer_ID
),

loan_summary AS
(
    SELECT
        l.Customer_ID,
        COALESCE(SUM(l.Loan_Amount), 0) AS Total_Loan_Amount
    FROM Loans$ l
    GROUP BY l.Customer_ID
),

customer_summary AS
(
    SELECT
        c.Customer_ID,
        c.Name,
        c.Annual_Income,
        c.City,
        c.Occupation,

        COALESCE(a.Total_Balance, 0) AS Total_Balance,
        COALESCE(t.Total_Transactions, 0) AS Total_Transactions,
        COALESCE(l.Total_Loan_Amount, 0) AS Total_Loan_Amount,
        coalesce(t.Total_transaction_value,0) as Total_transaction_value

    FROM ['Customers (1)$'] c

    LEFT JOIN account_summary a
        ON c.Customer_ID = a.Customer_ID

    LEFT JOIN transaction_summary t
        ON c.Customer_ID = t.Customer_ID

    LEFT JOIN loan_summary l
        ON c.Customer_ID = l.Customer_ID
),

customer_scoring AS
(
    SELECT
        *,
        
        CASE
            WHEN Annual_Income >= 2000000 THEN 3
            WHEN Annual_Income >= 800000 THEN 2
            ELSE 1
        END AS Income_Score,

        CASE
            WHEN Total_Balance >= 1000000 THEN 3
            WHEN Total_Balance >= 200000 THEN 2
            ELSE 1
        END AS Balance_Score,

        CASE
            WHEN Total_Transactions >= 50 THEN 3
            WHEN Total_Transactions >= 15 THEN 2
            ELSE 1
        END AS Activity_Score

    FROM customer_summary
),

customer_seg AS
(
    SELECT
        *,
        Income_Score + Balance_Score + Activity_Score 
            AS Customer_Value_Score,

        CASE
            WHEN Income_Score + Balance_Score + Activity_Score >= 7
                THEN 'Premium Customers'

            WHEN Income_Score + Balance_Score + Activity_Score BETWEEN 5 AND 6
                THEN 'Regular Customer'

            ELSE 'Low Engagement Customer'
        END AS Customer_Segmentation

    FROM customer_scoring
)

SELECT
    Customer_ID,
    Name,
    Annual_Income,
    City,
    Occupation,
    Customer_Segmentation,
    Customer_Value_Score,
    Total_Balance,
    Total_Loan_Amount,
    Total_Transactions,
    sum(Total_transaction_value) as sn
FROM customer_seg
where Customer_Segmentation='Premium Customers';


select customer_id,sum(Total_transaction_value) as sn from customer_segmentation_view
where Customer_Segmentation='Premium Customers'
group by Customer_ID;

