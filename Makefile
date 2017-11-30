ifneq (x${http_proxy},x)
ARGS = --build-arg PROXY=${http_proxy}
endif

ifneq (x${APT_SERVER},x)
ARGS += --build-arg APT_SERVER=${APT_SERVER}
endif

.PHONY: build
build:
	@docker build --no-cache $(ARGS) -t takumin/nvidia-jupyter .

.PHONY: clean
clean:
	@docker rmi takumin/nvidia-jupyter
