-- Customer Segmentation & Churn Pattern Analytics in European Banking
CREATE DATABASE IF NOT EXISTS project_1;
USE project_1;

-- Open MySQL Workbench Go to your schema → project_1 Right-click → Table Data Import Wizard
-- Select: bank_churn_clean.csv Choose: Use existing table → bank_churn_clean

-- DATA EXPLORATION
-- COUNT ROWS
SELECT COUNT(*) FROM bank_churn_clean;

-- SAMPLE DATA 
SELECT * FROM bank_churn_clean 
LIMIT 10;

-- SHOW NULL VALUES 
SELECT * FROM bank_churn_clean
WHERE
CreditScore IS NULL
OR
Geography IS NULL
OR
Gender IS NULL
OR
Age IS NULL
OR
Tenure IS NULL
OR
Balance IS NULL
OR
NumOfProducts IS NULL
OR
HasCrCard IS NULL
OR 
IsActiveMember IS NULL
OR 
EstimatedSalary IS NULL
OR 
Exited IS NULL;


-- DIFFERENT GEOGRAPHY PLACES
SELECT DISTINCT Geography FROM bank_churn_clean
ORDER BY Geography;


-- Create Customer Segments
DROP VIEW IF EXISTS customer_segments;
CREATE VIEW customer_segments AS
SELECT *,
-- Age Segment
CASE
    WHEN Age < 30 THEN 'Under 30'
    WHEN Age BETWEEN 30 AND 45 THEN '30-45'
    WHEN Age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS AgeGroup,
-- Credit Score Segment
CASE
    WHEN CreditScore < 500 THEN 'Low'
    WHEN CreditScore BETWEEN 500 AND 700 THEN 'Medium'
    ELSE 'High'
END AS CreditScoreGroup,
-- Tenure Segment
CASE
    WHEN Tenure <= 3 THEN 'New Customer'
    WHEN Tenure BETWEEN 4 AND 7 THEN 'Mid-term Customer'
    ELSE 'Long-term Customer'
END AS TenureSegment,
-- Balance Segment
CASE
    WHEN Balance = 0 THEN 'Zero Balance'
    WHEN Balance > 0 AND Balance <= 100000 THEN 'Low Balance'
    ELSE 'High Balance'
END AS BalanceSegment
FROM bank_churn_clean;


-- Calculate Key KPIs

-- 1 Overall Churn Rate
SELECT
COUNT(*) AS total_customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*), 2) AS churn_rate
FROM bank_churn_clean;


-- 2 Churn by Geography
SELECT
Geography,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate,
ROUND(SUM(Exited)/(SELECT SUM(Exited) FROM bank_churn_clean)*100,2) AS churn_contribution
FROM bank_churn_clean
GROUP BY Geography
ORDER BY churn_rate DESC;
-- Germany has Higher churn rate


-- 3 Churn by Gender Analysis
SELECT
Gender,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM bank_churn_clean
GROUP BY Gender;
-- Females have Higher churn rate


-- 4 Churn by Age Group
SELECT
AgeGroup,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM customer_segments
GROUP BY AgeGroup;
-- Age group - 46-60 have higher churn rate 
-- Under 30 have low churn rate


-- 5 Churn by TenureSegment
SELECT
TenureSegment,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate,
ROUND(SUM(Exited) / (SELECT SUM(Exited) FROM customer_segments) * 100, 2) AS churn_contribution
FROM customer_segments
GROUP BY TenureSegment
ORDER BY churn_rate DESC;
-- Mid-term Customers have Higher Churn rate


-- 6 Churn by Balance 
SELECT
BalanceSegment,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate, 
ROUND(SUM(Exited)/(SELECT SUM(Exited) FROM customer_segments)*100,2) AS churn_contribution
FROM customer_segments
GROUP BY BalanceSegment
ORDER BY churn_rate DESC;
-- High balance Segment Customers have Higher Churn rate and High Contribution to churn


-- 7 Churn by Product Usage Analysis
SELECT
NumOfProducts,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) churn_rate
FROM bank_churn_clean
GROUP BY NumOfProducts
ORDER BY NumOfProducts;
-- Customers with 4 products have Higher Churn rate 
-- Churn products - 4>3>1>2


-- 8 Churn by Active vs Inactive Customer
SELECT
IsActiveMember,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM bank_churn_clean
GROUP BY IsActiveMember;
-- Inactive Customers have Higher Churn rate 


-- 9 Churn by Salary Analysis
SELECT
CASE
    WHEN EstimatedSalary < 50000 THEN 'Low Salary'
    WHEN EstimatedSalary BETWEEN 50000 AND 100000 THEN 'Medium Salary'
    ELSE 'High Salary'
END AS SalarySegment,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM bank_churn_clean
GROUP BY SalarySegment
ORDER BY churn_rate DESC;
-- High Salary and Low Salary customers churn most


-- 10 Churn by Credit Score 
SELECT
CreditScoreGroup,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM customer_segments
GROUP BY CreditScoreGroup
ORDER BY churn_rate DESC;
-- Low Credit Score customers have higher churn rate


-- ANALYSIS

--  1 Geography + Age Analysis
SELECT
Geography,
AgeGroup,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM customer_segments
GROUP BY Geography, AgeGroup
ORDER BY Geography;
-- AgeGroup 30 - 45 is most likely to churn in each geography 
-- Middle-aged customers 30–45 show higher churn


