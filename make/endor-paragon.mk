###########################################################
#
# endor-paragon
#
###########################################################

# You must replace "endor-paragon" and "ENDOR_PARAGON" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ENDOR_PARAGON_VERSION, ENDOR_PARAGON_SITE and ENDOR_PARAGON_SOURCE define
# the upstream location of the source code for the package.
# ENDOR_PARAGON_DIR is the directory which is created when the source
# archive is unpacked.
# ENDOR_PARAGON_UNZIP is the command used to unzip the source.
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


ENDOR_PARAGON_REPOSITORY=https://github.com/Calnex/Springbank
ENDOR_PARAGON_DOCUMENTATION_REPOSITORY=https://github.com/Calnex/EndorDocumentation
ENDOR_PARAGON_VERSION=$(shell echo "$(BUILD_VERSION_NUMBER)" | cut --delimiter "." --output-delimiter "." -f2,3,4)
ENDOR_PARAGON_SOURCE=endor-paragon-$(ENDOR_PARAGON_VERSION).tar.gz
ENDOR_PARAGON_DIR=endor-paragon
ENDOR_PARAGON_UNZIP=zcat
ENDOR_PARAGON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENDOR_PARAGON_DESCRIPTION=Describe endor-paragon here.
ENDOR_PARAGON_SECTION=base
ENDOR_PARAGON_PRIORITY=optional
ENDOR_PARAGON_DEPENDS=postgresql, mono, xsp, nginx, phantomjs
ENDOR_PARAGON_SUGGESTS=
ENDOR_PARAGON_CONFLICTS=endor-attero

#
# ENDOR_PARAGON_IPK_VERSION should be incremented when the ipk changes.
#
ENDOR_PARAGON_IPK_VERSION=$(BUILD_NUMBER)

#
# ENDOR_PARAGON_CONFFILES should be a list of user-editable files
#ENDOR_PARAGON_CONFFILES=/opt/etc/endor-paragon.conf /opt/etc/init.d/SXXendor-paragon

#
# ENDOR_PARAGON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ENDOR_PARAGON_PATCHES=$(ENDOR_PARAGON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENDOR_PARAGON_CPPFLAGS=
ENDOR_PARAGON_LDFLAGS=

#
# ENDOR_PARAGON_BUILD_DIR is the directory in which the build is done.
# ENDOR_PARAGON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENDOR_PARAGON_IPK_DIR is the directory in which the ipk is built.
# ENDOR_PARAGON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ifdef ENDOR_COMMON_SOURCE_REPOSITORY
ENDOR_PARAGON_SPRINGBANK_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/Springbank
ENDOR_PARAGON_CAT_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/CAT
ENDOR_PARAGON_DATASTORAGE_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/DataStorage
ENDOR_PARAGON_DOCUMENTATION_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/EndorDocumentation
ENDOR_PARAGON_CALNEXCOMMON_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/CalnexCommon
endif
ENDOR_PARAGON_GIT_TAG?=HEAD
ENDOR_PARAGON_GIT_OPTIONS?=
ENDOR_PARAGON_TREEISH=$(ENDOR_PARAGON_GIT_TAG)
ENDOR_PARAGON_BUILD_DIR=$(BUILD_DIR)/endor-paragon

## Source dir is common for now
ENDOR_PARAGON_SOURCE_DIR=$(SOURCE_DIR)/endor
ENDOR_PARAGON_IPK_DIR=$(BUILD_DIR)/endor-paragon-ipk
ENDOR_PARAGON_IPK=$(BUILD_DIR)/endor-paragon_$(ENDOR_PARAGON_IPK_VERSION)-$(ENDOR_PARAGON_VERSION)_$(TARGET_ARCH).ipk
ENDOR_PARAGON_BUILD_UTILITIES_DIR=$(BUILD_DIR)/../BuildUtilities

ENDOR_PARAGON_CAT_BUILD_DIR = $(BUILD_DIR)/cat

