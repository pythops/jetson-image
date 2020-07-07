DOCKER ?= docker
CURRENT_USER := --match-uid #-u `id -u`:`id -g`

build.builder-image:
	$(DOCKER) build -t jetson-img-builder .

run.qemu-static:
	sudo $(DOCKER) run --rm --privileged multiarch/qemu-user-static:register

build.image:
	./create-rootfs.sh
	cd ansible
	ansible-playbook jetson.yml
	cd ..
	./create-image.sh

build: run.qemu-static build.builder-image
	mkdir build || true
	$(DOCKER) run $(CURRENT_USER)  --rm -it -v $(shell pwd)/build:/build:rw jetson-img-builder -- "make build.image"