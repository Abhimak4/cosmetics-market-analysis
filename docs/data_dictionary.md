# Data Dictionary — Cosmetics Market Analysis

Source: `data/raw/Cosmetics_products.csv` — 15,000 products, 14 columns, **0 missing values, 0 exact duplicate rows**.
Processed: `data/processed/final_cosmetics_powerbi.csv` — 15,000 rows, 21 columns (14 source + 7 engineered).

## Source columns

| Column | Type | Description | Example / values |
|---|---|---|---|
| `Product_Name` | text | Product name (120 unique names reused across brands/categories) | Magic Foundation |
| `Brand` | text | Brand (40 brands) | Milk Makeup, NARS, Kiehl's |
| `Category` | text | Product category (24) | Serum, Mascara, Face Oil, Lipstick |
| `Usage_Frequency` | text | How often the product is used | Daily, Weekly, Monthly, Occasional |
| `Price_USD` | decimal | Listed price, $10.00–$149.99 (avg $80.13) | 80.04 |
| `Rating` | decimal | Average customer rating, 1.0–5.0 (avg 3.00) | 4.8 |
| `Number_of_Reviews` | integer | Review count, 52–10,000 (total 75,213,470) | 9,972 |
| `Product_Size` | text | Pack size | 30ml, 50ml, 100ml, 150ml, 200ml, 250ml |
| `Skin_Type` | text | Target skin type | Dry, Oily, Normal, Sensitive, Combination |
| `Gender_Target` | text | Target audience | Female, Male, Unisex |
| `Packaging_Type` | text | Packaging format | Bottle, Jar, Tube, Spray, Stick, Compact |
| `Main_Ingredient` | text | Hero ingredient (7) | Retinol, Vitamin C, Hyaluronic Acid, Aloe Vera, Glycerin, Salicylic Acid, Shea Butter |
| `Cruelty_Free` | boolean | Cruelty-free certification (49.4% True) | True / False |
| `Country_of_Origin` | text | Country of manufacture (8) | Italy, USA, France, Japan, South Korea, UK, Germany, Australia |

## Engineered columns

Created in SQL (`final_cosmetics_analysis`) and mirrored in Python so both pipelines produce the same model.

| Column | Logic | Values |
|---|---|---|
| `price_segment` | `Price_USD < 40` → Budget; `40–90` → Mid-Range; `> 90` → Premium | Budget 3,168 · Mid-Range 5,384 · Premium 6,448 |
| `rating_segment` | `>= 4.0` High Rated; `3.0–3.9` Average Rated; `< 3.0` Low Rated | — |
| `review_segment` | `>= 7,000` High Engagement; `3,000–6,999` Medium; `< 3,000` Low | — |
| `daily_use_score` | 1 if `Usage_Frequency = Daily`, else 0 | Daily = 3,668 products (24.5%) |
| `review_score` | `Number_of_Reviews / MAX(Number_of_Reviews)` (0–1) | — |
| `opportunity_score` | `0.40 × Rating + 0.40 × (review_score × 5) + 0.20 × (daily_use_score × 5)`, range 0–5, catalog avg 2.45 | Top product: 4.95 |
| `product_performance` | Rating ≥ 4.0 **and** reviews ≥ 7,000 → Top Performer; rating ≥ 3.0 **and** reviews ≥ 3,000 → Moderate Performer; else Low Performer | Top 1,215 · Moderate 4,164 · Low 9,621 |
