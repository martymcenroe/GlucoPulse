-- 1. Set the context:
USE DATABASE CGM_HEALTH;
USE SCHEMA ANALYTICS;

-- 2. Create a "Stage" to put the file in. 
-- A Stage is a Snowflake object that points to a storage location.
CREATE OR REPLACE STAGE RAW_FILE_STAGE;

-- 3. Create the raw landing table. 
-- Notice all 19 columns are VARCHAR and use double-quotes 
-- to preserve spacing/special characters from your header.
CREATE OR REPLACE TABLE LANDING_LIBRE_RAW (
    "Device" VARCHAR,
    "Serial Number" VARCHAR,
    "Device Timestamp" VARCHAR,
    "Record Type" VARCHAR,
    "Historic Glucose mg/dL" VARCHAR,
    "Scan Glucose mg/dL" VARCHAR,
    "Non-numeric Rapid-Acting Insulin" VARCHAR,
    "Rapid-Acting Insulin (units)" VARCHAR,
    "Non-numeric Food" VARCHAR,
    "Carbohydrates (grams)" VARCHAR,
    "Carbohydrates (servings)" VARCHAR,
    "Non-numeric Long-Acting Insulin" VARCHAR,
    "Long-Acting Insulin (units)" VARCHAR,
    "Notes" VARCHAR,
    "Strip Glucose mg/dL" VARCHAR,
    "Ketone mmol/L" VARCHAR,
    "Meal Insulin (units)" VARCHAR,
    "Correction Insulin (units)" VARCHAR,
    "User Change Insulin (units)" VARCHAR
);

-- 3. UPLOAD YOUR FILE
-- Go to the Snowsight UI:
-- Data -> Databases -> CGM_HEALTH -> ANALYTICS -> Stages
-- Click on "RAW_FILE_STAGE".
-- Click "+ Files" in the top right, select your big CSV file, and upload it.
-- It will now be at the location '@RAW_FILE_STAGE/your_file_name.csv'

LIST @RAW_FILE_STAGE;

-- 4. Load the data from the Stage into the Table
-- *** Change 'your_file_name.csv' to the real file name ***
COPY INTO LANDING_LIBRE_RAW
  FROM '@raw_file_stage/MM_glucose_11-12-2025 (2).csv'  --<-- CHANGE THIS
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1  -- This skips the UGLY title row (row 1)
  );

-- 5. Check your raw data
SELECT * FROM LANDING_LIBRE_RAW LIMIT 20;

-- 6. Transform!
CREATE OR REPLACE TABLE RAW_READINGS AS
SELECT
    -- 1. Cast the timestamp (universal for all record types)
    TO_TIMESTAMP_NTZ("Device Timestamp", 'MM-DD-YYYY HH12:MI AM') AS TIMESTAMP,
    
    -- 2. Unify the glucose columns. This will be NULL for Record Type 6, which is correct.
    CASE 
        WHEN "Record Type" = '0' THEN "Historic Glucose mg/dL"
        WHEN "Record Type" = '1' THEN "Scan Glucose mg/dL"
    END AS GLUCOSE_STRING,

    -- 3. Cast the unified value to a number
    TO_NUMBER(GLUCOSE_STRING, 10, 2) AS GLUCOSE_VALUE,
    
    -- 4. Cast the Record Type
    TO_NUMBER("Record Type") AS READING_TYPE,
    
    -- 5. Coalesce all 'note' fields. This will be NULL for most 0/1 records,
    --    but will be populated for Record Type 6.
    COALESCE(
        "Notes",
        "Non-numeric Food",
        "Carbohydrates (grams)",
        "Non-numeric Rapid-Acting Insulin",
        "Rapid-Acting Insulin (units)",
        "Non-numeric Long-Acting Insulin",
        "Long-Acting Insulin (units)",
        "Strip Glucose mg/dL",
        "Ketone mmol/L",
        "Meal Insulin (units)",
        "Correction Insulin (units)",
        "User Change Insulin (units)"
    ) AS NOTES
    
FROM
    LANDING_LIBRE_RAW
WHERE
    -- 1. Keep ALL relevant record types
    "Record Type" IN ('0', '1', '6')
    
    -- 2. Filter out the header row that got loaded
    AND "Record Type" != 'Record Type';