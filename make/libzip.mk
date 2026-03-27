###########################################################
#
# libzip
#
###########################################################

LIBZIP_CALNEX_SITE=$(PACKAGES_SERVER)

LIBZIP_SITE=https://libzip.org/download/
LIBZIP_VERSION=1.11.4
LIBZIP_SOURCE=libzip-$(LIBZIP_VERSION).tar.gz
LIBZIP_DIR=libzip-$(LIBZIP_VERSION)
LIBZIP_UNZIP=zcat
LIBZIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBZIP_DESCRIPTION=A library for reading, creating, and modifying zip files
LIBZIP_SECTION=libs
LIBZIP_PRIORITY=optional
LIBZIP_DEPENDS=zlib
LIBZIP_CONFLICTS=

LIBZIP_IPK_VERSION=1

LIBZIP_BUILD_DIR=$(BUILD_DIR)/libzip
LIBZIP_SOURCE_DIR=$(SOURCE_DIR)/libzip
LIBZIP_IPK=$(BUILD_DIR)/libzip_$(LIBZIP_VERSION)-$(LIBZIP_IPK_VERSION)_$(TARGET_ARCH).ipk
LIBZIP_IPK_DIR=$(BUILD_DIR)/libzip-$(LIBZIP_VERSION)-ipk

LIBZIP_CPPFLAGS=
LIBZIP_LDFLAGS=

.PHONY: libzip-source libzip-unpack libzip libzip-stage libzip-ipk libzip-clean libzip-dirclean libzip-check

$(DL_DIR)/$(LIBZIP_SOURCE):
	$(WGET) -P $(@D) $(LIBZIP_CALNEX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(LIBZIP_SITE)/$(@F)

libzip-source: $(DL_DIR)/$(LIBZIP_SOURCE)

$(LIBZIP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBZIP_SOURCE) make/libzip.mk
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBZIP_DIR) $(@D)
	$(LIBZIP_UNZIP) $(DL_DIR)/$(LIBZIP_SOURCE) | tar -C $(BUILD_DIR) -xf -
	mv $(BUILD_DIR)/$(LIBZIP_DIR) $(@D)
	mkdir -p $(@D)/build
	(cd $(@D)/build; \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig:$$PKG_CONFIG_PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBZIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBZIP_LDFLAGS)" \
		cmake .. \
		-DCMAKE_INSTALL_PREFIX=/opt \
		-DCMAKE_INSTALL_LIBDIR=lib \
		-DCMAKE_PREFIX_PATH=$(STAGING_PREFIX) \
		-DZLIB_ROOT=$(STAGING_PREFIX) \
		-DZLIB_INCLUDE_DIR=$(STAGING_INCLUDE_DIR) \
		-DZLIB_LIBRARY=$(STAGING_LIB_DIR)/libz.so \
		-DBUILD_SHARED_LIBS=ON \
		-DBUILD_STATIC_LIBS=OFF \
		-DENABLE_ZSTD=OFF \
	)
	touch $@

libzip-unpack: $(LIBZIP_BUILD_DIR)/.configured

$(LIBZIP_BUILD_DIR)/.built: $(LIBZIP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/build
	touch $@

libzip: $(LIBZIP_BUILD_DIR)/.built

$(LIBZIP_BUILD_DIR)/.staged: $(LIBZIP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/build DESTDIR=$(STAGING_DIR) install
	touch $@

libzip-stage: $(LIBZIP_BUILD_DIR)/.staged

$(LIBZIP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libzip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBZIP_PRIORITY)" >>$@
	@echo "Section: $(LIBZIP_SECTION)" >>$@
	@echo "Version: $(LIBZIP_VERSION)-$(LIBZIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBZIP_MAINTAINER)" >>$@
	@echo "Source: $(LIBZIP_SITE)/$(LIBZIP_SOURCE)" >>$@
	@echo "Description: $(LIBZIP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBZIP_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBZIP_CONFLICTS)" >>$@

$(LIBZIP_IPK): $(LIBZIP_BUILD_DIR)/.built
	rm -rf $(LIBZIP_IPK_DIR) $(BUILD_DIR)/libzip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBZIP_BUILD_DIR)/build DESTDIR=$(LIBZIP_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBZIP_IPK_DIR)/opt/lib/libzip.so.*
	$(MAKE) $(LIBZIP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBZIP_IPK_DIR)

libzip-ipk: $(LIBZIP_IPK)

libzip-clean:
	-test -d $(LIBZIP_BUILD_DIR)/build && $(MAKE) -C $(LIBZIP_BUILD_DIR)/build clean || true

libzip-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBZIP_DIR) $(LIBZIP_BUILD_DIR) $(LIBZIP_IPK_DIR) $(LIBZIP_IPK)

libzip-check: $(LIBZIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
