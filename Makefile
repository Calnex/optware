# Makefile for Optware packages
#
# Copyright (C) 2004 by Rod Whitby <unslung@gmail.com>
# Copyright (C) 2004 by Oleg I. Vdovikin <oleg@cs.msu.su>
# Copyright (C) 2001-2004 Erik Andersen <andersen@codepoet.org>
# Copyright (C) 2002 by Tim Riker <Tim@Rikers.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

# one of `ls platforms/toolchain-*.mk | sed 's|^platforms/toolchain-\(.*\)\.mk$$|\1|'`
OPTWARE_TARGET ?= Springbank

# Add new packages here - make sure you have tested compilation.
# When they have been tested, they will be promoted and uploaded.
#
PACKAGES_READY_FOR_TESTING = 

# Document issues for broken packages here.
#
PACKAGES_THAT_NEED_TO_BE_FIXED = 

# libao - has runtime trouble?
COMMON_CROSS_PACKAGES = c-ares \
			geoip \
			gettext \
			glib \
			gnutls \
			ipkg-opt \
			ipkg-utils \
			ipkg-web \
			libffi \
			libgcrypt \
			libgmp \
			libgpg-error \
			libidn \
			libpcap \
			libstdc++ \
			libtasn1 \
			mono \
			nettle \
			openssl \
			optware-bootstrap\
			pcre \
			springbank \
			tshark-1.11.3 \
			tshark-1.10.3 \
			tshark-1.4.9 \
			wget \
			wget-ssl \
			zlib \

##############

HOST_MACHINE:=$(shell \
if test x86_64 = `uname -m` -a 32-bit = `file /sbin/init | awk '{print $$3}'`; then echo i386 ; else uname -m; fi \
| sed -e 's/i[3-9]86/i386/' )
HOST_OS:=$(shell uname)

# Directory location definitions

OPTWARE_TOP=$(shell if ! grep -q ^OPTWARE_TOP= ./Makefile; then cd ..; fi; pwd)
BASE_DIR:=$(shell pwd)

SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads
TOOL_BUILD_DIR=$(BASE_DIR)/toolchain
PACKAGE_DIR=$(BASE_DIR)/packages

BUILD_DIR=$(BASE_DIR)/builds
STAGING_DIR=$(BASE_DIR)/staging

STAGING_PREFIX=$(STAGING_DIR)/opt
STAGING_INCLUDE_DIR=$(STAGING_PREFIX)/include
STAGING_LIB_DIR=$(STAGING_PREFIX)/lib
STAGING_CPPFLAGS=$(TARGET_CFLAGS) -I$(STAGING_INCLUDE_DIR)
STAGING_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_LIB_DIR) -Wl,-rpath,/opt/lib -Wl,-rpath-link,$(STAGING_LIB_DIR)

HOST_BUILD_DIR=$(BASE_DIR)/host/builds
HOST_STAGING_DIR=$(BASE_DIR)/host/staging

HOST_STAGING_PREFIX=$(HOST_STAGING_DIR)/opt
HOST_STAGING_INCLUDE_DIR=$(HOST_STAGING_PREFIX)/include
HOST_STAGING_LIB_DIR=$(HOST_STAGING_PREFIX)/lib
HOST_STAGING_CPPFLAGS=-I$(HOST_STAGING_INCLUDE_DIR)
HOST_STAGING_LDFLAGS=-L$(HOST_STAGING_LIB_DIR) -Wl,-rpath,/opt/lib -Wl,-rpath-link,$(HOST_STAGING_LIB_DIR)

WHAT_TO_DO_WITH_IPK_DIR=rm -rf
# WHAT_TO_DO_WITH_IPK_DIR=: keep

export TMPDIR=$(BASE_DIR)/tmp

##############

all: directories toolchain packages

TARGET_OPTIMIZATION=-O2 #-mtune=xscale -march=armv4 -Wa,-mcpu=xscale
TARGET_DEBUGGING= #-g

include $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
ifndef TARGET_USRLIBDIR
TARGET_USRLIBDIR = $(TARGET_LIBDIR)
endif

ifeq (darwin,$(TARGET_OS))
SHLIB_EXT=dylib
SO=
DYLIB=.dylib
else	# default linux
SHLIB_EXT=so
SO=.so
DYLIB=
endif

ifeq ($(LIBC_STYLE), uclibc)
include $(OPTWARE_TOP)/platforms/packages-uclibc.mk
else
LIBC_STYLE=glibc
endif

include $(OPTWARE_TOP)/platforms/packages-$(OPTWARE_TARGET).mk

