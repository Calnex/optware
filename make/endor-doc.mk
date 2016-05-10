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
# ENDOR_DOC_VERSION, ENDOR_DOC_SITE and ENDOR_DOC_SOURCE define
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
BUILD_VERSION_NUMBER?=0.1.0.0
BUILD_NUMBER?=devel

ENDOR_DOC_VERSION=$(shell echo "$(BUILD_VERSION_NUMBER)" | cut --delimiter "." --output-delimiter "." -f2,3,4)
ENDOR_DOC_SOURCE=endor-$(PRODUCT_BUILD_TARGET)-$(ENDOR_DOC_VERSION).tar.gz
ENDOR_DOC_MAINTAINER=Calnex <info@calnexsol.com>
ENDOR_DOC_DESCRIPTION=Describe endor documentation here.
ENDOR_DOC_SECTION=base
ENDOR_DOC_PRIORITY=optional
ENDOR_DOC_DEPENDS=endor-$(PRODUCT_BUILD_TARGET)
ENDOR_DOC_PACKAGE=endor-$(PRODUCT_BUILD_TARGET)-doc
ENDOR_DOC_SUGGESTS=
ENDOR_DOC_CONFLICTS=

#
# ENDOR_IPK_VERSION should be incremented when the ipk changes.
#
ENDOR_DOC_IPK_VERSION=$(BUILD_NUMBER)

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
ENDOR_DOC_CPPFLAGS=
ENDOR_DOC_LDFLAGS=

#
# ENDOR_BUILD_DIR is the directory in which the build is done.
# ENDOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENDOR_IPK_DIR is the directory in which the ipk is built.
# ENDOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ENDOR_DOC_GIT_TAG?=HEAD
ENDOR_DOC_GIT_OPTIONS?=
ENDOR_DOC_TREEISH=$(ENDOR_DOC_GIT_TAG)
ENDOR_DOC_BUILD_DIR=$(BUILD_DIR)/endor-$(PRODUCT_BUILD_TARGET)
ENDOR_DOC_SOURCE_DIR=$(ENDOR_BUILD_DIR)/OptWare/$(ENDOR_PRODUCT)/sources/endor-$(PRODUCT_BUILD_TARGET)
ENDOR_DOC_IPK_DIR=$(BUILD_DIR)/endor-$(PRODUCT_BUILD_TARGET)-doc-$(ENDOR_DOC_VERSION)-ipk
ENDOR_DOC_IPK=$(BUILD_DIR)/endor-$(PRODUCT_BUILD_TARGET)-doc_$(ENDOR_DOC_VERSION)-$(ENDOR_DOC_IPK_VERSION)_$(TARGET_ARCH).ipk

ENDOR_DOC_GIT_REFERENCE_ROOT?=$(ENDOR_COMMON_SOURCE_REPOSITORY)

.PHONY: endor-source endor-unpack endor endor-stage endor-ipk endor-clean endor-dirclean endor-check


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
endor-source: $(DL_DIR)/$(ENDOR_DOC_SOURCE) $(ENDOR_PATCHES) 

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
$(ENDOR_DOC_BUILD_DIR)/.configured-doc: make/endor-doc.mk
	mkdir -p $(ENDOR_DOC_BUILD_DIR)
	touch $@

endor-unpack: $(ENDOR_DOC_BUILD_DIR)/.configured-doc

#
# This builds the actual binary.
#
$(ENDOR_DOC_BUILD_DIR)/.built-doc: $(ENDOR_DOC_BUILD_DIR)/.configured-doc
	rm -f $@
	#$(MAKE) -C $(@D)
	touch $@

#
# If you are building a library, then you need to stage it too.
#
$(ENDOR_DOC_BUILD_DIR)/.staged: $(ENDOR_DOC_BUILD_DIR)/.built-doc
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

endor-doc-stage: $(ENDOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/endor
#
$(ENDOR_DOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: $(ENDOR_DOC_PACKAGE)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENDOR_DOC_PRIORITY)" >>$@
	@echo "Section: $(ENDOR_DOC_SECTION)" >>$@
	@echo "Version: $(ENDOR_DOC_IPK_VERSION)-$(ENDOR_DOC_VERSION)" >>$@
	@echo "Maintainer: $(ENDOR_DOC_MAINTAINER)" >>$@
	@echo "Source: $(ENDOR_DOC_SITE)/$(ENDOR_DOC_SOURCE)" >>$@
	@echo "Description: $(ENDOR_DOC_DESCRIPTION)" >>$@
	@echo "Depends: $(ENDOR_DOC_DEPENDS)" >>$@
	@echo "Suggests: $(ENDOR_DOC_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENDOR_DOC_CONFLICTS)" >>$@

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
$(ENDOR_DOC_IPK): $(ENDOR_DOC_BUILD_DIR)/.built-doc
	rm -rf $(ENDOR_IPK_DIR) $(BUILD_DIR)/endor-$(PRODUCT_BUILD_TARGET)-doc_*_$(TARGET_ARCH).ipk
	
	# Help documentation
	#
	install -d $(ENDOR_DOC_IPK_DIR)/opt/lib/endor/Help/Documents
	install -m 444 $(ENDOR_DOC_BUILD_DIR)/Endor/BuildInformation/GitCommitIds.txt                 $(ENDOR_DOC_IPK_DIR)/opt/lib/endor/Help/GitCommitIds.txt

	cd $(ENDOR_DOC_BUILD_DIR)/EndorDocumentation/DocumentationShippedWith${TARGET_PRODUCT} && \
	find . -name *.xml | cpio -pdm --verbose $(ENDOR_DOC_IPK_DIR)/opt/lib/endor/Help/ && \
	find . -name *.pdf | cpio -pdm --verbose $(ENDOR_DOC_IPK_DIR)/opt/lib/endor/Help/
	# Provide the control information
	#
	mkdir -p $(ENDOR_DOC_IPK_DIR)/CONTROL
	$(MAKE) $(ENDOR_DOC_IPK_DIR)/CONTROL/control
	# Now go and build the package
	#
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENDOR_DOC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ENDOR_DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
endor-doc-ipk: $(ENDOR_DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
endor-doc-clean:
	rm -f $(ENDOR_DOC_BUILD_DIR)/.built
	$(MAKE) -C $(ENDOR_DOC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
endor-doc-dirclean:
	rm -rf $(ENDOR_DOC_BUILD_DIR) $(ENDOR_DOC_IPK_DIR) $(ENDOR_DOC_IPK)
#
#
# Some sanity check for the package.
#
endor-doc-check: $(ENDOR_DOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
