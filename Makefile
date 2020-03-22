
src:
	wget https://github.com/sqlite/sqlite/archive/release.tar.gz -O- \
		| tar xvz

prereqs:
	sudo yum install readline-devel tcl-devel ctags

.ONESHELL:
normal:
	mkdir -p build
	pushd build
	../sqlite-release/configure \
		CFLAGS=-march=native \
		--prefix=/usr/local/sqlite-3.31.1a --enable-releasemode --enable-all  --enable-memsys5 --enable-tempstore
	$(MAKE) -C build --debug=bj
	$(MAKE) -C build --debug=bj quicktest

.ONESHELL:
build.small/sqlite3.c:
	mkdir -p build.small
	pushd build.small
	../sqlite-release/configure \
		CFLAGS=-march=native \
		--prefix=/usr/local/sqlite-3.31.1a --enable-releasemode --enable-all  --enable-memsys5 --enable-tempstore
	$(MAKE) -j
	tclsh8.6 ../sqlite-release/tool/mksqlite3c.tcl

kvtest: build.small/sqlite3.c
	gcc -Os -Ibuild.small/ -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION sqlite-release/test/kvtest.c build.small/sqlite3.c  -o $@

speedtest: build.small/sqlite3.c
	gcc -Os -Ibuild.small/ -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION sqlite-release/test/speedtest1.c build.small/sqlite3.c  -o $@

kvtest.db: kvtest
	./kvtest init $@ --count 100K --size 12K --variance 5K

runspeedtest: speedtest | kvtest.db
	./speedtest kvtest.db

.PHONY: amalgamation runspeedtest
