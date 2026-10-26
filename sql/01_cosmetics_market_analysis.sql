/*
===========================================================
PROJECT: Cosmetics Market Analysis
AUTHOR: Abhishek Makwana
DESCRIPTION:
End-to-end SQL script for:
1. Data validation
2. Data cleaning
3. Feature engineering
4. Business analysis queries
===========================================================
*/

-----------------------------------------------------------
-- STEP 1: USE DATABASE
-----------------------------------------------------------
USE Cosmetics_Data;
GO


-----------------------------------------------------------
-- STEP 2: CHECK RAW DATA
-----------------------------------------------------------

-- View sample data
SELECT TOP 10 *
FROM Cosmetics_products;

-- Count total rows
SELECT COUNT(*) AS total_rows
FROM Cosmetics_products;

-- Check column completeness (null check)
SELECT
    COUNT(*) AS total_rows,
    COUNT(Product_Name) AS product_name_count,
    COUNT(Brand) AS brand_count,
    COUNT(Category) AS category_count,
    COUNT(Price_USD) AS price_count,
    COUNT(Rating) AS rating_count,
    COUNT(Number_of_Reviews) AS review_count
FROM Cosmetics_products;


-----------------------------------------------------------
-- STEP 3: CHECK DUPLICATES
-----------------------------------------------------------

-- Identify duplicate products
SELECT 
    Product_Name,
    Brand,
    Category,
    COUNT(*) AS duplicate_count
FROM Cosmetics_products
GROUP BY Product_Name, Brand, Category
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-----------------------------------------------------------
-- STEP 4: CREATE CLEANED TABLE
-----------------------------------------------------------

-- Drop if already exists

DROP TABLE IF EXISTS clean_cosmetics;
GO

-- Clean and standardize data
SELECT
    TRIM(Product_Name) AS product_name,
    TRIM(Brand) AS brand,
    TRIM(Category) AS category,
    TRIM(Usage_Frequency) AS usage_frequency,

    -- Convert numeric fields
    CAST(Price_USD AS DECIMAL(10,2)) AS price_usd,
    CAST(Rating AS DECIMAL(3,2)) AS rating,
    CAST(Number_of_Reviews AS INT) AS number_of_reviews,

    TRIM(Product_Size) AS product_size,
    TRIM(Skin_Type) AS skin_type,
    TRIM(Gender_Target) AS gender_target,
    TRIM(Packaging_Type) AS packaging_type,
    TRIM(Main_Ingredient) AS main_ingredient,

    -- Convert boolean field
    CAST(Cruelty_Free AS BIT) AS cruelty_free,

    TRIM(Country_of_Origin) AS country_of_origin

INTO clean_cosmetics
FROM Cosmetics_products

-- Remove invalid data
WHERE Product_Name IS NOT NULL
  AND Brand IS NOT NULL
  AND Category IS NOT NULL
  AND Price_USD BETWEEN 1 AND 500
  AND Rating BETWEEN 1 AND 5
  AND Number_of_Reviews >= 0;


-----------------------------------------------------------
-- STEP 5: CREATE FINAL ANALYSIS TABLE
-----------------------------------------------------------

DROP TABLE IF EXISTS final_cosmetics_analysis;
GO

SELECT *,
    -------------------------------------------------------
    -- Price segmentation (business strategy)
    -------------------------------------------------------
    CASE
        WHEN price_usd < 40 THEN 'Budget'
        WHEN price_usd BETWEEN 40 AND 90 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_segment,

    -------------------------------------------------------
    -- Rating segmentation (quality level)
    -------------------------------------------------------
    CASE
        WHEN rating >= 4.0 THEN 'High Rated'
        WHEN rating >= 3.0 THEN 'Average Rated'
        ELSE 'Low Rated'
    END AS rating_segment,

    -------------------------------------------------------
    -- Review segmentation (popularity)
    -------------------------------------------------------
    CASE
        WHEN number_of_reviews >= 7000 THEN 'High Engagement'
        WHEN number_of_reviews >= 3000 THEN 'Medium Engagement'
        ELSE 'Low Engagement'
    END AS review_segment,

    -------------------------------------------------------
    -- Daily usage flag
    -------------------------------------------------------
    CASE
        WHEN usage_frequency = 'Daily' THEN 1
        ELSE 0
    END AS is_daily_use,

    -------------------------------------------------------
    -- Cruelty-free label
    -------------------------------------------------------
    CASE
        WHEN cruelty_free = 1 THEN 'Cruelty-Free'
        ELSE 'Not Cruelty-Free'
    END AS cruelty_free_status,

    -------------------------------------------------------
    -- Product performance classification
    -------------------------------------------------------
    CASE
        WHEN rating >= 4.0 AND number_of_reviews >= 7000 THEN 'Top Performer'
        WHEN rating >= 3.0 AND number_of_reviews >= 3000 THEN 'Moderate Performer'
        ELSE 'Low Performer'
    END AS product_performance

