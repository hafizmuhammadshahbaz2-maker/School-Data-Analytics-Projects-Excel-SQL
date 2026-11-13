-- School Student Performance Analysis
-- Simulated dataset: 300 students, Classes 6-10
-- Database: MySQL 8.0+
-- Run this file in MySQL Workbench.

CREATE DATABASE IF NOT EXISTS school_db;
USE school_db;

DROP TABLE IF EXISTS student_results;

CREATE TABLE student_results (
    student_id VARCHAR(10) PRIMARY KEY,
    class INT NOT NULL,
    section CHAR(1) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    attendance INT NOT NULL,
    math INT NOT NULL,
    physics INT NOT NULL,
    english INT NOT NULL,
    urdu INT NOT NULL,
    computer INT NOT NULL,
    total_marks INT NOT NULL,
    percentage DECIMAL(5,2) NOT NULL,
    grade VARCHAR(2) NOT NULL,
    result VARCHAR(5) NOT NULL
);

-- Import student_results.csv using MySQL Workbench Table Data Import Wizard.
-- Alternatively, use LOAD DATA LOCAL INFILE after enabling local_infile.

-- 1. Preview records
SELECT * FROM student_results LIMIT 10;

-- 2. Total students
SELECT COUNT(*) AS total_students FROM student_results;

-- 3. Overall performance
SELECT
    ROUND(AVG(percentage), 2) AS average_percentage,
    ROUND(AVG(attendance), 2) AS average_attendance,
    SUM(result = 'Pass') AS pass_count,
    SUM(result = 'Fail') AS fail_count,
    ROUND(100 * AVG(result = 'Pass'), 2) AS pass_percentage
FROM student_results;

-- 4. Subject-wise average
SELECT 'Math' AS subject, ROUND(AVG(math),2) AS average_marks FROM student_results
UNION ALL
SELECT 'Physics', ROUND(AVG(physics),2) FROM student_results
UNION ALL
SELECT 'English', ROUND(AVG(english),2) FROM student_results
UNION ALL
SELECT 'Urdu', ROUND(AVG(urdu),2) FROM student_results
UNION ALL
SELECT 'Computer', ROUND(AVG(computer),2) FROM student_results;

-- 5. Class-wise performance
SELECT class, COUNT(*) AS students,
       ROUND(AVG(percentage),2) AS avg_percentage,
       ROUND(AVG(attendance),2) AS avg_attendance,
       SUM(result='Pass') AS pass_count,
       SUM(result='Fail') AS fail_count
FROM student_results
GROUP BY class
ORDER BY class;

-- 6. Section-wise comparison
SELECT class, section, COUNT(*) AS students,
       ROUND(AVG(percentage),2) AS avg_percentage
FROM student_results
GROUP BY class, section
ORDER BY class, section;

-- 7. Students needing academic support (any subject below 40)
SELECT student_id, class, section, math, physics, english, urdu, computer, percentage
FROM student_results
WHERE LEAST(math, physics, english, urdu, computer) < 40
ORDER BY percentage;

-- 8. Low attendance students
SELECT student_id, class, section, attendance, percentage
FROM student_results
WHERE attendance < 75
ORDER BY attendance;

-- 9. Attendance and performance bands
SELECT
    CASE
        WHEN attendance >= 90 THEN '90-100%'
        WHEN attendance >= 75 THEN '75-89%'
        ELSE 'Below 75%'
    END AS attendance_band,
    COUNT(*) AS students,
    ROUND(AVG(percentage),2) AS avg_percentage
FROM student_results
GROUP BY attendance_band
ORDER BY attendance_band;

-- 10. Gender-wise comparison
SELECT gender, COUNT(*) AS students,
       ROUND(AVG(percentage),2) AS avg_percentage,
       ROUND(AVG(attendance),2) AS avg_attendance
FROM student_results
GROUP BY gender;

-- 11. Top 10 students
SELECT student_id, class, percentage, grade
FROM student_results
ORDER BY percentage DESC
LIMIT 10;

-- 12. Grade distribution
SELECT grade, COUNT(*) AS students
FROM student_results
GROUP BY grade
ORDER BY FIELD(grade, 'A+','A','B','C','D','F');

-- 13. Correlation (MySQL 8.0.17+)
SELECT ROUND(CORR(attendance, percentage), 3) AS attendance_percentage_correlation
FROM student_results;

-- 14. Class ranking using a window function
SELECT class, student_id, percentage,
       DENSE_RANK() OVER (PARTITION BY class ORDER BY percentage DESC) AS class_rank
FROM student_results;

-- 15. Data quality checks
SELECT COUNT(*) AS duplicate_id_count
FROM (
    SELECT student_id
    FROM student_results
    GROUP BY student_id
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT *
FROM student_results
WHERE attendance NOT BETWEEN 0 AND 100
   OR math NOT BETWEEN 0 AND 100
   OR physics NOT BETWEEN 0 AND 100
   OR english NOT BETWEEN 0 AND 100
   OR urdu NOT BETWEEN 0 AND 100
   OR computer NOT BETWEEN 0 AND 100;
