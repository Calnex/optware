###########################################################
#
# php
#
###########################################################

#
# PHP_VERSION, PHP_SITE and PHP_SOURCE define
# the upstream location of the source code for the package.
# PHP_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
PHP_SITE=http://www.php.net/distributions/
PHP_VERSION=5.6.27
PHP_SOURCE=php-$(PHP_VERSION).tar.bz2
PHP_DIR=php-$(PHP_VERSION)
PHP_UNZIP=bzcat
PHP_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
PHP_DESCRIPTION=The php scripting language
PHP_SECTION=net
PHP_PRIORITY=optional
PHP_DEPENDS=bzip2, zlib, gdbm, pcre
PHP_CONFLICTS=debian (<= 9.0)

#
# PHP_IPK_VERSION should be incremented when the ipk changes.
#
PHP_IPK_VERSION=7

#
# PHP_CONFFILES should be a list of user-editable files
#
#PHP_CONFFILES=/opt/etc/php.ini

#
# PHP_LOCALES defines which locales get installed
#
PHP_LOCALES=

#
# PHP_CONFFILES should be a list of user-editable files
#PHP_CONFFILES=/opt/etc/php.conf /opt/etc/init.d/SXXphp

#
# PHP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PHP_PATCHES=
#PHP_PATCHES=\
#	$(PHP_SOURCE_DIR)/aclocal.m4.patch \
#	$(PHP_SOURCE_DIR)/configure.in.patch \
#	$(PHP_SOURCE_DIR)/threads.m4.patch \
#	$(PHP_SOURCE_DIR)/endian-5.0.4.patch \
#	$(PHP_SOURCE_DIR)/ext-posix-uclibc.patch \
#	$(PHP_SOURCE_DIR)/pcre_info.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_CPPFLAGS=
PHP_LDFLAGS=-ldl

#
# PHP_BUILD_DIR is the directory in which the build is done.
# PHP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_IPK_DIR is the directory in which the ipk is built.
# PHP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_BUILD_DIR=$(BUILD_DIR)/php
PHP_SOURCE_DIR=$(SOURCE_DIR)/php
PHP_IPK_DIR=$(BUILD_DIR)/php-$(PHP_VERSION)-ipk
PHP_IPK=$(BUILD_DIR)/php_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_DEV_IPK_DIR=$(BUILD_DIR)/php-dev-$(PHP_VERSION)-ipk
PHP_DEV_IPK=$(BUILD_DIR)/php-dev_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_EMBED_IPK_DIR=$(BUILD_DIR)/php-embed-$(PHP_VERSION)-ipk
PHP_EMBED_IPK=$(BUILD_DIR)/php-embed_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_MBSTRING_IPK_DIR=$(BUILD_DIR)/php-mbstring-$(PHP_VERSION)-ipk
PHP_MBSTRING_IPK=$(BUILD_DIR)/php-mbstring_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_PEAR_IPK_DIR=$(BUILD_DIR)/php-pear-$(PHP_VERSION)-ipk
PHP_PEAR_IPK=$(BUILD_DIR)/php-pear_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_CONFIGURE_ARGS=
PHP_CONFIGURE_ENV=
PHP_TARGET_IPKS = \
	$(PHP_IPK) \
	$(PHP_DEV_IPK) \
	$(PHP_EMBED_IPK) \
	$(PHP_MBSTRING_IPK) \
	$(PHP_PEAR_IPK) \


.PHONY: php-source php-unpack php php-stage php-ipk php-clean php-dirclean php-check

