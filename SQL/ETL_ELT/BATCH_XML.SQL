-- Common Table Expression (CTE) to get distinct ICCIDs inserted today
WITH lov AS (
    SELECT DISTINCT
        iccid 
    FROM 
        database.schema.table
    WHERE 
        DW_INSERT_TMS >= CURRENT_DATE
),

-- CTE to calculate the total number of batches needed
-- batch_count AS (
--     SELECT 
--         CEIL(COUNT(1) / 50) AS batch_count 
--     FROM 
--         lov 
-- ),

-- CTE to assign row numbers and batch numbers to each ICCID
batch_calc AS (
    SELECT 
        iccid,
        ROW_NUMBER() OVER (ORDER BY iccid) AS row_num,
        CEIL(ROW_NUMBER() OVER (ORDER BY iccid) / 50) AS batch_number
    FROM 
        lov 
)

-- Final selection to create URL lists for each batch
SELECT  
    --batch_number, 
    --ANY_VALUE(batch_count) AS batch_count,
    --'{"ICCID":' ||
    LISTAGG('<sch:iccid>' || iccid || '</sch:iccid>', '') WITHIN GROUP (ORDER BY iccid) AS iccid_list
    --|| '}' 
FROM 
    batch_calc 
    --JOIN batch_count
GROUP BY 
    batch_number 
ORDER BY 
    batch_number;
