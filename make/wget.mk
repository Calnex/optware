###########################################################
#
# wget
#
###########################################################
#
# WGET_VERSION, WGET_SITE and WGET_SOURCE define
# the upstream location of the source code for the package.
# WGET_DIR is the directory which is created when the source
# archive is unpacked.
# WGET_UNZIP is the command used to unzip the source.
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
WGET_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/wget
WGET_VERSION=3.2.1
WGET_SOURCE=wget-$(WGET_VERSION).tar.gz
WGET_DIR=wget-$(WGET_VERSION)
WGET_UNZIP=zcat
WGET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WGET_DESCRIPTION=Describe wget here.
WGET_SECTION=
WGET_PRIORITY=optional
WGET_DEPENDS=
WGET_SUGGESTS=
WGET_CONFLICTS=

#
# WGET_IPK_VERSION should be incremented when the ipk changes.
#
WGET_IPK_VERSION=1

#
# WGET_CONFFILES should be a list of user-editable files
# Adding user editable files will cause the GUI install to 
# hang waiting for user input DO NOT DO THIS!
#WGET_CONFFILES=/opt/etc/wget.conf /opt/etc/init.d/SXXwget

#
# WGET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
WGET_PATCHES=$(WGET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WGET_CPPFLAGS=
WGET_LDFLAGS=

#
# WGET_BUILD_DIR is the directory in which the build is done.
# WGET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WGET_IPK_DIR is the directory in which the ipk is built.
# WGET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WGET_BUILD_DIR=$(BUILD_DIR)/wget
WGET_SOURCE_DIR=$(SOURCE_DIR)/wget
WGET_IPK_DIR=$(BUILD_DIR)/wget-$(WGET_VERSION)-ipk
WGET_IPK=$(BUILD_DIR)/wget_$(WGET_VERSION)-$(WGET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: wget-source wget-unpack wget wget-stage wget-ipk wget-clean wget-dirclean wget-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WGET_SOURCE):
	$(WGET) -P $(@D) $(WGET_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wget-source: $(DL_DIR)/$(WGET_SOURCE) $(WGET_PATCHES)

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
$(WGET_BUILD_DIR)/.configured: $(DL_DIR)/$(WGET_SOURCE) $(WGET_PATCHES) make/wget.mk
	$(MAKE) wget-stage <bar>-stage
	rm -rf $(BUILD_DIR)/$(WGET_DIR) $(@D)
	$(WGET_UNZIP) $(DL_DIR)/$(WGET_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(WGET_PATCHES)" ; \
		then cat $(WGET_PATCHES) | \
		patch -d $(BUILD_DIR)/$(WGET_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(WGET_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(WGET_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WGET_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

wget-unpack: $(WGET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WGET_BUILD_DIR)/.built: $(WGET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
wget: $(WGET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WGET_BUILD_DIR)/.staged: $(WGET_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

wget-stage: $(WGET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wget
#
$(WGET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: wget" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WGET_PRIORITY)" >>$@
	@echo "Section: $(WGET_SECTION)" >>$@
	@echo "Version: $(WGET_VERSION)-$(WGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WGET_MAINTAINER)" >>$@
	@echo "Source: $(WGET_SITE)/$(WGET_SOURCE)" >>$@
	@echo "Description: $(WGET_DESCRIPTION)" >>$@
	@echo "Depends: $(WGET_DEPENDS)" >>$@
	@echo "Suggests: $(WGET_SUGGESTS)" >>$@
	@echo "Conflicts: $(WGET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WGET_IPK_DIR)/opt/sbin or $(WGET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WGET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WGET_IPK_DIR)/opt/etc/wget/...
# Documentation files should be installed in $(WGET_IPK_DIR)/opt/doc/wget/...
# Daemon startup scripts should be installed in $(WGET_IPK_DIR)/opt/etc/init.d/S??wget
#
# You may need to patch your application to make it use these locations.
#
$(WGET_IPK): $(WGET_BUILD_DIR)/.built
	rm -rf $(WGET_IPK_DIR) $(BUILD_DIR)/wget_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(WGET_BUILD_DIR) DESTDIR=$(WGET_IPK_DIR) install-strip
#	install -d $(WGET_IPK_DIR)/opt/etc/
#	install -m 644 $(WGET_SOURCE_DIR)/wget.conf $(WGET_IPK_DIR)/opt/etc/wget.conf
#	install -d $(WGET_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(WGET_SOURCE_DIR)/rc.wget $(WGET_IPK_DIR)/opt/etc/init.d/SXXwget
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WGET_IPK_DIR)/opt/etc/init.d/SXXwget
	$(MAKE) $(WGET_IPK_DIR)/CONTROL/control
#	install -m 755 $(WGET_SOURCE_DIR)/postinst $(WGET_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WGET_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(WGET_SOURCE_DIR)/prerm $(WGET_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WGET_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(WGET_IPK_DIR)/CONTROL/postinst $(WGET_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(WGET_CONFFILES) | sed -e 's/ /\n/g' > $(WGET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WGET_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(WGET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wget-ipk: $(WGET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wget-clean:
	rm -f $(WGET_BUILD_DIR)/.built
	$(MAKE) -C $(WGET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wget-dirclean:
	rm -rf $(BUILD_DIR)/$(WGET_DIR) $(WGET_BUILD_DIR) $(WGET_IPK_DIR) $(WGET_IPK)
#
#
# Some sanity check for the package.
#
wget-check: $(WGET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
