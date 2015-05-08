###########################################################
#
# debian-installer
#
###########################################################

# You must replace "debian-installer" and "DEBIAN-INSTALLER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DEBIAN-INSTALLER_VERSION, DEBIAN-INSTALLER_SITE and DEBIAN-INSTALLER_SOURCE define
# the upstream location of the source code for the package.
# DEBIAN-INSTALLER_DIR is the directory which is created when the source
# archive is unpacked.
# DEBIAN-INSTALLER_UNZIP is the command used to unzip the source.
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
DEBIAN-INSTALLER_VERSION=0.0.1
DEBIAN-INSTALLER_SOURCE=debian-installer-$(DEBIAN-INSTALLER_VERSION).tar.gz
DEBIAN-INSTALLER_DIR=debian-installer-$(DEBIAN-INSTALLER_VERSION)
DEBIAN-INSTALLER_UNZIP=zcat
DEBIAN-INSTALLER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DEBIAN-INSTALLER_DESCRIPTION=Describe debian-installer here.
DEBIAN-INSTALLER_SECTION=
DEBIAN-INSTALLER_PRIORITY=optional
DEBIAN-INSTALLER_DEPENDS=
DEBIAN-INSTALLER_SUGGESTS=
DEBIAN-INSTALLER_CONFLICTS=

#
# DEBIAN-INSTALLER_IPK_VERSION should be incremented when the ipk changes.
#
DEBIAN-INSTALLER_IPK_VERSION=1

#
# DEBIAN-INSTALLER_CONFFILES should be a list of user-editable files
#DEBIAN-INSTALLER_CONFFILES=/opt/etc/debian-installer.conf /opt/etc/init.d/SXXdebian-installer

#
# DEBIAN-INSTALLER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DEBIAN-INSTALLER_CONFIG=$(DEBIAN-INSTALLER_SRC_DIR)/config

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DEBIAN-INSTALLER_CPPFLAGS=
DEBIAN-INSTALLER_LDFLAGS=

#
# DEBIAN-INSTALLER_BUILD_DIR is the directory in which the build is done.
# DEBIAN-INSTALLER_SRC_DIR is the directory which holds all the
# patches and ipkg control files.
# DEBIAN-INSTALLER_IPK_DIR is the directory in which the ipk is built.
# DEBIAN-INSTALLER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEBIAN-INSTALLER_BUILD_DIR=$(BUILD_DIR)/debian-installer
DEBIAN-INSTALLER_SRC_DIR=$(SOURCE_DIR)/debian-installer
DEBIAN-INSTALLER_IPK_DIR=$(BUILD_DIR)/debian-installer-$(DEBIAN-INSTALLER_VERSION)-ipk
DEBIAN-INSTALLER_IPK=$(BUILD_DIR)/DEBIAN-INSTALLER_$(DEBIAN-INSTALLER_VERSION)-$(DEBIAN-INSTALLER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: debian-installer-source debian-installer-unpack debian-installer debian-installer-stage debian-installer-ipk debian-installer-clean debian-installer-dirclean debian-installer-check

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
$(DEBIAN-INSTALLER_BUILD_DIR)/.configured: $(DEBIAN-INSTALLER_PATCHES) make/debian-installer.mk
#	$(MAKE) packages
	$(MAKE) optware-bootstrap-ipk debian-root
	sudo rm -rf $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR)
	# Apply the Debian root configs such that the live demo and
	# root FS match as closely as possible.
	#cp -ar $(DEBIAN-ROOT_CONFIG) $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR)
	# Configs for the live system *OLNY*
	#cp -ar $(DEBIAN-LIVE_CONFIG) $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR)
	# Configs for the installer
	cp -ar $(DEBIAN-INSTALLER_CONFIG) $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR)
	mkdir -p $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR)/config/includes.binary/optware
	cd $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR)/config/includes.binary/optware ; \
		wget -r --no-parent --no-host-directories --cut-dirs=2 --reject "index.html*" \
		http://packages.calnexsol.com/optware/$(TARGET_DISTRO)/ | true; # Don't error out.
	if test "$(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	# Live config recipe (no not modify unless you know 				\
	# what you're doing!) 								\
	sudo lb config									\
		--architectures				amd64				\
		--binary-images				iso-hybrid			\
		--distribution				jessie				\
		--memtest				memtest86+			\
		--checksums				sha1				\
		--debian-installer			live				\
		--debian-installer-preseedfile		debconf				\
		--win32-loader				false				\
		--loadlin				false				\
		--mirror-bootstrap			$(TARGET_REPO_MIRROR)/debian	\
		--mirror-chroot				$(TARGET_REPO_MIRROR)/debian	\
		--mirror-chroot-security	$(TARGET_REPO_MIRROR)/security	\
		--mirror-binary				$(TARGET_REPO_MIRROR)/debian	\
		--mirror-binary-security	$(TARGET_REPO_MIRROR)/security	\
		--debootstrap-options		"--no-check-gpg" \
		--bootappend-live		"boot=live config username=calnex"	\
		--iso-application			"Springbank installer"		\
		--iso-publisher				"Calnex Solutions"		\
		--iso-volume				"Springbank installer"		\
		;									\
		sudo mkdir -p $(@D)/config/includes.chroot/bin/; 			\
		sudo cp $(BUILD_DIR)/Springbank-bootstrap_1.2-7_x86_64.xsh $(@D)/config/includes.chroot/bin/; \
		sudo cp $(DEBIAN-ROOT_BUILD_DIR)/live-image-amd64.hybrid.iso $(@D)/config/includes.binary/ ;\
	)
	touch $@

