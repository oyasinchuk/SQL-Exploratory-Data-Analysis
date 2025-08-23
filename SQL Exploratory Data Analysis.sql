
/************************************************************************************************************/
/******************** Exploratory Data Analysis Project *****************************************************/
/*************************************************************************************************************
  Dataset source: data.gov
  Author: Olena Yasinchuk
  Date: August 21, 2025                                                                                     
*************************************************************************************************************/

SELECT * FROM ischemic_stroke.stroke_mortality;

-- Check if there are any duplicates
WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER () OVER (
PARTITION BY `year`, `county`, `hospital`, `OSHPDID`, `Measure`, `Risk Adjusted Rate`, `# of Deaths/Readmissions`, `# of Cases`,
`Hospital ratings`, `Location 1`) AS row_num
FROM ischemic_stroke.stroke_mortality)

SELECT * FROM duplicate_cte
WHERE row_num>1;

-- 30-day mortality cases, number of deaths/readmissions, rate of mortality
SELECT county, hospital, `year`,`# of Cases` AS num_cases, `# of Deaths/Readmissions`AS num_death_readm, `Risk Adjusted Rate` as death_rate
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality'
GROUP BY county, hospital, num_cases, num_death_readm, death_rate, `year`
ORDER BY death_rate DESC, county, hospital, num_cases DESC, num_death_readm DESC, `year`;

-- -- 30-day readmission cases, number of deaths/readmissions, rate of readmissions
SELECT county, hospital, `year`,`# of Cases` AS num_cases, `# of Deaths/Readmissions`AS num_death_readm, `Risk Adjusted Rate` as readm_rate
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Readmission' 
GROUP BY county, hospital, num_cases, num_death_readm, readm_rate, `year`
ORDER BY county, hospital, num_cases DESC, num_death_readm DESC, readm_rate DESC, `year`;

-- Check minimum and maximum for death cases
SELECT MIN(`Risk Adjusted Rate`), MAX(`Risk Adjusted Rate`), MIN(`# of Deaths/Readmissions`), MAX(`# of Deaths/Readmissions`), 
MIN(`# of Cases`), MAX(`# of Cases`)
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' AND hospital !='Statewide';

-- Check minimum and maximum for readmission cases
SELECT MIN(`Risk Adjusted Rate`), MAX(`Risk Adjusted Rate`), MIN(`# of Deaths/Readmissions`), MAX(`# of Deaths/Readmissions`), 
MIN(`# of Cases`), MAX(`# of Cases`)
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Readmission' AND hospital !='Statewide';

-- Compare hospital rating with 30-day death rate for death cases
SELECT county, hospital, `# of Deaths/Readmissions`AS num_death_readm, `Risk Adjusted Rate` as readm_rate, `Hospital ratings` AS hosp_rating
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' 
GROUP BY hosp_rating, county, hospital, num_death_readm, readm_rate
ORDER BY readm_rate DESC, hosp_rating, county, hospital, num_death_readm;

-- Compare hospital rating with 30-day readmission rate for readmission cases
SELECT county, hospital, `# of Deaths/Readmissions`AS num_death_readm, `Risk Adjusted Rate` as readm_rate, `Hospital ratings` AS hosp_rating
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Readmission' 
GROUP BY hosp_rating, county, hospital, num_death_readm, readm_rate
ORDER BY readm_rate DESC, hosp_rating, county, hospital, num_death_readm;

-- Which hospitals have 30-day Mortality rate less than 10%
SELECT county, hospital, `# of Deaths/Readmissions`AS num_death_readm, `Risk Adjusted Rate` as readm_rate, `Hospital ratings` AS hosp_rating
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' and `Risk Adjusted Rate`<10
GROUP BY hosp_rating, county, hospital, num_death_readm, readm_rate
ORDER BY readm_rate DESC, hosp_rating, county, hospital, num_death_readm;

-- Which hospitals have 30-day Mortality rate greater than or equal to 20%
SELECT county, hospital, `# of Deaths/Readmissions`AS num_death_readm, `Risk Adjusted Rate` as readm_rate, `Hospital ratings` AS hosp_rating
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' and `Risk Adjusted Rate`>=20
GROUP BY hosp_rating, county, hospital, num_death_readm, readm_rate
ORDER BY readm_rate DESC, hosp_rating, county, hospital, num_death_readm;

-- Which hospitals have 30-day Readmission rate less than 10%
SELECT county, hospital, `# of Deaths/Readmissions`AS num_death_readm, `Risk Adjusted Rate` as readm_rate, `Hospital ratings` AS hosp_rating
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Readmission' and `Risk Adjusted Rate`<10
GROUP BY hosp_rating, county, hospital, num_death_readm, readm_rate
ORDER BY readm_rate DESC, hosp_rating, county, hospital, num_death_readm;

-- Which hospitals have 30-day Readmission rate greater than or equal to 20%
SELECT county, hospital, `# of Deaths/Readmissions`AS num_death_readm, `Risk Adjusted Rate` as readm_rate, `Hospital ratings` AS hosp_rating
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Readmission' and `Risk Adjusted Rate`>=20
GROUP BY hosp_rating, county, hospital, num_death_readm, readm_rate
ORDER BY readm_rate DESC, hosp_rating, county, hospital, num_death_readm;

