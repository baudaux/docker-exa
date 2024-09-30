# docker-exa

Offer the whole environement for compiling your project for exaequOS.
Note: An online Docker image exists at: https://hub.docker.com/repository/docker/lecrapouille/exaequos

## Prerequisite

- Install Docker engine: https://docs.docker.com/engine/install/
- Create a cache folder in your home folder:
```
mkdir -p ~/.cache/exaequos
```

If this folder is not created, the Docker will create one but with root priviledge and you do not want to have root folder inside your folders.


## Clone the Dockerfile for exaequOS

```
git clone https://github.com/baudaux/docker-exa.git
cd docker-exa
```

## Build the docker image

```
docker build -t exaequos .
```

## Run exaequOS Docker against your project you want to compile

- Go to you project folder first. Let suppose your user name is `John` and the project name is `Test`.
- Then call exaequOS docker against your project:

```
cd /home/John/test
docker run -it -u $(id -u ${USER}):$(id -g ${USER}) -v $(pwd):$(pwd) -v ~/.cache/exaequos:/home/exaequos/emscripten-exa/cache -p 127.0.0.1:7777:7777 -w $(pwd) exaequos
```

Once inside your Docker, you will see this kind of prompt:

```
ExaequOS:720c9a20d6d4:/home/John/test$
```

If your project depends on graphical libs. You can download them:

```
ExaequOS:720c9a20d6d4:/home/John/test$ epm.py install exa-wayland glfw raylib
```

A folder `exapkgs` shall have been created. You can refer the path to pkg-config:

```
ExaequOS:720c9a20d6d4:/home/John/Test$ export PKG_CONFIG_PATH=/home/John/test/exapkgs/pkgconfigs
```

Let compile your project. For example

```
ExaequOS:720c9a20d6d4:/home/John/test/src$ emcc test.c -o Test.js
```

Use `em++` for compiling C++ files and `emar crs` for creating static libs. Compilation flags are not shown here but are the same than gcc/g++.

## Run local server inside docker

Once your project has been compiled, copy the `test.js` and `test.wasm` binaries inside the `/home/John/test/media/localhost/test/exa` folder.
Create in this folder an `exa.html` file with the following content (Replace `test.js` by the real name of your application):

```
<!doctype html>
<html lang="en-us">
<head>
  <meta charset="utf-8">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>Emscripten-Generated Code</title>
  <style>
    html, body {
      margin : 0;
      padding: 0;
      border: none;
      width: 100%;
      height: 100%;
    }
  </style>
</head>
<body>
  <script async type="text/javascript" src="test.js"></script>
</body>
</html>
```

Start the node server at parent directory of `media/locahost` (`/home/John/test/` in this example)

```
node /home/exaequos/emscripten-exa/third_party/server/server.js &
```

## Run app inside exaequos.com

Go to https://www.exaequos.com/ start the console `Havoc` and type:

```
/media/localhost/test
```

## For developers

Publish the docker image to Docker hub:

```
docker login
docker tag exaequos:latest lecrapouille/exaequos:latest
docker push lecrapouille/exaequos:latest
```
