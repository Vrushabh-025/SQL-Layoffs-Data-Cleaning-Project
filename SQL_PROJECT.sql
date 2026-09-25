Select * 
FROM layoffs;

use sql_project;
-- 1. Remove Duplicates
-- 2. Inconsistent text
-- 3. Null Values or blank values
-- 4. Remove any Columns

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
select *
from layoffs;

SELECT * 
FROM layoffs_staging;


SELECT *
FROM sql_project.layoffs_staging
;

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		sql_project.layoffs_staging;
        


with duplicate_cte as
(
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		sql_project.layoffs_staging
) 
select * 
from duplicate_cte
WHERE  row_num > 1;


SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		sql_project.layoffs_staging
) duplicates
WHERE 
	row_num > 1;


CREATE TABLE layoffs_staging2
LIKE layoffs;


INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off,
                     percentage_laid_off, `date`, stage, country,
                     funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

select * from layoffs_staging2;
SELECT * FROM layoffs_staging2 WHERE row_num > 1;
DELETE FROM layoffs_staging2 WHERE row_num > 1;
-- -- --- -- --- ----------------------------------------------------------------------
-- 2. Inconsistent text

Select distinct (company) from layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
where country like 'United States% ';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

SELECT 	* FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- -- 3. Null Values or blank values

Select *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

DELETE FROM sql_project.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

select *
from sql_project.layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

select *
from sql_project.layoffs_staging2;














