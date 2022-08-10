HOMEBREW_PREFIX ?= "/usr/local"

build-macos:
	rake host_clean
	mkdir -p $(HOMEBREW_PREFIX)/opt/libressl/lib/dylibs
	(cd $(HOMEBREW_PREFIX)/opt/libressl/lib && ls | grep .dylib | xargs -I@ mv $(HOMEBREW_PREFIX)/opt/libressl/lib/@ $(HOMEBREW_PREFIX)/opt/libressl/lib/dylibs/@)
	BUILD_TARGET=Darwin-x86_64 rake compile
	(cd $(HOMEBREW_PREFIX)/opt/libressl/lib/dylibs && ls | grep .dylib | xargs -I@ mv $(HOMEBREW_PREFIX)/opt/libressl/lib/dylibs/@ $(HOMEBREW_PREFIX)/opt/libressl/lib/@)

ACLI_VERSION := $(shell sh -c 'cat .dockerdev/docker-compose.yml | grep "acli-dev" | sed "s/    image: palkan\/acli-dev://"')

anycable/acli-dev:
	docker push anycable/acli-dev:$(ACLI_VERSION)
	docker tag anycable/acli-dev:$(ACLI_VERSION) anycable/acli-dev:latest
	docker push anycable/acli-dev:latest
