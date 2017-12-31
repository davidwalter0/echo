# To enable kubernetes commands a valid configuration is required
export GOPATH=/go
export kubectl=${GOPATH}/bin/kubectl  --kubeconfig=${PWD}/cluster/auth/kubeconfig
SHELL=/bin/bash
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CURRENT_DIR := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_DIR))))
export DIR=$(MAKEFILE_DIR)

.PHONY: deps install clean image build push test

build_deps:=$(wildcard *.go)
target:=bin/$(notdir $(PWD))

all: $(target)
	@echo Target $(target)
	@echo Build deps $(build_deps)
	@echo Depends $(depends)

etags:
	etags $(depends) $(build_deps)

.dep: $(target) $(depends) Makefile
	touch .dep

build: $(target)

$(target): $(build_deps) $(depends) Makefile
	@echo "Building via % rule for $@ from $<"
	@echo $(depends)
	@if go version|grep -q 1.4 ; then														\
	    . .version;																	\
	    args="-s -w -X main.Version $${version} -X main.Build $$(date -u +%Y.%m.%d.%H.%M.%S.%:::z) -X main.Commit $$(git log --format=%h-%aI -n1)";	\
	else																		\
	    . .version;																	\
	    args="-s -w -X main.Version=$${version} -X main.Build=$$(date -u +%Y.%m.%d.%H.%M.%S.%:::z) -X main.Commit=$$(git log --format=%h-%aI -n1)";	\
	fi;																		\
	echo CGO_ENABLED=0 go build --tags netgo -ldflags "$${args}" -o $@ $(build_deps) ;								\
	CGO_ENABLED=0 go build --tags netgo -ldflags "$${args}" -o $@ $(build_deps) ;

install: build
	cp $(target) /go/bin/

image: build
	docker build --tag=davidwalter/$(notdir $(PWD)):latest .
	. .version; \
	docker tag davidwalter/$(notdir $(PWD)):latest \
	davidwalter/$(notdir $(PWD)):$${version}

push: image
	docker push davidwalter/$(notdir $(PWD)):latest
	. .version; \
	docker push davidwalter/$(notdir $(PWD)):$${version}

delete:
	$(kubectl) delete ds/forwarder || true

apply:
	$(kubectl) apply -f daemonset.yaml

clean:
	@if [[ -x "$(target)" ]]; then rm -f $(target) ; fi
	@if [[ -d "bin" ]]; then rmdir bin; fi
