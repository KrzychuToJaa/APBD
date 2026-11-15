-- Członkowie: Krzysztof Kata 254776, Patryk Nagórka 254825, Jakub Żmijowski 254919

--Utwórz wyzwalacz, który po usunięciu jednego lub wielu miast za pomocą pojedynczego polecenia wypisze ich nazwy oraz nazwy ich krajów. Potwierdź działanie poprzez usunięcie wszystkich miast, w których żaden departament nie ma swojej siedziby.
--Uwaga! W niektórych systemach wymagane jest utworzenie kursora lub własnej funkcji.

-- SQL SERVER
CREATE TRIGGER after_city_delete
ON locations
FOR DELETE
AS
BEGIN
    DECLARE @city VARCHAR(30);
    DECLARE @country_name VARCHAR(40);

    DECLARE my_cursor CURSOR FOR
    SELECT d.city, c.country_name FROM deleted d
    JOIN countries c ON d.country_id = c.country_id;

    OPEN my_cursor;
    FETCH NEXT FROM my_cursor INTO @city, @country_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        PRINT 'Usunięto miasto: ' + @city + ', Kraj: ' + @country_name;
        FETCH NEXT FROM my_cursor INTO @city, @country_name;
    END;

    CLOSE my_cursor;
    DEALLOCATE my_cursor;
END

--PostgreSQL
CREATE FUNCTION deleted_city()
RETURNS TRIGGER AS
$$
DECLARE
v_country_name countries.country_name%TYPE;
BEGIN
	SELECT country_name 
    INTO v_country_name
    FROM countries 
    WHERE country_id = OLD.country_id;
RAISE NOTICE 'Usunięto miasto: %, Kraj: %', OLD.city, v_country_name;
RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER after_delete_city
AFTER DELETE ON locations
FOR EACH ROW
EXECUTE FUNCTION deleted_city();



-- Usuwanie miast bez siedziby departamentu (PostgreSQL i SQL Server)
DELETE FROM locations
WHERE NOT EXISTS (
    SELECT 1
    FROM departments AS d
    WHERE d.location_id = locations.location_id
);
