TARGET_ARCH=x86_64
TARGET_OS=linux
LIBC_STYLE=glibc

#Ugly and fragile hack to cope with floating between machines.
LIBSTDC++_VERSION=
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
TARGET_DISTRO = wheezy
#TARGET_TEMP = $(TARGET_CROSS_TOP)/temp
TARGET_TEMP = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain
TARGET_CROSS = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/usr/bin/
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -O2 -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

NATIVE_GCC_VERSION=4.8.2

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(TARGET_CROSS_TOP)/.unpacked: 
	mkdir -p $(TARGET_TEMP) && \
	sudo debootstrap $(TARGET_DISTRO) $(TARGET_TEMP) && \
	sudo chroot $(TARGET_TEMP) apt-get -y install build-essential; exit
	USER=`whoami` && \
	sudo chown -R $(USER):$(USER) $(TARGET_CROSS_TOP)/temp
	mkdir -p $(TARGET_LIBDIR)
	#find $(TARGET_TEMP)/lib 	-type l -name *.so* \
	#-exec mv -f --backup=numbered -t $(TARGET_LIBDIR) '{}' +
	#find $(TARGET_TEMP)/lib 	-type f -name *.so* \
	#-exec mv -f --backup=numbered -t $(TARGET_LIBDIR) '{}' +
	#find $(TARGET_TEMP)/lib64 	-type l -name *.so* \
	#-exec mv -f --backup=numbered -t $(TARGET_LIBDIR) '{}' +
	#find $(TARGET_TEMP)/lib64 	-type f -name *.so* \
	#-exec mv -f --backup=numbered -t $(TARGET_LIBDIR) '{}' +
	#find $(TARGET_TEMP)/usr/lib 	-type l -name *.so* \
	#-exec mv -f --backup=numbered -t $(TARGET_USRLIBDIR) '{}' +
	#find $(TARGET_TEMP)/usr/lib 	-type f -name *.so* \
	#-exec mv -f --backup=numbered -t $(TARGET_USRLIBDIR) '{}' +
	#find $(TARGET_TEMP)/usr/lib64 	-type l -name *.so* \
	#-exec mv -f --backup=numbered -t $(TARGET_USRLIBDIR) '{}' +
	#find $(TARGET_TEMP)/usr/lib64 	-type f -name *.so* \
	#-exec mv -f --backup=numbered -t $(TARGET_USRLIBDIR) '{}' +
	#rm -rf $(TARGET_TEMP)
	touch $@

endif
