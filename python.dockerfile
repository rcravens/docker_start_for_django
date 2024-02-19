ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION}

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update

RUN apt-get install -y libgdal-dev

RUN pip install --upgrade pip

RUN pip install gunicorn psycopg2-binary GDAL==3.2.2.1 redis Django django-environ django-redis-sessions

WORKDIR /app

ADD ./django/entry_point.sh /app/entry_point.sh


