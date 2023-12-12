CREATE OR REPLACE FUNCTION change_data_secure( new_confidentiality_label INTEGER, new_name VARCHAR)
RETURNS void
AS $$

DECLARE
	str VARCHAR;
BEGIN
	str := 'UPDATE teacher SET confidentiality_label = $1 WHERE name = $2';
	RAISE NOTICE 'Query=%', str;
	EXECUTE str using new_confidentiality_label, new_name;
END;

$$ LANGUAGE plpgsql;