INTO final_cosmetics_analysis
FROM clean_cosmetics;


-----------------------------------------------------------
-- STEP 6: VALIDATE FINAL TABLE
-----------------------------------------------------------

SELECT COUNT(*) AS final_rows
FROM final_cosmetics_analysis;

SELECT TOP 10 *
FROM final_cosmetics_analysis;


-----------------------------------------------------------
-- STEP 7: BUSINESS ANALYSIS QUERIES
-----------------------------------------------------------

-----------------------------------------------------------
-- 1. CATEGORY PERFORMANCE
-- Identify most popular categories and their ratings
-----------------------------------------------------------
SELECT 
    category,
    COUNT(*) AS total_products,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(price_usd), 2) AS avg_price,
    ROUND(AVG(number_of_reviews), 0) AS avg_reviews
FROM final_cosmetics_analysis
GROUP BY category
ORDER BY total_products DESC;


-----------------------------------------------------------
-- 2. PRICE SEGMENT ANALYSIS
-- Compare budget vs premium performance
-----------------------------------------------------------
SELECT 
    price_segment,
    COUNT(*) AS total_products,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(number_of_reviews), 0) AS avg_reviews
FROM final_cosmetics_analysis
GROUP BY price_segment
ORDER BY avg_rating DESC;


-----------------------------------------------------------
-- 3. INGREDIENT ANALYSIS
-- Identify best-performing ingredients
-----------------------------------------------------------
SELECT 
    main_ingredient,
    COUNT(*) AS total_products,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(price_usd), 2) AS avg_price,
    ROUND(AVG(number_of_reviews), 0) AS avg_reviews
FROM final_cosmetics_analysis
GROUP BY main_ingredient
ORDER BY avg_rating DESC;


-----------------------------------------------------------
-- 4. SKIN TYPE ANALYSIS
-- Understand customer segmentation
-----------------------------------------------------------
SELECT 
    skin_type,
    category,
    COUNT(*) AS total_products,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(number_of_reviews), 0) AS avg_reviews
FROM final_cosmetics_analysis
GROUP BY skin_type, category
ORDER BY total_products DESC;


-----------------------------------------------------------
-- 5. PRODUCT LAUNCH OPPORTUNITY
-- Identify best market opportunities
-----------------------------------------------------------
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
WHERE usage_frequency IN ('Daily', 'Weekly')
GROUP BY category, main_ingredient, skin_type, price_segment
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC, avg_reviews DESC;


-----------------------------------------------------------

SELECT usage_frequency, COUNT(*) 
FROM final_cosmetics_analysis
GROUP BY usage_frequency;

SELECT 
    category,
    main_ingredient,
    skin_type,
    price_segment,
    COUNT(*) AS product_count
FROM final_cosmetics_analysis
WHERE usage_frequency IN ('Daily', 'Weekly')
GROUP BY category, main_ingredient, skin_type, price_segment
ORDER BY product_count DESC;

SELECT 
    category,
    main_ingredient,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(number_of_reviews), 0) AS avg_reviews,
    ROUND(AVG(price_usd), 2) AS avg_price
FROM final_cosmetics_analysis
WHERE LOWER(usage_frequency) IN ('daily', 'weekly')
GROUP BY category, main_ingredient
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC, avg_reviews DESC;

SELECT 
    category,
    main_ingredient,
    skin_type,
    price_segment,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS avg_rating
FROM final_cosmetics_analysis
GROUP BY category, main_ingredient, skin_type, price_segment
ORDER BY product_count DESC;

SELECT 
    category,
    main_ingredient,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(number_of_reviews), 0) AS avg_reviews,
    ROUND(AVG(price_usd), 2) AS avg_price
FROM final_cosmetics_analysis
WHERE LOWER(usage_frequency) IN ('daily', 'weekly')
GROUP BY category, main_ingredient
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC, avg_reviews DESC;














-- END OF FILE
-----------------------------------------------------------