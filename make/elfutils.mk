#############################################################
#
# elfutils
#
#############################################################

ELFUTILS_CALNEX_SITE=$(PACKAGES_SERVER)

ELFUTILS_VERSION=0.183
ELFUTILS_LIB_VERSION=0.183
ELFUTILS_SITE2=https://sourceware.org/elfutils/ftp/$(ELFUTILS_VERSION)
ELFUTILS_SOURCE=elfutils-$(ELFUTILS_VERSION).tar.bz2
ELFUTILS_DIR=elfutils-$(ELFUTILS_VERSION)
ELFUTILS_UNZIP=bzcat
ELFUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ELFUTILS_DESCRIPTION=elfutils 
ELFUTILS_SECTION=libs
ELFUTILS_PRIORITY=optional
ELFUTILS_DEPENDS=
ELFUTILS_CONFLICTS=

ELFUTILS_IPK_VERSION=2


ELFUTILS_CFLAGS= $(TARGET_CFLAGS) -fPIC 
ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
ELFUTILS_CFLAGS+= -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
endif

ifneq (darwin,$(TARGET_OS))
ELFUTILS_LDFLAGS=-Wl,-soname,libz.so.1
ELFUTILS_MAKE_FLAGS=-j LDSHARED="$(TARGET_CC) -shared $(STAGING_LDFLAGS) $(ELFUTILS_LDFLAGS)  -Wl,--version-script=$(ELFUTILS_BUILD_DIR)/elfutils.map"
endif

ELFUTILS_BUILD_DIR=$(BUILD_DIR)/elfutils
ELFUTILS_SOURCE_DIR=$(SOURCE_DIR)/elfutils