ifeq ($(HOSTCC), $(TARGET_CC))
PACKAGES ?= $(COMMON_NATIVE_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(NATIVE_PACKAGES_READY_FOR_TESTING)
else
PACKAGES ?= $(filter-out \
	$(NATIVE_PACKAGES) \
	$(BROKEN_PACKAGES) \
	$(if $(filter x86_64, $(HOST_MACHINE)), $(PACKAGES_BROKEN_ON_64BIT_HOST), ) \
	, $(COMMON_CROSS_PACKAGES) $(SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
endif

ifneq (, $(filter ipkg-opt $(OPTWARE_TARGET)-bootstrap $(OPTWARE_TARGET)-optware-bootstrap, $(PACKAGES)))
UPD-ALT_PREFIX ?= /opt
endif

testing:
	$(MAKE) PACKAGES="$(PACKAGES_READY_FOR_TESTING)" all
	$(PERL) -w scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) --objdump-path=$(TARGET_CROSS)objdump --base-dir=$(BASE_DIR) $(patsubst %,$(BUILD_DIR)/%*.ipk,$(PACKAGES_READY_FOR_TESTING))

# Common tools which may need overriding
CVS=cvs
SUDO=sudo
WGET=wget --passive-ftp
PERL=perl
GIT=git

# Required host-tools, which will build if they missing
HOST_TOOL_GCC33 = $(MAKE) gcc-host-stage GCC_VERSION=3.3.6
HOST_TOOL_ACLOCAL19 = \
	$(MAKE) automake19-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_AUTOMAKE19 = \
	$(MAKE) automake19-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_ACLOCAL14 = \
	$(MAKE) automake14-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_AUTOMAKE14 = \
	$(MAKE) automake14-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage


# The hostname or IP number of our local dl.sf.net mirror
SOURCEFORGE_MIRROR=downloads.sourceforge.net
#SOURCES_NLO_SITE=http://sources.nslu2-linux.org/sources
SOURCES_NLO_SITE=http://ftp.osuosl.org/pub/nslu2/sources

TARGET_CXX=$(TARGET_CROSS)g++
TARGET_CC=$(TARGET_CROSS)gcc
TARGET_CPP="$(TARGET_CC) -E"
TARGET_LD=$(TARGET_CROSS)ld
TARGET_AR=$(TARGET_CROSS)ar
TARGET_AS=$(TARGET_CROSS)as
TARGET_NM=$(TARGET_CROSS)nm
TARGET_RANLIB=$(TARGET_CROSS)ranlib
TARGET_STRIP?=$(TARGET_CROSS)strip
TARGET_CONFIGURE_OPTS= \
	AR=$(TARGET_AR) \
	AS=$(TARGET_AS) \
	LD=$(TARGET_LD) \
	NM=$(TARGET_NM) \
	CC=$(TARGET_CC) \
	CPP=$(TARGET_CPP) \
	GCC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	RANLIB=$(TARGET_RANLIB) \
	STRIP=$(TARGET_STRIP)
TARGET_PATH=$(STAGING_PREFIX)/bin:$(STAGING_DIR)/bin:/opt/bin:/opt/sbin:/bin:/sbin:/usr/bin:/usr/sbin

STRIP_COMMAND ?= $(TARGET_STRIP) --remove-section=.comment --remove-section=.note --strip-unneeded

PATCH_LIBTOOL=sed -i \
	-e 's|^sys_lib_search_path_spec=.*"$$|sys_lib_search_path_spec="$(TARGET_LIBDIR) $(STAGING_LIB_DIR)"|' \
	-e 's|^sys_lib_dlsearch_path_spec=.*"$$|sys_lib_dlsearch_path_spec=""|' \
	-e 's|^hardcode_libdir_flag_spec=.*"$$|hardcode_libdir_flag_spec=""|' \
	-e 's|nmedit |$(TARGET_CROSS)nmedit |' \

# Clear these variables to remove assumptions
AR=
AS=
LD=
NM=
CC=
GCC=
CXX=
RANLIB=
STRIP=
PKG_CONFIG=pkg-config

# Preload the correct library paths.
PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig
LIBRARY_PATH="$(STAGING_LIB_DIR):$(TARGET_LIB_DIR)"
LD_LIBRARY_PATH="$(STAGING_LIB_DIR):$(TARGET_LIB_DIR)"

PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_STAGE:=$(patsubst %,%-stage,$(PACKAGES))
PACKAGES_IPKG:=$(patsubst %,%-ipk,$(PACKAGES))

$(PACKAGES) : directories toolchain
$(PACKAGES_STAGE) : directories toolchain
%-stage : directories toolchain
$(PACKAGES_IPKG) : directories toolchain ipkg-utils
%-ipk : directories toolchain ipkg-utils

.PHONY: index
index: $(PACKAGE_DIR)/Packages

ifeq ($(PACKAGE_DIR),$(BASE_DIR)/packages)
    ifeq (,$(findstring -bootstrap,$(SPECIFIC_PACKAGES)))
$(PACKAGE_DIR)/Packages: $(BUILD_DIR)/*.ipk
    else
$(PACKAGE_DIR)/Packages: $(BUILD_DIR)/*.ipk $(BUILD_DIR)/*.xsh
    endif
	if ls $(BUILD_DIR)/*_$(TARGET_ARCH).xsh > /dev/null 2>&1; then \
		rm -f $(@D)/*_$(TARGET_ARCH).xsh ; \
		cp -fal $(BUILD_DIR)/*_$(TARGET_ARCH).xsh $(@D)/ ; \
	fi
	rm -f $(@D)/*_$(TARGET_ARCH).ipk
	cp -fal $(BUILD_DIR)/*_$(TARGET_ARCH).ipk $(@D)/
else
$(PACKAGE_DIR)/Packages:
endif
	{ \
		cd $(PACKAGE_DIR); \
		$(IPKG_MAKE_INDEX) . > Packages; \
		gzip -c Packages > Packages.gz; \
	}
	@echo "ALL DONE."

packages: $(PACKAGES_IPKG)
	$(MAKE) index

.PHONY: all clean dirclean distclean directories packages source toolchain \
	buildroot-toolchain libuclibc++-toolchain \
	autoclean \
	$(PACKAGES) $(PACKAGES_SOURCE) $(PACKAGES_DIRCLEAN) \
	$(PACKAGES_STAGE) $(PACKAGES_IPKG) \
	query-%

query-%:
	@echo $($(*))

TARGET_CC_VER = $(shell test -x "$(TARGET_CC)" && $(TARGET_CC) -dumpversion)

include make/*.mk

directories: $(DL_DIR) $(BUILD_DIR) $(STAGING_DIR) $(STAGING_PREFIX) \
	$(STAGING_LIB_DIR) $(STAGING_INCLUDE_DIR) $(TOOL_BUILD_DIR) \
	$(PACKAGE_DIR) $(TMPDIR)

$(DL_DIR):
	mkdir $(DL_DIR)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(STAGING_DIR):
	mkdir $(STAGING_DIR)

$(STAGING_PREFIX):
	mkdir $(STAGING_PREFIX)

$(STAGING_LIB_DIR):
	mkdir $(STAGING_LIB_DIR)

$(STAGING_INCLUDE_DIR):
	mkdir $(STAGING_INCLUDE_DIR)

$(TOOL_BUILD_DIR):
	mkdir $(TOOL_BUILD_DIR)

$(PACKAGE_DIR):
	mkdir $(PACKAGE_DIR)

$(TMPDIR):
	mkdir $(TMPDIR)

source: $(PACKAGES_SOURCE)

check-packages:
	@$(PERL) -w scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) --objdump-path=$(TARGET_CROSS)objdump --base-dir=$(BASE_DIR) $(filter-out $(BUILD_DIR)/crosstool-native-%,$(wildcard $(BUILD_DIR)/*.ipk))

autoclean:
	$(PERL) -w scripts/optware-autoclean.pl -v -C $(BASE_DIR)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN)
	find . -name '*~' -print | xargs /bin/rm -f
	find . -name '.*~' -print | xargs /bin/rm -f
	find . -name '.#*' -print | xargs /bin/rm -f

dirclean: $(PACKAGES_DIRCLEAN)

distclean:
	cd $(OPTWARE_TOP)
	rm -rf $(BUILD_DIR) $(STAGING_DIR) $(PACKAGE_DIR)
	rm -rf host
	rm -rf `ls platforms/toolchain-*.mk | sed 's|^platforms/toolchain-\(.*\)\.mk$$|\1|'`

toolclean:
	rm -rf $(TOOL_BUILD_DIR)

%-savespace:
	scripts/clean-workdir.sh $*

host/.configured:
	[ -d $(HOST_BUILD_DIR) ] || ( \
		if [ "$(OPTWARE_TARGET)" = $(shell basename $(BASE_DIR)) ]; \
			then mkdir -p ../host; ln -s ../host .; \
			else mkdir -p host; \
		fi; \
		mkdir -p $(HOST_BUILD_DIR) $(HOST_STAGING_PREFIX); \
	)
	[ -e $@ ] || touch $@

%-target %/.configured:
	[ -e ${DL_DIR} ] || mkdir -p ${DL_DIR}
	[ -e $*/Makefile ] || ( \
		mkdir -p $* ; \
		echo "OPTWARE_TARGET=$*" > $*/Makefile ; \
		echo "include ../Makefile" >> $*/Makefile ; \
		ln -s ../downloads $*/downloads ; \
		ln -s ../make $*/make ; \
		ln -s ../scripts $*/scripts ; \
		ln -s ../sources $*/sources ; \
	)
	touch $*/.configured


make/%.mk:
	PKG_UP=$$(echo $* | tr [a-z\-] [A-Z_]);			\
	sed -e "s/<foo>/$*/g" -e "s/<FOO>/$${PKG_UP}/g"		\
		 -e '6,11d' make/template.mk > $@
