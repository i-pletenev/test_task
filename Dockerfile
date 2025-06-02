FROM ubuntu:20.04

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    tar \
    cmake \
    zlib1g-dev \ 
    libbz2-dev \
    libcurl4-openssl-dev \
    libncurses5-dev \
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
ENV LIBDEFLATE=$SOFT/libdeflate-${LIBDEFLATE_VERSION}/bin/libdeflate-gzip

# Install htslib v1.22 (release: 2025-05-30)
ENV HTSLIB_VERSION=1.22
RUN mkdir -p $SOFT/htslib-${HTSLIB_VERSION} && \
    cd $SOFT/htslib-${HTSLIB_VERSION} && \
    wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 && \
    tar -xjf htslib-${HTSLIB_VERSION}.tar.bz2 --strip-components=1 && \
    ./configure --prefix=$SOFT/htslib-${HTSLIB_VERSION} && \
    make -j$(nproc) && make install && \
    rm -rf htslib-${HTSLIB_VERSION}.tar.bz2

ENV PATH=$SOFT/htslib-${HTSLIB_VERSION}/bin:$PATH
ENV HTSLIB=$SOFT/htslib-${HTSLIB_VERSION}/bin/htsfile

# Install samtools v1.22 (release: 2025-05-30)
ENV SAMTOOLS_VERSION=1.22
RUN mkdir -p $SOFT/samtools-${SAMTOOLS_VERSION} && \
    cd $SOFT/samtools-${SAMTOOLS_VERSION} && \
    wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    tar -xjf samtools-${SAMTOOLS_VERSION}.tar.bz2 --strip-components=1 && \
    ./configure --prefix=$SOFT/samtools-${SAMTOOLS_VERSION} --with-htslib=$SOFT/htslib-${HTSLIB_VERSION} && \
    make -j$(nproc) && make install && \
    rm -rf samtools-${SAMTOOLS_VERSION}.tar.bz2

ENV PATH=$SOFT/samtools-${SAMTOOLS_VERSION}/bin:$PATH
ENV SAMTOOLS=$SOFT/samtools-${SAMTOOLS_VERSION}/bin/samtools
