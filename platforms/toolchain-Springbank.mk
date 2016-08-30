TARGET_ARCH=x86_64
TARGET_OS=linux

#Ugly and fragile hack to cope with floating between machines.
LIBSTDC++_VERSION=6.0.20
LIBNSL_VERSION=2.6.18

GNU_TARGET_NAME = x86_64-calnex-linux-gnu

TARGET_CC_PROBE := $(shell test -x "/opt/bin/ipkg" \
&& test -x "/opt/bin/$(GNU_TARGET_NAME)-gcc" \
&& echo yes)
STAGING_CPPFLAGS+= -DPATH_MAX=4096 -DLINE_MAX=2048 -DMB_LEN_MAX=16

BINUTILS_VERSION := 2.22
BINUTILS_IPK_VERSION := 1

ifeq (yes, $(TARGET_CC_PROBE))

HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(GNU_TARGET_NAME)
TARGET_CROSS = /opt/bin/
TARGET_LIBDIR = /opt/lib
TARGET_INCDIR = /opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS= -O2 -pipe -w
TARGET_CFLAGS= -I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

toolchain:

else

HOSTCC = gcc
GNU_HOST_NAME = $(GNU_TARGET_NAME)
SNAPSHOT_VERSION ?= devel
TARGET_DISTRO ?= wheezy
TARGET_PRODUCT ?= Paragon
TARGET_PRODUCT_LOWER = $(shell echo $(TARGET_PRODUCT) | tr A-Z a-z)
TARGET_REPO_MIRROR ?= http://packages.calnexsol.com/debian
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain
TARGET_CROSS = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/$(GNU_TARGET_NAME)/lib
TARGET_LIB32DIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/$(GNU_TARGET_NAME)/lib32
TARGET_LIB64DIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/$(GNU_TARGET_NAME)/lib64
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -O2 -pipe -w
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

NATIVE_GCC_VERSION=4.9.1

TOOLCHAIN_BINARY_SITE=http://packages.calnexsol.com/optware/toolchains
ifeq (wheezy, $(TARGET_DISTRO))
LIBC_STYLE=eglibc
TOOLCHAIN_BINARY=gcc491-eglibc213_x86_64.tar.gz
else
LIBC_STYLE=glibc
TOOLCHAIN_BINARY=gcc491-glibc219_x86_64.tar.gz
endif

ifeq ("", $(TARGET_PRODUCT))
        $(error TARGET_PRODUCT has not been set.  Exiting.)
endif

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(@D) $(TOOLCHAIN_BINARY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.unpacked: \
$(DL_DIR)/$(TOOLCHAIN_BINARY) \
$(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(@D)
	mkdir -p $(@D)
	tar -xz -C $(@D) -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	touch $@

endif

