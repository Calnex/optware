###########################################################
#
# nunit
#
###########################################################

# You must replace "nunit" and "NUNIT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NUNIT_VERSION, NUNIT_SITE and NUNIT_SOURCE define
# the upstream location of the source code for the package.
# NUNIT_DIR is the directory which is created when the source
# archive is unpacked.
# NUNIT_UNZIP is the command used to unzip the source.
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
NUNIT_SITE=https://launchpad.net/nunitv2/trunk/2.6.3/+download/
NUNIT_VERSION=2.6.3
NUNIT_SOURCE=NUnit-$(NUNIT_VERSION)-src.zip
NUNIT_DIR=NUnit-$(NUNIT_VERSION)
NUNIT_UNZIP=unzip
NUNIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NUNIT_DESCRIPTION=Describe nunit here.
NUNIT_SECTION=extras
NUNIT_PRIORITY=optional
NUNIT_DEPENDS=
NUNIT_SUGGESTS=
NUNIT_CONFLICTS=

NUNIT_XBUILD=$(MONO_STAGING_DIR)/opt/bin/xbuild

#
# NUNIT_IPK_VERSION should be incremented when the ipk changes.
#
NUNIT_IPK_VERSION=1

#
# NUNIT_CONFFILES should be a list of user-editable files
#NUNIT_CONFFILES=/opt/etc/nunit.conf /opt/etc/init.d/SXXnunit

#
# NUNIT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NUNIT_PATCHES=$(NUNIT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NUNIT_CPPFLAGS=
NUNIT_LDFLAGS=

#
# NUNIT_BUILD_DIR is the directory in which the build is done.
# NUNIT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NUNIT_IPK_DIR is the directory in which the ipk is built.
# NUNIT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NUNIT_BUILD_DIR=$(BUILD_DIR)/nunit
NUNIT_SOURCE_DIR=$(SOURCE_DIR)/nunit
NUNIT_IPK_DIR=$(BUILD_DIR)/nunit-$(NUNIT_VERSION)-ipk
NUNIT_IPK=$(BUILD_DIR)/nunit_$(NUNIT_VERSION)-$(NUNIT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nunit-source nunit-unpack nunit nunit-stage nunit-ipk nunit-clean nunit-dirclean nunit-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NUNIT_SOURCE):
	$(WGET) -P $(@D) $(NUNIT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nunit-source: $(DL_DIR)/$(NUNIT_SOURCE) $(NUNIT_PATCHES)

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
$(NUNIT_BUILD_DIR)/.configured: $(DL_DIR)/$(NUNIT_SOURCE) $(NUNIT_PATCHES) make/nunit.mk
	rm -rf $(BUILD_DIR)/$(NUNIT_DIR) $(@D)
	$(NUNIT_UNZIP) $(DL_DIR)/$(NUNIT_SOURCE) -d $(BUILD_DIR)
	if test -n "$(NUNIT_PATCHES)" ; \
		then cat $(NUNIT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NUNIT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NUNIT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NUNIT_DIR) $(@D) ; \
	fi
	touch $@

nunit-unpack: $(NUNIT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NUNIT_BUILD_DIR)/.built: $(NUNIT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D);\
		$(MONO_STAGING_DIR)$(NUNIT_XBUILD) /property:Configuration=Release ./src/NUnitCore/core/nunit.core.dll.csproj ;\
		$(NUNIT_XBUILD) /property:Configuration=Release ./src/NUnitCore/interfaces/nunit.core.interfaces.dll.csproj ;\
		$(NUNIT_XBUILD) /property:Configuration=Release ./src/NUnitFramework/framework/nunit.framework.dll.csproj ;\
		$(NUNIT_XBUILD) /property:Configuration=Release ./src/NUnitMocks/mocks/nunit.mocks.csproj ;\
		$(NUNIT_XBUILD) /property:Configuration=Release ./src/ClientUtilities/util/nunit.util.dll.csproj ;\
		$(NUNIT_XBUILD) /property:Configuration=Release ./src/ConsoleRunner/nunit-console/nunit-console.csproj ;\
		$(NUNIT_XBUILD) /property:Configuration=Release ./src/ConsoleRunner/nunit-console-exe/nunit-console.exe.csproj ;\
	)
	touch $@

