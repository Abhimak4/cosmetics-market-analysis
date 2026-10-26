# Dashboard Guide — Cosmetics_Data_Dashboard.pbix

How the Power BI dashboard is built, what each visual means, and how to extend it.
Open the file in **Power BI Desktop**; point the data source at `data/processed/final_cosmetics_powerbi.csv` if asked, then **Refresh**.

## Page 1 — Executive Overview (as built)

| # | Visual | Fields | What it answers |
|---|---|---|---|
| 1 | KPI card — Total Products | Count of `product_name` | How big is the catalog? **15,000** |
| 2 | KPI card — Average Rating | Average of `rating` | Overall quality level: **3.00★** |
| 3 | KPI card — Average Price | Average of `price_usd` | Price positioning: **$80.13** |
| 4 | KPI card — Total Reviews | Sum of `number_of_reviews` | Total customer engagement: **75.2M** |
| 5 | Clustered column chart | `category` × count of products | Where is the shelf concentrated? Serum (710) leads; all 24 categories hold 571–710 products |
| 6 | Bar chart | `category` × average `rating` | Which categories are loved? Contour 3.13★ (best) → Lip Liner 2.89★ (worst) |
| 7 | Donut chart | `price_segment` × count of products | Price mix: Premium 6,448 · Mid-Range 5,384 · Budget 3,168 |
| 8–12 | Slicers | `category`, `gender_target`, `brand`, `rating`, `skin_type` | Cross-filter every visual on the page |

One thing worth trying: filter the page to Premium products and watch the Average Rating card. It stays at about 3.00, which is the main finding of the project — price and quality are not connected in this catalog.

## Page 2 — Opportunities & Performance (my plan for the next page)

Page 2 is where the Opportunity Score and product performance results will go. Build steps:

1. **Rename Page 2** to `Opportunities & Performance`.
2. **Top 10 Opportunities table** — Insert → Table. Columns: `product_name`, `brand`, `category`, `rating`, `number_of_reviews`, `opportunity_score`. Sort descending by `opportunity_score`, add a Top-N filter (Top 10 by opportunity score), and turn on data bars for the score column (Format → Cell elements → Background).
   - Expected #1 row: *Magic Foundation — RMS Beauty — Lip Gloss — 4.9★ — 9,972 reviews — 4.95*.
3. **Performance donut** — Insert → Donut chart. Legend: `product_performance`, Values: count of products. Expected: Top Performer 1,215 · Moderate 4,164 · Low 9,621.
4. **Opportunity by category** — Insert → Bar chart. Axis: `category`, Values: average of `opportunity_score`. Primer (2.51) and Contour (2.52) lead; Eyeliner (2.40) trails.
5. **Brand leaderboard** — Insert → Table or bar chart: `brand`, count of products, average `rating`, sum of `number_of_reviews`. Highlight Milk Makeup (426 products, 3.15★) and NARS (2.09M reviews).
6. **Slicers** — add `price_segment`, `skin_type`, and `rating_segment`. Prefer `rating_segment` over the raw numeric `rating` range slicer: business users think in High / Average / Low.
7. **Sync slicers** — select each Page 1 slicer → View → Sync Slicers → check both pages, so filters follow the reader across pages.
8. **Format** — keep the report theme consistent: navy `#0F2A44` headers, Power BI yellow `#F2C811` accents, white cards.

## Data refresh checklist

- [ ] Replace the source with `data/processed/final_cosmetics_powerbi.csv` (21 columns — includes `product_performance` and the corrected brand names Kiehl's / Juvia's Place)
- [ ] Transform data → verify `rating` and `price_usd` are Decimal, `number_of_reviews` is Whole Number, `cruelty_free` is True/False
- [ ] Refresh → confirm KPI cards read 15,000 / 3.00 / $80.13 / 75,213,470
- [ ] File → Export → screenshot Page 1 for LinkedIn / portfolio use
