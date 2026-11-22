USE HR;
GO

DECLARE @wynik INT;

EXEC dbo.Zmiana_stanowisk
    @stare_stanowisko = 'Sales Manager',
    @nowe_stanowisko  = 'Sales Representative',
    @kraj             = 'United Kingdom',
    @liczba_zmienionych = @wynik OUTPUT;

PRINT 'Liczba zmodyfikowanych rekordów: ' + CAST(@wynik AS VARCHAR(100));