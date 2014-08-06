###########################################################
#
# intltool
#
###########################################################

# You must replace "intltool" and "INTLTOOL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# INTLTOOL_VERSION, INTLTOOL_SITE and INTLTOOL_SOURCE define
# the upstream location of the source code for the package.
# INTLTOOL_DIR is the directory which is created when the source
# archive is unpacked.
# INTLTOOL_UNZIP is the command used to unzip the source.
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
INTLTOOL_SITE=https://launchpad.net/intltool/trunk/$(INTLTOOL_VERSION)/+download
INTLTOOL_VERSION=0.50.2
INTLTOOL_SOURCE=intltool-$(INTLTOOL_VERSION).tar.gz
INTLTOOL_DIR=intltool-$(INTLTOOL_VERSION)
INTLTOOL_UNZIP=zcat
INTLTOOL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
INTLTOOL_DESCRIPTION=Describe intltool here.
INTLTOOL_SECTION=
INTLTOOL_PRIORITY=optional
INTLTOOL_DEPENDS=
INTLTOOL_SUGGESTS=
INTLTOOL_CONFLICTS=

#
# INTLTOOL_IPK_VERSION should be incremented when the ipk changes.
#
INTLTOOL_IPK_VERSION=1

#
# INTLTOOL_CONFFILES should be a list of user-editable files
#INTLTOOL_CONFFILES=/opt/etc/intltool.conf /opt/etc/init.d/SXXintltool

#
# INTLTOOL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#INTLTOOL_PATCHES=$(INTLTOOL_SOURCE_DIR)/configure.patch
INTLTOOL_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
INTLTOOL_CPPFLAGS=
INTLTOOL_LDFLAGS=

#
# INTLTOOL_BUILD_DIR is the directory in which the build is done.
# INTLTOOL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# INTLTOOL_IPK_DIR is the directory in which the ipk is built.
# INTLTOOL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
INTLTOOL_BUILD_DIR=$(BUILD_DIR)/intltool
INTLTOOL_SOURCE_DIR=$(SOURCE_DIR)/intltool
INTLTOOL_IPK_DIR=$(BUILD_DIR)/intltool-$(INTLTOOL_VERSION)-ipk
INTLTOOL_IPK=$(BUILD_DIR)/intltool_$(INTLTOOL_VERSION)-$(INTLTOOL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: intltool-source intltool-unpack intltool intltool-stage intltool-ipk intltool-clean intltool-dirclean intltool-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(INTLTOOL_SOURCE):
	$(WGET) -P $(@D) $(INTLTOOL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
intltool-source: $(DL_DIR)/$(INTLTOOL_SOURCE) $(INTLTOOL_PATCHES)

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
$(INTLTOOL_BUILD_DIR)/.configured: $(DL_DIR)/$(INTLTOOL_SOURCE) $(INTLTOOL_PATCHES) make/intltool.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(INTLTOOL_DIR) $(@D)
	$(INTLTOOL_UNZIP) $(DL_DIR)/$(INTLTOOL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(INTLTOOL_PATCHES)" ; \
		then cat $(INTLTOOL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(INTLTOOL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(INTLTOOL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(INTLTOOL_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INTLTOOL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INTLTOOL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

intltool-unpack: $(INTLTOOL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(INTLTOOL_BUILD_DIR)/.built: $(INTLTOOL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
intltool: $(INTLTOOL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(INTLTOOL_BUILD_DIR)/.staged: $(INTLTOOL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

intltool-stage: $(INTLTOOL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/intltool
#
$(INTLTOOL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: intltool" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INTLTOOL_PRIORITY)" >>$@
	@echo "Section: $(INTLTOOL_SECTION)" >>$@
	@echo "Version: $(INTLTOOL_VERSION)-$(INTLTOOL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INTLTOOL_MAINTAINER)" >>$@
	@echo "Source: $(INTLTOOL_SITE)/$(INTLTOOL_SOURCE)" >>$@
	@echo "Description: $(INTLTOOL_DESCRIPTION)" >>$@
	@echo "Depends: $(INTLTOOL_DEPENDS)" >>$@
	@echo "Suggests: $(INTLTOOL_SUGGESTS)" >>$@
	@echo "Conflicts: $(INTLTOOL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(INTLTOOL_IPK_DIR)/opt/sbin or $(INTLTOOL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(INTLTOOL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(INTLTOOL_IPK_DIR)/opt/etc/intltool/...
# Documentation files should be installed in $(INTLTOOL_IPK_DIR)/opt/doc/intltool/...
# Daemon startup scripts should be installed in $(INTLTOOL_IPK_DIR)/opt/etc/init.d/S??intltool
#
# You may need to patch your application to make it use these locations.
#
$(INTLTOOL_IPK): $(INTLTOOL_BUILD_DIR)/.built
	rm -rf $(INTLTOOL_IPK_DIR) $(BUILD_DIR)/intltool_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(INTLTOOL_BUILD_DIR) DESTDIR=$(INTLTOOL_IPK_DIR) install-strip
#	install -d $(INTLTOOL_IPK_DIR)/opt/etc/
#	install -m 644 $(INTLTOOL_SOURCE_DIR)/intltool.conf $(INTLTOOL_IPK_DIR)/opt/etc/intltool.conf
#	install -d $(INTLTOOL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(INTLTOOL_SOURCE_DIR)/rc.intltool $(INTLTOOL_IPK_DIR)/opt/etc/init.d/SXXintltool
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(INTLTOOL_IPK_DIR)/opt/etc/init.d/SXXintltool
	$(MAKE) $(INTLTOOL_IPK_DIR)/CONTROL/control
#	install -m 755 $(INTLTOOL_SOURCE_DIR)/postinst $(INTLTOOL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(INTLTOOL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(INTLTOOL_SOURCE_DIR)/prerm $(INTLTOOL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(INTLTOOL_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(INTLTOOL_IPK_DIR)/CONTROL/postinst $(INTLTOOL_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(INTLTOOL_CONFFILES) | sed -e 's/ /\n/g' > $(INTLTOOL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INTLTOOL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(INTLTOOL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
intltool-ipk: $(INTLTOOL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
intltool-clean:
	rm -f $(INTLTOOL_BUILD_DIR)/.built
	-$(MAKE) -C $(INTLTOOL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
intltool-dirclean:
	rm -rf $(BUILD_DIR)/$(INTLTOOL_DIR) $(INTLTOOL_BUILD_DIR) $(INTLTOOL_IPK_DIR) $(INTLTOOL_IPK)
#
#
# Some sanity check for the package.
#
intltool-check: $(INTLTOOL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
