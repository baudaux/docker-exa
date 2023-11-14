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


### run docker

```docker run -it -v $(pwd)/root:/home/root -v $(pwd)/cache:/home/emscripten-exa/cache -p 127.0.0.1:7777:7777 exaequos```

### Build app inside docker

```emcc src/test.c -o exa/test.js```

### Run local server inside docker

```node /home/emscripten-exa/third_party/server/server.js```

### Run app inside exaequos

```/media/localhost/test```

