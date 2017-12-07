ARGS ?= --no-cache

ifneq (x${NO_PROXY},x)
ARGS += --build-arg NO_PROXY=${NO_PROXY}
endif

ifneq (x${FTP_PROXY},x)
ARGS += --build-arg FTP_PROXY=${FTP_PROXY}
endif

ifneq (x${HTTP_PROXY},x)
ARGS += --build-arg HTTP_PROXY=${HTTP_PROXY}
endif

ifneq (x${HTTPS_PROXY},x)
ARGS += --build-arg HTTPS_PROXY=${HTTPS_PROXY}
endif

ifneq (x${UBUNTU_MIRROR},x)
ARGS += --build-arg UBUNTU_MIRROR=${UBUNTU_MIRROR}
endif

ifneq (x${NVIDIA_CUDA_MIRROR},x)
ARGS += --build-arg NVIDIA_CUDA_MIRROR=${NVIDIA_CUDA_MIRROR}
endif

ifneq (x${NVIDIA_ML_MIRROR},x)
ARGS += --build-arg NVIDIA_ML_MIRROR=${NVIDIA_ML_MIRROR}
endif

.PHONY: build
build:
	@docker build $(ARGS) -t takumin/nvidia-jupyter .

.PHONY: run
run:
	@docker run --runtime=nvidia --name jupyter -p 8888:8888 -d takumin/nvidia-jupyter

.PHONY: clean
clean:
	@docker rmi takumin/nvidia-jupyter
