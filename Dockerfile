###############################################################################
### Dockerfile offering compilation evironements for ExaequOS.
### https://github.com/exaequos
###############################################################################

FROM debian:bookworm-slim
ENV SHELL /usr/bin/bash
RUN set -ex
ENV EXAEQUOS "exaequos"

###############################################################################
### Operating system packages.
###############################################################################
RUN apt-get -y update
RUN apt-get -y install git cmake make ninja-build pkg-config lsb-release wget curl software-properties-common gnupg bc bash-completion autotools-dev autoconf vim
RUN apt-get -y install python3  python3-requests
RUN apt-get -y install nodejs npm
RUN echo "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-16 main" > /etc/apt/sources.list.d/apt.llvm.org.list
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key |  tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
RUN apt-get -y install clang-16 lldb-16 lld-16 clangd-16 clang-tidy-16 clang-format-16 clang-tools-16 llvm-16-dev lld-16 lldb-16 llvm-16-tools libomp-16-dev libc++-16-dev libc++abi-16-dev libclang-common-16-dev libclang-16-dev libclang-cpp16-dev libunwind-16-dev libclang-rt-16-dev libpolly-16-dev

RUN ln -s /usr/bin/clang-16 /usr/bin/clang
RUN ln -s /usr/bin/clang++-16 /usr/bin/clang++
RUN ln -s /usr/bin/llc-16 /usr/bin/llc
RUN ln -s /usr/bin/llvm-ar-16 /usr/bin/llvm-ar
RUN ln -s /usr/bin/llvm-ranlib-16 /usr/bin/llvm-ranlib
RUN ln -s /usr/bin/llvm-nm-16 /usr/bin/llvm-nm
RUN ln -s /usr/bin/llvm-objcopy-16 /usr/bin/llvm-objcopy
RUN ln -s /usr/bin/llvm-strip-16 /usr/bin/llvm-strip
RUN ln -s /usr/lib/llvm-16/bin/wasm-ld /usr/bin/wasm-ld

#RUN apt-get clean
#RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###############################################################################
### Create user and home folder. Customize prompt. Do it after apt-get install.
###############################################################################
ENV USER $EXAEQUOS
ENV HOME "/home/$USER"
RUN adduser --quiet --disabled-password --gecos '' $USER
RUN mkdir -p /media/localhost
RUN chown $USER:$USER /media/localhost
USER $USER

###############################################################################
### Download, compile and install ExaequOS repos.
###############################################################################
ENV EXA_EMSCRIPTEN=$HOME/emscripten-exa
ENV PATH "$EXA_EMSCRIPTEN:$EXA_EMSCRIPTEN/third_party/epm:$PATH"

WORKDIR $HOME
RUN git clone https://github.com/baudaux/emscripten-exa.git --depth 1
RUN $EXA_EMSCRIPTEN/emcc --generate-config
RUN git clone https://github.com/WebAssembly/binaryen.git --branch version_110 --recursive --depth 1
RUN (cd binaryen && cmake -DBUILD_TESTS=OFF . && make -j`nproc --all`)

WORKDIR $EXA_EMSCRIPTEN/third_party/server
RUN npm install

USER root
RUN (cd $HOME/binaryen && make install)

###############################################################################
###
###############################################################################
USER $USER

#RUN echo 'function prompt_command {' >> $HOME/.bashrc
#RUN echo '  PS1="\[\033[1;36m\]ExaequOS\[\e[0m\]:\[\033[1;33m\]${HOSTNAME}\[\e[0m\]:\[\033[1;34m\]${PWD}\[\e[0m\]$ "' >> $HOME/.bashrc
#RUN echo '}' >> $HOME/.bashrc
#RUN echo 'PROMPT_COMMAND=prompt_command' >> $HOME/.bashrc
#RUN echo 'if [ -f /usr/share/bash-completion/bash_completion ]; then . /usr/share/bash-completion/bash_completion; fi' >> $HOME/.bashrc
#RUN echo 'if [ "`ps -ef | grep -v grep | grep node`" == "" ]; then node /home/exaequos/emscripten-exa/third_party/server/server.js & fi' >> $HOME/.bashrc