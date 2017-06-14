ifdef VERSION
else
	VERSION := $(shell sh -c 'git describe --always --tags')
endif

build-all: clean-all build-macos build-linux

clean-all:
	rm -rf ./dist
	rm -rf ./mruby/build/macos*
	rm -rf ./mruby/build/linux*

build-macos:
	rake host_clean
	mkdir -p /usr/local/opt/libressl/lib/dylibs
	(cd /usr/local/opt/libressl/lib && ls | grep .dylib | xargs -I@ mv /usr/local/opt/libressl/lib/@ /usr/local/opt/libressl/lib/dylibs/@)
	BUILD_TARGET=darwin-x86_64 rake compile
	(cd /usr/local/opt/libressl/lib/dylibs && ls | grep .dylib | xargs -I@ mv /usr/local/opt/libressl/lib/dylibs/@ /usr/local/opt/libressl/lib/@)

build-linux:
	rake host_clean
	docker-compose run --rm -e BUILD_TARGET=linux-x86_64 compile

s3-deploy:
	aws s3 sync --acl=public-read ./dist "s3://acli/builds/$(VERSION)"

downloads-md:
	ruby etc/generate_downloads.rb

collect-bins:
	ruby etc/collect_bins.rb

release: build-all collect-bins s3-deploy downloads-md
