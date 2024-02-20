# Django Docker Starter Kit

This is a pretty simplified, but complete, workflow for using Docker and Docker Compose with Django python development.
The
included docker-compose.yml file, Dockerfiles, and config files, set up a Django project in
the `PATH_TO_CODE` directory.

The following architecture is created:

- Nginx - Used as the main application gateway. Nginx proxies python calls to the WSGI compliant gateway
- Django - This container hosts the python code in a volume and runs a WSGI compliant gateway (`gunicorn` or built
  in `runserver`)
- Postgres - This container hosts the Postres data server. This server has the Post GIS extensions already installed
- Redis - This container hosts the redis server that is used for session caching

Using this starter kit, you can get developing in Django without installing the typical application stack (e.g., python,
django, postgres...etc)

## Getting Started

### Configuration Settings

Copy `.env_example` to `.env` and set the following variables:

#### Application Settings

- `COMPOSE_PROJECT_NAME=django` Used in the docker-compose.yml file to namespace the services (e.g.,
  APP_NAME=abc_app)
- `APP_DOMAIN=django.local` - Used in the nginx service to automatically create a self-signed certificate for this
  domain.
- `PATH_TO_CODE=../code` - Location of the code that is used to configure map volumes into the containers

#### Docker Container Versions

The following are used to set the container versions for the services. Here is an example configuration:

- `PYTHON_VERSION=3.9`
- `NODE_VERSION=13.7`
- `REDIS_VERSION=latest`
- `NGINX_VERSION=stable`
- `POSTGRES_MAJOR_VERSION=16`
- `POSTGIS_MAJOR_VERSION=3`
- `POSTGIS_MINOR_RELEASE=4`

#### Docker Services Exposed Ports

The following are used to configure the exposed ports for the services. Here is an example, but update to de-conflict
ports:

- `HTTP_ON_HOST=8001`
- `HTTPS_ON_HOST=44301`
- `POSTGRES_ON_HOST=54321`
- `REDIS_ON_HOST=6379`

#### Database Settings

The following are used by docker when building the database service:

- `POSTGRES_DB=django_db`
- `POSTGRES_USER=django`
- `POSTGRES_PASSWORD=secret`

### Hosts File

For local development, update your Operating System's host file. For example, add the following line to resolve a domain
to localhost:

- `127.0.0.1     django.local`

## Basic Usage

1. To get started, make sure you have [Docker installed](https://docs.docker.com/docker-for-mac/install/) on your
   system, and then copy this repo to a desired location on your development machine.

2. For existing projects, place your Django code into the `PATH_TO_CODE` directory. For new project, this will be
   created automatically.

3. Using the terminal app, navigate to the directory you placed this repo. Run the following command to create docker
   images and start containers:

`docker compose up -d --build nginx`.

4. **Update Hosts** - In the `my_site/settings.py` file update the following entries:

```
# adjust for actual `APP_DOMAIN` variable
ALLOWED_HOSTS = ['django.local']

# adjust for actual `APP_DOMAIN`, `HTTPS_ON_HOST` variables
CSRF_TRUSTED_ORIGINS = ['https://django.local:44301']

INTERNAL_IPS = ['127.0.0.1', 'localhost']
```

5. **Switch to Containerized Postgres** - To use the Postgres container, the following changes are required:

- Create a `.env` file in your top level code directory (same level as `manage.py`) with the following lines:

```
POSTGRES_DB=django_db
POSTGRES_USER=django
POSTGRES_PASSWORD=secret
```

- Update the `my_site/settings.py` file to contain the following lines:

```
# add import statement near the top
import os
import environ

# import the .env settings. place this after BASE_DIR is defined
env = environ.Env()
environ.Env.read_env(BASE_DIR / '.env')

# database settings
DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': env('POSTGRES_DB'),
        'USER': env('POSTGRES_USER'),
        'PASSWORD': env('POSTGRES_PASSWORD'),
        'HOST': 'postgres',
        'PORT': 5432,
    }
}
```

- Run the migrations on the new database:
  `./pyman.sh migrate`

- Create a super user by running the following:
  `./pyman.sh createsuperuser`

- After making the above changes, you can delete the SQLite file that was created.


6. **Switch to Containerized Redis** - To use the Redis container, the following changes are required to
   the `my_site/settings.py` file:

```
# redis cache / session
CACHES = {
  "default": {
    "BACKEND": "django.core.cache.backends.redis.RedisCache",
    "LOCATION": "redis://redis:6379/0",
  }
}

SESSION_ENGINE = "django.contrib.sessions.backends.cache"

SESSION_CACHE_ALIAS = "default"
```

- after this switch, your existing session will not be found, and you will need to log in again

7. Navigate to public page: [https://django.local:44301](https://django.local:44301)

8. Navigate to admin page and login: [https://django.local:44301/admin](https://django.local:44301/admin)

## Exposed Services

When the container network is up, the following services and their ports are available to the host machine:

- **nginx** - `:HTTPS_ON_HOST`, `:HTTP_ON_HOST`
- **postgres** - `:POSTGRES_ON_HOST`
- **redis** - `:REDIS_ON_HOST`

## Other

There are a few shell script helpers included. These are:

- `./pyman <COMMAND>` runs the `python manage.py <COMMAND>` inside the django container
- `./pip <COMMAND>` runs `pip <COMMAND>` inside the django container

Here are a few examples that you will be familiar with:

- `./pyman startapp <APPNAME>`
- `./pyman makemigrations`
- `./pyman migrate`
- `./pyman collectstatic`
- `./pip install djangorestframework`
- `./pip freeze > requirements.txt`

You can create an interactive shell inside the container by doing one of the following:

- If there is NOT a running container: `docker compose run -it --entrypoint /bin/sh <SERVICE>`
- If there is already a running container: `docker compose exec -it <SERVICE> /bin/sh` 
