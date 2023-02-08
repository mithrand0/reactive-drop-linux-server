# project
Reactive Drop linux server

# what does it run on
This container does not require a Windows installation to run. It runs on windows, linux, macosx, without gui.

# requirements
You need Docker

About Docker:
- https://www.docker.com/resources/what-container
- https://www.docker.com/products/docker-enterprise

Get Docker:
- https://www.docker.com/get-started
- https://docs.docker.com/compose/

Install Docker and Docker-Compose.

# how to run

Download `docker-compose.yml`, make your changes, and run `docker-compose up`. 

# winesync

The container optionally supports WineSync, if you have a kernel that supports it.

# how to customize
The game is installed in a volume `/usr/lib/games/reactivedrop/`, you can mount that volume on the host.

Any configuration parameters starting with `rd_` with be written as config, i.e. `rd_rcon_password=test` will be `rcon_password=test` in the server config.
