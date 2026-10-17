# Amazon Performance Business Analytics

![BigQuery](https://github.com/sitimuyassaroh/Amazon_Performance_Business_Analytics/BigQuery%20Syntax/BigQuery%20Amazon.png)
![Looker Studio](https://img.shields.io/badge/Looker_Studio-Dashboard-4285F4?logo=looker&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

An end-to-end data analytics project: cleaning an Amazon product dataset with **BigQuery SQL**, visualizing it in a **Looker Studio** dashboard, and presenting the findings in a **PowerPoint** analysis.

**Live dashboard:** [Amazon Performance Business Analytics Dashboard](https://datastudio.google.com/reporting/a46afda5-93d0-470a-bda1-e8d1b101184a)

![Dashboard preview](dashboard/dashboard_preview.png)

---

## Table of Contents
- [Business Problem](#business-problem)
- [Dataset](#dataset)
- [Tools](#tools)
- [Repository Structure](#repository-structure)
- [Data Cleansing Workflow (BigQuery)](#data-cleansing-workflow-bigquery)
- [Dashboard (Looker Studio)](#dashboard-looker-studio)
- [Key Insights](#key-insights)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [How to Reproduce](#how-to-reproduce)
- [Author](#author)

---

## Business Problem

Amazon sells products across many categories, but without one consolidated view it is hard to see which categories satisfy customers, whether discounts lift ratings, and which products draw the most engagement.

This project answers four questions:

1. How is the product catalog spread across main categories?
2. How satisfied are customers, overall and by category?
3. Do bigger discounts lead to better ratings?
4. Which products attract the most ratings?

## Dataset

The Amazon Sales dataset contains product listings with these fields:

| Group | Columns |
|---|---|
| Product | `product_id`, `product_name`, `category`, `about_product`, `img_link`, `product_link` |
| Price | `actual_price`, `discounted_price`, `discount_percentage` |
| Rating | `rating`, `rating_count` |
| Reviews | `user_id`, `user_name`, `review_id`, `review_title`, `review_content` |

- **Raw size:** 1,465 rows
- **After cleaning:** 1,351 unique products

## Tools

- **Google BigQuery** (Sandbox): data storage, profiling, and cleansing with SQL
- **Looker Studio**: interactive dashboard
- **Microsoft PowerPoint**: analysis presentation

## Repository Structure

```
amazon-performance-business-analytics/
├── README.md
├── sql/                         # BigQuery scripts, run in order
│   ├── 01_data_profiling.sql
│   ├── 02_remove_duplicates.sql
│   ├── 03_fix_rating.sql
│   ├── 04_split_category.sql
│   ├── 05_standardize_discount.sql
│   ├── 06_split_user_and_review.sql
│   ├── 07_text_and_link_checks.sql
│   ├── 08_final_table_and_validation.sql
│   └── 09_dashboard_view.sql
├── dashboard/
│   ├── dashboard_preview.png
│   └── Dashboard-Amazon_Performance_Business_Analytics.pdf
└── presentation/
    └── Amazon_Performance_Full_Analysis.pptx
```

## Data Cleansing Workflow (BigQuery)

Each step creates a new table from the previous one, so the raw table is never modified and every step can be repeated.

`amazon_raw_table` → `amazon_clean_data` → `_v2` → `_v3` → `_v4` → `_v5` → `amazon_clean_final` → `viz_produk` (view)

| # | Script | Issue found | Technique | Result |
|---|---|---|---|---|
| 1 | `01_data_profiling.sql` | Unknown data quality | `COUNT`, `COUNTIF`, `SAFE_CAST`, `TO_JSON_STRING` | 1,465 rows, 1,351 unique `product_id`, 2 empty `rating_count`, 1 invalid rating |
| 2 | `02_remove_duplicates.sql` | Repeated `product_id` (identical except `img_link` and `product_link`) | `ROW_NUMBER() OVER (PARTITION BY ...)` | 114 duplicate rows removed |
| 3 | `03_fix_rating.sql` | One rating stored as `\|` | `SAFE_CAST(... AS FLOAT64)` | Invalid value became `NULL`; range 2 to 5 |
| 4 | `04_split_category.sql` | Several category levels in one cell | `SPLIT`, `SAFE_OFFSET` | `main_category`, `sub_category`, `sub_category_2` |
| 5 | `05_standardize_discount.sql` | `discount_percentage` stored as a fraction (0 to 1) | `ROUND(x * 100)` | 0 to 100 scale; 0 mismatches against prices |
| 6 | `06_split_user_and_review.sql` | Several users and reviews in one cell | `SPLIT`, `UNNEST ... WITH OFFSET` | 10,598 rows; `product_id` + `review_id` is unique |
| 7 | `07_text_and_link_checks.sql` | Possible empty text or broken links | `TRIM`, `STARTS_WITH` | 0 issues found |
| 8 | `08_final_table_and_validation.sql` | Final checks | `INFORMATION_SCHEMA`, `UNION ALL` | `amazon_clean_final`, data types verified |
| 9 | `09_dashboard_view.sql` | Final table has one row per review | `GROUP BY` + `ANY_VALUE` | 1,351 rows, one per product |

**Example snippets**

```sql
-- Keep one row per product_id
CREATE OR REPLACE TABLE `project.dataset.amazon_clean_data` AS
SELECT * EXCEPT(rn) FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_link) AS rn
  FROM `project.dataset.amazon_raw_table`
)
WHERE rn = 1;

-- Turn an invalid rating into NULL
SELECT * REPLACE (SAFE_CAST(rating AS FLOAT64) AS rating)
FROM `project.dataset.amazon_clean_data`;

-- Split two aligned multi-value columns into one row per review
SELECT * EXCEPT(user_id, review_id), TRIM(uid) AS user_id, TRIM(rid) AS review_id
FROM `project.dataset.amazon_clean_data_v4`,
UNNEST(SPLIT(user_id, ',')) AS uid WITH OFFSET AS pos1,
UNNEST(SPLIT(review_id, ',')) AS rid WITH OFFSET AS pos2
WHERE pos1 = pos2;
```

**Why a separate view for the dashboard?** `amazon_clean_final` has one row per review, so product-level values (price, discount, rating) repeat. Averaging them directly would overweight products with many reviews. `viz_produk` returns one row per product, which keeps the dashboard metrics consistent.

## Dashboard (Looker Studio)

| Component | What it shows |
|---|---|
| Scorecards (5) | Total products, average rating, total of ratings, main categories, average discount |
| Snapshot table | Top products by number of ratings, with price, discount, and rating |
| Average ratings by main category | Satisfaction by category |
| Percentage of products by main category | Catalog mix |
| Distribution of ratings | How ratings are spread |
| Top 10 products with the most count of ratings | Most popular products |
| Discount vs. rating scatter plot | Relationship between discount and rating |
| Filters (3) | Name of products, Category, Rating |

## Key Insights

| Metric | Value |
|---|---|
| Total products | 1,351 |
| Average rating | 4.09 |
| Total of ratings | 23,802,442 |
| Main categories | 9 |
| Average discount | 46.69% |

- **Concentrated catalog.** Electronics (36.3%), Home & Kitchen (33.2%), and Computers & Accessories (27.8%) hold 97.3% of products.
- **High, steady satisfaction.** Category averages range from 3.80 (Car & Motorbike) to 4.31 (Office Products), a spread of only 0.51 points. Ratings are left-skewed and peak at 4.2 to 4.4.
- **Discounts and ratings are unrelated.** The scatter plot shows no clear slope between discount percentage and rating.
- **Popularity is concentrated.** The top 10 most-rated products are all Electronics and come from only three product families: Amazon Basics, boAt, and Redmi.
- **Highest scores, smallest samples.** The best-rated categories are among the smallest, so their averages are less reliable.

The full reading of every parameter is in the [presentation](presentation/Amazon_Performance_Full_Analysis.pptx).

## Recommendations

- Audit the low-rated tail of the catalog (products below roughly 3.6) for quality and listing accuracy.
- Broaden the assortment beyond the top three categories.
- Use the top product families as anchors for promotions and bundles.
- Judge discounts by selling price rather than list price, and test discount depth by category.
- Add sales, time, and review-text data to link ratings and discounts to outcomes.

## Limitations

- Variants of the same product share almost identical rating counts, so totals and the top 10 may double count.
- Six small categories hold only 2.7% of products, so their averages are indicative only.
- The dataset is a snapshot with no time or sales data, so the dashboard shows association, not cause and effect.
- `user_name`, `review_title`, and `review_content` were not split per review, and 9 products lost some reviews during the user/review split.

## How to Reproduce

1. Upload the CSV to BigQuery as `amazon_raw_table` (schema auto-detect, skip 1 header row).
2. Run the scripts in `sql/` in numerical order, replacing `project.dataset` with your own project and dataset names.
3. Create the `viz_produk` view with `09_dashboard_view.sql`.
4. In Looker Studio, create a report with BigQuery as the data source and select `viz_produk`.
5. Build the charts and filters listed in the dashboard table above.

## Author

**Siti Muyassaroh**

- GitHub: [@sitimuyassaroh](https://github.com/sitimuyassaroh/)
- LinkedIn: [Siti Muyassaroh](https://www.linkedin.com/in/sitimuyassaroh/)
