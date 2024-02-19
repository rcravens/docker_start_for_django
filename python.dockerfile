ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION}

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update

RUN apt-get install -y libgdal-dev

RUN pip install --upgrade pip

#RUN apt-get install gdal-bin

RUN pip install GDAL==3.2.2.1

WORKDIR /app

ADD ./django/entry_point.sh /app/entry_point.sh