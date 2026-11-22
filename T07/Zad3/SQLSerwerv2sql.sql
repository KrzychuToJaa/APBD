IF EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = 'jhist_emp_id_st_date_pk'
)
BEGIN
    ALTER TABLE job_history
    DROP CONSTRAINT jhist_emp_id_st_date_pk;
END;
GO