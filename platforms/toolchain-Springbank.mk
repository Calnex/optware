TARGET_ARCH=x86_64
TARGET_OS=linux
LIBC_STYLE=glibc

#Ugly and fragile hack to cope with floating between machines.
LIBSTDC++_VERSION=$(shell find /usr/lib* -type f | grep stdc++ 2>&1 | grep .so. | sed -e 's/.*libstdc++\.so\.//g' | uniq)
LIBNSL_VERSION=2.6.18

GNU_TARGET_NAME = x86_64-linux

TARGET_CC_PROBE := $(shell test -x "/opt/bin/ipkg" \
&& test -x "/opt/bin/$(GNU_TARGET_NAME)-gcc" \
&& echo yes)
STAGING_CPPFLAGS+= -DPATH_MAX=4096 -DLINE_MAX=2048 -DMB_LEN_MAX=16

BINUTILS_VERSION := 2.20
BINUTILS_IPK_VERSION := 1

ifeq (yes, $(TARGET_CC_PROBE))

HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(GNU_TARGET_NAME)
TARGET_CROSS = /opt/bin/
TARGET_LIBDIR = /opt/lib
TARGET_INCDIR = /opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS= -O2 -pipe
TARGET_CFLAGS= -I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

toolchain:

else

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-linux
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain
#TARGET_CROSS = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -O2 -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

NATIVE_GCC_VERSION=4.8.2

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(TARGET_CROSS_TOP)/.unpacked: 
	mkdir -p $(TARGET_LIBDIR)
	ln -fs `find /lib/*` $(TARGET_LIBDIR)
	ln -fs `find /lib64/*` $(TARGET_LIBDIR)
	ln -fs `find /usr/lib/*` $(TARGET_USRLIBDIR)
	ln -fs `find /usr/lib64/*` $(TARGET_USRLIBDIR)
	touch $@

endif