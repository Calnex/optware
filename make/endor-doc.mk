###########################################################
#
# endor-doc
#
###########################################################

# You must replace "endor-doc" and "ENDOR-DOC" with the lower case name and
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
ENDOR_BRANCH_PARAM?=master

ENDOR_DOCUMENTATION_REPOSITORY?=https://github.com/Calnex/EndorDocumentation
ENDOR_DOC_VERSION=$(shell echo "$(BUILD_VERSION_NUMBER)" | cut --delimiter "." --output-delimiter "." -f2,3,4)
ENDOR_DOC_SOURCE=endor-$(TARGET_PRODUCT_LOWER)-doc-$(ENDOR_DOC_VERSION).tar.gz
ENDOR_UNZIP=zcat
ENDOR_DOC_MAINTAINER=Calnex <info@calnexsol.com>
ENDOR_DOC_DESCRIPTION=Describe endor documentation here.
ENDOR_DOC_SECTION=base
ENDOR_DOC_PRIORITY=optional
ENDOR_DOC_DEPENDS=
ENDOR_DOC_PACKAGE=endor-$(TARGET_PRODUCT_LOWER)-doc
ENDOR_DOC_SUGGESTS=
ENDOR_DOC_CONFLICTS=endor-paragon, endor-paragon-doc, endor-paragon-neo, endor-paragon-neo-doc
ifeq "${TARGET_PRODUCT_LOWER}" "paragon"
	ENDOR_DOC_CONFLICTS=endor-attero, endor-attero-doc, endor-paragon-neo, endor-paragon-neo-doc
else ifeq "${TARGET_PRODUCT_LOWER}" "paragon-neo"
	ENDOR_DOC_CONFLICTS=endor-attero, endor-attero-doc, endor-paragon, endor-paragon-doc
endif

#
# ENDOR_IPK_VERSION should be incremented when the ipk changes.
#
ENDOR_DOC_IPK_VERSION=$(BUILD_NUMBER)

#
# ENDOR_CONFFILES should be a list of user-editable files
#ENDOR_CONFFILES=/opt/etc/endor.conf /opt/etc/init.d/SXXendor

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
ENDOR_GIT_OPTIONS?=
ENDOR_DOC_TREEISH=$(ENDOR_DOC_GIT_TAG)
ENDOR_DOC_BUILD_DIR=$(BUILD_DIR)/endor-$(TARGET_PRODUCT_LOWER)-doc
ENDOR_DOC_SOURCE_DIR=$(ENDOR_BUILD_DIR)/OptWare/$(TARGET_PRODUCT_LOWER)/sources/endor-$(TARGET_PRODUCT_LOWER)
ENDOR_DOC_IPK_DIR=$(BUILD_DIR)/endor-$(TARGET_PRODUCT_LOWER)-doc-$(ENDOR_DOC_VERSION)-ipk
ENDOR_DOC_IPK=$(BUILD_DIR)/endor-$(TARGET_PRODUCT_LOWER)-doc_$(ENDOR_DOC_VERSION)-$(ENDOR_DOC_IPK_VERSION)_$(TARGET_ARCH).ipk
ifdef ENDOR_COMMON_SOURCE_REPOSITORY
ENDOR_DOCUMENTATION_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/EndorDocumentation
endif

ENDOR_DOC_GIT_REFERENCE_ROOT?=$(ENDOR_COMMON_SOURCE_REPOSITORY)

.PHONY: endor-doc-source endor-doc-unpack endor endor-doc-stage endor-doc-ipk endor-doc-clean endor-doc-dirclean endor-doc-check

$(DL_DIR)/$(ENDOR_DOC_SOURCE):
	([ -z "${BUILD_VERSION_NUMBER}" ] && { echo "ERROR: Need to set BUILD_VERSION_NUMBER"; exit 1; }; \
		# \
		# Check out EndorDocumentation \
		# \
		mkdir -p $(ENDOR_DOC_BUILD_DIR) ; \
		cd $(ENDOR_DOC_BUILD_DIR) ; \
		/usr/bin/git clone $(ENDOR_DOCUMENTATION_REPOSITORY) EndorDocumentation $(ENDOR_GIT_OPTIONS) --branch $(ENDOR_BRANCH_PARAM) $(ENDOR_DOCUMENTATION_GIT_REFERENCE) ; \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			cd $(ENDOR_DOC_BUILD_DIR)/EndorDocumentation ; \
			echo "Checking out Documentation at TAG: ${TAG_NAME} "  ;  \
			/usr/bin/git checkout -b br_doc_${TAG_NAME} ${TAG_NAME} ; \
		fi; \
		cd $(ENDOR_DOC_BUILD_DIR) && \
		tar --transform  "s,^,endor-$(ENDOR_PRODUCT)-doc/,S" -cz -f $@ --exclude=.git* * && \
		# Cleanup any branches we created \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			cd $(BUILD_DIR)/endor-$(ENDOR_PRODUCT)-doc/EndorDocumentation ; \
			/usr/bin/git checkout master ; \
			/usr/bin/git branch -D br_doc_${TAG_NAME} ; \
			cd $(BUILD_DIR)/endor-$(ENDOR_PRODUCT)-doc ; \
			/usr/bin/git checkout master ; \
			/usr/bin/git branch -D br_${TAG_NAME} ; \
		fi; \
		cd $(BUILD_DIR) ;\
		rm -rf endor-$(ENDOR_PRODUCT)-doc ;\
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
endor-doc-source: $(DL_DIR)/$(ENDOR_DOC_SOURCE)

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
$(ENDOR_DOC_BUILD_DIR)/.configured-doc: $(DL_DIR)/$(ENDOR_DOC_SOURCE) make/endor-doc.mk
	rm -rf $(BUILD_DIR)/endor-$(ENDOR_PRODUCT)-doc $(@D)
	$(ENDOR_UNZIP) $(DL_DIR)/$(ENDOR_DOC_SOURCE) | tar -C $(BUILD_DIR) -xf -
	touch $@

endor-doc-unpack: $(ENDOR_DOC_BUILD_DIR)/.configured-doc

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
	rm -rf $(ENDOR_IPK_DIR) $(BUILD_DIR)/endor-$(TARGET_PRODUCT_LOWER)-doc_*_$(TARGET_ARCH).ipk
	
	# Help documentation
	#
	install -d $(ENDOR_DOC_IPK_DIR)/opt/share/endor

	cd $(ENDOR_DOC_BUILD_DIR)/EndorDocumentation/DocumentationShippedWith${TARGET_PRODUCT} && \
	find . -name *.xml | cpio -pdm --verbose $(ENDOR_DOC_IPK_DIR)/opt/share/endor/ && \
	find . -name *.pdf | cpio -pdm --verbose $(ENDOR_DOC_IPK_DIR)/opt/share/endor/
	# Provide the control information
	#
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
	rm -f $(ENDOR_DOC_BUILD_DIR)/.built-doc
	$(MAKE) -C $(ENDOR_DOC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
endor-doc-dirclean:
	rm -rf $(BUILD_DIR)/$(ENDOR_DOC_BUILD_DIR) $(ENDOR_DOC_IPK_DIR) $(ENDOR_DOC_IPK)
#
#
# Some sanity check for the package.
#
endor-doc-check: $(ENDOR_DOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
