WITH tbl AS (
    SELECT
        id,
        SUM(CASE WHEN event_type in ('pomo', 'break', 'stop') THEN 1 ELSE 0 END)
            OVER(ORDER BY timestamp)
        AS pomo_id,
        event_type,
        len,
        timestamp,
        DATETIME(timestamp, '+' || len || ' minute') AS target
    FROM
        pomo
),

pause_ids AS (
    SELECT
        pomo_id,
        event_type,
        timestamp,
        SUM(CASE WHEN event_type = 'pause' THEN 1 ELSE 0 END)
            OVER(PARTITION BY pomo_id ORDER BY timestamp)
        + (10 * pomo_id) AS pause_id
    FROM
        tbl
    WHERE event_type in ('pause', 'unpause')
),

jd_pause AS (
    SELECT
        pomo_id,
        SUM(JULIANDAY(unpause) - JULIANDAY(timestamp)) AS jd_pause_len
    FROM (
        SELECT *,
            LEAD(timestamp) OVER (PARTITION BY pause_id ORDER BY timestamp) AS unpause
        FROM
            pause_ids
    )
    WHERE event_type = 'pause'
    GROUP BY pomo_id
),

seconds_until_target AS (
    SELECT
        t.pomo_id,
        (
            JULIANDAY(target)
            + IFNULL(p.jd_pause_len, 0)
            - JULIANDAY(
                CASE WHEN t.pomo_id = (SELECT MAX(pomo_id) FROM tbl)
                    THEN CURRENT_TIMESTAMP
                    ELSE LEAD(timestamp) OVER(ORDER BY timestamp)
                END
            )
        ) * 24 * 60 * 60 AS total_seconds
    FROM tbl t
    LEFT JOIN jd_pause p
    ON t.pomo_id = p.pomo_id
    WHERE event_type in ('pomo', 'break')
)

SELECT DISTINCT
    p.pomo_id,
    (SELECT event_type FROM tbl ORDER BY id LIMIT 1) AS event,
    (SELECT len FROM tbl WHERE len IS NOT NULL LIMIT 1) AS pomo_len,
    (SELECT event_type = 'pause' FROM tbl ORDER BY id DESC LIMIT 1) AS paused,
    JSON_OBJECT(
        'hr', ABS(CAST(total_seconds / 24 / 60 % 60 AS INT)),
        'min', ABS(CAST(total_seconds / 60 % 60 AS INT)),
        'sec', ABS(CAST(total_seconds % 60 AS INT)),
        'time_exceeded', CASE WHEN total_seconds < 0 THEN true ELSE false END
    ) AS time_remaining
FROM tbl p
LEFT JOIN seconds_until_target s
ON p.pomo_id = s.pomo_id
WHERE p.pomo_id = (SELECT MAX(pomo_id) FROM tbl)
