-- Krzysztof Kata 254776



-- 6. Wyświetl nazwy miast, w których swoją siedzibę ma więcej departamentów
-- niż wynosi średnia liczba departamentów we wszystkich miastach. W rozwiązaniu wykorzystaj klauzulę with.
WITH city_department AS (
    SELECT l.city, COUNT(d.department_id) AS d_count
    FROM locations AS l
    JOIN departments AS d ON l.location_id = d.location_id
    GROUP BY l.country_id, l.city
)
SELECT city
FROM city_department
WHERE d_count > (
    SELECT AVG(d_count) 
    FROM city_department
);