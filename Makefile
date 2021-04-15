.DEFAULT_GOAL := runspeedtest
SRC_DIR       := sqlite-release
SRC_FILE      := build.small/sqlite3.c
CC			  := gcc


#.ONESHELL:
#normal: src
#	mkdir -p build
#	pushd build
#	../sqlite-release/configure \
#		CFLAGS=-march=native \
#		--prefix=/usr/local/sqlite-3.31.1a --enable-releasemode --enable-all  --enable-memsys5 --enable-tempstore
#	$(MAKE) -C . --debug=bj
#
#normaltest:
#	$(MAKE) -C . --debug=bj quicktest


### try prebuilt:
### https://www.sqlite.org/2021/sqlite-tools-linux-x86-3350400.zip
.ONESHELL:
$(SRC_FILE): $(SRC_DIR)
	### https://www.sqlite.org/compile.html#rcmd
	### https://www.sqlite.org/howtocompile.html
	### hardening options to try for GCC 10:
	### https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc/
	### https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html
	### https://github.com/decalage2/awesome-security-hardening/blob/master/README.md
	mkdir -p build.small
	pushd build.small
	../$(SRC_DIR)/configure \
		CFLAGS='-march=native -D_FORTIFY_SOURCE=2 -O2' \
		--prefix=/usr/local/sqlite3 \
		--with-pic \
		--enable-releasemode \
		--enable-all \
		--enable-memsys5 \
		--enable-tempstore
	$(MAKE) -j
	#tclsh8.6 ../$(SRC_DIR)/tool/mksqlite3c.tcl

small.test: $(SRC_FILE)
	$(MAKE) -C . --debug=bj quicktest

kvtest: $(SRC_FILE)
	$(CC) -O3 -Ibuild.small/ -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION $(SRC_DIR)/test/kvtest.c $^  -o $@

speedtest: $(SRC_FILE)
	$(CC) -O3 -Ibuild.small/ -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION $(SRC_DIR)/test/speedtest1.c $^ -o $@

kvtest.db: kvtest
	./$^ init $@ --count 100K --size 12K --variance 5K

runspeedtest: speedtest | kvtest.db
	./speedtest kvtest.db

$(SRC_DIR):
	wget -q -nv https://github.com/sqlite/sqlite/archive/release.tar.gz -O- \
		| tar xvz

test:
	### needs to run as NONroot, but needs write perms to /APP/build.small/
	sudo -u nobody make -C build.small/ test

dockerbuild:
	docker build -t centos:8dev .
	-docker container rm centos8dev
	docker run -it --name centos8dev  centos:8dev

.PHONY: runspeedtest normal
