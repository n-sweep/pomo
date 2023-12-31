import sqlite3
from flask import Flask, g

app = Flask(__name__)


def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect('pomo.db')
    return db


def insert_event(event):
    db = get_db()
    cur = db.cursor()
    cur.executemany('INSERT INTO pomo (event_type, len) VALUES(?, ?)', [event])
    db.commit()


@app.route('/start')
def start():
    insert_event(('pomo', 25))
    return '200'


@app.route('/pause')
def pause():
    insert_event(('pause', None))
    return '200'


@app.route('/unpause')
def unpause():
    insert_event(('unpause', None))
    return '200'


@app.route('/short_break')
def short_break():
    insert_event(('break', 5))
    return '200'


@app.route('/long_break')
def long_break():
    insert_event(('break', 15))
    return '200'


if __name__ == "__main__":
    app.run(debug=True)
