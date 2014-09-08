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

HOSTCC			= $(TARGET_CC)
GNU_HOST_NAME		= $(GNU_TARGET_NAME)
TARGET_CROSS		= /opt/bin/
TARGET_LIBDIR		= /opt/lib
TARGET_INCDIR		= /opt/include
TARGET_LDFLAGS		= -L/opt/lib
TARGET_CUSTOM_FLAGS	= -O2 -pipe 
TARGET_CPPFLAGS		= -I$(TARGET_CHROOT)/usr/include/c++/4.7 \
			  -I$(TARGET_CHROOT)/usr/include/c++/4.7/x86_65-linux-gnu \
			  -I$(TARGET_CHROOT)/usr/include/c++/4.7/backward \
			  -I$(TARGET_CHROOT)/usr/local/include \
			  -I$(TARGET_CHROOT)/usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed \
			  -I$(TARGET_CHROOT)/usr/include/x86_64-linux-gnu \
			  -I$(TARGET_CHROOT)/usr/include
TARGET_CFLAGS		= -I/opt/include \
			  $(TARGET_OPTIMIZATION) \
			  $(TARGET_DEBUGGING) \
			  $(TARGET_CUSTOM_FLAGS) \
			  $(TARGET_CPPFLAGS) 

toolchain:

else

HOSTCC = gcc
GNU_HOST_NAME		= $(HOST_MACHINE)-linux
TARGET_DISTRO		?= wheezy
<<<<<<< HEAD
TARGET_REPOMIRROR	?= "http://ftp.us.debian.org/debian"
TARGET_CROSS_TOP	= $(BASE_DIR)/toolchain
TARGET_CHROOT		= $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)
#TARGET_CROSS		= $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/usr/bin/
TARGET_LIBDIR		= $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR	= $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_INCDIR		= $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
TARGET_LDFLAGS		=
TARGET_CUSTOM_FLAGS	= -O2 -pipe
TARGET_CFLAGS		= $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
=======
TARGET_CROSS_TOP	= $(BASE_DIR)/toolchain
TARGET_CHROOT		= $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)
TARGET_CROSS		= $(TARGET_CHROOT)/usr/bin/
TARGET_LIBDIR		= $(TARGET_CHROOT)/lib
TARGET_LIBDIR_ARCH	= $(TARGET_LIBDIR)/$(GNU_TARGET_NAME)
TARGET_LIB64DIR		= $(TARGET_CHROOT)/lib64
TARGET_USRLIBDIR	= $(TARGET_CHROOT)/usr/lib
TARGET_USRLIBDIR_ARCH	= $(TARGET_USRLIBDIR)/$(GNU_TARGET_NAME)-gnu
TARGET_USR_LCLLIBDIR	= $(TARGET_CHROOT)/usr/local/lib
TARGET_INCDIR		= $(TARGET_CHROOT)/include
TARGET_GCC_LIBDIR	= $(TARGET_USRLIBDIR)/$(GNU_TARGET_NAME)
TARGET_LDFLAGS		+= -L$(TARGET_USR_LCLLIBDIR) \
			   -L$(TARGET_LIBDIR_ARCH) \
			   -L$(TARGET_USRLIBDIR_ARCH) \
			   -L$(TARGET_USRLIBDIR)
TARGET_LD_LIBRARY_PATH	= "$(TARGET_USR_LCLLIBDIR):$(TARGET_LIBDIR_ARCH):$(TARGET_USRLIBDIR_ARCH):$(TARGET_USRLIBDIR)"
TARGET_CONFIGURE_OPTS+=LD_LIBRARY_PATH=$(TARGET_LD_LIBRARY_PATH)
TARGET_BUILD_OPTS+=LD_LIBRARY_PATH=$(TARGET_LD_LIBRARY_PATH)
>>>>>>> f86de8f81f9e2467f53806072b594d6e7d314d7f

NATIVE_GCC_VERSION=4.8.2

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(TARGET_CROSS_TOP)/.unpacked: 
	mkdir -p $(TARGET_CHROOT) && \
<<<<<<< HEAD
	sudo debootstrap --include=build-essential,libtool,zlib1g-dev,sudo \
	$(TARGET_DISTRO) $(TARGET_CHROOT) $(TARGET_REPOMIRROR) && \
	sudo rm -f $(TARGET_CHROOT)/etc/passwd \
		   $(TARGET_CHROOT)/etc/passwd- \
		   $(TARGET_CHROOT)/etc/shadow \
		   $(TARGET_CHROOT)/etc/shadow- \
		   $(TARGET_CHROOT)/etc/group \
		   $(TARGET_CHROOT)/etc/group- \
		   $(TARGET_CHROOT)/etc/sudoers && \
	cd $(TARGET_CHROOT)/etc && \
	sudo ln /etc/passwd && \
	sudo ln /etc/passwd- && \
	sudo ln /etc/shadow && \
	sudo ln /etc/shadow- && \
	sudo ln /etc/group && \
	sudo ln /etc/group- && \
	sudo ln /etc/sudoers && \
	USER=`whoami` && \
	sudo mkdir -p $(TARGET_CHROOT)$(HOME) && \
	sudo chown --reference=$(HOME) $(TARGET_CHROOT)$(HOME) && \
	sudo chmod --reference=$(HOME) $(TARGET_CHROOT)$(HOME) && \
	sudo mount -o bind $(HOME) $(TARGET_CHROOT)$(HOME) && \
=======
	sudo debootstrap --include=build-essential,libtool,zlib1g-dev \
	$(TARGET_DISTRO) $(TARGET_CHROOT) http://ftp.uk.debian.org/debian && \
	USER=`whoami` && \
	sudo chown -R $(USER) $(TARGET_CHROOT)
>>>>>>> f86de8f81f9e2467f53806072b594d6e7d314d7f
	touch $@

endif
