FROM ubuntu:20.04

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

RUN apt update && \
    apt install -y --no-install-recommends \
        build-essential \
        wget \
    	curl \
    	tar \
    	cmake \
    	pkg-config \
    	zlib1g-dev \ 
    	libbz2-dev \
    	libcurl4-openssl-dev \
    	libncurses5-dev \
    	liblzma-dev \
    	python3 \
    	python3-pip \
    	python3-setuptools \
    	python3-dev \
    	ca-certificates && \
    pip3 install --no-cache-dir \
	pandas pysam && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

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

# Install bcftools v1.22 (release: 2025-05-30)
ENV BCFTOOLS_VERSION=1.22
RUN mkdir -p $SOFT/bcftools-${BCFTOOLS_VERSION} && \
    cd $SOFT/bcftools-${BCFTOOLS_VERSION} && \
    wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 && \
    tar -xjf bcftools-${BCFTOOLS_VERSION}.tar.bz2 --strip-components=1 && \
    ./configure --prefix=$SOFT/bcftools-${BCFTOOLS_VERSION} --with-htslib=$SOFT/htslib-${BCFTOOLS_VERSION} && \
    make -j$(nproc) && make install && \
    rm -rf bcftools-${BCFTOOLS_VERSION}.tar.bz2

ENV PATH=$SOFT/bcftools-${BCFTOOLS_VERSION}/bin:$PATH
ENV BCFTOOLS=$SOFT/bcftools-${BCFTOOLS_VERSION}/bin/bcftools

# Install vcftools v0.1.17 (release: 2025-05-15)
ENV VCFTOOLS_VERSION=0.1.17
RUN mkdir -p $SOFT/vcftools-${VCFTOOLS_VERSION} && \
    cd $SOFT && \
    wget https://github.com/vcftools/vcftools/releases/download/v${VCFTOOLS_VERSION}/vcftools-${VCFTOOLS_VERSION}.tar.gz && \
    tar -xzf vcftools-${VCFTOOLS_VERSION}.tar.gz && \
    cd vcftools-${VCFTOOLS_VERSION} && \
    ./configure --prefix=$SOFT/vcftools-${VCFTOOLS_VERSION} && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf vcftools-${VCFTOOLS_VERSION}.tar.gz

ENV PATH=$SOFT/vcftools-${VCFTOOLS_VERSION}/bin:$PATH
ENV VCFTOOLS=$SOFT/vcftools-${VCFTOOLS_VERSION}/bin/vcftools


# Add python script
COPY set_ref_alt.py /usr/local/bin/
RUN chmod +x /usr/local/bin/set_ref_alt.py
