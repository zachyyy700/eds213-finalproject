duckdb horses.duckdb
.table

-- 207 unique 'sires'
SELECT DISTINCT l.f_father_name AS sires FROM Lineage l; 

--- grandsire line stats
SELECT
    --- output columns
    l.f_father_name AS sire_line,
    COUNT(DISTINCT l.horse_id) AS horses,
    COUNT(*) AS total_races,
    SUM(CASE WHEN r.finish_pos = 1 THEN 1 ELSE 0 END) AS wins,
    ROUND(SUM(CASE WHEN r.finish_pos = 1 THEN 1 ELSE 0 END) / COUNT(*), 3) AS win_rate,
    ---
    FROM Lineage l
    JOIN Results r USING (horse_id)
    WHERE f_father_name IS NOT NULL
    GROUP BY sire_line
    ORDER BY horses DESC LIMIT 20;

--- mare line
SELECT
    --- output columns
    l.f_mother_name AS mare_line,
    COUNT(DISTINCT l.horse_id) AS horses,
    COUNT(*) AS total_races,
    SUM(CASE WHEN r.finish_pos = 1 THEN 1 ELSE 0 END) AS wins,
    ROUND(SUM(CASE WHEN r.finish_pos = 1 THEN 1 ELSE 0 END) / COUNT(*), 3) AS win_rate,
    ---
    FROM Lineage l
    JOIN Results r USING (horse_id)
    WHERE f_mother_name IS NOT NULL
    GROUP BY mare_line
    ORDER BY horses DESC LIMIT 20;