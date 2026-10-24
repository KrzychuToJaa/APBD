WITH chierarchia AS (
SELECT 0 AS employee_level, e.employee_id, e.first_name, e.last_name, e.manager_id
FROM employees AS e
WHERE e.first_name LIKE 'Diana' AND e.last_name LIKE 'Lorentz'

UNION ALL

SELECT p.employee_level + 1, en.employee_id, en.first_name, en.last_name, en.manager_id
FROM chierarchia AS p
JOIN employees as en ON en.employee_id = p.manager_id
)


SELECT employee_level, first_name, last_name
FROM chierarchia
ORDER BY employee_level

--UNION ALL jest wymagane w konstrukcji z rekurencj� w SQL Server
