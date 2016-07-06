###########################################################
#
# nettle
#
###########################################################

# You must replace "nettle" and "NETTLE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NETTLE_VERSION, NETTLE_SITE and NETTLE_SOURCE define
# the upstream location of the source code for the package.
# NETTLE_DIR is the directory which is created when the source
# archive is unpacked.
# NETTLE_UNZIP is the command used to unzip the source.
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

NETTLE_CALNEX_SITE=$(PACKAGES_SERVER)

NETTLE_SITE=http://www.lysator.liu.se/~nisse/archive
NETTLE_VERSION=2.7.1
NETTLE_SOURCE=nettle-$(NETTLE_VERSION).tar.gz
NETTLE_DIR=nettle-$(NETTLE_VERSION)
NETTLE_UNZIP=zcat
NETTLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NETTLE_DESCRIPTION=Describe nettle here.
NETTLE_SECTION=libs
NETTLE_PRIORITY=optional
NETTLE_DEPENDS=libgmp
NETTLE_SUGGESTS=
NETTLE_CONFLICTS=

#
# NETTLE_IPK_VERSION should be incremented when the ipk changes.
#
NETTLE_IPK_VERSION=1

#
# NETTLE_CONFFILES should be a list of user-editable files
#NETTLE_CONFFILES=/opt/etc/nettle.conf /opt/etc/init.d/SXXnettle

#
# NETTLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NETTLE_PATCHES=$(NETTLE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NETTLE_CPPFLAGS=
NETTLE_LDFLAGS=

#
# NETTLE_BUILD_DIR is the directory in which the build is done.
# NETTLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETTLE_IPK_DIR is the directory in which the ipk is built.
# NETTLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETTLE_BUILD_DIR=$(BUILD_DIR)/nettle
NETTLE_SOURCE_DIR=$(SOURCE_DIR)/nettle
NETTLE_IPK_DIR=$(BUILD_DIR)/nettle-$(NETTLE_VERSION)-ipk
NETTLE_IPK=$(BUILD_DIR)/nettle_$(NETTLE_VERSION)-$(NETTLE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nettle-source nettle-unpack nettle nettle-stage nettle-ipk nettle-clean nettle-dirclean nettle-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETTLE_SOURCE):
	$(WGET) -P $(@D) $(NETTLE_CALNEX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(NETTLE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nettle-source: $(DL_DIR)/$(NETTLE_SOURCE) $(NETTLE_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(NETTLE_BUILD_DIR)/.configured: $(DL_DIR)/$(NETTLE_SOURCE) $(NETTLE_PATCHES) make/nettle.mk
	$(MAKE) libgmp-stage 
	rm -rf $(BUILD_DIR)/$(NETTLE_DIR) $(@D)
	$(NETTLE_UNZIP) $(DL_DIR)/$(NETTLE_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test "$(BUILD_DIR)/$(NETTLE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NETTLE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NETTLE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NETTLE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--exec_prefix=/opt \
		--includedir=/opt/include \
		--disable-nls \
	)
	touch $@

nettle-unpack: $(NETTLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NETTLE_BUILD_DIR)/.built: $(NETTLE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
nettle: $(NETTLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NETTLE_BUILD_DIR)/.staged: $(NETTLE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	(\
		cd $(STAGING_DIR)/opt/share/info && \
		rm -f dir && \
		for f in *.info ; do ginstall-info $$f dir ; done \
	)
	touch $@

nettle-stage: $(NETTLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nettle
#
$(NETTLE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nettle" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NETTLE_PRIORITY)" >>$@
	@echo "Section: $(NETTLE_SECTION)" >>$@
	@echo "Version: $(NETTLE_VERSION)-$(NETTLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NETTLE_MAINTAINER)" >>$@
	@echo "Source: $(NETTLE_SITE)/$(NETTLE_SOURCE)" >>$@
	@echo "Description: $(NETTLE_DESCRIPTION)" >>$@
	@echo "Depends: $(NETTLE_DEPENDS)" >>$@
	@echo "Suggests: $(NETTLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(NETTLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETTLE_IPK_DIR)/opt/sbin or $(NETTLE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETTLE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETTLE_IPK_DIR)/opt/etc/nettle/...
# Documentation files should be installed in $(NETTLE_IPK_DIR)/opt/doc/nettle/...
# Daemon startup scripts should be installed in $(NETTLE_IPK_DIR)/opt/etc/init.d/S??nettle
#
# You may need to patch your application to make it use these locations.
#
$(NETTLE_IPK): $(NETTLE_BUILD_DIR)/.built
	rm -rf $(NETTLE_IPK_DIR) $(BUILD_DIR)/nettle_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NETTLE_BUILD_DIR) DESTDIR=$(NETTLE_IPK_DIR) install
	$(MAKE) $(NETTLE_IPK_DIR)/CONTROL/control
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
	echo $(NETTLE_CONFFILES) | sed -e 's/ /\n/g' > $(NETTLE_IPK_DIR)/CONTROL/conffiles
	rm -f $(NETTLE_IPK_DIR)/opt/share/info/dir*
	install -m 755 $(SOURCE_DIR)/common/gen_info_dir  $(NETTLE_IPK_DIR)/CONTROL/postinst
	install -m 755 $(SOURCE_DIR)/common/gen_info_dir  $(NETTLE_IPK_DIR)/CONTROL/postrm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETTLE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NETTLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nettle-ipk: $(NETTLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nettle-clean:
	rm -f $(NETTLE_BUILD_DIR)/.built
	$(MAKE) -C $(NETTLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nettle-dirclean:
	rm -rf $(BUILD_DIR)/$(NETTLE_DIR) $(NETTLE_BUILD_DIR) $(NETTLE_IPK_DIR) $(NETTLE_IPK)
#
#
# Some sanity check for the package.
#
nettle-check: $(NETTLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
