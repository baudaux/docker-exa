# docker-exa

### Build the docker image

```docker build -t exaequos .```

### File tree of current project

Example of file tree for an app in /media/localhost/

    <project pwd>
		/build/media/localhost/
			<app name>/
				src/
					sources
				exa/
					<app name>.js
					<app name>.wasm

### Run docker

```docker run -it -v $(pwd):$(pwd) -w $(pwd) -v $(pwd)/.cache:/home/emscripten-exa/cache -p 127.0.0.1:7777:7777 -u $(id -u ${USER}):$(id -g ${USER}) exaequos```

### Build app inside docker

```emcc src/test.c -o exa/test.js```

### Run local server inside docker

Start server.js at parent directory of /media/locahost (build dir in this example)

```node /home/emscripten-exa/third_party/server/server.js```

### Run app inside exaequos.com

```/media/localhost/test```

