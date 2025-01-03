import os
import json
import logging
import socket
import sqlite3
from flask import Flask

app = Flask(__name__)

log_file = os.path.expanduser('~/.data/tomato.log')
db_file = os.path.expanduser('~/.data/pomo.db')

logging.basicConfig(filename=log_file, level=logging.INFO)


def get_query(name):
    with open(os.path.join(os.path.dirname(__file__), name), 'r') as f:
        return f.read()


def get_db():
    db = sqlite3.connect(db_file)
    cur = db.cursor()
    res = cur.execute("SELECT name FROM sqlite_master WHERE name='pomo'")
    if not res.fetchall():
        tq = get_query('table.sql')
        cur.execute(tq)
        db.commit()
    return db, cur


def insert_event(event):
    db, cur = get_db()
    cur.executemany('INSERT INTO pomo (event_type, len) VALUES(?, ?)', [event])
    db.commit()

    return '200'


def status():
    db, cur = get_db()
    cur = db.cursor()
    q = get_query('status.sql')
    res = cur.execute(q).fetchall()
    if res:
        keys = [d[0] for d in cur.description]
        output = dict(zip(keys, res[0]))
        output['time_remaining'] = json.loads(output['time_remaining'])

        return output
    else:
        return {}


@app.route('/start')
def start():
    return insert_event(('pomo', 25))


@app.route('/stop')
def stop():
    return insert_event(('stop', None))


@app.route('/pause')
def pause():
    return insert_event(('pause', None))


@app.route('/unpause')
@app.route('/resume')
def unpause():
    return insert_event(('unpause', None))


@app.route('/short_break')
def short_break():
    return insert_event(('break', 5))


@app.route('/long_break')
def long_break():
    return insert_event(('break', 15))


@app.route('/status')
def show():
    return status()


if __name__ == "__main__":
    host_name = socket.getfqdn()
    ip = socket.gethostbyname(host_name)

    app.run(host=ip, port=7666)