#
# This is the build convenience target.
#
nunit: $(NUNIT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NUNIT_BUILD_DIR)/.staged: $(NUNIT_BUILD_DIR)/.built
	rm -f $@
	cp -r $(NUNIT_BUILD_DIR)/bin/Release/* $(MONO_STAGING_DIR)/opt/bin/
	echo "#! /bin/sh" > $(MONO_STAGING_DIR)/opt/bin/nunit-console_$(NUNIT_VERSION)
	echo "exec $(MONO_STAGING_DIR)/opt/bin/mono --debug $$MONO_OPTIONS $(MONO_STAGING_DIR)/opt/bin/nunit-console.exe \"$$@\"" >> $(MONO_STAGING_DIR)/opt/bin/nunit-console_$(NUNIT_VERSION)
	chmod +x $(MONO_STAGING_DIR)/opt/bin/nunit-console_$(NUNIT_VERSION)
	touch $@

nunit-stage: $(NUNIT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nunit
#
$(NUNIT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nunit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NUNIT_PRIORITY)" >>$@
	@echo "Section: $(NUNIT_SECTION)" >>$@
	@echo "Version: $(NUNIT_VERSION)-$(NUNIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NUNIT_MAINTAINER)" >>$@
	@echo "Source: $(NUNIT_SITE)/$(NUNIT_SOURCE)" >>$@
	@echo "Description: $(NUNIT_DESCRIPTION)" >>$@
	@echo "Depends: $(NUNIT_DEPENDS)" >>$@
	@echo "Suggests: $(NUNIT_SUGGESTS)" >>$@
	@echo "Conflicts: $(NUNIT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NUNIT_IPK_DIR)/opt/sbin or $(NUNIT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NUNIT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NUNIT_IPK_DIR)/opt/etc/nunit/...
# Documentation files should be installed in $(NUNIT_IPK_DIR)/opt/doc/nunit/...
# Daemon startup scripts should be installed in $(NUNIT_IPK_DIR)/opt/etc/init.d/S??nunit
#
# You may need to patch your application to make it use these locations.
#
$(NUNIT_IPK): $(NUNIT_BUILD_DIR)/.built
	rm -rf $(NUNIT_IPK_DIR) $(BUILD_DIR)/nunit_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NUNIT_BUILD_DIR) DESTDIR=$(NUNIT_IPK_DIR) install-strip
#	install -d $(NUNIT_IPK_DIR)/opt/etc/
#	install -m 644 $(NUNIT_SOURCE_DIR)/nunit.conf $(NUNIT_IPK_DIR)/opt/etc/nunit.conf
#	install -d $(NUNIT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NUNIT_SOURCE_DIR)/rc.nunit $(NUNIT_IPK_DIR)/opt/etc/init.d/SXXnunit
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NUNIT_IPK_DIR)/opt/etc/init.d/SXXnunit
	$(MAKE) $(NUNIT_IPK_DIR)/CONTROL/control
#	install -m 755 $(NUNIT_SOURCE_DIR)/postinst $(NUNIT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NUNIT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NUNIT_SOURCE_DIR)/prerm $(NUNIT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NUNIT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NUNIT_IPK_DIR)/CONTROL/postinst $(NUNIT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NUNIT_CONFFILES) | sed -e 's/ /\n/g' > $(NUNIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NUNIT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NUNIT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nunit-ipk: $(NUNIT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nunit-clean:
	rm -f $(NUNIT_BUILD_DIR)/.built
	$(MAKE) -C $(NUNIT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nunit-dirclean:
	rm -rf $(BUILD_DIR)/$(NUNIT_DIR) $(NUNIT_BUILD_DIR) $(NUNIT_IPK_DIR) $(NUNIT_IPK)
#
#
# Some sanity check for the package.
#
nunit-check: $(NUNIT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
