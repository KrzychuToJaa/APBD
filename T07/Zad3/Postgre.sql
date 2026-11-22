CREATE OR REPLACE PROCEDURE zmiana_stanowisk(
    IN stare_stanowisko VARCHAR,
    IN nowe_stanowisko VARCHAR,
    IN kraj VARCHAR,
    OUT liczba_zmienionych INT,
    OUT emaile REFCURSOR,
    OUT departamenty REFCURSOR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_country_id CHAR(2);
    stare_job_id VARCHAR(10);
    nowe_job_id VARCHAR(10);
    departament_id NUMERIC(4);
    departament_name VARCHAR(30);
    liczba_w_dziale INT;
    liczba_zaktualizowanych BIGINT;

    departament_cursor CURSOR FOR
        SELECT d.department_id, d.department_name FROM departments d
        JOIN locations l ON l.location_id = d.location_id
        WHERE l.country_id = v_country_id
        ORDER BY d.department_id;

BEGIN
    liczba_zmienionych := 0;
	emaile := 'wynik_emaile';
	departamenty := 'wynik_departamenty';

    SELECT c.country_id INTO v_country_id FROM countries c
    WHERE c.country_name = kraj;

    IF v_country_id IS NULL THEN
        RAISE EXCEPTION 'Brak kraju % w bazie danych!', kraj;
    END IF;

    IF NOT EXISTS (
		SELECT 1 FROM departments d
        JOIN locations l ON l.location_id = d.location_id
        WHERE l.country_id = v_country_id
    ) THEN 
		RAISE EXCEPTION 'Brak departamentów w kraju %!', kraj;
    END IF;

    SELECT j.job_id INTO stare_job_id FROM jobs j
    WHERE j.job_title = stare_stanowisko;

    SELECT j.job_id INTO nowe_job_id FROM jobs j
    WHERE j.job_title = nowe_stanowisko;

    IF stare_job_id IS NULL OR nowe_job_id IS NULL THEN
        RAISE EXCEPTION 'Nie ma takiego stanowiska!';
    END IF;

    CREATE TEMP TABLE zmienieni (
        employee_id NUMERIC(6),
        first_name VARCHAR(20),
        last_name VARCHAR(25),
        email VARCHAR(25),
        department_id NUMERIC(4),
        department_name VARCHAR(30)
    ) ON COMMIT DROP;

    OPEN departament_cursor;

    LOOP
        FETCH NEXT FROM departament_cursor
        INTO departament_id, departament_name;

        EXIT WHEN NOT FOUND;

        liczba_w_dziale := l_pracownikow(stare_stanowisko, departament_name, kraj);

        IF liczba_w_dziale = 0 THEN
            RAISE WARNING 'Brak pracowników na stanowisku % w departamencie % w kraju %!',
                stare_stanowisko, departament_name, kraj;
        ELSE
            WITH zaktualizowani AS (
				UPDATE employees e SET job_id = nowe_job_id
                WHERE e.department_id = departament_id AND e.job_id = stare_job_id
                RETURNING e.employee_id, e.first_name, e.last_name, e.email, e.department_id
            )
            INSERT INTO pg_temp.zmienieni (employee_id, first_name, last_name, email, department_id, department_name)
            SELECT z.employee_id, z.first_name, z.last_name, z.email, z.department_id, departament_name
            FROM zaktualizowani z;
			
            liczba_zmienionych := liczba_zmienionych + liczba_w_dziale;
        END IF;
    END LOOP;

    CLOSE departament_cursor;

    OPEN emaile FOR
        SELECT z.email FROM pg_temp.zmienieni z
        ORDER BY z.email;


    OPEN departamenty FOR
        SELECT d.department_name, z.first_name, z.last_name FROM departments d
        JOIN locations l ON l.location_id = d.location_id
        JOIN pg_temp.zmienieni z ON z.department_id = d.department_id
        WHERE l.country_id = v_country_id
        ORDER BY d.department_name, z.last_name, z.first_name;
END;
$$;
