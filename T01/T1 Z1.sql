USE hr;

SELECT employee_id, last_name, department_name, salary 
FROM employees 
JOIN departments ON departments.department_id = employees.department_id
where department_name = 'IT'
ORDER BY salary DESC, last_name;