-- How many days each customer visited zomato?
SELECT userid,
       Count(DISTINCT( created_date )) distinct_days
FROM   sales
GROUP  BY userid 


-- What is total amount each customer spent on zomato?

SELECT s.userid,
       Sum(p.price) AS total_amt
FROM   sales s
       LEFT JOIN product p
              ON s.product_id = p.product_id
GROUP  BY s.userid; 

-- What was the first product purchased by each customer?
WITH cte
     AS (SELECT userid,
                created_date,
                product_id,
                Row_number()
                  OVER (
                    partition BY userid
                    ORDER BY created_date) rn
         FROM   sales)
SELECT userid,
       created_date,
       product_id
FROM   cte
WHERE  rn = 1 

-- What is the most ordered product and how many times each user ordered that product?
SELECT userid,
       Count(product_id) AS maxcount
FROM   sales
WHERE  product_id = (SELECT TOP 1 product_id
                     FROM   sales
                     GROUP  BY product_id
                     ORDER  BY Count(product_id) DESC)
GROUP  BY userid 

-- Which product is most popular for each of the customer?
SELECT userid,
       product_id,
       ordercount
FROM   (SELECT *,
               Rank()
                 OVER(
                   partition BY userid
                   ORDER BY ordercount DESC) rnk
        FROM   (SELECT userid,
                       product_id,
                       Count(product_id) AS ordercount
                FROM   sales
                GROUP  BY userid,
                          product_id)a)b
WHERE  rnk = 1 


-- Which item was purchased first by the customer after they became a gold member?
SELECT d.userid,
       d.created_date,
       d.product_id,
       d.gold_signup_date
FROM   (SELECT c.*,
               Rank()
                 OVER (
                   partition BY userid
                   ORDER BY created_date)rnk
        FROM   (SELECT a.userid,
                       a.created_date,
                       a.product_id,
                       b.gold_signup_date
                FROM   sales a
                       INNER JOIN goldusers_signup b
                               ON a.userid = b.userid
                                  AND created_date >= gold_signup_date)c)d
WHERE  rnk = 1 


-- Which item was purchased just before the customer became a gold member?
SELECT d.userid,
       d.created_date,
       d.product_id,
       d.gold_signup_date
FROM   (SELECT c.*,
               Rank()
                 OVER (
                   partition BY userid
                   ORDER BY created_date DESC)rnk
        FROM   (SELECT a.userid,
                       a.created_date,
                       a.product_id,
                       b.gold_signup_date
                FROM   sales a
                       INNER JOIN goldusers_signup b
                               ON a.userid = b.userid
                                  AND created_date < gold_signup_date)c)d
WHERE  rnk = 1 

-- What is the total orders and amount spent by each customer before they became a member?
SELECT c.userid,
       Count(c.product_id) AS No_of_orders,
       Sum(d.price)        AS Total_amt_spent
FROM   (SELECT a.userid,
               a.created_date,
               a.product_id,
               b.gold_signup_date
        FROM   sales a
               INNER JOIN goldusers_signup b
                       ON a.userid = b.userid
                          AND created_date < gold_signup_date)c
       INNER JOIN product d
               ON c.product_id = d.product_id
GROUP  BY userid 


-- If buying each product generates points and each product has different purchasing points, let's say:
-- for P1 5rs=1 zomato point, for P2 10rs=5 zomato points and for P3 5rs=1 zomato points.
-- Calculate points collected by each customer?
SELECT f.userid,
       Sum(f.points_earned) AS zomato_points
FROM   (SELECT e.*,
               e.total_amt / e.unit_point_amt AS points_earned
        FROM   (SELECT d.*,
                       CASE
                         WHEN d.product_id = 1 THEN 5
                         WHEN d.product_id = 2 THEN 2
                         WHEN d.product_id = 3 THEN 5
                         ELSE 0
                       END AS unit_point_amt
                FROM   (SELECT c.userid,
                               c.product_id,
                               Sum(c.price) AS total_amt
                        FROM   (SELECT a.*,
                                       b.price
                                FROM   sales a
                                       INNER JOIN product b
                                               ON a.product_id = b.product_id) c
                        GROUP  BY c.userid,
                                  c.product_id)d)e)f
GROUP  BY f.userid 


-- From above question calculate for which product most points has been given till now?
SELECT *
FROM   (SELECT *,
               Rank()
                 OVER(
                   ORDER BY zomato_points DESC)rnk
        FROM   (SELECT f.product_id,
                       Sum(f.points_earned) AS zomato_points
                FROM   (SELECT e.*,
                               e.total_amt / e.unit_point_amt AS points_earned
                        FROM   (SELECT d.*,
                                       CASE
                                         WHEN d.product_id = 1 THEN 5
                                         WHEN d.product_id = 2 THEN 2
                                         WHEN d.product_id = 3 THEN 5
                                         ELSE 0
                                       END AS unit_point_amt
                                FROM   (SELECT c.userid,
                                               c.product_id,
                                               Sum(c.price) AS total_amt
                                        FROM   (SELECT a.*,
                                                       b.price
                                                FROM   sales a
                                                       INNER JOIN product b
                                                               ON a.product_id =
                                                                  b.product_id) c
                                        GROUP  BY c.userid, c.product_id) d) e) f
                GROUP  BY f.product_id) g) h
WHERE  rnk = 1 


-- In the first one year after the customer become the gold member (including their join date)
-- irrespective of what the customer has purchased they earned 5 zomato points for every 10rs spent,
-- who earned more customer 1 or customer 3 and what was their earned points in that first year?

SELECT c.*,
       Floor(d.price * 0.5) AS total_pts_earned
FROM   (SELECT a.userid,
               a.created_date,
               a.product_id,
               b.gold_signup_date
        FROM   sales a
               INNER JOIN goldusers_signup b
                       ON a.userid = b.userid
                          AND created_date >= gold_signup_date
                          AND created_date < Dateadd(year, 1, gold_signup_date)) c
       INNER JOIN product d
               ON c.product_id = d.product_id
ORDER  BY total_pts_earned DESC 


-- Rank all the transactions of the customers.
SELECT *,
       Rank()
         OVER(
           partition BY userid
           ORDER BY created_date)rnk
FROM   sales 


-- Rank all the transactions for each member whenever they became a gold member and for every non-gold member transaction mark #NA.
SELECT a.userid,
       a.created_date,
       a.product_id,
       b.gold_signup_date,
       CASE
         WHEN b.gold_signup_date IS NULL THEN '#NA'
         ELSE Cast(( Rank()
                       OVER(
                         partition BY a.userid
                         ORDER BY a.created_date DESC)) AS VARCHAR)
       END AS rnk
FROM   sales a
       LEFT JOIN goldusers_signup b
              ON a.userid = b.userid
                 AND created_date >= gold_signup_date 
