build-macos:
	rake host_clean
	mkdir -p /usr/local/opt/libressl/lib/dylibs
	(cd /usr/local/opt/libressl/lib && ls | grep .dylib | xargs -I@ mv /usr/local/opt/libressl/lib/@ /usr/local/opt/libressl/lib/dylibs/@)
	BUILD_TARGET=Darwin-x86_64 rake compile
	(cd /usr/local/opt/libressl/lib/dylibs && ls | grep .dylib | xargs -I@ mv /usr/local/opt/libressl/lib/dylibs/@ /usr/local/opt/libressl/lib/@)
