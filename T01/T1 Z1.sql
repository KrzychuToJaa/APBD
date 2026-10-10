SELECT first_name, last_name
FROM employees 
JOIN departments ON departments.department_id = employees.department_id
where department_name = 'IT'
ORDER BY salary DESC, last_name;