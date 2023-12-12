CREATE OR REPLACE FUNCTION change_data( new_confidentiality_label INTEGER, new_name VARCHAR)
RETURNS void
AS $$

DECLARE
	query VARCHAR;
BEGIN
	query := 'UPDATE teacher SET confidentiality_label = ' || new_confidentiality_label || ' WHERE name = ''' || new_name || '''';
	RAISE NOTICE 'Query=%', query;
	EXECUTE query;
END;

$$ LANGUAGE plpgsql;