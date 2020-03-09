build-macos:
	rake host_clean
	mkdir -p /usr/local/opt/libressl/lib/dylibs
	(cd /usr/local/opt/libressl/lib && ls | grep .dylib | xargs -I@ mv /usr/local/opt/libressl/lib/@ /usr/local/opt/libressl/lib/dylibs/@)
	BUILD_TARGET=Darwin-x86_64 rake compile
	(cd /usr/local/opt/libressl/lib/dylibs && ls | grep .dylib | xargs -I@ mv /usr/local/opt/libressl/lib/dylibs/@ /usr/local/opt/libressl/lib/@)

ACLI_VERSION := $(shell sh -c 'cat .dockerdev/docker-compose.yml | grep "acli-dev" | sed "s/    image: palkan\/acli-dev://"')

anycable/acli-dev:
	docker push anycable/acli-dev:$(ACLI_VERSION)
	docker tag anycable/acli-dev:$(ACLI_VERSION) anycable/acli-dev:latest
	docker push anycable/acli-dev:latest
