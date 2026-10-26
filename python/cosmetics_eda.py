"""
===========================================================
PROJECT: Cosmetics Market Analysis
AUTHOR: Abhishek Makwana
DESCRIPTION:
    Python (pandas) exploratory data analysis for the
    Cosmetics Market Analysis project.

    Pipeline position:
        SQL Server cleaning/feature engineering (sql/)
            -> THIS SCRIPT: EDA + Opportunity Score
            -> Power BI dashboard (powerbi/)

    Run from the repository root:
        pip install -r requirements.txt
        python python/cosmetics_eda.py

    Input : data/raw/Cosmetics_products.csv
    Output: data/processed/final_cosmetics_powerbi.csv
===========================================================
"""

from pathlib import Path

import numpy as np
import pandas as pd

# ---------------------------------------------------------
# Paths (relative to the repository root — portable)
# ---------------------------------------------------------
ROOT = Path(__file__).resolve().parents[1]
INPUT_PATH = ROOT / "data" / "raw" / "Cosmetics_products.csv"
OUTPUT_PATH = ROOT / "data" / "processed" / "final_cosmetics_powerbi.csv"

# ---------------------------------------------------------
# STEP 1: LOAD DATA
# ---------------------------------------------------------
df = pd.read_csv(INPUT_PATH)
df.columns = df.columns.str.strip().str.lower()

print("Data loaded successfully")
print("Shape:", df.shape)
print("Columns:", list(df.columns))
print(df.head())

# ---------------------------------------------------------
# STEP 2: DATA QUALITY FIXES
# ---------------------------------------------------------
# Brand names arrived with broken encoding (mojibake) in the
# source file, e.g. "Kiehlâ€™s" instead of "Kiehl's".
df["brand"] = df["brand"].replace(
    {
        "Kiehlâ€™s": "Kiehl's",
        "Juviaâ€™s Place": "Juvia's Place",
    }
)

# ---------------------------------------------------------
# STEP 3: BASIC DATA CHECK
# ---------------------------------------------------------
print("\nDataset Info:")
df.info()

print("\nMissing Values:")
print(df.isnull().sum())

print("\nStatistical Summary:")
print(df.describe())

print("\nDuplicate rows (exact):", df.duplicated().sum())

# ---------------------------------------------------------
# STEP 4: CATEGORY SUMMARY
# ---------------------------------------------------------
category_summary = (
    df.groupby("category")
    .agg(
        total_products=("product_name", "count"),
        avg_rating=("rating", "mean"),
        avg_price=("price_usd", "mean"),
        avg_reviews=("number_of_reviews", "mean"),
    )
    .sort_values("total_products", ascending=False)
)

print("\nCategory Summary:")
print(category_summary)

# ---------------------------------------------------------
# STEP 5: OPPORTUNITY SCORE
# Business idea: rank products by launch/expansion potential.
#   opportunity_score (out of 5) =
#       40% product rating          (quality)
#     + 40% normalized review volume (engagement / demand proof)
#     + 20% daily-use flag           (purchase frequency)
# ---------------------------------------------------------
df["usage_frequency"] = df["usage_frequency"].astype(str).str.strip()

df["review_score"] = df["number_of_reviews"] / df["number_of_reviews"].max()
df["daily_use_score"] = np.where(df["usage_frequency"].str.lower() == "daily", 1, 0)

df["opportunity_score"] = (
    df["rating"] * 0.40
    + (df["review_score"] * 5) * 0.40
    + (df["daily_use_score"] * 5) * 0.20
)

# ---------------------------------------------------------
# STEP 6: FEATURE COLUMNS (segments)
# ---------------------------------------------------------
df["price_segment"] = pd.cut(
    df["price_usd"],
    bins=[0, 40, 90, 500],
    labels=["Budget", "Mid-Range", "Premium"],
    include_lowest=True,
)

df["rating_segment"] = pd.cut(
    df["rating"],
    bins=[0, 3, 4, 5],
    labels=["Low Rated", "Average Rated", "High Rated"],
    include_lowest=True,
)

df["review_segment"] = pd.cut(
    df["number_of_reviews"],
    bins=[0, 3000, 7000, df["number_of_reviews"].max()],
    labels=["Low Engagement", "Medium Engagement", "High Engagement"],
    include_lowest=True,
)

# Performance classification (mirrors the SQL final table so
# the CSV and the SQL pipeline can never drift apart)
df["product_performance"] = np.where(
    (df["rating"] >= 4.0) & (df["number_of_reviews"] >= 7000),
    "Top Performer",
    np.where(
        (df["rating"] >= 3.0) & (df["number_of_reviews"] >= 3000),
        "Moderate Performer",
        "Low Performer",
    ),
)

# ---------------------------------------------------------
# STEP 7: TOP OPPORTUNITIES
# ---------------------------------------------------------
top_opportunities = df.sort_values("opportunity_score", ascending=False)[
    [
        "product_name",
        "brand",
        "category",
        "main_ingredient",
        "price_segment",
        "rating",
        "number_of_reviews",
        "usage_frequency",
        "opportunity_score",
    ]
]

print("\nTop 10 Product Opportunities:")
print(top_opportunities.head(10))

print("\nPerformance mix:")
print(df["product_performance"].value_counts())

# ---------------------------------------------------------
# STEP 8: EXPORT FINAL POWER BI FILE
# ---------------------------------------------------------
OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(OUTPUT_PATH, index=False)

print("\nFinal Power BI file created successfully:")
print(OUTPUT_PATH)
print("Rows x columns:", df.shape)
