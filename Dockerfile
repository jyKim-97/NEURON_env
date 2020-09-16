FROM ubuntu:18.04
# usage: sudo docker build ./docker_test -t nrn:7.7

# set env params
ARG NRN_VERSION="7.7"
ARG NRN_ARCH="x86_64"
ARG NRN_CFLAGS="-O3"
ARG NRN_CXXFLAGS="-O3"
ARG NRN_CONFIG_OPT="--without-iv --with-nrnpython=python3.6 --with-paranrn --enable-static=yes"

RUN apt-get update
# install basic packages
RUN apt-get install -y \
 locales \
 zlib1g-dev \
 wget \
 gcc \
 g++ \
 build-essential \
 libncurses-dev # use to install neuron	

# install python
WORKDIR /usr/src
#RUN  wget https://www.python.org/ftp/python/3.6.10/Python-3.6.10.tgz \
#    && tar xzf Python-3.6.10.tgz \
#    && rm Python-3.6.10.tgz
#    && cd Python-3.6.10 \
#    && ./configure --enable-optimizations
#RUN make \
#    && make install
RUN apt-get install -y python3.6 libpython3.6-dev python3-pip
RUN apt-get install -y \
 cython3 \
 openmpi-bin \
 openmpi-common \
 libopenmpi-dev
RUN pip3 install --upgrade pip
# locale setting
# RUN localedef -cvi en_US -f UTF-8 en_US.UTF-8 -A /usr/share/locale/locale.alias
RUN locale-gen en_US.UTF-8

# working directory
RUN mkdir /work
WORKDIR /work

# install neuron 
RUN wget http://www.neuron.yale.edu/ftp/neuron/versions/v${NRN_VERSION}/nrn-${NRN_VERSION}.tar.gz
RUN tar xvzf nrn-${NRN_VERSION}.tar.gz
RUN rm nrn-${NRN_VERSION}.tar.gz
RUN ls
# RUN cd nrn-${NRN_VERSION}
WORKDIR /work/nrn-${NRN_VERSION}
RUN ./configure --prefix=/work/nrn-${NRN_VERSION} ${NRN_CONFIG_OPT} CFLAGS=${NRN_CFLAGS} CXXFLAGS=${NRN_CXXFLAGS}
RUN make && make install
RUN cd /work/nrn-${NRN_VERSION}/src/nrnpython \
 && python3 setup.py install

# set env params
RUN echo 'alias python="python3.6"' >> /root/.bashrc
RUN echo 'alias pip="pip3"' >> /root/.bashrc
RUN /bin/bash -c "source /root/.bashrc"

# add user
RUN useradd -m jungyoung
USER jungyoung

# set path
ENV LANG en_US.UTF-8
ENV PATH $PATH:/work/nrn-${NRN_VERSION}/x86_64/bin
