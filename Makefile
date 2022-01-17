PREFIX := /usr
BUILD_OUT := build/output/arm-zephyr-eabi
INSTALL := cp -lr


all: build

install:

	# target specific
	mkdir -p $(DESTDIR)$(PREFIX)
	${INSTALL} ${BUILD_OUT}/arm-zephyr-eabi	$(DESTDIR)$(PREFIX)/
	${INSTALL} ${BUILD_OUT}/bin $(DESTDIR)$(PREFIX)/

	mkdir -p $(DESTDIR)$(PREFIX)/lib	
	${INSTALL} ${BUILD_OUT}/lib/gcc $(DESTDIR)$(PREFIX)/lib/
	${INSTALL} ${BUILD_OUT}/lib/ldscripts $(DESTDIR)$(PREFIX)/lib/

	mkdir -p $(DESTDIR)$(PREFIX)/libexec/gcc
	${INSTALL} ${BUILD_OUT}/libexec/gcc/arm-zephyr-eabi $(DESTDIR)$(PREFIX)/libexec/gcc/

	# not target specific?
	mkdir -p $(DESTDIR)$(PREFIX)/share
	${INSTALL} ${BUILD_OUT}/share/gcc-* $(DESTDIR)$(PREFIX)/share/
	${INSTALL} ${BUILD_OUT}/share/gdb $(DESTDIR)$(PREFIX)/share/
	${INSTALL} ${BUILD_OUT}/share/licenses $(DESTDIR)$(PREFIX)/share/


build:
	mkdir -p build/output/sources

	# newlib-git.tar.bz2
	test -e build/output/sources/newlib-git-*.tar.bz2 || ln newlib-git-*.tar.bz2 build/output/sources/

	# newlib-nano-git.tar.bz2
	test -e build/output/sources/newlib-nano-git-*.tar.bz2 || ln newlib-nano-git-*.tar.bz2 build/output/sources/

	# binutils-git-c7d30a54fc1.tar.bz2
	test -e build/output/sources/binutils-git-*.tar.bz2 || ln binutils-git-*.tar.bz2 build/output/sources/

	# gcc-git-15e25dda.tar.bz2
	test -e build/output/sources/gcc-*.tar.bz2 || ln gcc-*.tar.bz2 build/output/sources/

	# expat-2.2.9.tar.xz
	test -e build/output/sources/expat-*.tar.xz || ln expat-*.tar.xz build/output/sources/

	# gdb-git-76b05e96250.tar.bz2
	test -e build/output/sources/gdb-git-*.tar.bz2 || ln gdb-git-*.tar.bz2 build/output/sources/

	# gmp-6.2.1.tar.xz
	test -e build/output/sources/gmp-*.tar.xz || ln gmp-*.tar.xz build/output/sources/

	# isl-0.22.tar.xz
	test -e build/output/sources/isl-*.tar.xz || ln isl-*.tar.xz build/output/sources/

	# mpc-1.2.0.tar.gz
	test -e build/output/sources/mpc-*.tar.gz || ln mpc-*.tar.gz build/output/sources/

	# mpfr-4.1.0.tar.xz
	test -e build/output/sources/mpfr-*.tar.xz || ln mpfr-*.tar.xz build/output/sources/

	# ncurses-6.2.tar.gz
	test -e build/output/sources/ncurses-*.tar.gz || ln ncurses-*.tar.gz build/output/sources/

	# zlib-1.2.11.tar.xz
	test -e build/output/sources/zlib-*.tar.xz || ln zlib-*.tar.xz build/output/sources/

	+ unset CFLAGS CXXFLAGS && CT_NG=ct-ng ./go.sh arm

clean:
	: # do nothing

distclean: clean

uninstall:
	: # do nothing

.PHONY: all build install clean distclean uninstall