:bangbang: Very much work in progress!

# The container

The Dockerfile contains two container definitions: 

- a CI container which should contain everyhting necessary to build C++ applications and run their tests
- a DEV container which inherits the CI container and adds debugging tools like valgrind, gdb, etc.

The compose file contains a basic setup to run the DEV container locally. Since some IDEs depend on a SSH connection to a container (or for remote develpment in general), SSHD is started in the service defined by the compose file.

The user for the Docker container is `dev`.
The compose file maps `~/git` on the host machine to `/home/dev/git` in the contianer, so I suggest that you check out your project there.

# Scripts

The scripts directory has a few helpers for easier building and running of the container and executing commands in it. Consider adding the scripts directory to your path for ease of use.

## Building the container image

`d4c build` (re)builds and tags the container image

## Starting

`d4c up` starts the container in the background

## Stopping

`d4c down` stops the running container

## Entering the container/Running commands

- Via ssh: `ssh dev@localhost -p 2222` , password is `dev`
- Via docker exec: `d4c run` 
    - without commands: logs into the container via bash
    - with commands: executes the given commands in the container

`d4c run` starts the container if it is not active yet and changes to the working directory it is called from, if it exists inside container (including `${HOME}` -> `/home/dev` mapping)

