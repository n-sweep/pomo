FROM python:3.7-slim

RUN mkdir /root/.data
RUN apt update && apt install -y git
RUN pip install flask_socketio
RUN git clone https://github.com/n-sweep/pomo.git /root/pomo

EXPOSE 5000

CMD ["python3", "/root/pomo/run.py"]
