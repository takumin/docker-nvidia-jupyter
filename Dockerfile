FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

ARG NO_PROXY
ARG FTP_PROXY
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG UBUNTU_MIRROR="http://jp.archive.ubuntu.com/ubuntu"
ARG NVIDIA_CUDA_MIRROR="http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64"
ARG NVIDIA_ML_MIRROR="http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64"
ARG PIP_CACHE_HOST
ARG PIP_CACHE_PORT="3141"

RUN echo Start! \
 && APT_PACKAGES="python python3 python-dev python3-dev python-pip python3-pip nodejs-legacy npm libhdf5-dev openmpi-bin" \
 && PIP_PACKAGES="cython six ipython==5.5.0 ipykernel ipyparallel jupyter numpy scipy scikit-learn pandas matplotlib pillow h5py tensorflow-gpu chainer cupy keras" \
 && USER_ID_LIST="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30" \
 && if [ "x${NO_PROXY}" != "x" ]; then export no_proxy="${NO_PROXY}"; fi \
 && if [ "x${FTP_PROXY}" != "x" ]; then export ftp_proxy="${FTP_PROXY}"; fi \
 && if [ "x${HTTP_PROXY}" != "x" ]; then export http_proxy="${HTTP_PROXY}"; fi \
 && if [ "x${HTTPS_PROXY}" != "x" ]; then export https_proxy="${HTTPS_PROXY}"; fi \
 && if [ "x${PIP_CACHE_HOST}" != "x" ]; then export PIP_TRUSTED_HOST="${PIP_CACHE_HOST}"; export PIP_INDEX_URL="http://${PIP_CACHE_HOST}:${PIP_CACHE_PORT}/root/pypi/"; fi \
 && echo "deb ${UBUNTU_MIRROR} xenial          main restricted universe multiverse" >  /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-updates  main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${UBUNTU_MIRROR} xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb ${NVIDIA_CUDA_MIRROR} /" > /etc/apt/sources.list.d/cuda.list \
 && echo "deb ${NVIDIA_ML_MIRROR} /" > /etc/apt/sources.list.d/nvidia-ml.list \
 && export DEBIAN_FRONTEND="noninteractive" \
 && export DEBIAN_PRIORITY="critical" \
 && export DEBCONF_NONINTERACTIVE_SEEN="true" \
 && apt-get -y update \
 && apt-get -y dist-upgrade \
 && apt-get -y --no-install-recommends install ${APT_PACKAGES} \
 && apt-get clean autoclean \
 && apt-get autoremove --purge -y \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
 && python2 -m pip --no-cache-dir install --upgrade pip setuptools wheel \
 && python3 -m pip --no-cache-dir install --upgrade pip setuptools wheel \
 && python2 -m pip --no-cache-dir install ${PIP_PACKAGES} \
 && python3 -m pip --no-cache-dir install ${PIP_PACKAGES} \
 && python2 -m pip --no-cache-dir install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master \
 && python3 -m pip --no-cache-dir install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master \
 && python2 -m pip --no-cache-dir install https://cntk.ai/PythonWheel/GPU-1bit-SGD/cntk-2.3.1-cp27-cp27mu-linux_x86_64.whl \
 && python3 -m pip --no-cache-dir install https://cntk.ai/PythonWheel/GPU-1bit-SGD/cntk-2.3.1-cp35-cp35m-linux_x86_64.whl \
 && python2 -m pip --no-cache-dir install jupyter-tensorboard \
 && python3 -m pip --no-cache-dir install jupyter-tensorboard \
 && python3 -m pip --no-cache-dir install jupyterhub \
 && python2 -m ipykernel install --sys-prefix \
 && python3 -m ipykernel install --sys-prefix \
 && jupyter contrib nbextension install --sys-prefix --symlink \
 && jupyter nbextension install --py ipyparallel --sys-prefix \
 && jupyter nbextension enable --py ipyparallel --sys-prefix \
 && jupyter serverextension enable --py ipyparallel --sys-prefix \
 && npm install -g configurable-http-proxy \
 && npm cache clean \
 && mkdir /etc/jupyterhub \
 && echo "# JupyterHub Configuration"                   >  /etc/jupyterhub/jupyterhub_config.py \
 && echo "c.Authenticator.admin_users = set(['admin'])" >> /etc/jupyterhub/jupyterhub_config.py \
 && echo "c.Spawner.notebook_dir = '~/Notebook'"        >> /etc/jupyterhub/jupyterhub_config.py \
 && mkdir /etc/skel/Notebook \
 && useradd -U -m -s /bin/bash admin; echo admin:admin | chpasswd \
 && for i in ${USER_ID_LIST}; do useradd -U -m -s /bin/bash user$i; echo user$i:user$i | chpasswd; done \
 && echo Complete!

CMD ["jupyterhub", "-f", "/etc/jupyterhub/jupyterhub_config.py"]
EXPOSE 8000
