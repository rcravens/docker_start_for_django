ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION}

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update

RUN apt-get install -y libgdal-dev

RUN pip install --upgrade pip

#RUN pip install GDAL==3.2.2.1

RUN pip install gunicorn psycopg2-binary GDAL==3.2.2.1 redis Django django-environ django-redis-sessions

WORKDIR /app

# update the .env file with the
RUN mkdir -p /app/code

RUN echo "cache buster";

RUN if [ ! -e "/app/code/.env" ]; then \
    touch /app/code/.env; \
    fi;
#
#ARG POSTGRES_DB
#RUN if ! $(grep -Fxq "POSTGRES_DB" /app/code/.env); then \
#   "POSTGRES_DB=$POSTGRES_DB" > /app/code/.env; \
#   fi;

#ARG POSTGRES_USER
#RUN "POSTGRES_USER=${POSTGRES_USER}" >> /app/code/.env
#ARG POSTGRES_PASS
#RUN "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" >> /app/code/.env

ADD ./django/entry_point.sh /app/entry_point.sh


