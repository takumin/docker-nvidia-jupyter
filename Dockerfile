FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

MAINTAINER Takumi Takahashi <takumiiinn@gmail.com>

ARG PROXY
ARG NO_PROXY
ARG UBUNTU_MIRROR="http://jp.archive.ubuntu.com/ubuntu"
ARG NVIDIA_CUDA_MIRROR="http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64"
ARG NVIDIA_ML_MIRROR="http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64"

RUN echo Start! \
 && APT_PACKAGES="python python3 python-dev python3-dev python-pip python3-pip libhdf5-dev openmpi-bin" \
 && PIP_PACKAGES="cython six ipykernel ipyparallel jupyter numpy scipy scikit-learn pandas matplotlib pillow h5py tensorflow-gpu chainer cupy keras" \
 && if [ "x${PROXY}" != "x" ]; then export ftp_proxy="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export FTP_PROXY="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export http_proxy="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export HTTP_PROXY="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export https_proxy="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export HTTPS_PROXY="${PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export no_proxy="${NO_PROXY}"; fi \
 && if [ "x${PROXY}" != "x" ]; then export NO_PROXY="${NO_PROXY}"; fi \
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
 && apt-get clean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
 && python2 -m pip --no-cache-dir install --upgrade pip setuptools wheel \
 && python3 -m pip --no-cache-dir install --upgrade pip setuptools wheel \
 && python2 -m pip --no-cache-dir install ${PIP_PACKAGES} \
 && python3 -m pip --no-cache-dir install ${PIP_PACKAGES} \
 && python2 -m pip --no-cache-dir install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master \
 && python3 -m pip --no-cache-dir install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master \
 && python2 -m pip --no-cache-dir install jupyter-tensorboard \
 && python3 -m pip --no-cache-dir install jupyter-tensorboard \
 && python2 -m pip --no-cache-dir install https://cntk.ai/PythonWheel/GPU-1bit-SGD/cntk-2.3-cp27-cp27mu-linux_x86_64.whl \
 && python3 -m pip --no-cache-dir install https://cntk.ai/PythonWheel/GPU-1bit-SGD/cntk-2.3-cp35-cp35m-linux_x86_64.whl \
 && python2 -m ipykernel install --sys-prefix \
 && python3 -m ipykernel install --sys-prefix \
 && jupyter contrib nbextension install --sys-prefix --symlink \
 && jupyter nbextension install --py ipyparallel --sys-prefix \
 && jupyter nbextension enable --py ipyparallel --sys-prefix \
 && jupyter serverextension enable --py ipyparallel --sys-prefix \
 && mkdir /etc/jupyter \
 && echo "# Jupyter Notebook Configuration"             >  /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.ip = '*'"                       >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.port = 8888"                    >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.open_browser = False"           >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.notebook_dir = '/home/jupyter'" >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.token = ''"                     >> /etc/jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.password = ''"                  >> /etc/jupyter/jupyter_notebook_config.py \
 && adduser --disabled-password --gecos "Jupyter Notebook,,," --shell /bin/bash jupyter \
 && echo Complete!

COPY notebook/ /home/jupyter/
RUN chown -R jupyter:jupyter /home/jupyter

USER jupyter
CMD ["env", "SHELL=/bin/bash", "jupyter", "notebook"]
EXPOSE 8888