-- Which counties has the lowest and highest average 30-day Mortality rate 
WITH extreme_cte AS 
(
SELECT county, AVG(`Risk Adjusted Rate`) AS avg_death_rate
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' AND hospital !='Statewide'
GROUP BY county
ORDER BY 2 DESC
)
SELECT CAST(MIN(avg_death_rate) AS DECIMAL (6,2)), CAST(MAX(avg_death_rate) AS DECIMAL (6,2))
FROM extreme_cte;

-- Which counties has the lowest and highest average 30-day Readmission rate 
WITH extreme_cte AS 
(
SELECT county, AVG(`Risk Adjusted Rate`) AS avg_death_rate
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Readmission' AND hospital !='Statewide'
GROUP BY county
ORDER BY 2 DESC
)
SELECT CAST(MIN(avg_death_rate) AS DECIMAL (6,2)), CAST(MAX(avg_death_rate) AS DECIMAL (6,2))
FROM extreme_cte;

-- Let's look at progression of deaths
SELECT `year`, SUM(`# of Deaths/Readmissions`) as total_death
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' AND hospital!='Statewide'
GROUP BY `year`
ORDER BY 1;

-- Let's look at progression of readmissions
SELECT `year`, SUM(`# of Deaths/Readmissions`) AS total_readm
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Readmission' AND hospital!='Statewide'
GROUP BY `year`
ORDER BY 1;

-- Find out why year 2013-2014 has very high number of deaths
SELECT MIN(`# of Deaths/Readmissions`), MAX(`# of Deaths/Readmissions`)
 FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' AND hospital!='Statewide'
AND `year`='2011-2012'; /*0-105*/

SELECT MIN(`# of Deaths/Readmissions`), MAX(`# of Deaths/Readmissions`)
 FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' AND hospital!='Statewide'
AND `year`='2012-2013'; /*0-109 */

SELECT MIN(`# of Deaths/Readmissions`), MAX(`# of Deaths/Readmissions`)
FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' AND hospital!='Statewide'
AND `year`='2013-2014'; /*30-969*/

SELECT MIN(`# of Deaths/Readmissions`), MAX(`# of Deaths/Readmissions`)
 FROM ischemic_stroke.stroke_mortality
WHERE measure='30-day Mortality' AND hospital!='Statewide'
AND `year`='2014-2015'; /*0-91*/

SELECT * FROM ischemic_stroke.stroke_mortality
WHERE `# of Deaths/Readmissions`=969;

SELECT * FROM ischemic_stroke.stroke_mortality
WHERE `year`='2011-2012' AND 
`# of Deaths/Readmissions`>`# of Cases`; /*0 rows*/

SELECT * FROM ischemic_stroke.stroke_mortality
WHERE `year`='2012-2013' AND 
`# of Deaths/Readmissions`>`# of Cases`; /*0 rows*/

SELECT * FROM ischemic_stroke.stroke_mortality
WHERE `year`='2013-2014' AND 
`# of Deaths/Readmissions`>`# of Cases`; /*545 rows*/

SELECT * FROM ischemic_stroke.stroke_mortality
WHERE `year`='2014-2015' AND 
`# of Deaths/Readmissions`>`# of Cases`; /*0 rows*/

/*It looks like for year 2013-2014 the number of Deaths/Readmissions and the number of Cases were swapped resulting in incorrect totals.
Risk Adjusted Rate was still calculated correctly. The incorrect data need to be corrected or excluded before further analysis. */

-- Rolling total for mortality cases by year (excluding year 2013-2014 due to data integrity issue)
WITH rolling_total AS
(
SELECT `year`, SUM(`# of Deaths/Readmissions`) AS total_death
FROM ischemic_stroke.stroke_mortality
WHERE  measure='30-day Mortality' AND hospital !='Statewide'
AND `year`!='2013-2014'
GROUP BY `year`
ORDER BY 1
)
SELECT `year`, total_death, SUM(total_death) OVER (ORDER BY `year`) AS roll_total_death
FROM rolling_total;

-- Rolling total for readmission cases by year (excluding year 2013-2014 due to data integrity issue)
WITH rolling_total AS
(
SELECT `year`, SUM(`# of Deaths/Readmissions`) AS total_readm
FROM ischemic_stroke.stroke_mortality
WHERE  measure='30-day Readmission' AND hospital !='Statewide'
AND `year`!='2013-2014'
GROUP BY `year`
ORDER BY 1
)
SELECT `year`, total_readm, SUM(total_readm) OVER (ORDER BY `year`) AS roll_total_readm
FROM rolling_total;

-- Ranking hospitals by the number of deaths (excluding year 2013-2014 due to data integrity issue)
WITH hospital_year (hospital, years, total_death) AS 
(
SELECT hospital, `year`, SUM(`# of Deaths/Readmissions`) 
FROM ischemic_stroke.stroke_mortality
WHERE  measure='30-day Mortality' AND hospital !='Statewide'
AND `year`!='2013-2014'
GROUP BY hospital, `year`
),
hospital_year_rank as
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_death DESC) AS ranking
FROM hospital_year
)
SELECT * FROM hospital_year_rank;

-- Ranking hospitals by the number of readmissions (excluding year 2013-2014 due to data integrity issue)
WITH hospital_year (hospital, years, total_readm) AS 
(
SELECT hospital, `year`, SUM(`# of Deaths/Readmissions`) 
FROM ischemic_stroke.stroke_mortality
WHERE  measure='30-day Readmission' AND hospital !='Statewide'
AND `year`!='2013-2014'
GROUP BY hospital, `year`
),
hospital_year_rank as
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_readm DESC) AS ranking
FROM hospital_year
)
SELECT * FROM hospital_year_rank;