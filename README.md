# Amazon Performance Business Analytics

![BigQuery](https://img.shields.io/badge/Google_BigQuery-SQL-4285F4?logo=googlebigquery&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker_Studio-Dashboard-4285F4?logo=looker&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

An end-to-end data analytics project: cleaning an Amazon product dataset with **BigQuery SQL**, visualizing it in a **Looker Studio** dashboard, and presenting the findings in a **PowerPoint** analysis.

**Live dashboard:** [Amazon Performance Business Analytics Dashboard](https://datastudio.google.com/reporting/a46afda5-93d0-470a-bda1-e8d1b101184a)

![Dashboard preview](Visualization%20Dashboard/Amazon%20Dashboard.png)

 <p align="center"><em>Figure 1 - Visualization Dashboard of Amazon Business Analytics</em></p>

---

## Table of Contents
- [Business Problem](#business-problem)
- [Dataset](#dataset)
- [Tools](#tools)
- [How to Reproduce](#how-to-reproduce)
- [Repository Structure](#repository-structure)
- [Data Cleansing Workflow (BigQuery)](#data-cleansing-workflow-bigquery)
- [Dashboard (Looker Studio)](#dashboard-looker-studio)
- [Key Insights](#key-insights)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
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

## How to Reproduce

1. Upload the CSV to BigQuery as `amazon_first_raw_data` (schema auto-detect, skip 1 header row).
2. Run the scripts in `sql/` in numerical order, replacing `project.dataset` with your own project and dataset names.
3. Create the `viz_produk` view.
4. In Looker Studio, create a report with BigQuery as the data source and select `viz_produk`.
5. Build the charts and filters listed in the dashboard table above.

## Repository Structure

```
amazon-performance-business-analytics/
├── README.md
├── BigQuery Syntax/                         # BigQuery scripts, run in order
│   ├── 1.Check_the_first_raw_data.sql
│   ├── 2.Cleaning_duplicate_data.sql
│   ├── 3.Improving_rating_format_and_category_splits.sql
│   ├── 4.Improving_Discount_Percentage_Format.sql
│   ├── 5.Difference between user, product, and review.sql
│   └── 6.Create_Amazon_Final_Data.sql
├── Visualization Dashboard/
│   ├── Dashboard_Amazon.png
│   └── Dashboard-Amazon_Performance_Business_Analytics.pdf
└── Data Storytelling/
│   ├── Amazon_cleansing_data_storytelling.pdf
    └── PPT_Amazon_Performance_Full_Analysis.pdf
```

## Data Cleansing Workflow (BigQuery)

<details>
   <summary>Click the BigQuery Interface preview</summary>
    
![BigQuery Interface Preview](BigQuery%20Syntax/BigQuery%20Amazon.png)

 <p align="center"><em>Figure 2 - BigQuery Interface for Amazon Business Analytics</em></p>
   </details>

Each step creates a new table from the previous one, so the raw table is never modified and every step can be repeated.

`amazon_first_raw_data` → `amazon_clean_data` → `amazon_clean_data_v2` → `amazon_category` → `amazon_discount_percentage` → `amazon_user` → `amazon_final_data` → `viz_produk` (view)

| # | Script | Issue found | Technique | Result |
|---|---|---|---|---|
| 1 | `1.Check_the_first_raw_data.sql` | Unknown data quality | `COUNT`, `COUNTIF`, `SAFE_CAST`, `TO_JSON_STRING` | 1,465 rows, 1,351 unique `product_id`, 2 empty `rating_count`, 1 invalid rating |
| 2 | `2.Cleaning_duplicate_data.sql` | Repeated `product_id` (identical except `img_link` and `product_link`) | `ROW_NUMBER() OVER (PARTITION BY ...)` | 114 duplicate rows removed |
| 3 | `3.Improving_rating_format_and_category_splits.sql` | One rating stored as `\|` | `SAFE_CAST(... AS FLOAT64)` | Invalid value became `NULL`; range 2 to 5 |
| 4 | `3.Improving_rating_format_and_category_splits.sql` | Several category levels in one cell | `SPLIT`, `SAFE_OFFSET` | `main_category`, `sub_category`, `sub_category_2` |
| 5 | `4.Improving_Discount_Percentage_Format.sql` | `discount_percentage` stored as a fraction (0 to 1) | `ROUND(x * 100)` | 0 to 100 scale; 0 mismatches against prices |
| 6 | `5.Difference between user, product, and review.sql` | Several users and reviews in one cell | `SPLIT`, `UNNEST ... WITH OFFSET` | 10,598 rows; `product_id` + `review_id` is unique |
| 7 | `6.Create_Amazon_Final_Data.sql` | Possible empty text or broken links | `TRIM`, `STARTS_WITH` | 0 issues found |
| 8 | `6.Create_Amazon_Final_Data.sql` | Final checks | `INFORMATION_SCHEMA`, `UNION ALL` | `amazon_clean_final`, data types verified |

**Why a separate view for the dashboard?** `amazon_final_data` has one row per review, so product-level values (price, discount, rating) repeat. Averaging them directly would overweight products with many reviews. `viz_produk` returns one row per product, which keeps the dashboard metrics consistent.

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

The full reading of every parameter is in the [data storytelling or presentation](Data%20Storytelling/PPT_Amazon_Performance_Full_Analysis.pdf).

## Recommendations

- Audit the low-rated tail of the catalog (products below roughly 3.6) for quality and listing accuracy.
- Broaden the assortment beyond the top three categories.
- Use the top product families as anchors for promotions and bundles.
- Judge discounts by selling price rather than list price, and test discount depth by category.
- Add sales, time, and review-text data to link ratings and discounts to outcomes.

## Limitations

- Variants of the same product share almost identical rating counts, so totals and the top 10 may double count.
- The dataset is a snapshot with no time or sales data, so the dashboard shows association, not cause and effect.
- `user_name`, `review_title`, and `review_content` were not split per review, and 9 products lost some reviews during the user/review split.

## Author

**Siti Muyassaroh**

- GitHub: [@sitimuyassaroh](https://github.com/sitimuyassaroh/)
- LinkedIn: [Siti Muyassaroh](https://www.linkedin.com/in/sitimuyassaroh/)
