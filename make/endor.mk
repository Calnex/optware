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
# ENDOR_VERSION, ENDOR_SITE and ENDOR_SOURCE define
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


ENDOR_REPOSITORY?=https://github.com/Calnex/Springbank
ENDOR_PRODUCT=$(TARGET_PRODUCT_LOWER)
ENDOR_DOCUMENTATION_REPOSITORY?=https://github.com/Calnex/EndorDocumentation
ENDOR_VERSION=$(shell echo "$(BUILD_VERSION_NUMBER)" | cut --delimiter "." --output-delimiter "." -f2,3,4)
ENDOR_SOURCE=endor-$(ENDOR_PRODUCT)-$(ENDOR_VERSION).tar.gz
ENDOR_DIR=endor-$(ENDOR_PRODUCT)
ENDOR_UNZIP=zcat
ENDOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENDOR_DESCRIPTION=Describe endor-$(ENDOR_PRODUCT) here.
ENDOR_SECTION=base
ENDOR_PRIORITY=optional
ENDOR_DEPENDS=postgresql, mono, xsp, php, nginx, tshark, endor-$(ENDOR_PRODUCT)-doc
ENDOR_SUGGESTS=
ENDOR_CONFLICTS=endor-paragon, endor-paragon-doc, endor-paragon-neo, endor-paragon-neo-doc
ifeq "${ENDOR_PRODUCT}" "paragon"
	ENDOR_CONFLICTS=endor-attero, endor-attero-doc, endor-paragon-neo, endor-paragon-neo-doc
else ifeq "${ENDOR_PRODUCT}" "paragon-neo"
	ENDOR_CONFLICTS=endor-attero, endor-attero-doc, endor-paragon, endor-paragon-doc
endif

#
# ENDOR_IPK_VERSION should be incremented when the ipk changes.
#
ENDOR_IPK_VERSION=$(BUILD_NUMBER)

#
# ENDOR_CONFFILES should be a list of user-editable files
#ENDOR_CONFFILES=/opt/etc/endor-$(ENDOR_PRODUCT).conf /opt/etc/init.d/SXXendor-$(ENDOR_PRODUCT)

#
# ENDOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ENDOR_PATCHES=$(ENDOR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENDOR_CPPFLAGS=
ENDOR_LDFLAGS=

#
# ENDOR_BUILD_DIR is the directory in which the build is done.
# ENDOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENDOR_IPK_DIR is the directory in which the ipk is built.
# ENDOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ifdef ENDOR_COMMON_SOURCE_REPOSITORY
ENDOR_SPRINGBANK_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/Springbank
ENDOR_CAT_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/CAT
ENDOR_DATASTORAGE_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/DataStorage
ENDOR_DOCUMENTATION_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/EndorDocumentation
ENDOR_CALNEXCOMMON_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/CalnexCommon
endif
ENDOR_GIT_TAG?=HEAD
ENDOR_GIT_OPTIONS?=
ENDOR_TREEISH=$(ENDOR_GIT_TAG)
ENDOR_BUILD_DIR=$(BUILD_DIR)/endor-$(ENDOR_PRODUCT)

## Source dir is common for now
ENDOR_SOURCE_DIR=$(ENDOR_BUILD_DIR)/OptWare/sources/endor
ENDOR_IPK_DIR=$(BUILD_DIR)/endor-$(ENDOR_PRODUCT)-ipk
ENDOR_IPK=$(BUILD_DIR)/endor-$(ENDOR_PRODUCT)_$(ENDOR_IPK_VERSION)-$(ENDOR_VERSION)_$(TARGET_ARCH).ipk
ENDOR_BUILD_UTILITIES_DIR=$(BUILD_DIR)/../BuildUtilities

ENDOR_CAT_BUILD_DIR = $(BUILD_DIR)/cat

MONO_STAGING_DIR?=$(STAGING_DIR)

ENDOR_BUILD_CUSTOMCONSTANTS?=