#
# Automatically create a ipkg control file
#
$(PHP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: $(PHP_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_DEPENDS)" >>$@
	@echo "Conflicts: ${PHP_CONFLICTS}" >>$@

$(PHP_DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: php native development environment" >>$@
	@echo "Depends: php" >>$@

$(PHP_EMBED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-embed" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: php embedded library - the embed SAPI" >>$@
	@echo "Depends: php" >>$@

$(PHP_MBSTRING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-mbstring" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: mbstring extension for php" >>$@
	@echo "Depends: php" >>$@

$(PHP_PEAR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-pear" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: PHP Extension and Application Repository" >>$@
	@echo "Depends: php" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PHP_SOURCE):
	$(WGET) -P $(@D) $(PHP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
php-source: $(DL_DIR)/$(PHP_SOURCE) $(PHP_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(PHP_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_SOURCE) $(PHP_PATCHES) make/php.mk
	$(MAKE) bzip2-stage 
	$(MAKE) zlib-stage 
	$(MAKE) gdbm-stage 
	$(MAKE) pcre-stage
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(@D)
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PHP_DIR) $(@D)
	if test -n "$(PHP_PATCHES)"; \
	    then cat $(PHP_PATCHES) | patch -p0 -bd $(@D); \
	fi
#	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS) $(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		PATH="$(STAGING_DIR)/bin:$$PATH" \
		EXTENSION_DIR=/opt/lib/php/extensions \
		ac_cv_func_memcmp_working=yes \
		cv_php_mbstring_stdarg=yes \
		STAGING_PREFIX="$(STAGING_PREFIX)" \
		$(PHP_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-config-file-scan-dir=/opt/etc/php.d \
		--with-layout=GNU \
		--disable-static \
		--disable-all \
		--enable-fpm \
		--enable-session=shared \
                --enable-zip=shared \
		--enable-bcmath=shared \
		--enable-calendar=shared \
		--enable-embed=shared \
		--enable-exif=shared \
		--enable-ftp=shared \
		--enable-mbstring=shared \
		--enable-shmop=shared \
		--enable-sockets=shared \
		--enable-sysvmsg=shared \
		--enable-sysvshm=shared \
		--enable-sysvsem=shared \
		--with-bz2=shared,$(STAGING_PREFIX) \
		--with-gdbm=$(STAGING_PREFIX) \
		--with-zlib=shared,$(STAGING_PREFIX) \
		--with-freetype-dir=$(STAGING_PREFIX) \
		--with-zlib-dir=$(STAGING_PREFIX) \
		--with-pcre-regex=$(STAGING_PREFIX) \
		$(PHP_CONFIGURE_ARGS) \
		--without-pear \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

php-unpack: $(PHP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PHP_BUILD_DIR)/.built: $(PHP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
php: $(PHP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PHP_BUILD_DIR)/.staged: $(PHP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) INSTALL_ROOT=$(STAGING_DIR) program_prefix="" install
	cp $(STAGING_PREFIX)/bin/php-config $(STAGING_DIR)/bin/php-config
	cp $(STAGING_PREFIX)/bin/phpize $(STAGING_DIR)/bin/phpize
	sed -i -e 's!prefix=.*!prefix=$(STAGING_PREFIX)!' $(STAGING_DIR)/bin/phpize
	chmod a+rx $(STAGING_DIR)/bin/phpize
	touch $@

php-stage: $(PHP_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_IPK_DIR)/opt/sbin or $(PHP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PHP_IPK_DIR)/opt/etc/php/...
# Documentation files should be installed in $(PHP_IPK_DIR)/opt/doc/php/...
# Daemon startup scripts should be installed in $(PHP_IPK_DIR)/opt/etc/init.d/S??php
#
# You may need to patch your application to make it use these locations.
#
$(PHP_TARGET_IPKS): $(PHP_BUILD_DIR)/.built
	rm -rf $(PHP_IPK_DIR) $(BUILD_DIR)/php_*_$(TARGET_ARCH).ipk
	install -d $(PHP_IPK_DIR)/opt/var/lib/php/session
	chmod a=rwx $(PHP_IPK_DIR)/opt/var/lib/php/session
	$(MAKE) -C $(PHP_BUILD_DIR) INSTALL_ROOT=$(PHP_IPK_DIR) program_prefix="" install
	$(STRIP_COMMAND) $(PHP_IPK_DIR)/opt/bin/php
	$(STRIP_COMMAND) $(PHP_IPK_DIR)/opt/lib/*.so
	$(STRIP_COMMAND) $(PHP_IPK_DIR)/opt/lib/php/extensions/*.so
	rm -f $(PHP_IPK_DIR)/opt/lib/php/extensions/*.a
	install -d $(PHP_IPK_DIR)/opt/etc
	install -d $(PHP_IPK_DIR)/opt/etc/php.d
	install -m 644 $(PHP_SOURCE_DIR)/php.ini $(PHP_IPK_DIR)/opt/etc/php.ini
	install -m 644 $(PHP_SOURCE_DIR)/php-fpm.conf $(PHP_IPK_DIR)/opt/etc/php-fpm.conf
	install -d $(PHP_IPK_DIR)/opt/etc/init.d
	install -m 755 $(PHP_SOURCE_DIR)/rc.php-fpm $(PHP_IPK_DIR)/opt/etc/init.d/S99php-fpm
	### now make php-dev
	rm -rf $(PHP_DEV_IPK_DIR) $(BUILD_DIR)/php-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_DEV_IPK_DIR)/CONTROL/control
	install -d $(PHP_DEV_IPK_DIR)/opt/lib/php
	mv $(PHP_IPK_DIR)/opt/lib/php/build $(PHP_DEV_IPK_DIR)/opt/lib/php/
	mv $(PHP_IPK_DIR)/opt/include $(PHP_DEV_IPK_DIR)/opt/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_DEV_IPK_DIR)
	### now make php-embed
	rm -rf $(PHP_EMBED_IPK_DIR) $(BUILD_DIR)/php-embed_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_EMBED_IPK_DIR)/CONTROL/control
	install -d $(PHP_EMBED_IPK_DIR)/opt/lib/
	mv $(PHP_IPK_DIR)/opt/lib/libphp5.so $(PHP_EMBED_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_EMBED_IPK_DIR)

	### now make php-mbstring
	rm -rf $(PHP_MBSTRING_IPK_DIR) $(BUILD_DIR)/php-mbstring_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_MBSTRING_IPK_DIR)/CONTROL/control
	install -d $(PHP_MBSTRING_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_MBSTRING_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/mbstring.so $(PHP_MBSTRING_IPK_DIR)/opt/lib/php/extensions/mbstring.so
	echo extension=mbstring.so >$(PHP_MBSTRING_IPK_DIR)/opt/etc/php.d/mbstring.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MBSTRING_IPK_DIR)
	### now make php-pear
	rm -rf $(PHP_PEAR_IPK_DIR) $(BUILD_DIR)/php-pear_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_PEAR_IPK_DIR)/CONTROL/control
	install -m 644 $(PHP_SOURCE_DIR)/postinst.pear $(PHP_PEAR_IPK_DIR)/CONTROL/postinst
	install -m 644 $(PHP_SOURCE_DIR)/prerm.pear $(PHP_PEAR_IPK_DIR)/CONTROL/prerm
	install -d $(PHP_PEAR_IPK_DIR)/opt/etc
	install -m 644 $(PHP_SOURCE_DIR)/pear.conf $(PHP_PEAR_IPK_DIR)/opt/etc/pear.conf.new
	install -d $(PHP_PEAR_IPK_DIR)/opt/etc/pearkeys
	install -d $(PHP_PEAR_IPK_DIR)/opt/tmp
	cp -a $(PHP_BUILD_DIR)/pear $(PHP_PEAR_IPK_DIR)/opt/tmp
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_PEAR_IPK_DIR)
	### finally the main ipkg
	$(MAKE) $(PHP_IPK_DIR)/CONTROL/control
	echo $(PHP_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-ipk: $(PHP_TARGET_IPKS)

#
# This is called from the top level makefile to clean all of the built files.
#
php-clean:
	-$(MAKE) -C $(PHP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-dirclean:
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_BUILD_DIR) \
	$(PHP_IPK_DIR) $(PHP_IPK) \
	$(PHP_DEV_IPK_DIR) $(PHP_DEV_IPK) \
	$(PHP_EMBED_IPK_DIR) $(PHP_EMBED_IPK) \
	$(PHP_MBSTRING_IPK_DIR) $(PHP_MBSTRING_IPK) \
	$(PHP_PEAR_IPK_DIR) $(PHP_PEAR_IPK) \
	;


#
# Some sanity check for the package.
#
php-check: $(PHP_TARGET_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
