-- Use the world_layoffs database
USE world_layoffs;

-- View all records in the layoffs table
SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Handle Null or Blank Values
-- 4. Remove Unnecessary Columns

-- Create a staging table with the same structure as the layoffs table
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Insert all records from the layoffs table into the staging table
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- Check for duplicate records using a CTE
WITH duplicate_cte AS
(
    SELECT *, ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
        date, stage, country, funds_raised_millions) AS row_num
    FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

-- View records where the company is 'Casper'
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create another staging table with an additional column for row number
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

-- Insert records into the new staging table with row numbers for duplicates
INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
    date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Select records with duplicates
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

-- Disable safe updates to allow deletion
SET SQL_SAFE_UPDATES = 0;

-- Delete duplicate records
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Enable safe updates again
SET SQL_SAFE_UPDATES = 1;

-- Standardize data

-- Trim whitespace from company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Update industry names that start with 'Crypto' to 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Trim trailing periods from country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States.';

-- Convert date column to date type
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Handle Null or Blank Values

-- Set industry to NULL where it is blank
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Update NULL industries with non-null values from the same company
UPDATE layoffs_staging2 t1
INNER JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Remove records with both total_laid_off and percentage_laid_off as NULL
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove the row_num column as it is no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Convert all text columns to lowercase

-- Disable safe updates to allow deletion
SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET 
	company = LOWER(company),
    location = LOWER(location),
    industry = LOWER(industry),
    stage = LOWER(stage),
    country = LOWER(country);


-- Remove common domain extensions from company names
UPDATE layoffs_staging2
SET company = REPLACE(company, '.com', '');
    
UPDATE layoffs_staging2
SET company = REPLACE(company, '.au', '');

UPDATE layoffs_staging2
SET company = REPLACE(company, '.co', '');

UPDATE layoffs_staging2
SET company = REPLACE(company, '.fun', '');

UPDATE layoffs_staging2
SET company = REPLACE(company, '&', '');
    
UPDATE layoffs_staging2
SET company = REPLACE(company, '.ai', '');

UPDATE layoffs_staging2
SET company = REPLACE(company, '.org', '');

-- Check for invalid dates (e.g., future dates)
SELECT *
FROM layoffs_staging2
WHERE `date` > CURDATE();

-- Select rows where percentage_laid_off contains non-numeric characters
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off REGEXP '[^0-9.]';

ALTER TABLE layoffs_staging2
MODIFY COLUMN percentage_laid_off DECIMAL(5, 4);

-- Enable safe updates again
SET SQL_SAFE_UPDATES = 1;
    
    
    




