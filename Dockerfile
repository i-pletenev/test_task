FROM ubuntu:20.04

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    tar \
    cmake \
    zlib1g \ 
    bzip2 \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

ENV SOFT=/soft
RUN mkdir -p ${SOFT} && chmod -R 755 ${SOFT}

# Install libdeflate v1.24 (release: 2025-05-11)
ENV LIBDEFLATE_VERSION=1.24
RUN mkdir -p ${SOFT}/libdeflate-${LIBDEFLATE_VERSION} && \
    cd ${SOFT}/libdeflate-${LIBDEFLATE_VERSION} && \
    wget https://github.com/ebiggers/libdeflate/archive/refs/tags/v${LIBDEFLATE_VERSION}.tar.gz && \
    tar -xzf v${LIBDEFLATE_VERSION}.tar.gz --strip-components=1 && \
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=$SOFT/libdeflate-${LIBDEFLATE_VERSION} -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build -j$(nproc) && \
    cmake --install build && \
    rm -rf v${LIBDEFLATE_VERSION}.tar.gz build

ENV PATH=${SOFT}/libdeflate-${LIBDEFLATE_VERSION}/bin:${PATH}

# Install samtools

