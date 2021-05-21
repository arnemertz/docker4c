:bangbang: Very much work in progress!

# The container

## Building

`./build-image.sh`

## Starting

`docker-compose up -d`

## Entering

- Via ssh: `ssh dev@localhost -p 2222` , password is `dev`
- Via docker exec: `docker exec -i -t -u dev:dev cpp_docker_env bash`

## Stopping

`docker-compose down`


# Working on projects

The user for the Docker container is `dev`.
The compose file maps `~/git` on the host machine to `/home/dev/git` in the contianer, so I suggest that you check out your project there.
