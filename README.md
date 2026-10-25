# docker-exa

Docker image to compile a project for [ExaequOS](https://www.exaequos.com).
The published image is [lecrapouille/exaequos](https://hub.docker.com/r/lecrapouille/exaequos).

The compiler is in `/opt/emscripten-exa` and is readable by any user id.
`EM_CONFIG` points at `/opt/emscripten-exa/.emscripten`, and the cache is
`/opt/emscripten-exa/cache`. A CI job can run `docker run -u $(id -u)`
without being root.

## Prerequisite

Install Docker: https://docs.docker.com/engine/install/

Create the compiler cache before the first run. If the folder is missing,
Docker creates it as root inside your home:

```sh
mkdir -p ~/.cache/exaequos
```

## Build the image

```sh
git clone https://github.com/Lecrapouille/docker-exa.git
cd docker-exa
docker build -t exaequos .
```

## Compile a project

From the project directory (`test_project` below):

```sh
cd /home/John/test_project
docker run -it --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):$(pwd)" \
    -v "$HOME/.cache/exaequos:/opt/emscripten-exa/cache" \
    -p 127.0.0.1:7777:7777 \
    -w "$(pwd)" \
    exaequos
```

The prompt looks like:

```text
ExaequOS:720c9a20d6d4:/home/John/test_project$
```

A program that needs the graphical libraries installs them with `epm.py`.
They land in `exapkgs/`:

```sh
epm.py install exa-wayland glfw raylib
export PKG_CONFIG_PATH="$(pwd)/exapkgs/pkgconfigs"
```

Compile with `emcc` for C and `em++` for C++. `emar crs` creates a static
library. The flags are the same as for gcc and g++:

```sh
emcc test.c -o test.js
```

To install an extra Debian package, connect to the running container as root:

```sh
docker ps
docker exec -it -u root <container_id> /bin/bash
```

## Run it

Copy `test.js` and `test.wasm` into `media/localhost/test/exa`, next to an
`exa.html` that loads the script. A build with `-pthread` also needs
`test.worker.js` in that folder:

```html
<!doctype html>
<html lang="en-us">
<head>
  <meta charset="utf-8">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>Emscripten-Generated Code</title>
  <style>
    html, body {
      margin: 0;
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

The container does not start the file server. Start it yourself from the
directory that contains `media/` (the project directory here), so it sees
that folder. Port 7777 is the one published above:

```sh
node /opt/emscripten-exa/third_party/server/server.js &
```

Open https://www.exaequos.com/, start the console Havoc and type:

```text
/media/localhost/test
```

## Continuous integration

```yaml
- name: Compile with ExaequOS
  run: |
    mkdir -p "$HOME/.cache/exaequos"
    docker run --rm \
      -u "$(id -u):$(id -g)" \
      -v "$PWD:$PWD" \
      -v "$HOME/.cache/exaequos:/opt/emscripten-exa/cache" \
      -w "$PWD" \
      lecrapouille/exaequos:latest \
      bash -c 'make download-external-libs && make compile-external-libs && make -j"$(nproc)" && make install'
```

This command matches this Dockerfile. The image currently published as
`lecrapouille/exaequos:latest` still keeps the compiler in a private home,
so a runner has to use root until this image is pushed.

## Publish the image

```sh
docker login
docker tag exaequos:latest lecrapouille/exaequos:latest
docker push lecrapouille/exaequos:latest
```
