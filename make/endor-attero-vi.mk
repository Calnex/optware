###########################################################
#
# endor
#
###########################################################

# You must replace "endor" and "ENDOR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ENDOR_ATTERO_VI_VERSION, ENDOR_ATTERO_VI_SITE and ENDOR_ATTERO_VI_SOURCE define
# the upstream location of the source code for the package.
# ENDOR_DIR is the directory which is created when the source
# archive is unpacked.
# ENDOR_UNZIP is the command used to unzip the source.
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
ENDOR_ATTERO_VI_REPOSITORY=https://github.com/Calnex/Springbank
ENDOR_ATTERO_VI_DOCUMENTATION_REPOSITORY=https://github.com/Calnex/EndorDocumentation
ENDOR_ATTERO_VI_VERSION=1.0
ENDOR_ATTERO_VI_SOURCE=endor-attero-vi-$(ENDOR_ATTERO_VI_VERSION).tar.gz
ENDOR_ATTERO_VI_DIR=endor-attero-vi-$(ENDOR_ATTERO_VI_VERSION)
ENDOR_ATTERO_VI_UNZIP=zcat
ENDOR_ATTERO_VI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENDOR_ATTERO_VI_DESCRIPTION=Describe endor here.
ENDOR_ATTERO_VI_SECTION=base
ENDOR_ATTERO_VI_PRIORITY=optional
ENDOR_ATTERO_VI_DEPENDS=endor-attero-ipk
ENDOR_ATTERO_VI_SUGGESTS=
ENDOR_ATTERO_VI_CONFLICTS=endor-paragon-vi-ipk

#
# ENDOR_IPK_VERSION should be incremented when the ipk changes.
#
ENDOR_ATTERO_VI_IPK_VERSION=attero-vi

#
# ENDOR_CONFFILES should be a list of user-editable files
#ENDOR_CONFFILES=/opt/etc/endor.conf /opt/etc/init.d/SXXendor

#
# ENDOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ENDOR_PATCHES=$(ENDOR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENDOR_ATTERO_VI_CPPFLAGS=
ENDOR_ATTERO_VI_LDFLAGS=

#
# ENDOR_BUILD_DIR is the directory in which the build is done.
# ENDOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENDOR_IPK_DIR is the directory in which the ipk is built.
# ENDOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ENDOR_ATTERO_VI_GIT_TAG?=HEAD
ENDOR_ATTERO_VI_GIT_OPTIONS?=
ENDOR_ATTERO_VI_TREEISH=$(ENDOR_ATTERO_VI_GIT_TAG)
ENDOR_ATTERO_VI_BUILD_DIR=$(BUILD_DIR)/endor-attero-vi
ENDOR_ATTERO_VI_SOURCE_DIR=$(SOURCE_DIR)/endor-attero-vi
ENDOR_ATTERO_VI_IPK_DIR=$(BUILD_DIR)/endor-attero-vi-$(ENDOR_ATTERO_VI_VERSION)-ipk
ENDOR_ATTERO_VI_IPK=$(BUILD_DIR)/endor-attero-vi_$(ENDOR_ATTERO_VI_VERSION)-$(ENDOR_ATTERO_VI_IPK_VERSION)_$(TARGET_ARCH).ipk
ENDOR_ATTERO_VI_BUILD_UTILITIES_DIR=$(BUILD_DIR)/../BuildUtilities

ENDOR_ATTERO_VI_CAT_BUILD_DIR = $(BUILD_DIR)/cat

ENDOR_ATTERO_VI_GIT_REFERENCE_ROOT?=$(ENDOR_COMMON_SOURCE_REPOSITORY)

.PHONY: endor-source endor-unpack endor endor-stage endor-ipk endor-clean endor-dirclean endor-check


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
endor-attero-source: $(DL_DIR)/$(ENDOR_ATTERO_VI_SOURCE) $(ENDOR_PATCHES) 

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
$(ENDOR_ATTERO_VI_BUILD_DIR)/.configured-attero-vi: make/endor-attero-vi.mk
	mkdir -p $(ENDOR_ATTERO_VI_BUILD_DIR)
	touch $@