.PHONY: endor-source endor-unpack endor endor-stage endor-ipk endor-clean endor-dirclean endor-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ENDOR_SOURCE):
	([ -z "${BUILD_VERSION_NUMBER}" ] && { echo "ERROR: Need to set BUILD_VERSION_NUMBER"; exit 1; }; \
		cd $(BUILD_DIR) ; \
		rm -rf endor-$(ENDOR_PRODUCT) && \
		git clone $(ENDOR_REPOSITORY) endor-$(ENDOR_PRODUCT) $(ENDOR_GIT_OPTIONS) $(ENDOR_SPRINGBANK_GIT_REFERENCE) --branch $(ENDOR_BRANCH_PARAM)  && \
		cd endor-$(ENDOR_PRODUCT) && \
		if [ ! -z "${ENDOR_COMMIT_ID}" ] ; \
			then /usr/bin/git checkout ${ENDOR_COMMIT_ID} ; \
		fi ; \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			    echo "Checking out TAG: ${TAG_NAME} "  ;  \
			    /usr/bin/git checkout -b br_${TAG_NAME} ${TAG_NAME} ; \
		fi; \
		git submodule sync --recursive && \
		cd Server/Software/Libs/CAT && \
		git submodule update --init $(ENDOR_CAT_GIT_REFERENCE) && \
		cd Calnex.Endor.DataStorage && \
		git submodule update --init $(ENDOR_DATASTORAGE_GIT_REFERENCE) && \
        cd Calnex.Common && \
        git submodule update --init $(ENDOR_CALNEXCOMMON_GIT_REFERENCE) && \
		cd .. && \
		if [ ! -z "${CAT_TAG}" ] ; \
			then \
			    echo "Checking out a drop of the cat"             && \
				/usr/bin/git checkout -b br_${CAT_TAG} ${CAT_TAG} && \
				/usr/bin/git submodule update --recursive;           \
		fi; \
		cd $(BUILD_DIR) && \
		echo "using System.Reflection;" > endor-$(ENDOR_PRODUCT)/Server/Software/Endor/BuildInformation/Version.cs ; \
		echo "[assembly: AssemblyVersion(\"${BUILD_VERSION_NUMBER}\")]" >> endor-$(ENDOR_PRODUCT)/Server/Software/Endor/BuildInformation/Version.cs ; \
		echo "[assembly: AssemblyFileVersion(\"${BUILD_VERSION_NUMBER}\")]" >> endor-$(ENDOR_PRODUCT)/Server/Software/Endor/BuildInformation/Version.cs ; \
		cd endor-$(ENDOR_PRODUCT) && \
		git show-ref --heads > Server/Software/Endor/BuildInformation/GitCommitIds.txt; \
		$(ENDOR_BUILD_DIR)/Server/Software/OptWare/Make/endor-makefile minify "$(BUILD_DIR)" "$(ENDOR_PRODUCT)" ; \
		cd $(BUILD_DIR)/endor-$(ENDOR_PRODUCT)/Server/Software && \
		tar --transform  "s,^,endor-$(ENDOR_PRODUCT)/,S" -cz -f $@ --exclude=.git* * && \
		# Cleanup any branches we created \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			cd $(BUILD_DIR)/endor-$(ENDOR_PRODUCT)/Server/Software/EndorDocumentation ; \
			/usr/bin/git checkout master ; \
			/usr/bin/git branch -D br_doc_${TAG_NAME} ; \
			cd $(BUILD_DIR)/endor-$(ENDOR_PRODUCT) ; \
			/usr/bin/git checkout master ; \
			/usr/bin/git branch -D br_${TAG_NAME} ; \
		fi; \
		cd $(BUILD_DIR) ;\
		rm -rf endor-$(ENDOR_PRODUCT) ;\
	)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
endor-source: $(DL_DIR)/$(ENDOR_SOURCE) $(ENDOR_PATCHES) 

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
$(ENDOR_BUILD_DIR)/.configured: $(DL_DIR)/$(ENDOR_SOURCE) $(ENDOR_PATCHES)  make/endor.mk
	if [ "$(MONO_STAGING_DIR)" = "$(STAGING_DIR)" ] ; \
		then $(MAKE) mono-stage xsp-stage ; \
	fi
	rm -rf $(BUILD_DIR)/$(ENDOR_DIR) $(@D)
	$(ENDOR_UNZIP) $(DL_DIR)/$(ENDOR_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(ENDOR_PATCHES)" ; \
		then cat $(ENDOR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ENDOR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ENDOR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ENDOR_DIR) $(@D) ; \
	fi
	touch $@

endor-unpack: $(ENDOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ENDOR_BUILD_DIR)/.built: $(ENDOR_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D);\
		$(MONO_STAGING_DIR)/opt/bin/xbuild Endor.sln /p:CustomConstants="$(ENDOR_BUILD_CUSTOMCONSTANTS)" /p:Configuration=Release /p:CscToolPath=$(MONO_STAGING_DIR)/opt/lib/mono/4.5;\
	)
	touch $@


