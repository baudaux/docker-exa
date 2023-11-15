# docker-exa

### Build docker image

```docker build -t exaequos .```

### file tree

Example of tree for an <app> in /media/localhost/

    <host current dir>/root/media/localhost/
	    <app>/
			src/
				sources
			exa/
				<app>.js
				<app>.wasm

### Run docker

```docker run -it -v $(pwd):$(pwd) -w $(pwd) -v $(pwd)/.cache:/home/emscripten-exa/cache -p 127.0.0.1:7777:7777 -u $(id -u ${USER}):$(id -g ${USER}) exaequos```

### Build app inside docker

```emcc src/test.c -o exa/test.js```

### Run local server inside docker

At root directory:

```node /home/emscripten-exa/third_party/server/server.js```

### Run app inside exaequos.com

```/media/localhost/test```

