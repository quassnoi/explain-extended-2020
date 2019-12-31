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
	)
SELECT	REPEAT(pattern, pattern_count) AS line
FROM	patterns
CROSS JOIN
	parameters
ORDER BY
	y;
