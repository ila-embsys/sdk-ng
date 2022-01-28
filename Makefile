# To use default build targets (arm, riscv64)
# call `make` or `make build`
# it also build `cmake`
#
# You can specify target for building
# through call `make build arm` or `make build riscv64`
# it also build `cmake`
#
# To install built default targets (arm, riscv64)
# call `make install`
# it copy built files to `${PREFIX}/zephyr/<target-triplet>`
# (default PREFIX is /opt)
#
# To install specified targets
# use `make install arm` or `make install riscv64`
# it copy target files to `${PREFIX}/zephyr



PREFIX = /opt
INSTALL := cp -lr

# If arguments set. E.g. `make build` or `make install`
ifneq (,$(MAKECMDGOALS))
# If the first argument are "install" or "build"...
ifneq (,$(filter $(firstword $(MAKECMDGOALS)),install build))
# Use the rest as targets
# E.g. `make build arm` or `make install riscv64`
TARGETS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(TARGETS):;@:)
else
endif
endif

# Variables for "install_*" Make recipes
TARGET = ${1}
TRIPLET = $(TARGET)-zephyr-eabi
BUILD_OUT = build/output
PACKAGE_ROOT = ${BUILD_OUT}/${TRIPLET}
INSTALL_DIR = $(DESTDIR)$(PREFIX)/zephyr-sdk

define install_target

.PHONY: install_$(1)

install_$(1):

	@echo Processing the recipe: install_$(1)
	@echo Installing target: ${1}
	@echo Triplet: $(call TRIPLET,${1})
	@echo Package root: ${call PACKAGE_ROOT,${1}}
	@echo Install dir: $(call INSTALL_DIR,$(1))

	# target specific
	mkdir -p $(INSTALL_DIR)
	${INSTALL} ${PACKAGE_ROOT}/${TRIPLET}	$(INSTALL_DIR)/
	${INSTALL} ${PACKAGE_ROOT}/bin $(INSTALL_DIR)/

	mkdir -p $(INSTALL_DIR)/lib	
	${INSTALL} ${PACKAGE_ROOT}/lib/gcc $(INSTALL_DIR)/lib/
	${INSTALL} ${PACKAGE_ROOT}/lib/ldscripts $(INSTALL_DIR)/lib/

	mkdir -p $(INSTALL_DIR)/libexec/gcc
	${INSTALL} ${PACKAGE_ROOT}/libexec/gcc/${TRIPLET} $(INSTALL_DIR)/libexec/gcc/

	# not target specific?
	mkdir -p $(INSTALL_DIR)/share
	${INSTALL} ${PACKAGE_ROOT}/share/gcc-* $(INSTALL_DIR)/share/
	${INSTALL} ${PACKAGE_ROOT}/share/gdb $(INSTALL_DIR)/share/
	${INSTALL} ${PACKAGE_ROOT}/share/licenses $(INSTALL_DIR)/share/

	${INSTALL} VERSION ${PACKAGE_ROOT}/sdk_version
endef

# Dependencies for 'install' recipe
ifneq (,${TARGETS})
# Generate install recipes for selected targets
install_target_recipes := $(foreach T, $(TARGETS), install_${T})
else
# If no targets specifies, try guess from DESTDIR
ifneq (,${DESTDIR})
DESTDIR_NAME := $(notdir $(DESTDIR))
ifneq (,$(findstring -zephyr-eabi,$(DESTDIR_NAME)))
GUESSED_TARGET := $(subst -zephyr-eabi,,${DESTDIR_NAME})
install_target_recipes := install_${GUESSED_TARGET}
endif
endif
endif

# Default targets if called
# `make`, `make build` or `make install`
# without specify targets
ifeq (,$(TARGETS))
TARGETS := arm riscv64
endif

all: build

# Generate Make recipes
$(foreach T, $(install_target_recipes), $(eval $(call install_target,$(subst install_,,${T}))))

# Default install recipes
ifeq (,${install_target_recipes})
install_target_recipes := install_targets
endif

install_cmake:

	@echo Processing the recipe: install_cmake
	@echo Going to install CMake

	mkdir -p $(INSTALL_DIR)
	${INSTALL} cmake $(INSTALL_DIR)/zephyr-sdk-cmake

install_every_target:

	@echo Processing the recipe: install_every_target as build without filtering folders
	@echo Going to find built targets and install them

	find ${BUILD_OUT} -maxdepth 1 -name "*-zephyr-eabi" -execdir mkdir -p $(INSTALL_DIR)/'{}' \;
	find ${BUILD_OUT} -maxdepth 1 -name "*-zephyr-eabi" -exec ${INSTALL} '{}' $(INSTALL_DIR)/ \;
	find ${BUILD_OUT} -maxdepth 1 -name "*-zephyr-elf" -exec ${INSTALL} '{}' $(INSTALL_DIR)/ \;

install_common:

	if [ ! $(diff -x 'gdbinit' -r $(INSTALL_DIR)/*-zephyr-*/share) ]; then \
		echo "All toolchain's 'share' directory equal. Install as common package 'zephyr-sdk-gdb'"; \
		mkdir -p $(INSTALL_DIR)/zephyr-sdk-gdb; \
		ls ${BUILD_OUT} \
		| sort \
		| grep -e '^.*\-zephyr\-.*$$' \
		| head -n 1 \
		| sed 's@^@'"${BUILD_OUT}"'\/@' \
		| sed 's/$$/\/share/' \
		| xargs ${INSTALL} -t $(INSTALL_DIR)/zephyr-sdk-gdb/; \
		\
		mkdir -p $(INSTALL_DIR)/zephyr-sdk-licenses/share/; \
		mv $(INSTALL_DIR)/zephyr-sdk-gdb/share/licenses/ $(INSTALL_DIR)/zephyr-sdk-licenses/share/licenses; \
	else \
		echo "Not all toolchain's 'share' directory equal. Can not install as common package"; \
	fi

	mkdir -p $(INSTALL_DIR)/zephyr-sdk-version;
	${INSTALL} VERSION $(INSTALL_DIR)/zephyr-sdk-version/sdk_version

install_targets: install_every_target install_common

install: ${install_target_recipes} install_cmake

ifndef install_target_recipes
	@echo No install target specified
	@echo Going to install everything built target, CMake and hosttools to DESTDIR
	@echo To install specific target use command: make install target1 target2
	@echo Example: make install arm riscv64
	@echo If variable DESTDIR defined with last dir like arm-none-eabi
	@echo it will work as: make install arm
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

	+ unset CFLAGS CXXFLAGS && CT_NG=ct-ng ./go.sh ${TARGETS}

clean:
	: # do nothing

distclean: clean

uninstall:
	: # do nothing

.PHONY: all install_cmake install_every_target install_common install_targets add_preloaded_sources add_ada_to_configs build install clean distclean uninstall
