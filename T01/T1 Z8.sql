SELECT department_name, COUNT(employee_id)
FROM departments 
JOIN employees ON employees.department_id = departments.department_id 
GROUP BY department_name 
HAVING COUNT(employee_id) = (SELECT MAX(emp2)
							FROM (SELECT COUNT(employees.employee_id) as emp2
									FROM employees 
									GROUP BY employees.department_id) as emp3);