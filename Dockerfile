FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

ARG PROXY
ARG NO_PROXY
ARG APT_SERVER="http://jp.archive.ubuntu.com/ubuntu"

RUN echo Start! \
 && OPENCV_VERSION="3.3.1" \
 && COMMON_APT_PACKAGES="wget curl ca-certificates unzip git" \
 && BUILD_APT_PACKAGES="build-essential cmake ninja-build pkg-config" \
 && PYTHON_APT_PACKAGES="python python3 cython cython3 python-dev python3-dev python-pip python3-pip python-setuptools python3-setuptools python-wheel python3-wheel python-numpy python3-numpy python-scipy python3-scipy python-pandas python3-pandas python-matplotlib python3-matplotlib" \
 && OPENCV_APT_PACKAGES="libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev" \
 && APT_PACKAGE="${COMMON_APT_PACKAGES} ${BUILD_APT_PACKAGES} ${PYTHON_APT_PACKAGES} ${OPENCV_APT_PACKAGES}" \
 && PIP_PACKAGE="ipykernel jupyter tensorflow-gpu keras" \
 && if [ "x${PROXY}" != "x" ]; then export ftp_proxy="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export FTP_PROXY="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export http_proxy="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export HTTP_PROXY="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export https_proxy="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export HTTPS_PROXY="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export no_proxy="${NO_PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export NO_PROXY="${NO_PROXY}"; fi \
 && echo "deb ${APT_SERVER} xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb ${APT_SERVER} xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${APT_SERVER} xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && export DEBIAN_FRONTEND="noninteractive" \
 && export DEBIAN_PRIORITY="critical" \
 && export DEBCONF_NONINTERACTIVE_SEEN="true" \
 && apt-get -y update \
 && apt-get -y dist-upgrade \
 && apt-get -y --no-install-recommends install ${APT_PACKAGE} \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
 && wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
 && unzip ${OPENCV_VERSION}.zip \
 && cd opencv-${OPENCV_VERSION} \
 && mkdir build \
 && cd build \
 && cmake -G Ninja -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local .. \
 && ninja \
 && ninja install \
 && cd ../.. \
 && rm -fr opencv-${OPENCV_VERSION} \
 && rm ${OPENCV_VERSION}.zip \
 && python2 -m pip install --upgrade pip \
 && python3 -m pip install --upgrade pip \
 && python2 -m pip install ${PIP_PACKAGE} \
 && python3 -m pip install ${PIP_PACKAGE} \
 && python2 -m ipykernel install --user \
 && python3 -m ipykernel install --user \
 && echo Complete!

CMD ["jupyter", "notebook", "--no-browser", "--allow-root", "--notebook-dir='/root'", "--ip='0.0.0.0'"]
