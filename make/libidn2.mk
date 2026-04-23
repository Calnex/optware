###########################################################
#
# libidn2
#
###########################################################

# You must replace "libidn2" and "LIBIDN2" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBIDN2_VERSION, LIBIDN2_SITE and LIBIDN2_SOURCE define
# the upstream location of the source code for the package.
# LIBIDN2_DIR is the directory which is created when the source
# archive is unpacked.
# LIBIDN2_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#

LIBIDN2_CALNEX_SITE=$(PACKAGES_SERVER)

LIBIDN2_SITE=http://ftp.gnu.org/gnu/libidn
LIBIDN2_VERSION=2.3.8
LIBIDN2_SOURCE=libidn2-$(LIBIDN2_VERSION).tar.gz
LIBIDN2_DIR=libidn2-$(LIBIDN2_VERSION)
LIBIDN2_UNZIP=zcat
LIBIDN2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBIDN2_DESCRIPTION=GNU Libidn2 is an implementation of the Stringprep, Punycode and IDNA specifications defined by the IETF Internationalized Domain Names (IDN) working group, used for internationalized domain names.
LIBIDN2_SECTION=lib
LIBIDN2_PRIORITY=optional
LIBIDN2_DEPENDS=
LIBIDN2_SUGGESTS=
LIBIDN2_CONFLICTS=

#
# LIBIDN2_IPK_VERSION should be incremented when the ipk changes.
#
LIBIDN2_IPK_VERSION=1

#
# LIBIDN2_CONFFILES should be a list of user-editable files
#LIBIDN2_CONFFILES=/opt/etc/libidn.conf /opt/etc/init.d/SXXlibidn

#
# LIBIDN2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBIDN2_PATCHES=$(LIBIDN2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBIDN2_CPPFLAGS=
LIBIDN2_LDFLAGS=

# Options to pass to the make that is performed when building the code
LIBIDN2_MAKE_OPTIONS=-j


#
# LIBIDN2_BUILD_DIR is the directory in which the build is done.
# LIBIDN2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBIDN2_IPK_DIR is the directory in which the ipk is built.
# LIBIDN2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBIDN2_BUILD_DIR=$(BUILD_DIR)/libidn2
LIBIDN2_SOURCE_DIR=$(SOURCE_DIR)/libidn2
LIBIDN2_IPK_DIR=$(BUILD_DIR)/libidn2-$(LIBIDN2_VERSION)-ipk
LIBIDN2_IPK=$(BUILD_DIR)/libidn2_$(LIBIDN2_VERSION)-$(LIBIDN2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libidn2-source libidn2-unpack libidn2 libidn2-stage libidn2-ipk libidn2-clean libidn2-dirclean libidn2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBIDN2_SOURCE):
	$(WGET) -P $(@D) $(LIBIDN2_CALNEX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(LIBIDN2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libidn2-source: $(DL_DIR)/$(LIBIDN2_SOURCE) $(LIBIDN2_PATCHES)

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
$(LIBIDN2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBIDN2_SOURCE) $(LIBIDN2_PATCHES) make/libidn2.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBIDN2_DIR) $(@D)
	$(LIBIDN2_UNZIP) $(DL_DIR)/$(LIBIDN2_SOURCE) | tar -C $(BUILD_DIR) -xf -
#	cat $(LIBIDN2_PATCHES) | patch -d $(BUILD_DIR)/$(LIBIDN2_DIR) -p1
	mv $(BUILD_DIR)/$(LIBIDN2_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBIDN2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBIDN2_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-csharp \
		--disable-java \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libidn2-unpack: $(LIBIDN2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBIDN2_BUILD_DIR)/.built: $(LIBIDN2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) $(LIBIDN2_MAKE_OPTIONS) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libidn2: $(LIBIDN2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBIDN2_BUILD_DIR)/.staged: $(LIBIDN2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libidn2.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libidn2.pc
	(\
		cd $(STAGING_DIR)/opt/share/info && \
		rm -f dir && \
		for f in *.info ; do ginstall-info $$f dir ; done \
	)
	touch $@

libidn2-stage: $(LIBIDN2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libidn2
#
$(LIBIDN2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libidn2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBIDN2_PRIORITY)" >>$@
	@echo "Section: $(LIBIDN2_SECTION)" >>$@
	@echo "Version: $(LIBIDN2_VERSION)-$(LIBIDN2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBIDN2_MAINTAINER)" >>$@
	@echo "Source: $(LIBIDN2_SITE)/$(LIBIDN2_SOURCE)" >>$@
	@echo "Description: $(LIBIDN2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBIDN2_DEPENDS)" >>$@
	@echo "Suggests: $(LIBIDN2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBIDN2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBIDN2_IPK_DIR)/opt/sbin or $(LIBIDN2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBIDN2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBIDN2_IPK_DIR)/opt/etc/libidn2/...
# Documentation files should be installed in $(LIBIDN2_IPK_DIR)/opt/doc/libidn2/...
# Daemon startup scripts should be installed in $(LIBIDN2_IPK_DIR)/opt/etc/init.d/S??libidn2
#
# You may need to patch your application to make it use these locations.
#
$(LIBIDN2_IPK): $(LIBIDN2_BUILD_DIR)/.built
	rm -rf $(LIBIDN2_IPK_DIR) $(BUILD_DIR)/libidn2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBIDN2_BUILD_DIR) DESTDIR=$(LIBIDN2_IPK_DIR) install-strip
	rm -f $(LIBIDN2_IPK_DIR)/opt/lib/libidn2.a
	$(MAKE) $(LIBIDN2_IPK_DIR)/CONTROL/control
	rm -f $(LIBIDN2_IPK_DIR)/opt/share/info/dir*
	install -m 755 $(SOURCE_DIR)/common/gen_info_dir  $(LIBIDN2_IPK_DIR)/CONTROL/postinst
	install -m 755 $(SOURCE_DIR)/common/gen_info_dir  $(LIBIDN2_IPK_DIR)/CONTROL/postrm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBIDN2_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBIDN2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libidn2-ipk: $(LIBIDN2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libidn2-clean:
	$(MAKE) -C $(LIBIDN2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libidn2-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBIDN2_DIR) $(LIBIDN2_BUILD_DIR) $(LIBIDN2_IPK_DIR) $(LIBIDN2_IPK)

libidn2-check: $(LIBIDN2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
