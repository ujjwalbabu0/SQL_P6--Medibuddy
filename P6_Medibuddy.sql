-- ## Database setup
-- Database creation
create database medibuddy;

-- Table creation
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    gender ENUM('Male', 'Female', 'other'),
    city VARCHAR(30),
    registration_date DATE
);
    
CREATE TABLE consultations (
    consultation_id INT PRIMARY KEY,
    user_id INT,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    doctor_speciality VARCHAR(100),
    consultation_Date DATE,
    consultation_mode VARCHAR(30),
    consultation_fee FLOAT
);
    
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    order_date DATE,
    medicine_Category VARCHAR(100),
    amount FLOAT
);
    
CREATE TABLE checkups (
    booking_id INT PRIMARY KEY,
    user_id INT,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    package VARCHAR(150),
    booking_Date DATE,
    price FLOAT
);
    
-- ## General & Descriptive Questions
-- 1.total count of registered users, month-wise with growth rate and cumulative users count?
select
	yyyy_mon,
    users_cnt,
    sum(users_cnt) over(order by yyyy_mon rows between unbounded preceding and current row) as cumulative_users,
    round(((users_cnt - lag(users_cnt) over(order by yyyy_mon))*100/lag(users_cnt) over(order by yyyy_mon)),2) as growth_Rate
from (
select
	date_format(registration_date, '%Y-%m') as yyyy_mon,
    count(*) as users_cnt
from users
group by yyyy_mon) month_wise_users;

-- 2.distribution of users by city and gender?
SELECT 
    city, gender, COUNT(*) AS cnt
FROM
    users
GROUP BY city , gender
ORDER BY city , gender;

-- 3.Average age of users per city
SELECT 
    city, ROUND(AVG(age), 2) AS avg_Age
FROM
    users
GROUP BY city
ORDER BY city;

-- 4.Most popular consultation specialty
SELECT 
    doctor_speciality, COUNT(*) AS ttl_cnt
FROM
    consultations
GROUP BY doctor_speciality
ORDER BY ttl_cnt DESC;

-- 5.Mode split of consultations
SELECT 
    consultation_mode, COUNT(*) AS ttl_cnt
FROM
    consultations
GROUP BY consultation_mode
ORDER BY ttl_cnt DESC;

-- 6.Monthly medicine orders by category
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS yyyy_mon,
    medicine_category,
    COUNT(*) AS order_cnt
FROM
    orders
GROUP BY yyyy_mon , medicine_Category
ORDER BY order_cnt DESC;

-- 7.Average medicine order amount per user
SELECT 
    o.user_id, u.name, ROUND(AVG(amount), 2) AS avg_order_amt
FROM
    orders o
        LEFT JOIN
    users u ON u.user_id = o.user_id
GROUP BY o.user_id , u.name
ORDER BY avg_order_amt DESC;

-- ## Profit and Revenue-Based Questions
-- 8.Total revenue from all sources
SELECT 
    (SELECT 
            SUM(consultation_fee)
        FROM
            consultations) AS consultation_revenue,
    (SELECT 
            ROUND(SUM(amount), 2)
        FROM
            orders) AS medicine_revenue,
    (SELECT 
            SUM(price)
        FROM
            checkups) AS checkup_revenue,
    ROUND((COALESCE((SELECT 
                            SUM(consultation_fee)
                        FROM
                            consultations),
                    0) + COALESCE((SELECT 
                            SUM(amount)
                        FROM
                            orders),
                    0) + COALESCE((SELECT 
                            SUM(price)
                        FROM
                            checkups),
                    0)),
            2) AS total_revenue;
    
-- 9.Total and category wise Revenue by city
SELECT 
    City,
    consultation_revenue,
    medicine_revenue,
    checkup_revenue,
    ROUND((consultation_revenue + medicine_revenue + checkup_revenue),
            2) AS Total_revenue
FROM
    (SELECT 
        u.city,
            ROUND(COALESCE(SUM(c.consultation_fee), 0), 2) AS consultation_revenue,
            ROUND(COALESCE(SUM(o.amount), 0), 2) AS medicine_revenue,
            ROUND(COALESCE(SUM(ck.price), 0), 2) AS checkup_revenue
    FROM
        users u
    JOIN consultations c USING (user_id)
    JOIN orders o USING (user_id)
    JOIN checkups ck USING (user_id)
    GROUP BY u.city) city_service_wise_Revenue
ORDER BY total_Revenue DESC;

-- 10. Average revenue per user
SELECT 
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_user
FROM
    (SELECT 
        u.user_id,
            ROUND(SUM(COALESCE(consultation_fee, 0) + COALESCE(o.amount, 0) + COALESCE(ck.price, 0)), 2) AS total_revenue
    FROM
        users u
    JOIN consultations c USING (user_id)
    JOIN orders o USING (user_id)
    JOIN checkups ck USING (user_id)
    GROUP BY u.user_id) user_Wise_ttl_revenue;

-- 11.Revenue by doctor specialty
SELECT 
    doctor_speciality,
    ROUND(SUM(consultation_fee), 2) AS total_revenue
