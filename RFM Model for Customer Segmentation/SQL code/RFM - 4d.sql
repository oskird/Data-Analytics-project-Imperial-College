-- 1. Segmentation: using data from 2004 to 2006
-- calculate R, F and M, and additional dimension
SELECT * FROM customers LIMIT 3

CREATE TABLE rfm_segment_4d_2
AS
(WITH rfm_value
AS
(SELECT t1.cust_id, t1.acqdate AS acqdate, t2.recency_diff_day, t3.frequency, CAST(t4.monetary as numeric(6,2)) FROM customers as t1
LEFT JOIN
(SELECT cust_id, CAST('2006-06-30' as date) - max(orderdate) as recency_diff_day FROM orders WHERE orderdate <= '2006-06-30' AND orderdate >= '2004-01-01' GROUP BY cust_id) AS t2
ON t1.cust_id = t2.cust_id
LEFT JOIN
(SELECT cust_id, COUNT(ordernum) as frequency FROM orders WHERE orderdate <= '2006-06-30'  AND orderdate >= '2004-01-01' GROUP BY cust_id) as t3
ON t1.cust_id = t3.cust_id
LEFT JOIN
(SELECT cust_id, SUM(linedollars)/COUNT(DISTINCT ordernum) AS monetary FROM lines WHERE orderdate <= '2006-06-30'  AND orderdate >= '2004-01-01' GROUP BY cust_id) as t4
ON t1.cust_id = t4.cust_id
WHERE frequency IS NOT NULL AND recency_diff_day IS NOT NULL AND monetary IS NOT NULL AND acqdate IS NOT NULL) 
-- have 51359 active customers between 2014 and 2016 
-- customer segmentation
SELECT cust_id, CAST(seg_r AS text) || CAST(seg_f AS text) || CAST(seg_m AS text) || CAST(seg_i AS text) AS segment 
FROM 
(SELECT *, ntile(5) OVER(ORDER BY recency_diff_day DESC) AS seg_r,
ntile(5) OVER(ORDER BY frequency) AS seg_f,
ntile(5) OVER(ORDER BY monetary) AS seg_m,
ntile(5) OVER(ORDER BY acqdate) AS seg_i
FROM rfm_value) AS t)

-- view segmentation
SELECT * FROM rfm_segment_4d_2

-- 2. Train Stage: using data from 2004 to 2006
-- calculate average response rate for each group1: respond with 1 week
CREATE TABLE train_response_rate_4d_2
AS
(SELECT segment, SUM(valid_contact) as valid_contact, SUM(contact_num_c) AS catalog_contact, 
CAST(SUM(valid_contact)/SUM(contact_num_c) AS numeric(5,4)) AS response_rate
FROM
(SELECT t1.cust_id, t2.segment, t4.contact_num_c, 
CASE WHEN t5.valid_contact IS NULL THEN 0 ELSE t5.valid_contact END AS valid_contact
FROM customers AS t1 
INNER JOIN rfm_segment_4d_2 as t2
ON t1.cust_id = t2.cust_id
INNER JOIN (SELECT cust_id, COUNT(contactdate) as contact_num_c FROM contacts WHERE contactdate <= '2006-12-31'  AND contactdate >= '2004-01-01' AND contacttype='C' GROUP BY cust_id) AS t4
ON t1.cust_id = t4.cust_id
LEFT JOIN 
(SELECT cust_id, COUNT(ordernum) AS valid_contact FROM 
(SELECT t1.cust_id, t1.contactdate, t2.ordernum, t2.orderdate 
FROM contacts AS t1
INNER JOIN orders AS t2
ON t1.cust_id = t2.cust_id
WHERE t1.contactdate <= '2006-12-31'  AND t1.contactdate >= '2004-01-01' 
AND t2.orderdate <= '2006-12-31'  AND t2.orderdate >= '2004-01-01'
AND contacttype='C') as t
WHERE orderdate - contactdate < 14 AND orderdate - contactdate > 0
GROUP BY cust_id) as t5
ON t1.cust_id = t5.cust_id) as t
GROUP BY segment
HAVING SUM(contact_num_c) > 50
ORDER BY response_rate DESC)

-- view result
SELECT * FROM train_response_rate_4d_2

-- 3. Validate Stage: using data from 2007
-- calculate average response rate for each group
CREATE TABLE validate_response_rate_4d_2
AS
(SELECT segment, SUM(valid_contact) as valid_contact , SUM(contact_num_c) AS catalog_contact, 
CAST(SUM(valid_contact)/SUM(contact_num_c) AS numeric(5,4)) AS response_rate
FROM
(SELECT t1.cust_id, t2.segment, t4.contact_num_c, 
CASE WHEN t5.valid_contact IS NULL THEN 0 ELSE t5.valid_contact END AS valid_contact
FROM customers AS t1 
INNER JOIN rfm_segment_4d_2 as t2
ON t1.cust_id = t2.cust_id
INNER JOIN (SELECT cust_id, COUNT(contactdate) as contact_num_c FROM contacts WHERE contactdate >= '2007-01-01' AND contacttype='C' GROUP BY cust_id) AS t4
ON t1.cust_id = t4.cust_id
LEFT JOIN 
(SELECT cust_id, COUNT(ordernum) AS valid_contact FROM 
(SELECT t1.cust_id, t1.contactdate, t2.ordernum, t2.orderdate 
FROM contacts AS t1
INNER JOIN orders AS t2
ON t1.cust_id = t2.cust_id
WHERE t1.contactdate >= '2007-01-01' 
AND t2.orderdate >= '2007-01-01' AND contacttype='C') as t
WHERE orderdate - contactdate < 14 AND orderdate - contactdate > 0
GROUP BY cust_id) as t5
ON t1.cust_id = t5.cust_id) as t
WHERE segment IN (SELECT segment FROM train_response_rate_4d_2 ORDER BY response_rate DESC LIMIT 40)
GROUP BY segment
ORDER BY response_rate DESC)

-- see the performance
SELECT * FROM validate_response_rate_4d_2

COPY validate_response_rate_4d_2
TO 'E:\oskird\course\13. Digital Marketing\assignment\assignment 1\group\RFM.csv' 
WITH CSV HEADER