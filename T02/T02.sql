WITH city_department_counts AS (
    SELECT l.city, COUNT(d.department_id) AS dept_count
    FROM locations AS l
    JOIN departments AS d ON l.location_id = d.location_id
    GROUP BY l.country_id, l.city
)
SELECT city
FROM city_department_counts
WHERE dept_count > (
    SELECT AVG(dept_count) 
    FROM city_department_counts
);