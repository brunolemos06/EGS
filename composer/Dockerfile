##dockerfile for composer

FROM python:3.8.10

WORKDIR /ridemate_composer

COPY requirements.txt .
COPY static static

EXPOSE 8080

RUN pip3 install -r requirements.txt

COPY composer.py .
COPY setup_db.py .
COPY db_func.py .
# create database and run the app
RUN python3 setup_db.py
CMD ["python3", "composer.py"]
