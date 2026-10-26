# Cosmetics Market Analysis

This is a data analysis project I built to practice working end to end — cleaning raw data in SQL, analysing it in Python, and building a dashboard in Power BI.

The dataset has 15,000 cosmetics products from 40 brands across 24 categories, with about 75.2 million customer reviews in total. The question I wanted to answer was simple: which products in this catalog are actually good, and does paying more get you a better product?

Short answer: not really. Premium products (over $90) have an average rating of 3.00. Budget products (under $40) average 3.02. Price and rating have almost no relationship in this data.

## Tools I used

- SQL Server (SSMS) — data validation, cleaning, and creating the analysis tables
- Python (pandas, NumPy, matplotlib) — exploratory analysis and scoring
- Power BI Desktop — dashboard
- Excel/CSV — data files

## How I did it

**1. SQL — cleaning and feature engineering** (`sql/01_cosmetics_market_analysis.sql`)

I loaded the raw CSV into a table called `Cosmetics_products`, checked row counts, nulls and duplicates, then built a cleaned table (`clean_cosmetics`) using TRIM and CAST, and filtered out invalid rows (price outside 1–500, rating outside 1–5). On top of that I created `final_cosmetics_analysis` with extra columns using CASE statements:

- `price_segment` — Budget (under $40), Mid-Range ($40–90), Premium (over $90)
- `rating_segment` — Low / Average / High Rated
- `review_segment` — Low / Medium / High Engagement based on review count
- `is_daily_use` — flag for daily-use products
- `product_performance` — Top Performer (rating 4.0+ and 7,000+ reviews), Moderate Performer, or Low Performer

The script ends with the analysis queries: category performance, price segment comparison, ingredient analysis, skin type breakdown, and a product launch opportunity query.

**2. Python — EDA and Opportunity Score** (`python/cosmetics_eda.py`)

I loaded the same data in pandas, checked its shape, missing values and summary statistics, and grouped it by category. Then I created a score to rank products by launch potential:

```
Opportunity Score = (Rating x 0.40) + (Review score x 0.40) + (Daily-use score x 0.20)
```

Reviews are normalized to a 0–1 scale first (`review_score`). Daily-use products get the extra weight because products people use every day sell again and again. The script exports the final file (`data/processed/final_cosmetics_powerbi.csv`, 21 columns) that Power BI reads.

**3. Power BI — dashboard** (`powerbi/Cosmetics_Data_Dashboard.pbix`)

Page 1 has four KPI cards (Total Products, Average Rating, Average Price, Total Reviews), a column chart of products by category, a bar chart of average rating by category, a donut chart of the price segment split, and five slicers (category, gender target, brand, rating, skin type). Everything cross-filters.

I'm currently adding a second page for the Opportunity Score and product performance results — the plan for it is in `docs/dashboard_guide.md`.

## What I found

- **Price does not mean quality.** Budget, Mid-Range and Premium products all average around 3.0 stars.
- **A small group of products does most of the work.** 1,215 products (8.1% of the catalog) are Top Performers. They average 4.48 stars and hold 10.3 million reviews — 13.7% of all reviews in the data.
- **Most of the catalog is weak.** 9,621 products (64.1%) fall into Low Performer, averaging 2.45 stars.
- **Daily-use products rank highest.** Every product in my Top 10 opportunity list is a daily-use product. Daily products score 3.19 on average, against about 2.2 for weekly, monthly and occasional products.
- **Cruelty-free costs nothing.** Half the catalog (49.4%) is cruelty-free, and those products rate the same (3.01 vs 3.00) and cost the same ($80.23 vs $80.04) as the rest.
- **The biggest category is not the best one.** Serum has the most products (710) but a rating of 2.97, below average. The best-rated category is Contour (3.13) and the worst is Lip Liner (2.89).
- Milk Makeup has the most products (426) and also the highest average rating of any brand (3.15). NARS has the most reviews overall (2.09 million).

## What I would recommend to the business

1. Promote and expand the Top Performer products first — they already have the ratings and the review volume to sell.
2. Look at the Low Performer group before adding anything new. That is almost two-thirds of the catalog.
3. Use cruelty-free as the default positioning. There is no downside in this data.
4. For Premium products, show reviews and ratings clearly at the point of sale — customers are not getting better quality for the higher price right now.
5. Work on Serum quality. It is the largest category and it should not be below average.

Result tables are in the `results/` folder if you want the numbers behind this.

## Problems I ran into (and fixed)

- Two brand names had broken characters from an encoding issue — "Kiehlâ€™s" instead of Kiehl's, and the same for Juvia's Place. I fixed this in both the SQL and Python files. The fixes are written up in `sql/02_qa_fixes_and_improvements.sql`.
- My launch opportunity query in SQL returned almost no rows. The issue was the `HAVING COUNT(*) >= 20` filter — the biggest category/ingredient/skin-type/price combination in this data only has 20 products, so nearly everything got filtered out. Lowering it to 10 gives 329 combinations to work with.
- My Python export was missing the `product_performance` column even though the SQL script creates it. The processed CSV in this repo has it, so both files match now.
- One limitation in the data itself: there are only 120 unique product names, and they repeat across brands and categories, and a few names don't match their category (for example a "Foundation" listed under Lip Gloss). I left the data as it is and did the analysis at category and segment level, where this matters less.

## Data quality checks

- 15,000 rows, 14 columns in the raw file
- 0 missing values
- 0 exact duplicate rows
- Price range $10.00–$149.99 (average $80.13), ratings 1.0–5.0 (average 3.00)

Every column is described in `docs/data_dictionary.md`.

## How to run it

Python:

```
pip install -r requirements.txt
python python/cosmetics_eda.py
```

This regenerates `data/processed/final_cosmetics_powerbi.csv` and prints the category summary and Top 10 opportunities.

SQL: create a database called `Cosmetics_Data`, import the raw CSV as `Cosmetics_products`, then run `sql/01_cosmetics_market_analysis.sql` from top to bottom.

Power BI: open the `.pbix` file in Power BI Desktop. If it asks for the data source, select `data/processed/final_cosmetics_powerbi.csv` and refresh.

## Folder structure

```
data/raw/           original CSV
data/processed/     cleaned file used by Power BI
sql/                SQL Server scripts
python/             pandas EDA script
powerbi/            Power BI dashboard file
results/            summary tables from the analysis (CSV)
docs/               data dictionary and dashboard guide
dashboard/          interactive web version of the dashboard (open the HTML file in a browser)
```

## About me

Abhishek Makwana — Data Analyst based in Ontario, Canada. I work with SQL, Python, Power BI and Excel, and I'm currently looking for Data Analyst / Business Analyst roles in Canada.

LinkedIn: https://www.linkedin.com/in/abhimak4
Portfolio: https://abhimak4.net
