USE HR;
GO

CREATE OR ALTER PROCEDURE dbo.Zmiana_stanowisk
    @stare_stanowisko VARCHAR(35),
    @nowe_stanowisko VARCHAR(35),
    @kraj VARCHAR(40),
    @liczba_zmienionych INT OUTPUT
AS
BEGIN

    DECLARE
        @country_id CHAR(2),
        @komunikat NVARCHAR(255),
        @stare_job_id VARCHAR(10),
        @nowe_job_id VARCHAR(10),
        @departament_id NUMERIC(4),
        @departament_name VARCHAR(30),
        @liczba_w_dziale INT;
        

    SET @liczba_zmienionych = 0;

    SELECT @country_id = country_id FROM countries
    WHERE country_name = @kraj;

    IF @country_id IS NULL
    BEGIN
        SET @komunikat = 'Brak kraju ' + @kraj + ' w bazie danych!';
        THROW 50001, @komunikat, 1;
    END;

    IF NOT EXISTS (
        SELECT 1 FROM departments d
        JOIN locations l ON l.location_id = d.location_id
        WHERE l.country_id = @country_id
    )
    BEGIN
        SET @komunikat = 'Brak departamentów w kraju ' + @kraj + '!';
        THROW 50002, @komunikat, 1;
    END;

    SELECT @stare_job_id = job_id FROM jobs
    WHERE job_title = @stare_stanowisko;

    SELECT @nowe_job_id = job_id FROM jobs
    WHERE job_title = @nowe_stanowisko;

    IF @stare_job_id IS NULL OR @nowe_job_id IS NULL
    BEGIN
        THROW 50003, 'Nie ma takiego stanowiska!', 1;
    END;

    CREATE TABLE #zmienieni (
        employee_id NUMERIC(6),
        first_name VARCHAR(20),
        last_name VARCHAR(25),
        email VARCHAR(25),
        department_id NUMERIC(4),
        department_name VARCHAR(30)
    );

    DECLARE department_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT d.department_id, d.department_name FROM departments d
        JOIN locations l ON l.location_id = d.location_id
        WHERE l.country_id = @country_id
        ORDER BY d.department_id;

    OPEN department_cursor;

    FETCH NEXT FROM department_cursor
    INTO @departament_id, @departament_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @liczba_w_dziale = dbo.l_pracownikow(@stare_stanowisko, @departament_name, @kraj);

        IF @liczba_w_dziale = 0
        BEGIN
            RAISERROR(N'Brak pracowników na stanowisku %s w departamencie %s w kraju %s!', 10, 1, @stare_stanowisko, @departament_name, @kraj) 
            WITH NOWAIT;
        END
        ELSE
        BEGIN
            UPDATE e SET e.job_id = @nowe_job_id
            OUTPUT inserted.employee_id, inserted.first_name, inserted.last_name, inserted.email, inserted.department_id, @departament_name
            INTO #zmienieni(employee_id, first_name, last_name, email, department_id, department_name)
            FROM employees e
            WHERE e.department_id = @departament_id AND e.job_id = @stare_job_id;

            SET @liczba_zmienionych = @liczba_zmienionych + @liczba_w_dziale;
        END;

        FETCH NEXT FROM department_cursor
        INTO @departament_id, @departament_name;
    END;

    CLOSE department_cursor;
    DEALLOCATE department_cursor;

    IF EXISTS (SELECT 1 FROM #zmienieni)
    BEGIN
        SELECT email FROM #zmienieni
        ORDER BY email;
    END;

    SELECT d.department_name, z.first_name, z.last_name FROM departments d
    JOIN locations l ON l.location_id = d.location_id
    JOIN #zmienieni z ON z.department_id = d.department_id
    WHERE l.country_id = @country_id
    ORDER BY d.department_name, z.last_name, z.first_name;

    DROP TABLE #zmienieni;
END;
GO