WITH tbl AS (
    SELECT *,
        SUM(CASE WHEN event_type = 'pomo' THEN 1 ELSE 0 END)
        OVER(ORDER BY timestamp) AS pomo_id
    FROM
        pomo
),
time_diff AS (
    SELECT
        CAST(diff / 60 AS INT) AS min,
        CAST(diff % 60 AS INT) AS sec
    FROM (
        SELECT *,
            (JULIANDAY(DATETIME(timestamp, '+' || len || ' minute'))
             - JULIANDAY(CURRENT_TIMESTAMP)) * 24 * 60 * 60 AS diff
        FROM tbl
        WHERE event_type = 'pomo'
    )
)

SELECT * FROM tbl
