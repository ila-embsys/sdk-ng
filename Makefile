PREFIX = /opt/zephyr-sdk
INSTALL := cp -lr

# If the first argument is "install"...
ifeq (install,$(firstword $(MAKECMDGOALS)))
# use the rest as arguments for "install"
INSTALL_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(INSTALL_ARGS):;@:)
endif

# Variables for "install_*" Make recipes
TARGET = ${1}
TRIPLET = $(TARGET)-zephyr-eabi
BUILD_OUT = build/output
PACKAGE_ROOT = ${BUILD_OUT}/${TRIPLET}
INSTALL_DIR = $(DESTDIR)$(PREFIX)

define install_target
install_$(1):

	@echo Processing reciepe: install_$(1)
	@echo Installing target: ${1}
	@echo Triplet: $(call TRIPLET,${1})
	@echo Package root: ${call PACKAGE_ROOT,${1}}
	@echo Install dir: $(call INSTALL_DIR,$(1))

	# target specific
	mkdir -p $(INSTALL_DIR)
	${INSTALL} ${PACKAGE_ROOT}/arm-zephyr-eabi	$(INSTALL_DIR)/
	${INSTALL} ${PACKAGE_ROOT}/bin $(INSTALL_DIR)/

	mkdir -p $(INSTALL_DIR)/lib	
	${INSTALL} ${PACKAGE_ROOT}/lib/gcc $(INSTALL_DIR)/lib/
	${INSTALL} ${PACKAGE_ROOT}/lib/ldscripts $(INSTALL_DIR)/lib/

	mkdir -p $(INSTALL_DIR)/libexec/gcc
	${INSTALL} ${PACKAGE_ROOT}/libexec/gcc/arm-zephyr-eabi $(INSTALL_DIR)/libexec/gcc/

	# not target specific?
	mkdir -p $(INSTALL_DIR)/share
	${INSTALL} ${PACKAGE_ROOT}/share/gcc-* $(INSTALL_DIR)/share/
	${INSTALL} ${PACKAGE_ROOT}/share/gdb $(INSTALL_DIR)/share/
	${INSTALL} ${PACKAGE_ROOT}/share/licenses $(INSTALL_DIR)/share/
endef

# Dependencies for 'install' recipe
ifdef INSTALL_ARGS
install_recipes := $(foreach T, $(INSTALL_ARGS), install_${T})
else
ifdef DESTDIR
DH_INSTALL_TARGET := $(notdir $(DESTDIR))
install_recipes := install_$(subst -zephyr-eabi,,${DH_INSTALL_TARGET})
endif
endif

# Generate Make recipes
$(foreach T, $(install_recipes), $(eval $(call install_target,$(subst install_,,${T}))))

all: build

install: ${install_recipes}

ifndef install_recipes
	@echo kek
endif
	

add_preloaded_sources:

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

add_ada_to_configs:

	./patch_configs_for_ada.sh


build: add_preloaded_sources add_ada_to_configs

	+ unset CFLAGS CXXFLAGS && CT_NG=ct-ng ./go.sh arm

clean:
	: # do nothing

distclean: clean

uninstall:
	: # do nothing

.PHONY: all add_preloaded_sources add_ada_to_configs build install clean distclean uninstall
