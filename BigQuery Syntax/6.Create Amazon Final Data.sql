--Create final table
CREATE OR REPLACE TABLE amazon-data-analytics-511402.cleansing_table.amazon_final_data AS
SELECT *
FROM amazon-data-analytics-511402.cleansing_table.amazon_user;

--Compare the raw data
SELECT 'raw' AS raw_table, COUNT(*) AS row_data, COUNT(DISTINCT product_id) AS unique_product
FROM amazon-data-analytics-511402.cleansing_table.amazon_raw_table
UNION ALL
SELECT 'final' AS final_table, COUNT(*), COUNT(DISTINCT product_id)
FROM amazon-data-analytics-511402.cleansing_table.amazon_final_data;