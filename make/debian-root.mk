###########################################################
#
# debian-root
#
###########################################################

# You must replace "debian-root" and "DEBIAN-ROOT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DEBIAN-ROOT_VERSION, DEBIAN-ROOT_SITE and DEBIAN-ROOT_SOURCE define
# the upstream location of the source code for the package.
# DEBIAN-ROOT_DIR is the directory which is created when the source
# archive is unpacked.
# DEBIAN-ROOT_UNZIP is the command used to unzip the source.
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
DEBIAN-ROOT_VERSION=0.0.1
DEBIAN-ROOT_SOURCE=debian-root-$(DEBIAN-ROOT_VERSION).tar.gz
DEBIAN-ROOT_DIR=debian-root-$(DEBIAN-ROOT_VERSION)
DEBIAN-ROOT_UNZIP=zcat
DEBIAN-ROOT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DEBIAN-ROOT_DESCRIPTION=Describe debian-root here.
DEBIAN-ROOT_SECTION=
DEBIAN-ROOT_PRIORITY=optional
DEBIAN-ROOT_DEPENDS=
DEBIAN-ROOT_SUGGESTS=
DEBIAN-ROOT_CONFLICTS=

#
# DEBIAN-ROOT_IPK_VERSION should be incremented when the ipk changes.
#
DEBIAN-ROOT_IPK_VERSION=1

#
# DEBIAN-ROOT_CONFFILES should be a list of user-editable files
#DEBIAN-ROOT_CONFFILES=/opt/etc/debian-root.conf /opt/etc/init.d/SXXdebian-root

#
# DEBIAN-ROOT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DEBIAN-ROOT_CONFIG=$(DEBIAN-ROOT_SRC_DIR)/config

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DEBIAN-ROOT_CPPFLAGS=
DEBIAN-ROOT_LDFLAGS=

#
# DEBIAN-ROOT_BUILD_DIR is the directory in which the build is done.
# DEBIAN-ROOT_SRC_DIR is the directory which holds all the
# patches and ipkg control files.
# DEBIAN-ROOT_IPK_DIR is the directory in which the ipk is built.
# DEBIAN-ROOT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEBIAN-ROOT_BUILD_DIR=$(BUILD_DIR)/debian-root
DEBIAN-ROOT_SRC_DIR=$(SOURCE_DIR)/debian-root
DEBIAN-ROOT_IPK_DIR=$(BUILD_DIR)/debian-root-$(DEBIAN-ROOT_VERSION)-ipk
DEBIAN-ROOT_IPK=$(BUILD_DIR)/DEBIAN-ROOT_$(DEBIAN-ROOT_VERSION)-$(DEBIAN-ROOT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: debian-root-source debian-root-unpack debian-root debian-root-stage debian-root-ipk debian-root-clean debian-root-dirclean debian-root-check

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
$(DEBIAN-ROOT_BUILD_DIR)/.configured: $(DEBIAN-ROOT_PATCHES) make/debian-root.mk
#	$(MAKE) packages
	$(MAKE) optware-bootstrap-ipk
	sudo rm -rf $(BUILD_DIR)/$(DEBIAN-ROOT_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(DEBIAN-ROOT_DIR)
	cp -ar $(DEBIAN-ROOT_CONFIG) $(BUILD_DIR)/$(DEBIAN-ROOT_DIR)
	if test "$(BUILD_DIR)/$(DEBIAN-ROOT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DEBIAN-ROOT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	# Live config recipe (no not modify unless you know 				\
	# what you're doing!) 								\
	sudo lb config									\
		--architecture				amd64				\
		--binary-image				iso-hybrid			\
		--distribution				$(TARGET_DISTRO)		\
		--apt-indices				false				\
		--apt-recommends			false				\
		--bootloader				grub2				\
		--binary-filesystem			ext4				\
		--memtest				memtest86+			\
		--checksums				sha1				\
		--debian-installer                      live				\
		--debian-installer-preseedfile          debconf				\
		--debootstrap-options			"--variant=minbase"		\
		--win32-loader				false				\
		--loadlin				false				\
		--grub-splash				splash.png			\
		--bootappend-live		"boot=live config username=calnex"	\
		--backports				true				\
		;									\
		sudo mkdir -p $(@D)/config/includes.chroot/bin/; 			\
		sudo cp $(BUILD_DIR)/Springbank-bootstrap_1.2-7_x86_64.xsh $(@D)/config/includes.chroot/bin/; \
		sudo cp -ar $(PACKAGE_DIR) $(@D)/config/includes.binary/optware; \
	)
	touch $@

debian-root-unpack: $(DEBIAN-ROOT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DEBIAN-ROOT_BUILD_DIR)/.built: $(DEBIAN-ROOT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		sudo lb build; \
	)
	touch $@

#
# This is the build convenience target.
#
debian-root: $(DEBIAN-ROOT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DEBIAN-ROOT_BUILD_DIR)/.staged: $(DEBIAN-ROOT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

debian-root-stage: $(DEBIAN-ROOT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/debian-root
#
$(DEBIAN-ROOT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: debian-root" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEBIAN-ROOT_PRIORITY)" >>$@
	@echo "Section: $(DEBIAN-ROOT_SECTION)" >>$@
	@echo "Version: $(DEBIAN-ROOT_VERSION)-$(DEBIAN-ROOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEBIAN-ROOT_MAINTAINER)" >>$@
	@echo "Source: $(DEBIAN-ROOT_SITE)/$(DEBIAN-ROOT_SOURCE)" >>$@
	@echo "Description: $(DEBIAN-ROOT_DESCRIPTION)" >>$@
	@echo "Depends: $(DEBIAN-ROOT_DEPENDS)" >>$@
	@echo "Suggests: $(DEBIAN-ROOT_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEBIAN-ROOT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEBIAN-ROOT_IPK_DIR)/opt/sbin or $(DEBIAN-ROOT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEBIAN-ROOT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEBIAN-ROOT_IPK_DIR)/opt/etc/debian-root/...
# Documentation files should be installed in $(DEBIAN-ROOT_IPK_DIR)/opt/doc/debian-root/...
# Daemon startup scripts should be installed in $(DEBIAN-ROOT_IPK_DIR)/opt/etc/init.d/S??debian-root
#
# You may need to patch your application to make it use these locations.
#
$(DEBIAN-ROOT_IPK): $(DEBIAN-ROOT_BUILD_DIR)/.built
	rm -rf $(DEBIAN-ROOT_IPK_DIR) $(BUILD_DIR)/DEBIAN-ROOT_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(DEBIAN-ROOT_BUILD_DIR) DESTDIR=$(DEBIAN-ROOT_IPK_DIR) install-strip
	$(MAKE) $(DEBIAN-ROOT_IPK_DIR)/CONTROL/control
	echo $(DEBIAN-ROOT_CONFFILES) | sed -e 's/ /\n/g' > $(DEBIAN-ROOT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEBIAN-ROOT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DEBIAN-ROOT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
debian-root-ipk: $(DEBIAN-ROOT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
debian-root-clean:
	sudo rm -rf $(DEBIAN-ROOT_BUILD_DIR)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
debian-root-dirclean:
	rm -rf $(BUILD_DIR)/$(DEBIAN-ROOT_DIR) $(DEBIAN-ROOT_BUILD_DIR) $(DEBIAN-ROOT_IPK_DIR) $(DEBIAN-ROOT_IPK)
#
#
# Some sanity check for the package.
#
debian-root-check: $(DEBIAN-ROOT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
