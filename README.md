# project
Reactive Drop linux server

# what does it run on
This container does not require a Windows installation to run. It runs on windows, linux, macosx, without gui.

# how to run
You need Docker

About Docker:
- https://www.docker.com/resources/what-container
- https://www.docker.com/products/docker-enterprise

Get Docker:
- https://www.docker.com/get-started
- https://docs.docker.com/compose/

Install Docker and Docker-Compose.

Run: `docker-compose up`

# how to add custom configs

Copy docker-compose.yml to docker-compose.override.yml and make your changes.

Restart the container after that.

# how to customize
The game is installed in /usr/lib/games/reactivedrop/. You can overwrite any file there.