debian-installer-unpack: $(DEBIAN-INSTALLER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DEBIAN-INSTALLER_BUILD_DIR)/.built: $(DEBIAN-INSTALLER_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		sudo lb build; \
	)
	touch $@

#
# This is the build convenience target.
#
debian-installer: $(DEBIAN-INSTALLER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DEBIAN-INSTALLER_BUILD_DIR)/.staged: $(DEBIAN-INSTALLER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

debian-installer-stage: $(DEBIAN-INSTALLER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/debian-installer
#
$(DEBIAN-INSTALLER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: debian-installer" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEBIAN-INSTALLER_PRIORITY)" >>$@
	@echo "Section: $(DEBIAN-INSTALLER_SECTION)" >>$@
	@echo "Version: $(DEBIAN-INSTALLER_VERSION)-$(DEBIAN-INSTALLER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEBIAN-INSTALLER_MAINTAINER)" >>$@
	@echo "Source: $(DEBIAN-INSTALLER_SITE)/$(DEBIAN-INSTALLER_SOURCE)" >>$@
	@echo "Description: $(DEBIAN-INSTALLER_DESCRIPTION)" >>$@
	@echo "Depends: $(DEBIAN-INSTALLER_DEPENDS)" >>$@
	@echo "Suggests: $(DEBIAN-INSTALLER_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEBIAN-INSTALLER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEBIAN-INSTALLER_IPK_DIR)/opt/sbin or $(DEBIAN-INSTALLER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEBIAN-INSTALLER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEBIAN-INSTALLER_IPK_DIR)/opt/etc/debian-installer/...
# Documentation files should be installed in $(DEBIAN-INSTALLER_IPK_DIR)/opt/doc/debian-installer/...
# Daemon startup scripts should be installed in $(DEBIAN-INSTALLER_IPK_DIR)/opt/etc/init.d/S??debian-installer
#
# You may need to patch your application to make it use these locations.
#
$(DEBIAN-INSTALLER_IPK): $(DEBIAN-INSTALLER_BUILD_DIR)/.built
	rm -rf $(DEBIAN-INSTALLER_IPK_DIR) $(BUILD_DIR)/DEBIAN-INSTALLER_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(DEBIAN-INSTALLER_BUILD_DIR) DESTDIR=$(DEBIAN-INSTALLER_IPK_DIR) install-strip
	$(MAKE) $(DEBIAN-INSTALLER_IPK_DIR)/CONTROL/control
	echo $(DEBIAN-INSTALLER_CONFFILES) | sed -e 's/ /\n/g' > $(DEBIAN-INSTALLER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEBIAN-INSTALLER_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DEBIAN-INSTALLER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
debian-installer-ipk: $(DEBIAN-INSTALLER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
debian-installer-clean:
	sudo rm -rf $(DEBIAN-INSTALLER_BUILD_DIR)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
debian-installer-dirclean:
	rm -rf $(BUILD_DIR)/$(DEBIAN-INSTALLER_DIR) $(DEBIAN-INSTALLER_BUILD_DIR) $(DEBIAN-INSTALLER_IPK_DIR) $(DEBIAN-INSTALLER_IPK)
#
#
# Some sanity check for the package.
#
debian-installer-check: $(DEBIAN-INSTALLER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
