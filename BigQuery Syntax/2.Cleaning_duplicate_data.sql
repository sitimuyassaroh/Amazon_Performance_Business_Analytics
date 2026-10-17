CREATE OR REPLACE TABLE `amazon-data-analytics-511402.cleansing_table.amazon_clean_data` AS
SELECT * EXCEPT(rn) FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_Link) AS rn
  FROM `amazon-data-analytics-511402.cleansing_table.amazon_raw_table`
)
WHERE rn = 1;

SELECT COUNT(*) AS total, COUNT(DISTINCT product_id) AS unik
FROM `amazon-data-analytics-511402.cleansing_table.amazon_clean_data`;