-- 2 High Value Customer Churn Analysis
SELECT
COUNT(*) AS high_value_customers,
SUM(Exited) AS churned_high_value,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM bank_churn_clean
WHERE Balance > 100000;
-- How much churn comes from premium customers


-- 3 High Balance + Isactive Risk Churn Analysis
SELECT
BalanceSegment,
IsActiveMember,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM customer_segments
GROUP BY BalanceSegment, IsActiveMember
ORDER BY churn_rate DESC;
-- Inactive customers with high balances show the highest churn rate
-- This segment represents maximum financial
-- Highest churn = High Balance + Inactive, This is the most dangerous segment


-- 4 Geography + Balance Risk Churn Analysis
SELECT
Geography,
BalanceSegment,
COUNT(*) AS customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM customer_segments
GROUP BY Geography, BalanceSegment
ORDER BY churn_rate DESC;
-- Regions show High churn in high balance segment (Risky)
-- Others regions show churn in low balance (less risky financially)
-- High balance customers churning more


-- 5 Geography + High-Value Focus Churn Analysis
SELECT
Geography,
COUNT(*) AS high_value_customers,
SUM(Exited) AS churned_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM customer_segments
WHERE BalanceSegment = 'High Balance'
GROUP BY Geography
ORDER BY churn_rate DESC;
-- Certain countries show higher churn among high-balance customers
-- Indicates regional dissatisfaction or competition pressure
-- High-value customers are churning more


-- 6 Product Usage Churn Analysis
SELECT
CASE 
    WHEN NumOfProducts = 1 THEN 'A'
    WHEN NumOfProducts = 2 THEN 'B'
    WHEN NumOfProducts = 3 THEN 'C'
    WHEN NumOfProducts = 4 THEN 'D'
END AS Product_Category,
COUNT(*) AS total_customers,
SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) AS active_customers,
ROUND(AVG(Exited)*100,2) AS churn_rate
FROM bank_churn_clean
GROUP BY Product_Category
ORDER BY Product_Category;
-- Customers with 4 and 3 products show highest churn rate
-- Customers with 2 products show lowest churn and with 1 product shows mixed behavior


-- 7 Churned vs Retained Profile Comparison
SELECT
Exited,
COUNT(*) AS customers,
ROUND(AVG(Age),2) AS avg_age,
ROUND(AVG(CreditScore),2) AS avg_credit_score,
ROUND(AVG(Balance),2) AS avg_balance,
ROUND(AVG(EstimatedSalary),2) AS avg_salary,
ROUND(AVG(Tenure),2) AS avg_tenure
FROM customer_segments
GROUP BY Exited;
-- Middle age (above 40) May have Higher balance Lower engagement and 
-- Credit score differences may indicate Risk profile differences
-- Churn is linked to customer profile patterns


-- 8 Churned vs retained by geography
SELECT
Geography,
SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) AS retained_customers,
COUNT(*) AS total_customers,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM bank_churn_clean
GROUP BY Geography
ORDER BY churn_rate DESC;
-- Germany show High churn rate and High customer base
-- Spain and France show Low churn rate and more Retained customers


-- 9 Revenue Risk Analysis by Balance Segment
SELECT
BalanceSegment,
SUM(Balance) AS total_balance,
SUM(CASE WHEN Exited = 1 THEN Balance ELSE 0 END) AS balance_lost
FROM customer_segments
GROUP BY BalanceSegment;
-- High balance segment contributes most to total balance also contributes largest amount to loss
-- Even if churn rate is lower - loss is higher
-- Revenue risk is concentrated in premium customers


-- 10 Revenue loss by geography
SELECT
Geography,
SUM(Balance) AS total_balance,
SUM(CASE WHEN Exited = 1 THEN Balance ELSE 0 END) AS balance_lost,
ROUND(
    SUM(CASE WHEN Exited = 1 THEN Balance ELSE 0 END) /
    SUM(Balance) * 100, 2
) AS loss_percentage,
ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM bank_churn_clean
GROUP BY Geography
ORDER BY balance_lost DESC;
-- Shows actual financial loss 
-- Region with Highest balance lost ≠ highest churn rate
-- 	Germany with high churn rate lost more balance than France and Spain


-- 11 Revenue Risk Estimation.
SELECT
SUM(Balance) AS total_balance_lost
FROM bank_churn_clean
WHERE Exited = 1;
-- Total balance lost gives Direct financial impact of churn

-- Dataset for Power BI - clean analysis dataset.
SELECT 
Geography,
Gender,
AgeGroup,
CreditScoreGroup,
BalanceSegment,
TenureSegment,
NumOfProducts,
IsActiveMember,
Balance,
EstimatedSalary,
CASE
    WHEN EstimatedSalary < 50000 THEN 'Low Salary'
    WHEN EstimatedSalary BETWEEN 50000 AND 100000 THEN 'Medium Salary'
    ELSE 'High Salary'
END AS SalarySegment,
CASE
    WHEN Balance > 100000 AND IsActiveMember = 0 THEN 'High Risk'
    ELSE 'Normal'
END AS RiskSegment,
CASE
    WHEN Exited = 1 THEN Balance ELSE 0
END AS RevenueLost,
Exited
FROM customer_segments;
