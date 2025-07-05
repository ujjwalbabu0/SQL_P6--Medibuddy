# SQL_Project_6--Medibuddy
**Author - Ujjwal Babu**

![Medibuddy](https://github.com/user-attachments/assets/b7274355-1496-454f-a745-db535052b5d3)


# 🏥 MediBuddy SQL Analytics (SQL Project)
**
A comprehensive SQL project designed to analyze and derive insights from a healthcare platform database — **MediBuddy**. It includes customer behavior analysis, revenue tracking, cohort segmentation, and operational insights using advanced SQL techniques.**

------------------------------------------------------------------------------------------------

## Project Overview

- **Level:** Intermediate to Advanced
- **Database:** `medibuddy_db`
- **Skills Covered:** SQL joins (INNER, LEFT, RIGHT), Aggregate functions (SUM, AVG, COUNT, ROUND), Window functions (ROW_NUMBER(), RANK(), LAG(), LEAD()), Date/time formatting and calculation (DATEDIFF, DATE_FORMAT), Subqueries and CTEs, Conditional logic (CASE WHEN), Customer segmentation, Funnel and cohort analysis, Revenue and profit analysis

------------------------------------------------------------------------------------------------

## Objectives
1. **Database Setup**
Design a relational schema to store user data, consultations, medicine orders, and health checkups.
2. **Descriptive Analytics**
Understand user demographics, service usage trends, and popular specialties.
3. **Revenue Analysis**
Calculate total and segmented revenue, assess profitability, and model pricing impact.
4. **Customer Behavior & Segmentation**
Identify high-value users, and inactive users, and categorize customers based on spending and behavior.
5. **Operational Insights**
Analyze seasonality, underserved specialties, and drop-offs in the service funnel.
6. **Advanced Analysis**
Measure customer lifetime value (LTV), acquisition cost, and post-checkup purchase behavior.

------------------------------------------------------------------------------------------------

## 🗂️ Project Structure
medibuddy-sql-project/
├── checkups.csv              # Dataset for health checkup bookings  
├── consultations.csv         # Dataset for doctor consultations  
├── orders.csv                # Dataset for medicine orders  
├── users.csv                 # Dataset for user demographics and registration  
├── P6_Medibuddy.sql          # Main SQL file with all 33 analytical queries  
├── README.md                 # Project overview and documentation  


# File Descriptions
-- **users.csv** – Contains user information: age, gender, city, and registration date.
-- **consultations.csv** – Details of consultation activities including date, fee, mode, and specialty.
-- **orders.csv** – Medicine purchase records with category and amount.
-- **checkups.csv** – Health checkup bookings with package details and price.
-- **P6_Medibuddy.sql** – All SQL queries (objectives 1–33) answering business, customer, and operational questions.
-- **README.md** – Documentation with project goals, structure, and usage instructions.

### 1. database_setup
- **Database Creation;**
The project begins by creating a database named `medibuddy_db` to store all retail sales-related data.

- **Table Creation:**
-- **users**
-- Stores user demographic details like name, age, gender, city, and registration date.
-- **consultations**
-- Records doctor consultations including specialty, date, mode (online/offline), and fee.
-- **orders**
-- Tracks medicine orders with order date, category, and purchase amount.
-- **checkups**
-- Stores health checkup bookings with package name, booking date, and price.

![image](https://github.com/user-attachments/assets/1eeb2e86-10a2-4a6a-8742-6fb880b329f1)

## General & Descriptive Questions
-- 1. total count of registered users, month-wise, with growth rate and cumulative users count?
-- 2. Distribution of users by city and gender?
-- 3.The average age of users per city
-- 4.The most popular consultation specialty
-- 5.Mode split of consultations
-- 6.Monthly medicine orders by category
-- 7.Average medicine order amount per user

## Profit and Revenue-Based Questions
-- 8.Total revenue from all sources
-- 9.Total and category-wise Revenue by city
-- 10. Average revenue per user
-- 11.Revenue by doctor specialty
-- 12.Revenue by consultation mode
-- 13.Revenue by checkup package
-- 14.Revenue share by service type

## Customer Behavior / Retention / Segmentation
-- 15. Which users have done all 3: consultation, order, and checkup?
-- 16. Repeated users (consulted more than once)?
-- 17.Inactive users (no activity)
-- 18. Segment customers into low, mid, and high spenders based on lifetime value.
-- 19. What is the average time between registration and first activity?
-- 20. Which age group has the most health checkups?
-- 21. Who are the top 10 highest spending customers?

## Business Operational Questions
-- 22. Which doctor specialties are underserved in cities?
-- 23. Is there a seasonal trend in consultation?
-- 24. Are more consultations done during weekends or weekdays?
-- 25. Average consultation fee per city
-- 26. How long after registration do users typically place an order or book a checkup
-- 27. % of registered users are inactive (never did anything)
-- 28. Post-checkup medicine correlation (follow-up)

## Advanced / Predictive
-- 29. Classify users into behavioral cohorts
-- 30. The lifetime value (LTV) of a user
-- 31. Build a funnel: Registration → Consultation → Order → Checkup. What’s the drop-off?
-- 32. What is the revenue impact if we raise consultation fees by 10%?
-- 33. What’s the average "customer acquisition cost" if we assume ₹500 marketing per new user?

------------------------------------------------------------------------------------------------

### Conclusion:
This project demonstrates how SQL can be leveraged to extract meaningful business insights from healthcare data. By designing a normalized database (medibuddy_db) and writing 30+ analytical queries, I explored user behavior, revenue patterns, customer segmentation, and operational trends. The insights generated can support data-driven decision-making in areas like marketing, service optimization, and user engagement. This project is a solid foundation for further analytics, dashboarding, or predictive modeling in the healthcare domain.

------------------------------------------------------------------------------------------------

### The Repository

```bash
https://github.com/ujjwalbabu0/SQL_P6--Medibuddy.git
