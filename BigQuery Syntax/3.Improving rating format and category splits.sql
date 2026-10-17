SELECT product_id, product_name, rating, rating_count
FROM amazon-data-analytics-511402.cleansing_table.amazon_clean_data
WHERE SAFE_CAST(rating AS FLOAT64) IS NULL;

CREATE OR REPLACE TABLE amazon-data-analytics-511402.cleansing_table.amazon_clean_data_v2 AS
SELECT * REPLACE (SAFE_CAST(rating AS FLOAT64) AS rating)
FROM amazon-data-analytics-511402.cleansing_table.amazon_clean_data;

--validation of rating format
SELECT
  COUNTIF(rating IS NULL) AS rating_null,
  MIN(rating) AS rating_min,
  MAX(rating) AS rating_max
FROM amazon-data-analytics-511402.cleansing_table.amazon_clean_data_v2;

CREATE OR REPLACE TABLE amazon-data-analytics-511402.cleansing_table.amazon_category AS
SELECT
  * EXCEPT(category),
  category AS category_full,
  SPLIT(category, '|')[SAFE_OFFSET(0)] AS main_category,
  SPLIT(category, '|')[SAFE_OFFSET(1)] AS sub_category,
  SPLIT(category,'|')[SAFE_OFFSET(2)] AS sub_category_2,
  SPLIT(category,'|')[SAFE_OFFSET(3)] AS sub_category_3
FROM amazon-data-analytics-511402.cleansing_table.amazon_clean_data_v2;

--validation of split category
SELECT main_category, COUNT(*) AS jumlah
FROM amazon-data-analytics-511402.cleansing_table.amazon_category
GROUP BY main_category
ORDER BY jumlah DESC;
