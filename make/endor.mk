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
ENDOR_REPOSITORY=git@github.com:Calnex/Springbank.git
ENDOR_VERSION=1.0
ENDOR_SOURCE=endor-$(ENDOR_VERSION).tar.gz
ENDOR_DIR=endor-$(ENDOR_VERSION)
ENDOR_UNZIP=zcat
ENDOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENDOR_DESCRIPTION=Describe endor here.
ENDOR_SECTION=base
ENDOR_PRIORITY=optional
ENDOR_DEPENDS=postgresql, python3, mono, xsp
ENDOR_SUGGESTS=
ENDOR_CONFLICTS=

#
# ENDOR_IPK_VERSION should be incremented when the ipk changes.
#
ENDOR_IPK_VERSION=1

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
ENDOR_GIT_TAG?=HEAD
ENDOR_TREEISH=$(ENDOR_GIT_TAG)
ENDOR_BUILD_DIR=$(BUILD_DIR)/endor
ENDOR_SOURCE_DIR=$(SOURCE_DIR)/endor
ENDOR_IPK_DIR=$(BUILD_DIR)/endor-$(ENDOR_VERSION)-ipk
ENDOR_IPK=$(BUILD_DIR)/endor_$(ENDOR_VERSION)-$(ENDOR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: endor-source endor-unpack endor endor-stage endor-ipk endor-clean endor-dirclean endor-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ENDOR_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf endor && \
		git clone $(ENDOR_REPOSITORY) endor && \
		cd endor/Server/Software && \
		(git archive \
			--format=tar \
			--prefix=$(ENDOR_DIR)/ \
			$(ENDOR_TREEISH) | \
		gzip > $@) && \
		rm -rf endor ; \
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
$(ENDOR_BUILD_DIR)/.configured: $(DL_DIR)/$(ENDOR_SOURCE) $(ENDOR_PATCHES) make/endor.mk
	rm -rf $(BUILD_DIR)/$(ENDOR_DIR) $(@D)
	$(ENDOR_UNZIP) $(DL_DIR)/$(ENDOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ENDOR_PATCHES)" ; \
		then cat $(ENDOR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ENDOR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ENDOR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ENDOR_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		mdtool generate-makefiles Endor.sln -d:release && \
		sed -i -e 's/PROGRAMFILES = \\/PROGRAMFILES = \\\n\t$$(ASSEMBLY) \\/g' `find $(ENDOR_BUILD_DIR) -name Makefile.am` && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ENDOR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENDOR_LDFLAGS)" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

endor-unpack: $(ENDOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ENDOR_BUILD_DIR)/.built: $(ENDOR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
endor: $(ENDOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ENDOR_BUILD_DIR)/.staged: $(ENDOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

endor-stage: $(ENDOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/endor
#
$(ENDOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: endor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENDOR_PRIORITY)" >>$@
	@echo "Section: $(ENDOR_SECTION)" >>$@
	@echo "Version: $(ENDOR_VERSION)-$(ENDOR_IPK_VERSION)" >>$@
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
# Configuration files should be installed in $(ENDOR_IPK_DIR)/opt/etc/endor/...
# Documentation files should be installed in $(ENDOR_IPK_DIR)/opt/doc/endor/...
# Daemon startup scripts should be installed in $(ENDOR_IPK_DIR)/opt/etc/init.d/S??endor
#
# You may need to patch your application to make it use these locations.
#
$(ENDOR_IPK): $(ENDOR_BUILD_DIR)/.built
	rm -rf $(ENDOR_IPK_DIR) $(BUILD_DIR)/endor_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ENDOR_BUILD_DIR) DESTDIR=$(ENDOR_IPK_DIR) install-strip
	cd $(ENDOR_IPK_DIR)/opt/lib/endor && \
	tar --remove-files -cvzf long-filepaths.tar.gz \
		`find . -type f -ls | awk '{ if (length($$$$13) > 80) { print $$11}}'`
	install -d $(ENDOR_IPK_DIR)/opt/etc/init.d
	install -m 755 $(ENDOR_SOURCE_DIR)/instrumentcontroller-supervisor $(ENDOR_IPK_DIR)/opt/bin/instrumentcontroller-supervisor
	install -m 755 $(ENDOR_SOURCE_DIR)/rc.endor-webapp $(ENDOR_IPK_DIR)/opt/etc/init.d/S99endor-webapp
	install -m 755 $(ENDOR_SOURCE_DIR)/rc.endor-instrumentcontroller $(ENDOR_IPK_DIR)/opt/etc/init.d/S99endor-instrumentcontroller
	install -m 755 $(ENDOR_SOURCE_DIR)/rc.endor-virtualinstrument $(ENDOR_IPK_DIR)/opt/etc/init.d/S99endor-virtualinstrument
	install -m 755 $(ENDOR_IPK_DIR)/opt/lib/endor/WebApp.dll $(ENDOR_IPK_DIR)/opt/lib/endor/bin/WebApp.dll
	install -d $(ENDOR_IPK_DIR)/opt/share/endor
	install -m 755 $(ENDOR_BUILD_DIR)/Endor/Instrument/VirtualInstrument/Files/V0.05SyncEthernetDemowander_V4_NEW.cpd $(ENDOR_IPK_DIR)/opt/share/endor/V0.05SyncEthernetDemowander_V4_NEW.cpd
	cp -r $(ENDOR_BUILD_DIR)/Endor/Data/Schema $(ENDOR_IPK_DIR)/opt/lib/endor/schema
#	install -m 644 $(ENDOR_SOURCE_DIR)/endor.conf $(ENDOR_IPK_DIR)/opt/etc/endor.conf
	$(MAKE) $(ENDOR_IPK_DIR)/CONTROL/control
	install -m 755 $(ENDOR_SOURCE_DIR)/postinst $(ENDOR_IPK_DIR)/CONTROL/postinst
	install -m 755 $(ENDOR_SOURCE_DIR)/prerm $(ENDOR_IPK_DIR)/CONTROL/prerm
	echo $(ENDOR_CONFFILES) | sed -e 's/ /\n/g' > $(ENDOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENDOR_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ENDOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
endor-ipk: $(ENDOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
endor-clean:
	rm -f $(ENDOR_BUILD_DIR)/.built
	-$(MAKE) -C $(ENDOR_BUILD_DIR) clean

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
