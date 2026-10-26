/*
===========================================================
PROJECT: Cosmetics Market Analysis — QA Fixes & Improvements
AUTHOR: Abhishek Makwana
DESCRIPTION:
    Small, documented fixes found during a QA review of
    01_cosmetics_market_analysis.sql. The original script is
    kept unchanged; this file records what to adjust and why.
===========================================================
*/

-----------------------------------------------------------
-- FIX 1: Launch-opportunity query returned almost no rows
-----------------------------------------------------------
-- In the original script the launch-opportunity query groups by
--   category x main_ingredient x skin_type x price_segment
-- and filters with HAVING COUNT(*) >= 20.
-- In this dataset the LARGEST such combination is exactly 20
-- products and most combinations are far smaller, so the query
-- returns almost nothing.
--
-- Recommended threshold: >= 10 (329 combinations qualify)
-- or >= 5 (783 combinations), depending on how selective the
-- shortlist should be.

SELECT
    category,
    main_ingredient,
    skin_type,
    price_segment,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(number_of_reviews), 0) AS avg_reviews,
    ROUND(AVG(price_usd), 2) AS avg_price
FROM final_cosmetics_analysis
WHERE LOWER(usage_frequency) IN ('daily', 'weekly')
GROUP BY category, main_ingredient, skin_type, price_segment
HAVING COUNT(*) >= 10          -- was: >= 20
ORDER BY avg_rating DESC, avg_reviews DESC;


-----------------------------------------------------------
-- FIX 2: Brand-name encoding (mojibake)
-----------------------------------------------------------
-- Two brand names arrive with broken UTF-8 encoding:
--   'Kiehlâ€™s'      should be  Kiehl's
--   'Juviaâ€™s Place' should be  Juvia's Place
-- Fix once at the cleaning stage (also handled in the
-- Python pipeline):

UPDATE clean_cosmetics
SET brand = REPLACE(brand, 'Kiehlâ€™s', 'Kiehl''s')
WHERE brand LIKE 'Kiehl%';

UPDATE clean_cosmetics
SET brand = REPLACE(brand, 'Juviaâ€™s Place', 'Juvia''s Place')
WHERE brand LIKE 'Juvia%';
