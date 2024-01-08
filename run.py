import json
import socket
import sqlite3
from flask import Flask, g

app = Flask(__name__)


def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect('pomo.db')
    return db


def get_query(name):
    with open(name, 'r') as f:
        return f.read()


def insert_event(event):
    db = get_db()
    cur = db.cursor()
    cur.executemany('INSERT INTO pomo (event_type, len) VALUES(?, ?)', [event])
    db.commit()

    return '200'

def status():
    db = get_db()
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
    port = 7666

    app.run(host=ip, port=port)
