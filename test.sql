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
)
