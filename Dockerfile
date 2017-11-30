FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

ARG PROXY
ARG NO_PROXY
ARG APT_SERVER="http://jp.archive.ubuntu.com/ubuntu"

RUN echo Start! \
 && APT_PACKAGES="python python3 python-dev python3-dev python-pip python3-pip libhdf5-dev" \
 && PIP_PACKAGES="cython six ipykernel jupyter numpy scipy scikit-learn pandas matplotlib pillow h5py tensorflow-gpu chainer cupy keras" \
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
 && apt-get -y --no-install-recommends install ${APT_PACKAGES} \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
 && python2 -m pip --no-cache-dir install --upgrade pip setuptools wheel \
 && python3 -m pip --no-cache-dir install --upgrade pip setuptools wheel \
 && python2 -m pip --no-cache-dir install ${PIP_PACKAGES} \
 && python3 -m pip --no-cache-dir install ${PIP_PACKAGES} \
 && python2 -m ipykernel install --user \
 && python3 -m ipykernel install --user \
 && mkdir /etc/jupyter \
 && echo "# Jupyter Notebook Configuration"     >  /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.ip = '*'"               >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.port = 8888"            >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.open_browser = False"   >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.allow_root = True"      >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.notebook_dir = '/root'" >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.token = ''"             >> /etc/jupyter/jupyter_notebook_config.py \
 && echo Complete!

CMD ["jupyter", "notebook"]
