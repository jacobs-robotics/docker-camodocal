FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

MAINTAINER Arturo Gomez Chavez "a.gomezchavez@jacobs-university.de"

# setup environment
RUN apt-get clean && apt-get update && apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# create user folders
RUN mkdir -p $HOME/input_data
RUN mkdir -p $HOME/output_data

# upgrade existing packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# install necessary packages for OpenCV/Ceres/CamoDocal
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends \
    wget \
    build-essential \
	ca-certificates \
	libtiff5-dev \
	libv4l-dev \
	libatlas-base-dev \
	libgtk2.0-dev \
	gfortran \
	git \
	cmake \
    libblas-dev \
	libgoogle-glog-dev \
	libsuitesparse-dev \
	libboost-dev \	
	libboost-all-dev \
	pkg-config \
    && rm -rf /var/lib/apt/lists/*

# install eigen library needed by cered <-- 3.2.10 is the one reported to work best without bugs
WORKDIR /root
RUN wget https://gitlab.com/libeigen/eigen/-/archive/3.2.10/eigen-3.2.10.tar.gz
RUN tar zxf eigen-3.2.10.tar.gz
RUN mkdir eigen-bin && cd eigen-bin && cmake ../eigen-3.2.10
RUN cd eigen-bin && make -j6 install 

# install ceres library for camodocal <-- version 1.11.0 is the one reported to work best without bugs
RUN wget http://ceres-solver.org/ceres-solver-1.11.0.tar.gz
RUN tar zxf ceres-solver-1.11.0.tar.gz
RUN mkdir ceres-bin && cd ceres-bin && cmake ../ceres-solver-1.11.0
RUN cd ceres-bin && make -j6
RUN cd ceres-bin && make install 

# download OpenCV <-- 3.4.7 version is the latest check work with ceres and camodocal without error
RUN git clone https://github.com/opencv/opencv.git
RUN git clone https://github.com/opencv/opencv_contrib.git
RUN cd opencv && git checkout 3.4.7
RUN cd opencv_contrib && git checkout 3.4.7

# copy script to install OpenCV
COPY make_opencv.sh /root
RUN chmod a+x $HOME/make_opencv.sh 
RUN /bin/bash -c ". $HOME/make_opencv.sh"

# downlaod and install camodocal
RUN git clone https://github.com/hengli/camodocal.git
COPY make_camodocal.sh /root
RUN chmod a+x $HOME/make_camodocal.sh 
RUN /bin/bash -c ". $HOME/make_camodocal.sh"

# libdc1394 does not work in Docker, so disable it (we anyways don't need it in here)
RUN ln /dev/null /dev/raw1394 && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get remove -q -y libgtk2.0-dev
#Manual fix to prevent GTK errors
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends libgtk2.0-dev -qqy x11-apps


