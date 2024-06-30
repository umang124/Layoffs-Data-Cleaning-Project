-- Switch to the 'world_layoffs' database.
USE world_layoffs;

-- Select all records from the 'layoffs' table.
SELECT * 
FROM layoffs;

-- Create a new table 'layoffs_staging' with the same structure as the 'layoffs' table.
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Select all records from 'layoffs_staging' to verify its structure and content.
SELECT * 
FROM layoffs_staging;

-- Insert all records from 'layoffs' into 'layoffs_staging'.
INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- Common Table Expression (CTE) to identify duplicate records in 'layoffs_staging'.
WITH duplicate_cte AS
(
    -- Select all columns and add a row number for each duplicate record within the same partition.
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off,
	percentage_laid_off, `date`, stage, country, funds_raised_millions
	) AS row_num	
	FROM layoffs_staging
)
-- Select records from the CTE where the row number is greater than 1 (indicating duplicates).
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Select records from 'layoffs_staging' where the company is 'Casper'.
SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';

-- Create a new table 'layoffs_staging2' with an additional 'row_num' column to store row numbers.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert all records from 'layoffs_staging' into 'layoffs_staging2', adding row numbers for duplicates.
INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off,
	percentage_laid_off, `date`, stage, country, funds_raised_millions
	) AS row_num	
FROM layoffs_staging;

-- Select records from 'layoffs_staging2' where the row number is greater than 1 (indicating duplicates).
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Disable safe updates mode to allow updates to all records.
SET SQL_SAFE_UPDATES = 0;

-- Delete duplicate records from 'layoffs_staging2' where the row number is greater than 1.
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Standardize data by trimming whitespace from the 'company' column in 'layoffs_staging2'.
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';







-- Re-enable safe updates mode.
SET SQL_SAFE_UPDATES = 1;
















