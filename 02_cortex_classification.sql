-- Define a "damage" baseline. Let's use 140.
-- You could also use a lower one, like 120.
SET DAMAGE_BASELINE = 140;
SET DAMAGE_POWER = 3;

CREATE OR REPLACE TABLE GLUCOSE_FEATURES AS
SELECT
    TIMESTAMP,
    GLUCOSE_VALUE,
    -- Simple flag for "high"
    (GLUCOSE_VALUE > $DAMAGE_BASELINE)::INT AS IS_HIGH,
    
    -- Your new feature: GLYCATION_INDEX
    -- Only applies to high values, otherwise 0.
    CASE
        WHEN GLUCOSE_VALUE > $DAMAGE_BASELINE 
        THEN POW(GLUCOSE_VALUE - $DAMAGE_BASELINE, $DAMAGE_POWER)
        ELSE 0
    END AS GLYCATION_INDEX
FROM
    RAW_READINGS;

-- Now, look at your "most damaging" moments
SELECT 
    TIMESTAMP, 
    GLUCOSE_VALUE, 
    GLYCATION_INDEX 
FROM 
    GLUCOSE_FEATURES
WHERE 
    GLYCATION_INDEX > 0
ORDER BY 
    GLYCATION_INDEX DESC
LIMIT 20;