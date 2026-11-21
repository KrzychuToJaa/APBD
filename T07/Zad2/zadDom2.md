# Zad 2

1. Utwórz wyzwalacz, który przy zmianie stanowiska danego pracownika:
    – zaktualizuje datę jego zatrudnienia w tabeli employees na jutrzejszą,
    – zarchiwizuje dane o jego poprzednim stanowisku, tzn. doda odpowiednie informacje do tabeli job_history i ustawi datę zakończenia na dzisiejszą,
    – sprawdzi, czy jego aktualne wynagrodzenie należy do zdefiniowanego przedziału wartości wynagrodzeń dla jego nowego stanowiska. Jeżeli jego aktualne wynagrodzenie jest niższe niż minimalna wartość przedziału, to zaktualizuje je do tej wartości oraz wypisze informację o imieniu i nazwisku pracownika i kwocie uzyskanej przez niego podwyżki. Jeżeli jego aktualne wynagrodzenie jest wyższe niż maksymalna wartość przedziału, to zaktualizuje maksymalne wynagrodzenie dla jego nowego stanowiska do wartości jego aktualnego wynagrodzenia.
    Potwierdź działanie poprzez zmianę stanowiska Stevena Kinga na Shipping Clerk i zmianę stanowiska Douglasa Granta na President.
    Uwaga! Wyzwalacz powinien działać także przy zmianie stanowiska wielu pracowników jednocześnie.

*** Postrgesql ***

```sql
CREATE FUNCTION updated_employee_job()
RETURNS TRIGGER AS
$$
DECLARE 
	v_min_salary jobs.min_salary%TYPE;
	v_max_salary jobs.max_salary%TYPE;
BEGIN
	INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
	VALUES (OLD.employee_id, OLD.hire_date, CURRENT_DATE, OLD.job_id, OLD.department_id);

	UPDATE employees
	SET hire_date = DATE(CURRENT_DATE + 1)
	WHERE employee_id = OLD.employee_id;
	
		SELECT min_salary, max_salary 
		INTO v_min_salary, v_max_salary 
		FROM jobs
		WHERE job_id = NEW.job_id;
	
		IF NEW.salary < v_min_salary THEN
	        UPDATE employees
	        SET salary = v_min_salary
	        WHERE employee_id = NEW.employee_id;
	
	        RAISE NOTICE '% % – kwota podwyżki: %',
	            NEW.first_name, NEW.last_name, v_min_salary - NEW.salary;
	
	    ELSIF NEW.salary > v_max_salary THEN
	        UPDATE jobs
	        SET max_salary = NEW.salary
	        WHERE job_id = NEW.job_id;
	    END IF;

	RETURN NEW;
END;
$$
LANGUAGE
plpgsql;

CREATE TRIGGER after_update_employee_job
AFTER UPDATE OF job_id ON employees
FOR EACH ROW
EXECUTE FUNCTION updated_employee_job();

UPDATE employees
SET job_id = 'SH_CLERK'
WHERE first_name LIKE 'Steven' AND last_name LIKE 'King';

UPDATE employees
SET job_id = 'AD_PRES'
WHERE first_name LIKE 'Douglas' AND last_name LIKE 'Grant';
```

![Wynik zmiany stanowiska Stevena Kinga](wynikiZDJ/Steven_KING_UPDATE.png)

![Wynik zmiany stanowiska Douglasa Granta](wynikiZDJ/Douglas_Grant_UPDATE.png)


*** SQL Server ***

```sql
CREATE TRIGGER after_update_employee_job
ON employees
FOR UPDATE
AS
BEGIN
    DECLARE
        @emp_id NUMERIC(6),
        @first_name VARCHAR(20),
        @last_name VARCHAR(25),
        @old_hire_date DATE,
        @old_job_id VARCHAR(10),
        @old_dept_id NUMERIC(4),
        @new_job_id VARCHAR(10),
        @new_salary NUMERIC(8,2),
        @min_salary NUMERIC(6),
        @max_salary NUMERIC(6),
        @dzis DATE = CAST(GETDATE() AS DATE),
        @jutro DATE = DATEADD(day, 1, CAST(GETDATE() AS DATE));

    DECLARE cur_zmiany CURSOR FOR
        SELECT
            d.employee_id,
            i.first_name,
            i.last_name,
            d.hire_date,
            d.job_id,
            d.department_id,
            i.job_id,
            i.salary
        FROM deleted d
        JOIN inserted i ON d.employee_id = i.employee_id
        WHERE d.job_id <> i.job_id;

    OPEN cur_zmiany;
    FETCH NEXT FROM cur_zmiany INTO
        @emp_id, @first_name, @last_name, @old_hire_date,
        @old_job_id, @old_dept_id, @new_job_id, @new_salary;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
        VALUES (@emp_id, @old_hire_date, @dzis, @old_job_id, @old_dept_id);

        UPDATE employees
        SET hire_date = @jutro
        WHERE employee_id = @emp_id;

        SELECT @min_salary = min_salary, @max_salary = max_salary
        FROM jobs
        WHERE job_id = @new_job_id;

        IF @new_salary < @min_salary
        BEGIN
            UPDATE employees
            SET salary = @min_salary
            WHERE employee_id = @emp_id;

            PRINT CONCAT(@first_name, ' ', @last_name, ' – kwota podwyżki: ', @min_salary - @new_salary);
        END
        ELSE IF @new_salary > @max_salary
        BEGIN
            UPDATE jobs
            SET max_salary = @new_salary
            WHERE job_id = @new_job_id;
        END;

        FETCH NEXT FROM cur_zmiany INTO
            @emp_id, @first_name, @last_name, @old_hire_date,
            @old_job_id, @old_dept_id, @new_job_id, @new_salary;
    END;

    CLOSE cur_zmiany;
    DEALLOCATE cur_zmiany;
END;

UPDATE employees
SET job_id = 'SH_CLERK'
WHERE first_name LIKE 'Steven' AND last_name LIKE 'King';

UPDATE employees
SET job_id = 'AD_PRES'
WHERE first_name LIKE 'Douglas' AND last_name LIKE 'Grant';
```

![Wynik zmiany stanowiska Stevena Kinga](wynikiZDJ/sqlserver_update_KING.png)

![Wynik zmiany stanowiska Douglasa Granta](wynikiZDJ/sqlserver_update_GRANT.png)
