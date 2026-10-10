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