-- Zespół IAS_MK_pn_14:15_03

-- Zadanie 1
SELECT first_name, last_name
FROM employees 
JOIN departments ON departments.department_id = employees.department_id
where department_name = 'IT'
ORDER BY salary DESC, last_name;

-- Zadanie 8
SELECT department_name
FROM departments 
JOIN employees ON employees.department_id = departments.department_id 
GROUP BY department_name 
HAVING COUNT(employee_id) = (
							SELECT MAX(department_count)
							FROM (
									SELECT COUNT(employees.employee_id) as department_count
									FROM employees 
									GROUP BY employees.department_id
								) as department_stats
							);