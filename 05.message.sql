SELECT	SETSEED(0.20191231);

WITH	RECURSIVE
	parameters AS
	(
	SELECT	*
	FROM	(
		VALUES
		(16, 7, 50)
		) v (pattern_length, pattern_count, height)
	CROSS JOIN LATERAL
		(
		SELECT	pattern_length * pattern_count AS width
		) q
	),
	patterns AS
	(
	SELECT	y, pattern
	FROM	parameters
	CROSS JOIN LATERAL
		GENERATE_SERIES(0, height - 1) y
	CROSS JOIN LATERAL
		(
		SELECT	STRING_AGG(CHR(FLOOR(RANDOM() * 94)::INT + 33), '')
		FROM	GENERATE_SERIES(0 * y, pattern_length - 1) x
		) q (pattern)
	),
	mask AS
	(
	SELECT	x, y, CASE WHEN y > 4 AND SUBSTRING(SPLIT_PART(banner, E'\n', FLOOR(y / 4)::INT), FLOOR(x / 12)::INT, 1) = '*' THEN 2 ELSE 0 END depth
	FROM	parameters
	CROSS JOIN
		(
		SELECT	CONVERT_FROM(DECODE('
		KioqICoqKgogICogKiAqCioqKiAqICoK
		KiAgICogKgoqKiogKioqCgoqKiogKioqCiAgKiAqICoK
		KioqICogKgoqICAgKiAqCioqKiAqKioK',
		'BASE64'), 'UTF8') AS banner
		) q
	CROSS JOIN LATERAL
		GENERATE_SERIES(0, height - 1) y
	CROSS JOIN LATERAL
		GENERATE_SERIES(0, width - 1) x
	),
	lines AS
	(
	SELECT	0 AS x, y, pattern AS line
	FROM	patterns
	CROSS JOIN
		parameters
	UNION ALL
	SELECT	x + 1, y, line || LEFT(RIGHT(line, pattern_length - depth), 1)
	FROM	lines
	JOIN	mask
	USING	(x, y)
	CROSS JOIN
		parameters
	WHERE	x < width
	)
SELECT	SUBSTR(line, pattern_length + 1, width) AS line
FROM	lines
CROSS JOIN
	parameters
WHERE	x = width
ORDER BY
	y;