.PHONY: endor-paragon-source endor-paragon-unpack endor-paragon endor-paragon-stage endor-paragon-ipk endor-paragon-clean endor-paragon-dirclean endor-paragon-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ENDOR_PARAGON_SOURCE):
	([ -z "${BUILD_VERSION_NUMBER}" ] && { echo "ERROR: Need to set BUILD_VERSION_NUMBER"; exit 1; }; \
		cd $(BUILD_DIR) ; \
		rm -rf endor-paragon && \
		git clone $(ENDOR_PARAGON_REPOSITORY) endor-paragon $(ENDOR_PARAGON_GIT_OPTIONS) $(ENDOR_PARAGON_SPRINGBANK_GIT_REFERENCE) --branch $(ENDOR_BRANCH_PARAM) && \
		cd endor-paragon && \
		if [ ! -z "${ENDOR_PARAGON_COMMIT_ID}" ] ; \
			then /usr/bin/git checkout ${ENDOR_PARAGON_COMMIT_ID} ; \
		fi ; \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			    echo "Checking out TAG: ${TAG_NAME} "  ;  \
			    /usr/bin/git checkout -b br_${TAG_NAME} ${TAG_NAME} ; \
		fi; \
		git submodule sync --recursive && \
		cd Server/Software/Libs/CAT && \
		git submodule update --init $(ENDOR_PARAGON_CAT_GIT_REFERENCE) && \
		cd Calnex.Endor.DataStorage && \
		git submodule update --init $(ENDOR_PARAGON_DATASTORAGE_GIT_REFERENCE) && \
		cd Calnex.Common && \
		git submodule update --init $(ENDOR_PARAGON_CALNEXCOMMON_GIT_REFERENCE) && \
		cd .. && \
		if [ ! -z "${CAT_TAG}" ] ; \
			then \
			    echo "Checking out a drop of the cat"             && \
				/usr/bin/git checkout -b br_${CAT_TAG} ${CAT_TAG} && \
				/usr/bin/git submodule update --recursive;           \
		fi; \
		cd $(BUILD_DIR) && \
		echo "using System.Reflection;" > endor-paragon/Server/Software/Endor/BuildInformation/Version.cs ; \
		echo "[assembly: AssemblyVersion(\"${BUILD_VERSION_NUMBER}\")]" >> endor-paragon/Server/Software/Endor/BuildInformation/Version.cs ; \
		echo "[assembly: AssemblyFileVersion(\"${BUILD_VERSION_NUMBER}\")]" >> endor-paragon/Server/Software/Endor/BuildInformation/Version.cs ; \
		git show-ref --heads > endor-paragon/Server/Software/Endor/BuildInformation/GitCommitIds.txt; \
		# \
		# Check out EndorDocumentation \
		# \
		cd $(BUILD_DIR)/endor-paragon/Server/Software ; \
		/usr/bin/git clone $(ENDOR_PARAGON_DOCUMENTATION_REPOSITORY) EndorDocumentation --branch $(ENDOR_BRANCH_PARAM)  $(ENDOR_PARAGON_DOCUMENTATION_GIT_REFERENCE) ; \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			cd $(BUILD_DIR)/endor-paragon/Server/Software/EndorDocumentation ; \
			echo "Checking out Documentation at TAG: ${TAG_NAME} "  ;  \
			/usr/bin/git checkout -b br_doc_${TAG_NAME} ${TAG_NAME} ; \
		fi; \
	)
-include $(BUILD_DIR)/endor-paragon/Server/Software/Make/endor-paragon.mk ; \
cd $(BUILD_DIR)/endor-paragon/Server/Software/Make ; \
$(MAKE) endor-paragon.mk ; \


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
endor-paragon-source: $(DL_DIR)/$(ENDOR_PARAGON_SOURCE) $(ENDOR_PARAGON_PATCHES) 

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
$(ENDOR_PARAGON_BUILD_DIR)/.configured: $(DL_DIR)/$(ENDOR_PARAGON_SOURCE) $(ENDOR_PARAGON_PATCHES)  make/endor-paragon.mk
	rm -rf $(BUILD_DIR)/$(ENDOR_PARAGON_DIR) $(@D)
	$(ENDOR_PARAGON_UNZIP) $(DL_DIR)/$(ENDOR_PARAGON_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(ENDOR_PARAGON_PATCHES)" ; \
		then cat $(ENDOR_PARAGON_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ENDOR_PARAGON_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ENDOR_PARAGON_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ENDOR_PARAGON_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		mdtool generate-makefiles Endor.sln -d:release && \
		sed -i -e 's/PROGRAMFILES = \\/PROGRAMFILES = \\\n\t$$(ASSEMBLY) \\/g' `find $(ENDOR_PARAGON_BUILD_DIR) -name Makefile.am` && \
		sed -i -e 's/Endor/Endor/g' autogen.sh configure.ac && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ENDOR_PARAGON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENDOR_PARAGON_LDFLAGS)" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

endor-paragon-unpack: $(ENDOR_PARAGON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ENDOR_PARAGON_BUILD_DIR)/.built: $(ENDOR_PARAGON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@


#
# You should change the dependency to refer directly to the main binary
# which is built.
#
endor-paragon: $(ENDOR_PARAGON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ENDOR_PARAGON_BUILD_DIR)/.staged-paragon: $(ENDOR_PARAGON_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

endor-paragon-stage: $(ENDOR_PARAGON_BUILD_DIR)/.staged

#
# This is called from the top level makefile to create the IPK file.
#
endor-paragon-ipk: endor-paragon-source

#
# This is called from the top level makefile to clean all of the built files.
#
endor-paragon-clean:
	rm -f $(ENDOR_PARAGON_BUILD_DIR)/.built
	$(MAKE) -C $(ENDOR_PARAGON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
endor-paragon-dirclean:
	rm -rf $(BUILD_DIR)/$(ENDOR_PARAGON_DIR) $(ENDOR_PARAGON_BUILD_DIR) $(ENDOR_PARAGON_IPK_DIR) $(ENDOR_PARAGON_IPK)
#
#
# Some sanity check for the package.
#
endor-paragon-check: $(ENDOR_PARAGON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
