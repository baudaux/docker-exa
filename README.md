# docker-exa

## Build docker image

``` > docker build -t exaequos .

## run docker

``` > docker run -it -v $(pwd)/root:/home/root -v $(pwd)/cache:/home/emscripten-exa/cache -p 127.0.0.1:7777:7777 exaequos

## Build app inside docker

``` > /home/root/media/localhost/<app>/src# emcc test.c -o ../exa test.js

## Run local server

``` > /home/root# node /home/emscripten-exa/third_party/server/server.js

## Run app inside exaequos

``` > /media/localhost/test
