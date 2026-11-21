--SQL Server
CREATE OR ALTER FUNCTION dbo.l_pracownikow
(
    @stanowisko VARCHAR(255),
    @dzial VARCHAR(255),
    @kraj VARCHAR(255)
)
RETURNS INT
AS
BEGIN
    DECLARE @liczba_pracownikow INT;

    SELECT @liczba_pracownikow = COUNT(e.employee_id)
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    JOIN countries c ON l.country_id = c.country_id
    JOIN jobs j ON e.job_id = j.job_id
    WHERE j.job_title = @stanowisko
      AND d.department_name = @dzial
      AND c.country_name = @kraj;

    RETURN @liczba_pracownikow;
END;
GO

SELECT dbo.l_pracownikow ('Sales Manager', 'Sales', 'United Kingdom') AS liczba_pracownikow;




--PostgreSQL
CREATE OR REPLACE FUNCTION l_pracownikow( stanowisko VARCHAR, dzial VARCHAR, kraj VARCHAR)
RETURNS INT
LANGUAGE sql
AS $$
    SELECT COUNT(e.employee_id)
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    JOIN countries c ON l.country_id = c.country_id
    JOIN jobs j ON e.job_id = j.job_id
    WHERE j.job_title = stanowisko
      AND d.department_name = dzial
      AND c.country_name = kraj;
$$;

SELECT l_pracownikow('Sales Manager', 'Sales', 'United Kingdom') AS liczba_pracownikow;
