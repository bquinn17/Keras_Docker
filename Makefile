help:
	@cat Makefile

# DATA?="${HOME}/Data"
DATA?=/data/bryan
GPU?=all
DOCKER_FILE=Dockerfile
DOCKER=docker
BACKEND=tensorflow
PYTHON_VERSION?=3.6
CUDA_VERSION?=10.1
CUDNN_VERSION?=7
TEST=tests/
# SRC?=$(shell dirname `pwd`)
SRC?=/home/bryan/projects/
VISIBLE_GPUS?=0,1,2,3,4,5,6,7

reset:
	docker build --no-cache -t keras --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) -f $(DOCKER_FILE) .

build:
	docker build -t keras --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run --rm --name keras --gpus $(GPU) -it -v $(SRC):/src/workspace -v $(DATA):/data --env KERAS_BACKEND=$(BACKEND) NVIDIA_VISIBLE_DEVICES=$(VISIBLE_GPUS) keras /bin/bash

ipython: build
	$(DOCKER) run --rm --name keras --gpus $(GPU) -it -v $(SRC):/src/workspace -v $(DATA):/data --env KERAS_BACKEND=$(BACKEND) keras ipython

notebook:
	$(DOCKER) run --rm --name keras --gpus $(GPU) -it -v $(SRC):/src/workspace -v $(DATA):/data -p 8888:8888 --env KERAS_BACKEND=$(BACKEND) keras:stable

test: build
	$(DOCKER) run --rm --name keras --gpus $(GPU) -it -v $(SRC):/src/workspace -v $(DATA):/data --env KERAS_BACKEND=$(BACKEND) keras py.test $(TEST)
