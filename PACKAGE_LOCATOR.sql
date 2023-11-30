DECLARE
    TYPE VARCHAR_TABLE IS
        TABLE OF VARCHAR2(250) INDEX BY PLS_INTEGER;
    KEYWORDS         VARCHAR_TABLE;
    FILTRATION_QUERY CLOB;
BEGIN
    -- Declare keywords to search for here
    KEYWORDS(1) := '';
    KEYWORDS(2) := '';
    KEYWORDS(3) := '';

    IF KEYWORDS.LAST < 1 THEN
        GOTO QUIT_JUMP;
    END IF;
    --                              A where condition can be added here ↓ to filter owners to limit the data to look through.
    FILTRATION_QUERY := 'WITH TMP_ALL_SOURCE AS (SELECT * FROM ALL_SOURCE),UNIONIZED_RECORDS AS (';
    FOR I IN KEYWORDS.FIRST .. KEYWORDS.LAST LOOP
        FILTRATION_QUERY := FILTRATION_QUERY
                            ||'SELECT DISTINCT NAME FROM TMP_ALL_SOURCE WHERE INSTR(UPPER(TEXT), UPPER('''
                            ||KEYWORDS(I)
                            ||''')) > 0 ';
        IF I != KEYWORDS.LAST THEN
            FILTRATION_QUERY := FILTRATION_QUERY
                                || ' UNION ALL ';
        END IF;
    END LOOP;

    FILTRATION_QUERY := FILTRATION_QUERY
                        ||')SELECT NAME FROM UNIONIZED_RECORDS GROUP BY NAME HAVING COUNT(NAME) >= '
                        ||KEYWORDS.LAST;
    DECLARE
        FILTRATION_CURSOR SYS_REFCURSOR;
        RESULT_COLUMN     VARCHAR2(250);
        RESULT_CLOB       CLOB;
    BEGIN
        OPEN FILTRATION_CURSOR FOR FILTRATION_QUERY;
        LOOP
            FETCH FILTRATION_CURSOR INTO RESULT_COLUMN;
            EXIT WHEN FILTRATION_CURSOR%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(RESULT_COLUMN);
        END LOOP;

        CLOSE FILTRATION_CURSOR;
    END;

    <<QUIT_JUMP>>
    NULL;
END;
/
