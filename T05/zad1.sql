-- Grupa IAS_MK_pn_14:15_03
-- Członkowie: Krzysztof Kata 254776, Patryk Nagórka 254825, Jakub Żmijowski 254919

-- 1. Dla każdego pracownika, wyświetl jego imię, nazwisko oraz informację o prowizji:
-- – "Brak prowizji" w przypadku, gdy pracownik nie ma podanej prowizji,
-- – "Nieznana prowizja" w przypadku, gdy prowizja pracownika nie może być porównana względem pozostałych pracowników z tego samego działu,
-- – "Niska prowizja" w przypadku, gdy iloczyn prowizji i minimalnego wynagrodzenia dla stanowiska pracownika jest mniejszy niż średnie wynagrodzenie wszystkich pracowników z działu tego pracownika pomniejszone o 5000,
-- – "Wysoka prowizja" w pozostałych przypadkach.
-- Kolumnę z informacją o prowizji nazwij commission_info. Wynik posortuj według ostatniej informacji. W rozwiązaniu wykorzystaj instrukcję warunkową.

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