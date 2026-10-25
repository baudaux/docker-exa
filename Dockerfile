###############################################################################
### Compilation environment for ExaequOS.
### https://github.com/Lecrapouille/docker-exa
###
### The toolchain lives in /opt and is readable by any uid, so
### `docker run -u $(id -u)` works in CI. The compiler is clang 16 and
### Binaryen version_110, the pair emscripten-exa was built against.
### The debug tools (lldb, clang-tidy, clangd) and a from-source Binaryen
### build are not included.
###############################################################################

FROM debian:bookworm-slim

ENV EXAEQUOS=exaequos \
    EXA_EMSCRIPTEN=/opt/emscripten-exa \
    EM_CONFIG=/opt/emscripten-exa/.emscripten \
    PATH="/opt/emscripten-exa:/opt/emscripten-exa/third_party/epm:/opt/binaryen/bin:${PATH}" \
    LANG=C.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        autoconf autotools-dev bash bash-completion ca-certificates curl \
        git gnupg make nodejs npm pkg-config procps python3 python3-requests \
        vim \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key \
        | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-16 main" \
        > /etc/apt/sources.list.d/llvm-16.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends clang-16 lld-16 llvm-16 \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/bin/clang-16 /usr/bin/clang \
 && ln -sf /usr/bin/clang++-16 /usr/bin/clang++ \
 && ln -sf /usr/bin/llc-16 /usr/bin/llc \
 && ln -sf /usr/bin/llvm-ar-16 /usr/bin/llvm-ar \
 && ln -sf /usr/bin/llvm-ranlib-16 /usr/bin/llvm-ranlib \
 && ln -sf /usr/bin/llvm-nm-16 /usr/bin/llvm-nm \
 && ln -sf /usr/bin/llvm-objcopy-16 /usr/bin/llvm-objcopy \
 && ln -sf /usr/bin/llvm-strip-16 /usr/bin/llvm-strip \
 && ln -sf /usr/lib/llvm-16/bin/wasm-ld /usr/bin/wasm-ld

# The release tarball replaces a git clone of Binaryen and its cmake build.
RUN curl -fsSL -o /tmp/binaryen.tar.gz \
        https://github.com/WebAssembly/binaryen/releases/download/version_110/binaryen-version_110-x86_64-linux.tar.gz \
 && tar -xzf /tmp/binaryen.tar.gz -C /opt \
 && mv /opt/binaryen-version_110 /opt/binaryen \
 && rm /tmp/binaryen.tar.gz \
 && test -x /opt/binaryen/bin/wasm-opt

RUN git clone --depth 1 https://github.com/baudaux/emscripten-exa.git /opt/emscripten-exa \
 && printf '%s\n' \
        "EMSCRIPTEN_ROOT = '/opt/emscripten-exa'" \
        "LLVM_ROOT = '/usr/bin'" \
        "BINARYEN_ROOT = '/opt/binaryen'" \
        "NODE_JS = '/usr/bin/node'" \
        "CACHE = '/opt/emscripten-exa/cache'" \
        > /opt/emscripten-exa/.emscripten \
 && git config --system --add safe.directory /opt/emscripten-exa \
 && git config --system --add safe.directory '*' \
 && chmod -R a+rX /opt/emscripten-exa /opt/binaryen \
 && mkdir -p /opt/emscripten-exa/cache /media/localhost \
 && chmod 1777 /opt/emscripten-exa/cache /media/localhost

WORKDIR /opt/emscripten-exa/third_party/server
RUN npm install --omit=dev \
 && chmod -R a+rX /opt/emscripten-exa/third_party/server

RUN useradd --create-home --shell /bin/bash exaequos \
 && chmod 755 /home/exaequos \
 && printf '%s\n' \
        'PS1="\[\033[1;36m\]ExaequOS\[\e[0m\]:\[\033[1;33m\]\h\[\e[0m\]:\[\033[1;34m\]\w\[\e[0m\]$ "' \
        'if [ -f /usr/share/bash-completion/bash_completion ]; then . /usr/share/bash-completion/bash_completion; fi' \
        > /home/exaequos/.bashrc \
 && chmod 644 /home/exaequos/.bashrc

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

USER exaequos
WORKDIR /home/exaequos
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
