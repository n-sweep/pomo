# 🍅 Pomodoro Timer

```sh
curl -s localhost:5000/start
curl -s localhost:5000/pause
curl -s localhost:5000/unpause
curl -s localhost:5000/short_break
curl -s localhost:5000/status
```

```sh
curl -s localhost:5000/status | jq -r .time_remaining.time_exceeded
```

```sh
curl -s localhost:5000/status | jq -r '.time_remaining
| if .time_exceeded > 0
then "[:anger-symbol:-\(.min):\(.sec)]"
else "[:tomato:\(.min):\(.sec)]" end'\
| emoji -m
```
