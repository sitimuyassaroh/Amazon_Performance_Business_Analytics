--Check the number of user in one column
SELECT product_id,
  ARRAY_LENGTH(SPLIT(user_id, ',')) AS jumlah_user_id,
  ARRAY_LENGTH(SPLIT(user_name, ',')) AS jumlah_user_name,
  ARRAY_LENGTH(SPLIT(review_id, ',')) AS jumlah_review_id
FROM amazon-data-analytics-511402.cleansing_table.amazon_discount_percentage;

--Check the different of row
SELECT COUNT(*) AS baris_tidak_sejajar
FROM amazon-data-analytics-511402.cleansing_table.amazon_discount_percentage
WHERE ARRAY_LENGTH(SPLIT(user_id, ',')) != ARRAY_LENGTH(SPLIT(review_id, ',')) OR
  ARRAY_LENGTH(SPLIT(user_id, ',')) != ARRAY_LENGTH(SPLIT(user_name, ','));

--Check the number of user and review
SELECT product_id,
  ARRAY_LENGTH(SPLIT(user_id, ',')) AS jumlah_user_id,
  ARRAY_LENGTH(SPLIT(user_name, ',')) AS jumlah_user_name,
  ARRAY_LENGTH(SPLIT(review_id, ',')) AS jumlah_review_id,
  user_name
FROM amazon-data-analytics-511402.cleansing_table.amazon_discount_percentage
WHERE ARRAY_LENGTH(SPLIT(user_id, ',')) != ARRAY_LENGTH(SPLIT(review_id, ',')) OR
  ARRAY_LENGTH(SPLIT(user_id, ',')) != ARRAY_LENGTH(SPLIT(user_name, ','));

--Create table to clasify the user
CREATE OR REPLACE TABLE amazon-data-analytics-511402.cleansing_table.amazon_user AS
SELECT * EXCEPT (user_id, review_id),
  TRIM(uid) AS user_id,
  TRIM(rid) AS review_id
FROM amazon-data-analytics-511402.cleansing_table.amazon_discount_percentage,
UNNEST(SPLIT(user_id, ',')) AS uid WITH OFFSET AS pos1,
UNNEST(SPLIT(review_id, ',')) AS rid WITH OFFSET AS pos2
WHERE pos1 = pos2;

--Validation of Classification
SELECT COUNT(*) AS total_baris, COUNT(DISTINCT review_id) AS review_unik
FROM amazon-data-analytics-511402.cleansing_table.amazon_user;

--Check the difference between different products n unique review pairs
SELECT review_id,
  COUNT(*) AS jumlah,
  COUNT(DISTINCT product_id) AS produk_berbeda
FROM amazon-data-analytics-511402.cleansing_table.amazon_user
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY jumlah DESC;

SELECT COUNT(*) AS total,
  COUNT(DISTINCT CONCAT(product_id, '|', review_id)) AS unique_review_pairs
FROM amazon-data-analytics-511402.cleansing_table.amazon_user;