-- DROP TABLE IF EXISTS pomo;
CREATE TABLE pomo (
    id INTEGER PRIMARY KEY,
    event_type TEXT NOT NULL,
    len INTEGER,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
