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
        event_type,
        timestamp,
        SUM(CASE WHEN event_type = 'pause' THEN 1 ELSE 0 END)
            OVER(PARTITION BY pomo_id ORDER BY timestamp)
        + (10 * pomo_id) AS pause_id
    FROM
        tbl
    WHERE event_type in ('pause', 'unpause')
),
pauses AS (
    SELECT *
    FROM (
        SELECT *,
            timestamp AS pause,
            LEAD(timestamp) OVER (PARTITION BY pause_id ORDER BY timestamp) AS unpause
        FROM
            pause_ids
    )
),
time_remain AS (
    SELECT id,
        sec AS total_seconds,
        CAST(sec / 60 AS INT)
        || ":" ||
        ABS(CAST(sec % 60 AS INT)) AS remain_string
    FROM (
        SELECT
            id,
            (JULIANDAY(target) - JULIANDAY(
                CASE WHEN pomo_id = (SELECT MAX(pomo_id) FROM tbl)
                    THEN CURRENT_TIMESTAMP
                    ELSE LEAD(timestamp) OVER(ORDER BY timestamp)
                END
            )) * 24 * 60 * 60 AS sec
        FROM tbl
        WHERE event_type in ('pomo', 'break')
    )
)

-- SELECT
    -- p.id,
    -- pomo_id,
    -- event_type,
    -- len,
    -- timestamp,
    -- total_seconds,
    -- remain_string
-- FROM tbl p
-- LEFT JOIN time_remain t
-- ON p.id = t.id
select * from pauses
