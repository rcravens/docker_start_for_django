# Laravel Docker Workflow

This is a pretty simplified, but complete, workflow for using Docker and Docker Compose with Laravel development. The
included docker-compose.yml file, Dockerfiles, and config files, set up a LEMP stack powering a Laravel application in
the `code` directory.

## Getting Started

### Configuration Settings

Copy `.env_example` to `.env` and set the following variables:

#### Application Settings

- `COMPOSE_PROJECT_NAME=django_app` Used in the docker-compose.yml file to namespace the services (e.g.,
  APP_NAME=abc_app)
- `APP_DOMAIN=django_app.local` - Used in the nginx service to automatically create a self-signed certificate for this
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

- `127.0.0.1     django_app.local`

## Usage

1. To get started, make sure you have [Docker installed](https://docs.docker.com/docker-for-mac/install/) on your
   system,
   and then copy this directory to a desired location on your development machine.

2. Open the .env file and update any settings (e.g., versions & exposed ports) to match your desired development
   environment.

3. Navigate in your terminal to that directory, and spin up the containers for the full web server stack by running:
   `docker-compose up -d --build nginx`.

4. Update the `my_site/settings.py` file to contain the following lines:

- `ALLOWED_HOSTS = ['django_app.local']` (adjust for actual `APP_DOMAIN` variable)
- `CSRF_TRUSTED_ORIGINS = ['https://django_app.local:44301']` (adjust for actual `APP_DOMAIN`, `HTTPS_ON_HOST`
  variables)

5. Navigate to public page: [https_//django_app.local:44301](https_//django_app.local:44301)

6. Run `./pyman.sh createsuperuser` and follow the prompts to create the admin super user

7. Navigate to admin page and login: [https_//django_app.local:44301/admin](https_//django_app.local:44301/admin)

## Exposed Services

When the container network is up, the following services and their ports are available to the host machine:

- **nginx** - `:HTTPS_ON_HOST`, `:HTTP_ON_HOST`
- **postgres** - `:POSTGRES_ON_HOST`
- **mysql** - `:MYSQL_ON_HOST`
- **redis** - `:REDIS_ON_HOST`

## Other

There are a few shell script helpers included. These are:

- `./pyman <COMMAND>` runs the `python manage.py <COMMAND>` inside the django container
- `./pip <COMMAND>` runs `pip <COMMAND>` inside the django container

You can create an interactive shell inside the container by doing one of the following:

- If there is NOT a running container: `docker-compose run -it --entrypoint /bin/sh <SERVICE>`
- If there is already a running container: `docker compose exec -it <SERVICE> /bin/sh` 
