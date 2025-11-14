USE DATABASE CGM_HEALTH;
USE SCHEMA ANALYTICS;

-- Create a new table to hold the classified notes
CREATE OR REPLACE TABLE CLASSIFIED_NOTES AS
SELECT
    TIMESTAMP,
    NOTES,
    -- Call Cortex AI. We use 'snowflake-arctic', a fast, efficient model.
    -- This prompt forces it to choose from one of our categories.
    SNOWFLAKE.CORTEX.COMPLETE(
        'snowflake-arctic',
        CONCAT(
            'Classify the following lifestyle note into one category: EATING, EXERCISE, SLEEP, MEDICATION, ALCOHOL, STRESS, or OTHER. Respond with only the category name.\n',
            'Note: "', NOTES, '"\n',
            'Category:'
        )
    ) AS LIFESTYLE_CATEGORY
FROM
    RAW_READINGS
WHERE
    NOTES IS NOT NULL AND NOTES != ''; -- Only run on rows that have notes

-- Check your results
SELECT LIFESTYLE_CATEGORY, COUNT(*)
FROM CLASSIFIED_NOTES
GROUP BY LIFESTYLE_CATEGORY
ORDER BY COUNT(*) DESC;

SELECT * FROM CLASSIFIED_NOTES LIMIT 50;