ELFUTILS_IPK_DIR=$(BUILD_DIR)/elfutils-$(ELFUTILS_VERSION)-ipk
ELFUTILS_IPK=$(BUILD_DIR)/elfutils_$(ELFUTILS_VERSION)-$(ELFUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBELF_BUILD_PRODUCTS_DIR=$(ELFUTILS_BUILD_DIR)/libelf


.PHONY: elfutils-source elfutils-unpack elfutils elfutils-stage elfutils-ipk elfutils-clean \
elfutils-dirclean elfutils-check elfutils-host elfutils-host-stage elfutils-unstage


$(DL_DIR)/$(ELFUTILS_SOURCE):
	$(WGET) -P $(@D) $(ELFUTILS_CALNEX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(ELFUTILS_SITE2)/$(@F)

elfutils-source: $(DL_DIR)/$(ELFUTILS_SOURCE)

$(ELFUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(ELFUTILS_SOURCE) make/elfutils.mk
	rm -rf $(BUILD_DIR)/$(ELFUTILS_DIR) $(ELFUTILS_BUILD_DIR)
	
	rm -rf $(STAGING_INCLUDE_DIR)/elfutils
	rm -f $(STAGING_INCLUDE_DIR)libelf.h $(STAGING_INCLUDE_DIR)gelf.h $(STAGING_INCLUDE_DIR)nlist.h 
	rm -f $(STAGING_LIB_DIR)/libelf.a $(STAGING_LIB_DIR)/libelf.so*
	
	$(ELFUTILS_UNZIP) $(DL_DIR)/$(ELFUTILS_SOURCE) | tar -C $(BUILD_DIR) -xf -
	mv $(BUILD_DIR)/$(ELFUTILS_DIR) $(ELFUTILS_BUILD_DIR)
	
	$(MAKE) zlib-stage
	
ifeq (darwin,$(TARGET_OS))
	sed -i -e 's/`.*uname -s.*`/Darwin/' $(ELFUTILS_BUILD_DIR)/configure
endif
	(cd $(ELFUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ELFUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ELFULTIS_LDFLAGS)" \
		prefix=/opt \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-libdebuginfod \
		--disable-debuginfod \
	)
	touch $@

elfutils-unpack: $(ELFUTILS_BUILD_DIR)/.configured

$(ELFUTILS_BUILD_DIR)/.built: $(ELFUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) RANLIB="$(TARGET_RANLIB)" AR="$(TARGET_AR) " \
		SHAREDLIB="libz.$(SHLIB_EXT)" \
		SHAREDLIBV="libz$(SO).$(ELFUTILS_LIB_VERSION)$(DYLIB)" \
		SHAREDLIBM="libz$(SO).1$(DYLIB)" \
		CFLAGS="$(ELFUTILS_CFLAGS)" \
		CC=$(TARGET_CC) \
		$(ELFUTILS_MAKE_FLAGS) \
		-C $(ELFUTILS_BUILD_DIR)
	touch $@

elfutils: $(ELFUTILS_BUILD_DIR)/.built

$(ELFUTILS_BUILD_DIR)/.staged: $(ELFUTILS_BUILD_DIR)/.built
	rm -f $@ $(ELFUTILS_BUILD_DIR)/.unstaged
	
	
	
	install -d $(STAGING_INCLUDE_DIR)
	install -d $(STAGING_INCLUDE_DIR)/elfutils
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/elf-knowledge.h $(STAGING_INCLUDE_DIR)/elfutils
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/gelf.h          $(STAGING_INCLUDE_DIR)
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/libelf.h        $(STAGING_INCLUDE_DIR)
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/nlist.h         $(STAGING_INCLUDE_DIR)
	
	install -d $(STAGING_LIB_DIR)
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/libelf.a   $(STAGING_LIB_DIR)
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/libelf.so  $(STAGING_LIB_DIR)
	cd $(STAGING_DIR)/opt/lib && ln -fs libelf$(SO) libelf$(SO).1$(DYLIB)
	
	# record the library in pkgconfig
	install -d $(STAGING_LIB_DIR)/pkgconfig
	install -m 644 $(ELFUTILS_BUILD_DIR)/config/libelf.pc $(STAGING_LIB_DIR)/pkgconfig
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libelf.pc

	touch $@

elfutils-stage: $(ELFUTILS_BUILD_DIR)/.staged

$(ELFUTILS_BUILD_DIR)/.unstaged:
	rm -f $@ $(ELFUTILS_BUILD_DIR)/.staged
	rm -f $(STAGING_INCLUDE_DIR)/elfutils/elf-knowledge.h
	rmdir $(STAGING_INCLUDE_DIR)/elfutils/

	rm -f $(STAGING_INCLUDE_DIR)/gelf.h
	rm -f $(STAGING_INCLUDE_DIR)/libelf.h
	rm -f $(STAGING_INCLUDE_DIR)/nlist.h

	rm -f $(STAGING_LIB_DIR)/libelf.a
	rm -f $(STAGING_LIB_DIR)/libelf.so
	rm -f $(STAGING_LIB_DIR)/libelf.so.1
	-touch $@

elfutils-unstage: $(ELFUTILS_BUILD_DIR)/.unstaged


#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nylon
#
$(ELFUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libelf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ELFUTILS_PRIORITY)" >>$@
	@echo "Section: $(ELFUTILS_SECTION)" >>$@
	@echo "Version: $(ELFUTILS_VERSION)-$(ELFUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ELFUTILS_MAINTAINER)" >>$@
	@echo "Source: $(ELFUTILS_SITE)/$(ELFUTILS_SOURCE)" >>$@
	@echo "Description: $(ELFUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(ELFUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(ELFUTILS_CONFLICTS)" >>$@

$(ELFUTILS_IPK): $(ELFUTILS_BUILD_DIR)/.built
	rm -rf $(ELFUTILS_IPK_DIR) $(BUILD_DIR)/elfutils_*_$(TARGET_ARCH).ipk
	install -d $(ELFUTILS_IPK_DIR)/opt/include
	install -d $(ELFUTILS_IPK_DIR)/opt/include/elfutils
	
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/elf-knowledge.h $(ELFUTILS_IPK_DIR)/opt/include/elfutils
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/gelf.h          $(ELFUTILS_IPK_DIR)/opt/include
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/libelf.h        $(ELFUTILS_IPK_DIR)/opt/include
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/nlist.h         $(ELFUTILS_IPK_DIR)/opt/include

	install -d $(ELFUTILS_IPK_DIR)/opt/lib
	
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/libelf.a        $(ELFUTILS_IPK_DIR)/opt/lib
	install -m 644 $(LIBELF_BUILD_PRODUCTS_DIR)/libelf$(SO)     $(ELFUTILS_IPK_DIR)/opt/lib/libelf-$(ELFUTILS_LIB_VERSION)$(SO)
	$(STRIP_COMMAND) $(ELFUTILS_IPK_DIR)/opt/lib/libelf-$(ELFUTILS_LIB_VERSION)$(SO)


	cd $(ELFUTILS_IPK_DIR)/opt/lib && ln -fs libelf-$(ELFUTILS_LIB_VERSION)$(SO) libelf$(SO).1
	cd $(ELFUTILS_IPK_DIR)/opt/lib && ln -fs libelf$(SO).1 libelf$(SO)

	$(MAKE) $(ELFUTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ELFUTILS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ELFUTILS_IPK_DIR)

elfutils-ipk: $(ELFUTILS_IPK)

elfutils-clean: elfutils-unstage
	rm -f $(ELFUTILS_BUILD_DIR)/.built
	rm -f $(ELFUTILS_HOST_BUILD_DIR)/.staged
	$(MAKE) -C $(ELFUTILS_BUILD_DIR) clean

elfutils-dirclean: elfutils-unstage
	rm -rf $(BUILD_DIR)/$(ELFUTILS_DIR) $(ELFUTILS_BUILD_DIR) $(ELFUTILS_IPK_DIR) $(ELFUTILS_IPK)

#
# Some sanity check for the package.
#
elfutils-check: $(ELFUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
