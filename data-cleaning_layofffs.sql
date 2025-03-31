SELECT *
FROM layoffs;
-- Data cleaning 

-- creating a staging table 
CREATE TABLE layoffs_stagging
LIKE layoffs;

SELECT *
FROM layoffs_stagging;

INSERT layoffs_stagging
SELECT *
FROM layoffs;

-- removing a duplicate rows
SELECT *,ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,'date') AS row_num
FROM layoffs_stagging;


WITH duplicate_cte AS( 
	SELECT *,ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) AS row_num
	FROM layoffs_stagging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;



WITH duplicate_cte AS( 
	SELECT *,ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) AS row_num
	FROM layoffs_stagging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;


layoffs_stagging2CREATE TABLE `layoffs_stagging2` (
  `company` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `industry` varchar(255) DEFAULT NULL,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` float DEFAULT NULL,
  `date` date DEFAULT NULL,
  `stage` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `funds_raised_millions` INT DEFAULT NULL,
   number_row INT  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_stagging2;

INSERT INTO layoffs_stagging2
SELECT *,ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,'date') AS row_num
FROM layoffs_stagging;


DELETE
FROM layoffs_stagging2
WHERE number_row >1;

-- standardazing data 

SELECT company,TRIM(company)
FROM layoffs_stagging2;

UPDATE layoffs_stagging2
SET company=TRIM(company);

SELECT DISTINCT(industry)
FROM layoffs_stagging2
ORDER BY 1;


SELECT *
FROM layoffs_stagging2
WHERE industry  LIKE 'Crypto%';

UPDATE layoffs_stagging2 
SET industry ='Crypto'
WHERE industry like 'Crypto%';

SELECT DISTINCT(industry)
FROM layoffs_stagging2;

SELECT DISTINCT(country)
FROM layoffs_stagging2
ORDER BY 1;

SELECT DISTINCT country,TRIM(TRAILING '.' FROM country)
FROM layoffs_stagging2
ORDER BY 1;

UPDATE layoffs_stagging2
SET country=TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_stagging2
WHERE industry IS NULL OR industry = '';


SELECT *
FROM layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company=t2.company
	AND t1.location=t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company=t2.company
SET t1.location=t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

DELETE
FROM layoffs_stagging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


ALTER TABLE layoffs_stagging2
DROP COLUMN number_row;

SELECT *
FROM layoffs_stagging2;


-- exploratory data analysis 

SELECT MAX(total_laid_off)
FROM layoffs_stagging2;


SELECT MAX(percentage_laid_off)
FROM layoffs_stagging2;

SELECT *
FROM layoffs_stagging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_stagging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company,SUM(total_laid_off) AS total
FROM layoffs_stagging2
GROUP BY company
ORDER BY total DESC;


SELECT MIN(date),MAX(date)
FROM layoffs_stagging2;

SELECT industry,SUM(total_laid_off) AS total
FROM layoffs_stagging2
GROUP BY industry
ORDER BY total DESC;



SELECT country,SUM(total_laid_off) AS total
FROM layoffs_stagging2
GROUP BY country
ORDER BY total DESC;

SELECT date,SUM(total_laid_off) AS total
FROM layoffs_stagging2
GROUP BY date
ORDER BY total DESC;

SELECT EXTRACT(year FROM date) AS years,SUM(total_laid_off) AS total
FROM layoffs_stagging2
GROUP BY years
ORDER BY total DESC;

SELECT stage,SUM(total_laid_off) AS total
FROM layoffs_stagging2
GROUP BY stage
ORDER BY total DESC;

SELECT SUBSTRING(date,1,7) AS months,SUM(total_laid_off)
FROM layoffs_stagging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY months
ORDER BY 1 ASC;

WITH rolling_total AS 
(
SELECT SUBSTRING(date,1,7) AS months,SUM(total_laid_off) AS total_off
FROM layoffs_stagging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY months
ORDER BY 1 ASC
)
SELECT months,total_off,SUM(total_off) OVER(ORDER BY months) AS rolling_total
FROM rolling_total;

SELECT company,YEAR(date),SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company,YEAR(date)
ORDER BY 3 DESC;

WITH company_year(company,years,total_laid_off) AS
(
SELECT company,YEAR(date),SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company,YEAR(date)
ORDER BY 3 DESC
),company_year_rank AS(
SELECT *,DENSE_RANK()  OVER(PARTITION BY years ORDER BY total_laid_off DESC ) AS ranking
FROM company_year
WHERE years IS NOT NULL 
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;



SELECT *
FROM layoffs_stagging2;
