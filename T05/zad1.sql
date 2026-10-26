-- Grupa IAS_MK_pn_14:15_03
-- Członkowie: Krzysztof Kata 254776, Patryk Nagórka 254825, Jakub Żmijowski 254919


SELECT e.first_name, e.last_name,
    CASE 
        WHEN e.commission_pct IS NULL THEN 'Brak prowizji'
        WHEN e.department_id IS NULL THEN 'Nieznana prowizja'
        WHEN (e.commission_pct * j.min_salary) < (SELECT AVG(ed.salary) FROM employees ed WHERE ed.department_id = e.department_id) - 5000 THEN 'Niska prowizja'
        ELSE 'Wysoka prowizja'
    END AS commission_info
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
ORDER BY commission_info;