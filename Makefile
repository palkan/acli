ifdef VERSION
else
	VERSION := $(shell sh -c 'git describe --always --tags')
endif

build-all:
	rm -rf ./dist
	rm -rf ./mruby/build/macos*
	rm -rf ./mruby/build/linux*
	rake host_clean
	BUILD_TARGET=darwin-x86_64 rake compile
	rake host_clean
	docker-compose run --rm -e BUILD_TARGET=linux-x86_64 compile

s3-deploy:
	aws s3 sync --acl=public-read ./dist "s3://acli/builds/$(VERSION)"

downloads-md:
	ruby etc/generate_downloads.rb

collect-bins:
	ruby etc/collect_bins.rb

release: build-all collect-bins s3-deploy downloads-md
