CREATE OR REPLACE FUNCTION get_data_secure(teacher_name VARCHAR)
RETURNS TABLE (t_id INTEGER, name VARCHAR, post VARCHAR, confidentiality_label INTEGER)
AS $$

DECLARE
	str VARCHAR;
BEGIN
	str := 'SELECT * FROM teacher WHERE name = $1';
	RAISE NOTICE 'Query=%', str;
	RETURN query EXECUTE str using teacher_name;
END;

$$ LANGUAGE plpgsql;
