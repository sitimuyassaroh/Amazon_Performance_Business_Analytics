SELECT
  COUNTIF(discounted_price <= 0 OR actual_price <= 0) AS harga_nol_negatif,
  COUNTIF(discounted_price > actual_price) AS diskon_lebih_mahal,
  COUNTIF(discount_percentage NOT BETWEEN 0 AND 100) AS diskon_diluar_range,
  COUNTIF(ABS(discount_percentage * 100 - ROUND((actual_price - discounted_price) / actual_price * 100)) > 1) AS diskon_tidak_cocok
FROM amazon-data-analytics-511402.cleansing_table.amazon_category;

CREATE OR REPLACE TABLE amazon-data-analytics-511402.cleansing_table.amazon_discount_percentage AS
SELECT * REPLACE (ROUND(discount_percentage * 100) AS discount_percentage)
FROM amazon-data-analytics-511402.cleansing_table.amazon_category;