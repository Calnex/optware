###########################################################
#
# debian
#
###########################################################

# You must replace "debian" and "DEBIAN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DEBIAN_VERSION, DEBIAN_SITE and DEBIAN_SOURCE define
# the upstream location of the source code for the package.
# DEBIAN_DIR is the directory which is created when the source
# archive is unpacked.
# DEBIAN_UNZIP is the command used to unzip the source.
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
DEBIAN_VERSION=3.13.5
DEBIAN_SOURCE=debian-$(DEBIAN_VERSION).tar.gz
DEBIAN_DIR=debian-$(DEBIAN_VERSION)
DEBIAN_UNZIP=zcat
DEBIAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DEBIAN_DESCRIPTION=Describe debian here.
DEBIAN_SECTION=
DEBIAN_PRIORITY=optional
DEBIAN_DEPENDS=
DEBIAN_SUGGESTS=
DEBIAN_CONFLICTS=

#
# DEBIAN_IPK_VERSION should be incremented when the ipk changes.
#
DEBIAN_IPK_VERSION=1

#
# DEBIAN_BUILD_DIR is the directory in which the build is done.
# DEBIAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DEBIAN_IPK_DIR is the directory in which the ipk is built.
# DEBIAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEBIAN_BUILD_DIR=$(BUILD_DIR)/debian
DEBIAN_SOURCE_DIR=$(SOURCE_DIR)/debian
DEBIAN_IPK_DIR=$(BUILD_DIR)/debian-$(DEBIAN_VERSION)-ipk
DEBIAN_IPK=$(BUILD_DIR)/debian_$(DEBIAN_VERSION)-$(DEBIAN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: debian-unpack debian debian-ipk debian-clean debian-dirclean debian-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DEBIAN_SOURCE):

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
$(DEBIAN_BUILD_DIR)/.configured: $(DL_DIR)/$(DEBIAN_SOURCE) make/debian.mk
	rm -rf $(BUILD_DIR)/$(DEBIAN_DIR) $(@D)
	$(DEBIAN_UNZIP) $(DL_DIR)/$(DEBIAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(DEBIAN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DEBIAN_DIR) $(@D) ; \
	fi
	touch $@

debian-unpack: $(DEBIAN_BUILD_DIR)/.configured

#
# This is the build convenience target.
#
debian: $(DEBIAN_IPK)

#
# If you are building a library, then you need to stage it too.
#
$(DEBIAN_BUILD_DIR)/.staged: $(DEBIAN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

debian-stage: $(DEBIAN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/debian
#
$(DEBIAN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: debian" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEBIAN_PRIORITY)" >>$@
	@echo "Section: $(DEBIAN_SECTION)" >>$@
	@echo "Version: $(DEBIAN_VERSION)-$(DEBIAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEBIAN_MAINTAINER)" >>$@
	@echo "Source: $(DEBIAN_SITE)/$(DEBIAN_SOURCE)" >>$@
	@echo "Description: $(DEBIAN_DESCRIPTION)" >>$@
	@echo "Depends: $(DEBIAN_DEPENDS)" >>$@
	@echo "Suggests: $(DEBIAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEBIAN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEBIAN_IPK_DIR)/opt/sbin or $(DEBIAN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEBIAN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEBIAN_IPK_DIR)/opt/etc/debian/...
# Documentation files should be installed in $(DEBIAN_IPK_DIR)/opt/doc/debian/...
# Daemon startup scripts should be installed in $(DEBIAN_IPK_DIR)/opt/etc/init.d/S??debian
#
# You may need to patch your application to make it use these locations.
#
$(DEBIAN_IPK):
	rm -rf $(DEBIAN_IPK_DIR) $(BUILD_DIR)/debian_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DEBIAN_BUILD_DIR) DESTDIR=$(DEBIAN_IPK_DIR) install-strip
	$(MAKE) $(DEBIAN_IPK_DIR)/CONTROL/control
	install -m 755 $(DEBIAN_SOURCE_DIR)/postinst $(DEBIAN_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DEBIAN_IPK_DIR)/CONTROL/postinst
	install -m 755 $(DEBIAN_SOURCE_DIR)/prerm $(DEBIAN_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DEBIAN_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(DEBIAN_IPK_DIR)/CONTROL/postinst $(DEBIAN_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(DEBIAN_CONFFILES) | sed -e 's/ /\n/g' > $(DEBIAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEBIAN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DEBIAN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
debian-ipk: $(DEBIAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
debian-clean:
	rm -f $(DEBIAN_BUILD_DIR)/.built
	-$(MAKE) -C $(DEBIAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
debian-dirclean:
	rm -rf $(BUILD_DIR)/$(DEBIAN_DIR) $(DEBIAN_BUILD_DIR) $(DEBIAN_IPK_DIR) $(DEBIAN_IPK)
#
#
# Some sanity check for the package.
#
debian-check: $(DEBIAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