endor-attero-unpack: $(ENDOR_ATTERO_VI_BUILD_DIR)/.configured-attero-vi

#
# This builds the actual binary.
#
$(ENDOR_ATTERO_VI_BUILD_DIR)/.built-attero-vi: $(ENDOR_ATTERO_VI_BUILD_DIR)/.configured-attero-vi
	rm -f $@
	#$(MAKE) -C $(@D)
	touch $@

#
# If you are building a library, then you need to stage it too.
#
$(ENDOR_ATTERO_VI_BUILD_DIR)/.staged-attero: $(ENDOR_ATTERO_VI_BUILD_DIR)/.built-attero-vi
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

endor-attero-vi-stage: $(ENDOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/endor
#
$(ENDOR_ATTERO_VI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: endor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENDOR_ATTERO_VI_PRIORITY)" >>$@
	@echo "Section: $(ENDOR_ATTERO_VI_SECTION)" >>$@
	@echo "Version: $(ENDOR_ATTERO_VI_VERSION)-$(ENDOR_ATTERO_VI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ENDOR_ATTERO_VI_MAINTAINER)" >>$@
	@echo "Source: $(ENDOR_ATTERO_VI_SITE)/$(ENDOR_ATTERO_VI_SOURCE)" >>$@
	@echo "Description: $(ENDOR_ATTERO_VI_DESCRIPTION)" >>$@
	@echo "Depends: $(ENDOR_ATTERO_VI_DEPENDS)" >>$@
	@echo "Suggests: $(ENDOR_ATTERO_VI_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENDOR_ATTERO_VI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ENDOR_IPK_DIR)/opt/sbin or $(ENDOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENDOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ENDOR_IPK_DIR)/opt/etc/endor/...
# Documentation files should be installed in $(ENDOR_IPK_DIR)/opt/doc/endor/...
# Daemon startup scripts should be installed in $(ENDOR_IPK_DIR)/opt/etc/init.d/S??endor
#
# You may need to patch your application to make it use these locations.
#
$(ENDOR_ATTERO_VI_IPK): $(ENDOR_ATTERO_VI_BUILD_DIR)/.built-attero-vi
	rm -rf $(ENDOR_ATTERO_IPK_DIR) $(BUILD_DIR)/endor_attero_vi_*_$(TARGET_ARCH).ipk
	
	# Provide the Virtual Instrument startup file
	#
	mkdir -p $(ENDOR_ATTERO_VI_IPK_DIR)/opt/etc/init.d
	install -m 755 $(ENDOR_ATTERO_VI_SOURCE_DIR)/rc.endor-virtualinstrument.attero $(ENDOR_ATTERO_VI_IPK_DIR)/opt/etc/init.d/S96endor-virtualinstrument
	
	# Provide the control information
	#
	mkdir -p $(ENDOR_ATTERO_VI_IPK_DIR)/CONTROL
	$(MAKE) $(ENDOR_ATTERO_VI_IPK_DIR)/CONTROL/control
	install -m 755 $(ENDOR_ATTERO_VI_SOURCE_DIR)/postinst $(ENDOR_ATTERO_VI_IPK_DIR)/CONTROL/postinst
	install -m 755 $(ENDOR_ATTERO_VI_SOURCE_DIR)/prerm    $(ENDOR_ATTERO_VI_IPK_DIR)/CONTROL/prerm

	# Now go and build the package
	#
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENDOR_ATTERO_VI_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ENDOR_ATTERO_VI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
endor-attero-vi-ipk: $(ENDOR_ATTERO_VI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
endor-attero-vi-clean:
	rm -f $(ENDOR_ATTERO_VI_BUILD_DIR)/.built
	$(MAKE) -C $(ENDOR_ATTERO_VI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
endor-attero-vi-dirclean:
	rm -rf $(BUILD_DIR)/$(ENDOR_ATTERO_VI_DIR) $(ENDOR_ATTERO_VI_BUILD_DIR) $(ENDOR_ATTERO_VI_IPK_DIR) $(ENDOR_ATTERO_VI_IPK)
#
#
# Some sanity check for the package.
#
endor-attero-vi-check: $(ENDOR_ATTERO_VI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
