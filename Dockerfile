# syntax=docker/dockerfile:1

FROM debian:bookworm-slim
WORKDIR /home
RUN set -ex && \
    apt-get -y update && \
    apt-get -y install git

RUN set -ex && \
    apt-get -y update && \
    apt-get -y install pkg-config
    
RUN set -ex && \
    apt-get -y update && \
    apt-get -y install python3
    
RUN set -ex && \
    apt-get -y update && \
    apt-get -y install lsb-release wget software-properties-common gnupg

#RUN wget https://apt.llvm.org/llvm.sh
#RUN chmod +x llvm.sh
#RUN ./llvm.sh 16

RUN set -ex &&\
    echo "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-16 main" > /etc/apt/sources.list.d/apt.llvm.org.list &&\
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key |  tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc &&\
    apt-get -y update &&\
    apt-get -y install clang-16 lldb-16 lld-16 clangd-16 clang-tidy-16 clang-format-16 clang-tools-16 llvm-16-dev lld-16 lldb-16 llvm-16-tools libomp-16-dev libc++-16-dev libc++abi-16-dev libclang-common-16-dev libclang-16-dev libclang-cpp16-dev libunwind-16-dev libclang-rt-16-dev libpolly-16-dev

RUN ln -s /usr/bin/clang-16 /usr/bin/clang
RUN ln -s /usr/bin/clang++-16 /usr/bin/clang++
RUN ln -s /usr/bin/llc-16 /usr/bin/llc
RUN ln -s /usr/bin/llvm-ar-16 /usr/bin/llvm-ar
RUN ln -s /usr/bin/llvm-ranlib-16 /usr/bin/llvm-ranlib
RUN ln -s /usr/bin/llvm-nm-16 /usr/bin/llvm-nm
RUN ln -s /usr/bin/llvm-objcopy-16 /usr/bin/llvm-objcopy
RUN ln -s /usr/bin/llvm-strip-16 /usr/bin/llvm-strip
RUN ln -s /usr/lib/llvm-16/bin/wasm-ld /usr/bin/wasm-ld

RUN git clone https://github.com/baudaux/emscripten-exa.git
RUN /home/emscripten-exa/emcc --generate-config

RUN set -ex && \
    apt-get -y update && \
    apt-get -y install cmake

RUN git clone https://github.com/WebAssembly/binaryen.git
RUN cd binaryen && \
    git checkout tags/version_110 && \
    git submodule init && \
    git submodule update && \
    cmake -DBUILD_TESTS=OFF . && \
    make -j`nproc --all` && \
    make install
    
RUN set -ex && \
    apt-get -y update && \
    apt-get -y install nodejs npm

ENV PATH "$PATH:/home/emscripten-exa/"

WORKDIR /home/emscripten-exa/third_party/server
RUN npm install

WORKDIR /home
