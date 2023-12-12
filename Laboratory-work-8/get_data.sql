CREATE OR REPLACE FUNCTION get_data(teacher_name VARCHAR)
RETURNS TABLE (t_id INTEGER, name VARCHAR, post VARCHAR, confidentiality_label INTEGER)
AS $$

DECLARE
	query VARCHAR;
BEGIN
	query := 'SELECT * FROM teacher WHERE name = ''' || teacher_name || '''';
	RAISE NOTICE 'Query=%', query;
	RETURN query EXECUTE query;
END;

$$ LANGUAGE plpgsql;
