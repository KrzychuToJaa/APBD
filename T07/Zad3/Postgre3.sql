BEGIN;

CALL zmiana_stanowisk(
    'Sales Manager',
    'Sales Representative',
    'United Kingdom',
    NULL,
    NULL,
    NULL
);

FETCH ALL FROM wynik_emaile;
FETCH ALL FROM wynik_departamenty;

COMMIT;