FROM
    consultations
GROUP BY doctor_speciality;

-- 12.Revenue by consultation mode
SELECT 
    consultation_mode,
    ROUND(SUM(consultation_fee), 2) AS ttl_revenue
FROM
    consultations
GROUP BY consultation_mode;

-- 13.Revenue by checkup package
SELECT 
    package, ROUND(SUM(price), 2) AS ttl_revenue
FROM
    checkups
GROUP BY package;

-- 14.Revenue share by service type
SELECT 
    (SELECT 
            ROUND(SUM(consultation_Fee), 2)
        FROM
            consultations) AS consultation_Revenue,
    (SELECT 
            ROUND(SUM(amount), 2)
        FROM
            orders) AS medicine_revenue,
    (SELECT 
            ROUND(SUM(price), 2)
        FROM
            checkups) AS checkup_revenue;
    
-- ## Customer Behavior / Retention / Segmentation
-- 15. Which users have done all 3: consultation, order, and checkup?
SELECT DISTINCT
    u.*
FROM
    users u
        JOIN
    consultations USING (user_id)
        JOIN
    checkups USING (user_id)
        JOIN
    orders USING (user_id);

-- 16. Repeated users (consulted more than once)?
SELECT 
    ct.user_id, u.name, COUNT(*) AS ttl_consultation_cnt
FROM
    consultations ct
        JOIN
    users u USING (user_id)
GROUP BY ct.user_id , u.name
HAVING ttl_consultation_cnt > 1
ORDER BY ttl_consultation_cnt DESC , ct.user_id;

-- 17.Inactive users (no activity)
SELECT 
    u.user_id
FROM
    users u
        LEFT JOIN
    consultations c ON u.user_id = c.user_id
        LEFT JOIN
    orders o ON u.user_id = o.user_id
        LEFT JOIN
    checkups ch ON u.user_id = ch.user_id
WHERE
    c.consultation_id IS NULL
        AND o.order_id IS NULL
        AND ch.booking_id IS NULL;
    
-- 18. Segment customers into low, mid, and high spenders based on lifetime value.
SELECT 
    user_id,
    name,
    CASE
        WHEN ttl_revenue >= 5000 THEN 'High'
        WHEN ttl_revenue >= 2000 THEN 'Mid'
        ELSE 'Low'
    END AS customer_segment
FROM
    (SELECT 
        u.user_id,
            u.name,
            ROUND(SUM(COALESCE(o.amount, 0) + COALESCE(ct.consultation_fee, 0) + COALESCE(ck.price, 0)), 2) AS ttl_revenue
    FROM
        users u
    LEFT JOIN consultations ct USING (user_id)
    LEFT JOIN orders o USING (user_id)
    LEFT JOIN checkups ck USING (user_id)
    GROUP BY u.user_id , u.name) user_wise_ttl_revenue
ORDER BY user_id;

-- 19. What is the average time between registration and first activity?
SELECT 
    u.user_id,
    u.name,
    DATEDIFF(LEAST(COALESCE(MIN(ct.consultation_date), '9999-12-31'),
                    COALESCE(MIN(o.order_date), '9999-12-31')),
            u.registration_date) AS first_txn_days_diff
FROM
    users u
        LEFT JOIN
    consultations ct ON u.user_id = ct.user_id
        LEFT JOIN
    orders o ON u.user_id = o.user_id
GROUP BY u.user_id , u.name , u.registration_date
HAVING first_txn_days_diff < 9999;

-- 20. Which age group books health checkups the most?
SELECT 
    CASE
        WHEN u.age < 25 THEN 'under_25'
        WHEN u.age BETWEEN 25 AND 40 THEN '25-40'
        WHEN u.age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS ttl_checkup_cnt
FROM
    checkups ck
        JOIN
    users u USING (user_id)
GROUP BY age_group
ORDER BY ttl_checkup_cnt DESC;

-- 21. Who are the top 10 highest spending customers?
SELECT 
    u.user_id,
    u.name,
    ROUND(SUM(COALESCE(c.consultation_fee, 0) + COALESCE(o.amount, 0) + COALESCE(ch.price, 0)),
            2) AS total_spent
FROM
    users u
        LEFT JOIN
    consultations c ON u.user_id = c.user_id
        LEFT JOIN
    orders o ON u.user_id = o.user_id
        LEFT JOIN
    checkups ch ON u.user_id = ch.user_id
GROUP BY u.user_id , u.name
ORDER BY total_spent DESC
LIMIT 10;

-- ## Business Operational Questions
-- 22. Which doctor specialties are underserved in cities?
SELECT 
    u.city,
    ct.doctor_speciality,
    COUNT(*) AS ttl_consultation_cnt
FROM
    consultations ct
        JOIN
    users u USING (user_id)
GROUP BY u.city , ct.doctor_speciality
ORDER BY ttl_consultation_cnt , city;

-- 23. Is there a seasonal trend in consultation?
SELECT 
    DATE_FORMAT(consultation_date, '%Y-%m') AS yyyy_mon,
    COUNT(*) AS consultation_cnt
