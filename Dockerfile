FROM python:3.8.13-slim
FROM conda/miniconda3

WORKDIR /pyjanitor

ADD . .

RUN apt-get update && apt-get install -y make

