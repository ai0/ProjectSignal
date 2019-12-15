FROM python:3.7.0

COPY . /opt/app
WORKDIR /opt/app
RUN pip install -r requirements.txt

RUN apt update && apt install wait-for-it
