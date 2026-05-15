-- initialize duckdb
duckdb

-- define lineage table
CREATE TABLE Lineage (
    horse_id VARCHAR PRIMARY KEY,

    father_id VARCHAR,
    father_name VARCHAR,
    mother_id VARCHAR,
    mother_name VARCHAR,

    f_father_id VARCHAR,
    f_father_name VARCHAR,
    f_mother_id VARCHAR,
    f_mother_name VARCHAR,

    m_father_id VARCHAR,
    m_father_name VARCHAR,
    m_mother_id VARCHAR,
    m_mother_name VARCHAR
);

-- read csv into Lineage table
INSERT INTO Lineage
SELECT * EXCLUDE (raw_json) -- csv has unwanted column
FROM read_csv('data/raw/horse_profiles.csv', auto_detect=true);

-- view table
SELECT * FROM Lineage LIMIT 3;

----------------------------------------------------------------

-- define races table
CREATE TABLE Races (
    race_id VARCHAR PRIMARY KEY,
    race_name VARCHAR,

    date DATE,
    venue VARCHAR,
    race_num INT,

    distance INT,
    track_type TEXT,
    going TEXT,
);

-- read csv into Races table
INSERT INTO Races
SELECT * EXCLUDE (raw_json) -- csv has unwanted column
FROM read_csv('data/raw/races.csv', auto_detect=true);

-- view table
SELECT * FROM Races LIMIT 3;

----------------------------------------------------------------

-- define results table
CREATE TABLE Results (
    result_id VARCHAR PRIMARY KEY, 
    race_id VARCHAR,
    
    finish_pos INT,
    horse_entry_num INT,
    horse_id VARCHAR,
    horse_name VARCHAR,
    
    weight REAL, -- real vs float?
    odds REAL,
    time_sec REAL,
    margin FLOAT,

    FOREIGN KEY (race_id) REFERENCES Races (race_id),
    FOREIGN KEY (horse_id) REFERENCES Lineage (horse_id)
);

-- read csv into Results table
INSERT INTO Results
FROM read_csv('data/processed/results_processed.csv', auto_detect=true); 

-- view table
SELECT * FROM Results LIMIT 3;

-- export to .duckdb
ATTACH 'horses.duckdb' AS dest;
CREATE TABLE dest.Lineage AS SELECT * FROM Lineage;
CREATE TABLE dest.Results AS SELECT * FROM Results;
CREATE TABLE dest.Races AS SELECT * FROM Races;

-----------------------
-- ALTER TABLE, ADD GENDER COLUMN, JOIN ON horse_id in Results table
duckdb horses.duckdb

CREATE TEMP TABLE horse_gender AS
    SELECT horse_id::VARCHAR AS horse_id, gender::VARCHAR AS gender
    FROM read_csv('data/processed/results_processed_gender.csv');

-- create new empty column in results table
ALTER TABLE Results ADD COLUMN gender VARCHAR;

-- add gender entries from temp table
UPDATE Results
SET gender = horse_gender.gender
FROM horse_gender
WHERE Results.horse_id = horse_gender.horse_id;

SELECT gender FROM Results WHERE gender IS NULL;