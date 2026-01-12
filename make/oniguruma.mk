###########################################################
#
# Onigurama
#
###########################################################

ONIGURUMA_CALNEX_SITE=$(PACKAGES_SERVER)


ONIGURUMA_VERSION=6.9.6
ONIGURUMA_SITE=https://github.com/kkos/oniguruma
ONIGURUMA_LIB_VERSION=$(ONIGURUMA_VERSION)
ONIGURUMA_SOURCE=oniguruma-$(ONIGURUMA_VERSION).tar.gz
ONIGURUMA_DIR=oniguruma-$(ONIGURUMA_VERSION)
ONIGURUMA_UNZIP=zcat
ONIGURUMA_MAINTAINER=K. Kosako
ONIGURUMA_DESCRIPTION=Regular expression library
ONIGURUMA_SECTION=lib
ONIGURUMA_PRIORITY=optional
ONIGURUMA_DEPENDS=
ONIGURUMA_CONFLICTS=

ONIGURUMA_IPK_VERSION=1

ONIGURUMA_BUILD_DIR=$(BUILD_DIR)/oniguruma
ONIGURUMA_SOURCE_DIR=$(BUILD_DIR)/oniguruma/src
ONIGURUMA_BUILD_OUTPUTS_DIR=$(ONIGURUMA_SOURCE_DIR)/.libs
ONIGURUMA_IPK=$(BUILD_DIR)/oniguruma_$(ONIGURUMA_VERSION)-$(ONIGURUMA_IPK_VERSION)_$(TARGET_ARCH).ipk
ONIGURUMA_IPK_DIR=$(BUILD_DIR)/oniguruma-$(ONIGURUMA_VERSION)-ipk
ONIGURUMA_AUTORECONF=/usr/bin/autoreconf

.PHONY: oniguruma-source oniguruma-unpack oniguruma oniguruma-stage oniguruma-ipk oniguruma-clean oniguruma-dirclean oniguruma-check

$(DL_DIR)/$(ONIGURUMA_SOURCE):
	$(WGET) -P $(@D) $(ONIGURUMA_CALNEX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(ONIGURUMA_SITE)/$(@F)

oniguruma-source: $(DL_DIR)/$(ONIGURUMA_SOURCE)

$(ONIGURUMA_BUILD_DIR)/.configured: $(DL_DIR)/$(ONIGURUMA_SOURCE) make/oniguruma.mk
	rm -rf $(BUILD_DIR)/$(ONIGURUMA_DIR) $(@D)
	$(ONIGURUMA_UNZIP) $(DL_DIR)/$(ONIGURUMA_SOURCE) | tar -C $(BUILD_DIR) -xf -
	mv $(BUILD_DIR)/$(ONIGURUMA_DIR) $(@D)
	#sed -i -e 's/^CFLAGS *=/&$$(CPPFLAGS) /; s|1.0.4|$(ONIGURUMA_VERSION)|' $(@D)/Makefile*
	cd $(ONIGURUMA_BUILD_DIR); $(ONIGURUMA_AUTORECONF) -vfi
	

	(cd $(ONIGURUMA_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	);
	touch $@

oniguruma-unpack: $(ONIGURUMA_BUILD_DIR)/.configured

$(ONIGURUMA_BUILD_DIR)/.built: $(ONIGURUMA_BUILD_DIR)/.configured
	rm -f $@
	@$(MAKE) -C $(@D) \
		PREFIX=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ONIGURUMA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ONIGURUMA_LDFLAGS)" \
		-f Makefile
		
	touch $@

oniguruma: $(ONIGURUMA_BUILD_DIR)/.built

$(ONIGURUMA_BUILD_DIR)/.staged: $(ONIGURUMA_BUILD_DIR)/.built
	rm -f $@
	install -d $(STAGING_INCLUDE_DIR)
	install -m 644 $(ONIGURUMA_SOURCE_DIR)/oniggnu.h $(STAGING_INCLUDE_DIR)
	install -m 644 $(ONIGURUMA_SOURCE_DIR)/onigposix.h $(STAGING_INCLUDE_DIR)
	install -m 644 $(ONIGURUMA_SOURCE_DIR)/oniguruma.h $(STAGING_INCLUDE_DIR)
	install -d $(STAGING_LIB_DIR)
	install -m 644 $(ONIGURUMA_SOURCE_DIR)/.libs/libonig.so.5.1.0 $(STAGING_LIB_DIR)
	cd $(STAGING_LIB_DIR) && ln -fs libonig.so.5.1.0 libonig.so.5
	touch $@

oniguruma-stage: $(ONIGURUMA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.
#
$(ONIGURUMA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: oniguruma" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ONIGURUMA_PRIORITY)" >>$@
	@echo "Section: $(ONIGURUMA_SECTION)" >>$@
	@echo "Version: $(ONIGURUMA_VERSION)-$(ONIGURUMA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ONIGURUMA_MAINTAINER)" >>$@
	@echo "Source: $(ONIGURUMA_SITE)/$(ONIGURUMA_SOURCE)" >>$@
	@echo "Description: $(ONIGURUMA_DESCRIPTION)" >>$@
	@echo "Depends: $(ONIGURUMA_DEPENDS)" >>$@
	@echo "Conflicts: $(ONIGURUMA_CONFLICTS)" >>$@

$(ONIGURUMA_IPK): $(ONIGURUMA_BUILD_DIR)/.built
	rm -rf $(ONIGURUMA_IPK_DIR) $(BUILD_DIR)/oniguruma_*_$(TARGET_ARCH).ipk

	install -d $(ONIGURUMA_IPK_DIR)/opt/include
	install -m 644 $(ONIGURUMA_SOURCE_DIR)/oniggnu.h $(ONIGURUMA_IPK_DIR)/opt/include
	install -m 644 $(ONIGURUMA_SOURCE_DIR)/onigposix.h $(ONIGURUMA_IPK_DIR)/opt/include
	install -m 644 $(ONIGURUMA_SOURCE_DIR)/oniguruma.h $(ONIGURUMA_IPK_DIR)/opt/include


	install -d $(ONIGURUMA_IPK_DIR)/opt/lib
	install -m 644 $(ONIGURUMA_SOURCE_DIR)/.libs/libonig.so.5.1.0 $(ONIGURUMA_IPK_DIR)/opt/lib
	cd $(ONIGURUMA_IPK_DIR)/opt/lib && ln -fs libonig.so.5.1.0 libonig.so.5
	cd $(ONIGURUMA_IPK_DIR)/opt/lib && ln -fs libonig.so.5.1.0 libonig.so
	$(STRIP_COMMAND) $(ONIGURUMA_IPK_DIR)/opt/lib/libonig.so.5.1.0
	echo $(STRIP_COMMAND)
	
	$(MAKE) $(ONIGURUMA_IPK_DIR)/CONTROL/control

	cd $(BUILD_DIR); $(IPKG_BUILD) $(ONIGURUMA_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ONIGURUMA_IPK_DIR)

oniguruma-ipk: oniguruma-stage $(ONIGURUMA_IPK)

oniguruma-clean:
	$(MAKE) -C $(ONIGURUMA_BUILD_DIR) clean

oniguruma-dirclean:
	rm -rf $(BUILD_DIR)/$(ONIGURUMA_DIR) $(ONIGURUMA_BUILD_DIR) $(ONIGURUMA_IPK_DIR) $(ONIGURUMA_IPK)

oniguruma-check: $(ONIGURUMA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^