#
# You should change the dependency to refer directly to the main binary
# which is built.
#
endor: $(ENDOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ENDOR_BUILD_DIR)/.staged: $(ENDOR_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

endor-stage: $(ENDOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/endor
#
$(ENDOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: endor-$(ENDOR_PRODUCT)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENDOR_PRIORITY)" >>$@
	@echo "Section: $(ENDOR_SECTION)" >>$@
	@echo "Version: $(ENDOR_IPK_VERSION)-$(ENDOR_VERSION)" >>$@
	@echo "Maintainer: $(ENDOR_MAINTAINER)" >>$@
	@echo "Source: $(ENDOR_SITE)/$(ENDOR_SOURCE)" >>$@
	@echo "Description: $(ENDOR_DESCRIPTION)" >>$@
	@echo "Depends: $(ENDOR_DEPENDS)" >>$@
	@echo "Suggests: $(ENDOR_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENDOR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ENDOR_IPK_DIR)/opt/sbin or $(ENDOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENDOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ENDOR_IPK_DIR)/opt/etc/endor-$(ENDOR_PRODUCT)/...
# Documentation files should be installed in $(ENDOR_IPK_DIR)/opt/doc/endor-$(ENDOR_PRODUCT)/...
# Daemon startup scripts should be installed in $(ENDOR_IPK_DIR)/opt/etc/init.d/S??endor-$(ENDOR_PRODUCT)
#
# You may need to patch your application to make it use these locations.
# 
$(ENDOR_IPK): $(ENDOR_BUILD_DIR)/.built
	rm -rf $(ENDOR_IPK_DIR) $(BUILD_DIR)/endor-$(ENDOR_PRODUCT)_*_$(TARGET_ARCH).ipk
	install -d $(ENDOR_IPK_DIR)
	cp -ar $(ENDOR_BUILD_DIR)/Endor/Build/opt $(ENDOR_IPK_DIR)
#	find $(ENDOR_IPK_DIR)/opt/ -type f -name "*.mdb" --delete
	$(MAKE) $(ENDOR_IPK_DIR)/CONTROL/control
	install -m 755 $(ENDOR_SOURCE_DIR)/preinst  $(ENDOR_IPK_DIR)/CONTROL/preinst
	install -m 755 $(ENDOR_SOURCE_DIR)/postinst $(ENDOR_IPK_DIR)/CONTROL/postinst
	install -m 755 $(ENDOR_SOURCE_DIR)/prerm    $(ENDOR_IPK_DIR)/CONTROL/prerm
	install -m 755 $(ENDOR_SOURCE_DIR)/postrm   $(ENDOR_IPK_DIR)/CONTROL/postrm
	echo $(ENDOR_CONFFILES) | sed -e 's/ /\n/g' > $(ENDOR_IPK_DIR)/CONTROL/conffiles
	
	$(ENDOR_BUILD_DIR)/OptWare/Make/endor-makefile install $(BUILD_DIR) $(ENDOR_PRODUCT);

	# Embedded firmware
	#
	if [ ! -z "${ENDOR_FIRMWARE_VERSION}" ]; then \
	   if [ "${ENDOR_FIRMWARE_VERSION}" != "(none)" ] ; then \
		  install -d $(ENDOR_IPK_DIR)/opt/var/lib/embedded; \
		  install -m 755 $(BASE_DIR)/downloads/fw-update-$(ENDOR_FIRMWARE_VERSION).tar.gz $(ENDOR_IPK_DIR)/opt/var/lib/embedded/fw-update-$(ENDOR_FIRMWARE_VERSION).tar.gz; \
		  install -m 755 $(BASE_DIR)/downloads/fw-update-$(ENDOR_FIRMWARE_VERSION).tar.gz.md5 $(ENDOR_IPK_DIR)/opt/var/lib/embedded/fw-update-$(ENDOR_FIRMWARE_VERSION).tar.gz.md5; \
		  cat $(ENDOR_SOURCE_DIR)/postinst.firmware >> $(ENDOR_IPK_DIR)/CONTROL/postinst; \
		  sed -i -e 's/__FIRMWARE_VERSION__/${ENDOR_FIRMWARE_VERSION}/g' $(ENDOR_IPK_DIR)/CONTROL/postinst; \
	   fi; \
	fi
	# The version of tar used in ipkg_build chokes at file name lengths > 100 characters.
	# Build any such files into a tarball that can later be purged.
	#
	cd ${ENDOR_IPK_DIR}/opt/lib/endor && \
	tar --remove-files -czf long-filepaths.tar.gz \
		`find . -type f -ls | awk '{ if (length($$$$13) > 80) { print $$11}}'`
	# Now go and build the package
	#
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENDOR_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ENDOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
endor-ipk: $(ENDOR_IPK) $(ENDOR_VI_IPK) $(ENDOR_DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
endor-clean:
	rm -f $(ENDOR_BUILD_DIR)/.built
	$(MAKE) -C $(ENDOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
endor-dirclean:
	rm -rf $(BUILD_DIR)/$(ENDOR_DIR) $(ENDOR_BUILD_DIR) $(ENDOR_IPK_DIR) $(ENDOR_IPK)
#
#
# Some sanity check for the package.
#
endor-check: $(ENDOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

# This builds the endor service test binaries
#
endor-service-tests:
	$(ENDOR_BUILD_DIR)/OptWare/Make/endor-makefile service-tests $(BUILD_DIR) $(ENDOR_PRODUCT)

endor-service-tests-clean:
	$(ENDOR_BUILD_DIR)/OptWare/Make/endor-makefile service-tests-clean $(BUILD_DIR) $(ENDOR_PRODUCT)
