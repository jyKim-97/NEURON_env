FROM ubuntu:16.04
# sudo docker build ./docker_test -t nrn:7.7

ARG NRN_VERSION="7.7"
ARG NRN_ARCH="x86_64"
ARG NRN_CONFIGURE_OPT="--without-iv --with-nrnpython=/usr/local/bin/python3 --with-paranrn --enable-static=yes"
ARG NRN_CFLAGS="-O3"
ARG NRN_CXXFLAGS="-O3"

RUN mkdir /work
WORKDIR /work

RUN echo "apt-get install"
RUN apt-get update \
    && apt-get install -y \
        locales \
        zlib1g-dev \
        wget \
        gcc \
        g++ \
        build-essential \
        libncurses-dev
# python3.6 \

RUN echo "python env"
WORKDIR /usr/src
RUN  wget https://www.python.org/ftp/python/3.6.10/Python-3.6.10.tgz \
    && tar xzf Python-3.6.10.tgz \
    && rm Python-3.6.10.tgz
    && cd Python-3.6.10 \
    && ./configure --enable-optimizations
RUN make \
    && make install

RUN echo "neuron env"
WORKDIR /work
RUN apt-get install -y \
    python3-pip \
    libpython3-dev \
    cython3 \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev \
    && localedef -cvi en_US -f UTF-8 en_US.UTF-8 -A /usr/share/locale/locale.alias  \
    && pip3 install --upgrade pip \
# install neuron
    && wget http://www.neuron.yale.edu/ftp/neuron/versions/v${NRN_VERSION}/nrn-${NRN_VERSION}.tar.gz \
    && tar xvzf nrn-${NRN_VERSION}.tar.gz \
    && rm nrn-${NRN_VERSION}.tar.gz \
    && cd nrn-${NRN_VERSION} \
    && ./configure --prefix=`pwd` ${NRN_CONFIGURE_OPT} CFLAGS=${NRN_CFLAGS} CXXFLAGS=${NRN_CXXFLAGS} \
    && make \
    && make install \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoclean

RUN cd /work/nrn-${NRN_VERSION}/src/nrnpython \
    && python3 setup.py install

RUN \
   echo 'alias python="/usr/local/bin/python3"' >> /root/.bashrc && \
   echo 'alias pip="/usr/local/bin/pip3"' >> /root/.bashrc && \
   source /root/.bashrc

# finish
RUN useradd -m jungyoung
USER jungyoung

ENV LANG en_US.utf8
ENV PATH $PATH:/work/nrn-${NRN_VERSION}/x86_64/bin