FROM
    consultations
GROUP BY yyyy_mon
ORDER BY yyyy_mon;

-- 24. Are more consultations done during weekends or weekdays?
SELECT 
    CASE
        WHEN DAYOFWEEK(consultation_date) IN (1 , 7) THEN 'weekend'
        ELSE 'weekdays'
    END AS 'day_type',
    COUNT(*) AS consultation_cnt
FROM
    consultations
GROUP BY day_type
ORDER BY consultation_cnt DESC;

-- 25. Average consultation fee per city
SELECT 
    u.city, ROUND(AVG(ct.consultation_fee), 2) AS avg_fee
FROM
    consultations ct
        JOIN
    users u USING (user_id)
GROUP BY u.city
ORDER BY avg_fee DESC;

-- 26. How long after registration do users typically place an order or book a checkup
SELECT 
    u.user_id,
    u.name,
    DATEDIFF(LEAST(COALESCE(MIN(ct.consultation_date), '9999-12-31'),
                    COALESCE(MIN(o.order_date), '9999-12-31')),
            u.registration_date) AS first_txn_days_diff
FROM
    users u
        LEFT JOIN
    consultations ct ON u.user_id = ct.user_id
        LEFT JOIN
    orders o ON u.user_id = o.user_id
GROUP BY u.user_id , u.name , u.registration_date
HAVING first_txn_days_diff < 9999;

-- 27. % of registered users are inactive (never did anything)
SELECT 
    ROUND(100.0 * SUM(CASE
                WHEN
                    u.user_id NOT IN (SELECT 
                            user_id
                        FROM
                            consultations)
                        AND u.user_id NOT IN (SELECT 
                            user_id
                        FROM
                            orders)
                        AND u.user_id NOT IN (SELECT 
                            user_id
                        FROM
                            checkups)
                THEN
                    1
                ELSE 0
            END) / COUNT(*),
            2) AS inactive_percent
FROM
    users u;

-- 28. Post-checkup medicine correlation (follow-up)
SELECT 
    ch.user_id,
    COUNT(DISTINCT o.order_id) AS post_checkup_orders
FROM
    checkups ch
        JOIN
    orders o ON ch.user_id = o.user_id
        AND o.order_date > ch.booking_date
GROUP BY ch.user_id;

-- ## Advanced / Predictive
-- 29. classify users into behavioral cohorts
SELECT 
    user_id,
    CASE
        WHEN COUNT(DISTINCT consultation_id) > 5 THEN 'Heavy_user'
        WHEN COUNT(DISTINCT consultation_id) > 1 THEN 'Regular'
        ELSE 'Occasional'
    END AS user_type
FROM
    consultations
GROUP BY user_id;

-- 30. the lifetime value (LTV) of a user
SELECT 
    u.user_id,
    ROUND(SUM(COALESCE(c.consultation_fee, 0) + COALESCE(o.amount, 0) + COALESCE(ch.price, 0)),
            2) AS ltv
FROM
    users u
        LEFT JOIN
    consultations c ON u.user_id = c.user_id
        LEFT JOIN
    orders o ON u.user_id = o.user_id
        LEFT JOIN
    checkups ch ON u.user_id = ch.user_id
GROUP BY u.user_id;

-- 31. Build a funnel: Registration → Consultation → Order → Checkup. What’s the drop-off?
SELECT 
    COUNT(DISTINCT u.user_id) AS registered,
    COUNT(DISTINCT c.user_id) AS consulted,
    COUNT(DISTINCT o.user_id) AS ordered,
    COUNT(DISTINCT ch.user_id) AS checked_up
FROM
    users u
        LEFT JOIN
    consultations c ON u.user_id = c.user_id
        LEFT JOIN
    orders o ON u.user_id = o.user_id
        LEFT JOIN
    checkups ch ON u.user_id = ch.user_id;

-- 32. What is the revenue impact if we raise consultation fees by 10%?
SELECT
    SUM(consultation_fee) AS current_revenue,
    SUM(consultation_fee * 1.10) AS projected_revenue
FROM consultations;

-- 33. What’s the average "customer acquisition cost" if we assume ₹500 marketing per new user?
SELECT
  COUNT(DISTINCT u.user_id) * 500 AS total_marketing_cost,
  ROUND(SUM(COALESCE(c.consultation_fee, 0)) + 
        SUM(COALESCE(o.amount, 0)) + 
        SUM(COALESCE(ch.price, 0)), 2) AS revenue,
  ROUND(
    SUM(COALESCE(c.consultation_fee, 0)) + 
    SUM(COALESCE(o.amount, 0)) + 
    SUM(COALESCE(ch.price, 0)) - COUNT(DISTINCT u.user_id) * 500, 2
  ) AS profit
FROM users u
LEFT JOIN consultations c ON u.user_id = c.user_id
LEFT JOIN orders o ON u.user_id = o.user_id
LEFT JOIN checkups ch ON u.user_id = ch.user_id;