###########################################################
#
# debian-dummy
#
###########################################################

# You must replace "debian-dummy" and "DEBIAN-DUMMY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DEBIAN-DUMMY_VERSION, DEBIAN-DUMMY_SITE and DEBIAN-DUMMY_SOURCE define
# the upstream location of the source code for the package.
# DEBIAN-DUMMY_DIR is the directory which is created when the source
# archive is unpacked.
# DEBIAN-DUMMY_UNZIP is the command used to unzip the source.
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
DEBIAN-DUMMY_VERSION=$(SNAPSHOT_VERSION)
DEBIAN-DUMMY_DIR=debian-dummy-$(DEBIAN-DUMMY_VERSION)
DEBIAN-DUMMY_MAINTAINER=Calnex Solutions <www.calnexsol.com>
DEBIAN-DUMMY_DESCRIPTION=Minimal install of the Debian GNU/Linux Operating System
DEBIAN-DUMMY_SECTION=kernel
DEBIAN-DUMMY_PRIORITY=optional
DEBIAN-DUMMY_DEPENDS=
DEBIAN-DUMMY_SUGGESTS=
DEBIAN-DUMMY_CONFLICTS=

#
# DEBIAN-DUMMY_IPK_VERSION should be incremented when the ipk changes.
#
DEBIAN-DUMMY_IPK_VERSION=$(DEBIAN_IPK_VERSION)

#
# DEBIAN-DUMMY_CONFFILES should be a list of user-editable files
#DEBIAN-DUMMY_CONFFILES=/opt/etc/debian-dummy.conf /opt/etc/init.d/SXXdebian-dummy

#
# DEBIAN-DUMMY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DEBIAN-DUMMY_CONFIG=$(DEBIAN-DUMMY_SRC_DIR)/config

#
# DEBIAN-DUMMY_BUILD_DIR is the directory in which the build is done.
# DEBIAN-DUMMY_SRC_DIR is the directory which holds all the
# patches and ipkg control files.
# DEBIAN-DUMMY_IPK_DIR is the directory in which the ipk is built.
# DEBIAN-DUMMY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEBIAN-DUMMY_BUILD_DIR=$(BUILD_DIR)/debian-dummy
DEBIAN-DUMMY_IPK_DIR=$(BUILD_DIR)/debian-$(DEBIAN-DUMMY_VERSION)-dummy-ipk
DEBIAN-DUMMY_IPK=$(BUILD_DIR)/debian_$(DEBIAN-DUMMY_VERSION)-$(DEBIAN-DUMMY_IPK_VERSION)-dummy_$(TARGET_ARCH).ipk

.PHONY: debian-dummy-source debian-dummy-unpack debian-dummy debian-dummy-stage debian-dummy-ipk debian-dummy-clean debian-dummy-dirclean debian-dummy-check

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/debian-dummy
#
$(DEBIAN-DUMMY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: debian" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEBIAN-DUMMY_PRIORITY)" >>$@
	@echo "Section: $(DEBIAN-DUMMY_SECTION)" >>$@
	@echo "Version: $(DEBIAN-DUMMY_VERSION)-$(DEBIAN-DUMMY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEBIAN-DUMMY_MAINTAINER)" >>$@
	@echo "Source: $(DEBIAN-DUMMY_SITE)/$(DEBIAN-DUMMY_SOURCE)" >>$@
	@echo "Description: $(DEBIAN-DUMMY_DESCRIPTION)" >>$@
	@echo "Depends: $(DEBIAN-DUMMY_DEPENDS)" >>$@
	@echo "Suggests: $(DEBIAN-DUMMY_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEBIAN-DUMMY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEBIAN-DUMMY_IPK_DIR)/opt/sbin or $(DEBIAN-DUMMY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEBIAN-DUMMY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEBIAN-DUMMY_IPK_DIR)/opt/etc/debian-dummy/...
# Documentation files should be installed in $(DEBIAN-DUMMY_IPK_DIR)/opt/doc/debian-dummy/...
# Daemon startup scripts should be installed in $(DEBIAN-DUMMY_IPK_DIR)/opt/etc/init.d/S??debian-dummy
#
# You may need to patch your application to make it use these locations.
#
$(DEBIAN-DUMMY_IPK):
	rm -rf $(DEBIAN-DUMMY_IPK_DIR) $(BUILD_DIR)/debian_*-dummy_$(TARGET_ARCH).ipk
	$(MAKE) $(DEBIAN-DUMMY_IPK_DIR)/CONTROL/control
	echo $(DEBIAN-DUMMY_CONFFILES) | sed -e 's/ /\n/g' > $(DEBIAN-DUMMY_IPK_DIR)/CONTROL/conffiles
	install -d $(DEBIAN-DUMMY_IPK_DIR)/opt/var/lib/debian
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEBIAN-DUMMY_IPK_DIR) $(DEBIAN-DUMMY_IPK_DIR)
	mv $(DEBIAN-DUMMY_IPK_DIR)/debian_*_$(TARGET_ARCH).ipk $(DEBIAN-DUMMY_IPK)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DEBIAN-DUMMY_IPK_DIR)

$(DEBIAN-DUMMY_BUILD_DIR)/.ipk: $(DEBIAN-DUMMY_IPK)

debian-dummy-ipk: $(DEBIAN-DUMMY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
debian-dummy-clean:
	sudo rm -rf $(DEBIAN-DUMMY_BUILD_DIR)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
debian-dummy-dirclean:
	rm -rf $(BUILD_DIR)/$(DEBIAN-DUMMY_DIR) $(DEBIAN-DUMMY_BUILD_DIR) $(DEBIAN-DUMMY_IPK_DIR) $(DEBIAN-DUMMY_IPK)
#
#
# Some sanity check for the package.
#
debian-dummy-check: $(DEBIAN-DUMMY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
