###########################################################
#
# debian-live
#
###########################################################

# You must replace "debian-live" and "DEBIAN-LIVE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DEBIAN-LIVE_VERSION, DEBIAN-LIVE_SITE and DEBIAN-LIVE_SOURCE define
# the upstream location of the source code for the package.
# DEBIAN-LIVE_DIR is the directory which is created when the source
# archive is unpacked.
# DEBIAN-LIVE_UNZIP is the command used to unzip the source.
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
DEBIAN-LIVE_VERSION=0.0.1
DEBIAN-LIVE_SOURCE=debian-live-$(DEBIAN-LIVE_VERSION).tar.gz
DEBIAN-LIVE_DIR=debian-live-$(DEBIAN-LIVE_VERSION)
DEBIAN-LIVE_UNZIP=zcat
DEBIAN-LIVE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DEBIAN-LIVE_DESCRIPTION=Describe debian-live here.
DEBIAN-LIVE_SECTION=
DEBIAN-LIVE_PRIORITY=optional
DEBIAN-LIVE_DEPENDS=
DEBIAN-LIVE_SUGGESTS=
DEBIAN-LIVE_CONFLICTS=

TARGET_PRODUCT ?= Paragon

#
# DEBIAN-LIVE_IPK_VERSION should be incremented when the ipk changes.
#
DEBIAN-LIVE_IPK_VERSION=1

#
# DEBIAN-LIVE_CONFFILES should be a list of user-editable files
#DEBIAN-LIVE_CONFFILES=/opt/etc/debian-live.conf /opt/etc/init.d/SXXdebian-live

#
# DEBIAN-LIVE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DEBIAN-LIVE_CONFIG=$(DEBIAN-LIVE_SRC_DIR)/config

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DEBIAN-LIVE_CPPFLAGS=
DEBIAN-LIVE_LDFLAGS=

#
# DEBIAN-LIVE_BUILD_DIR is the directory in which the build is done.
# DEBIAN-LIVE_SRC_DIR is the directory which holds all the
# patches and ipkg control files.
# DEBIAN-LIVE_IPK_DIR is the directory in which the ipk is built.
# DEBIAN-LIVE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEBIAN-LIVE_BUILD_DIR=$(BUILD_DIR)/debian-live
DEBIAN-LIVE_SRC_DIR=$(SOURCE_DIR)/debian-live
DEBIAN-LIVE_IPK_DIR=$(BUILD_DIR)/debian-live-$(DEBIAN-LIVE_VERSION)-ipk
DEBIAN-LIVE_IPK=$(BUILD_DIR)/DEBIAN-LIVE_$(DEBIAN-LIVE_VERSION)-$(DEBIAN-LIVE_IPK_VERSION)_$(TARGET_ARCH).ipk

# If not defined, point to the Default Packages server
TARGET_PACKAGES_MIRROR?=http://packages.calnexsol.com/optware/$(TARGET_DISTRO)/

.PHONY: debian-live-source debian-live-unpack debian-live debian-live-stage debian-live-ipk debian-live-clean debian-live-dirclean debian-live-check

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
$(DEBIAN-LIVE_BUILD_DIR)/.configured: $(DEBIAN-LIVE_PATCHES) make/debian-live.mk
	$(MAKE) optware-bootstrap-ipk
	
	# Clear out the folder into which we are going to build
	#
	echo "Checking to see whether there is an existing debian-live folder"
	if [ -d $(DEBIAN-LIVE_BUILD_DIR) ]; \
        then \
		sudo umount `mount | grep $(DEBIAN-LIVE_BUILD_DIR) | awk '{ print $3}'` | true; \
		sudo rm -rf $(DEBIAN-LIVE_BUILD_DIR); \
	fi
	echo "Finished clearing existing debian-live folder"
	
	sudo rm -rf $(BUILD_DIR)/$(DEBIAN-LIVE_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(DEBIAN-LIVE_DIR)
	# Apply the Debian root configs such that the live demo and
	# root FS match as closely as possible.
	cp -ar $(DEBIAN_CONFIG) $(BUILD_DIR)/$(DEBIAN-LIVE_DIR)
	# Configs for the live system *OLNY*
	cp -ar $(DEBIAN-LIVE_CONFIG) $(BUILD_DIR)/$(DEBIAN-LIVE_DIR)
	# Delete the extlinux boot folder
	rm -rf $(@D)/config/includes.binary/boot
	# Inject product version into vi installation 
	sed -i -e "s/__TARGET_PRODUCT__/${TARGET_PRODUCT_LOWER}/g" $(BUILD_DIR)/$(DEBIAN-LIVE_DIR)/config/hooks/0460-install-endor.hook.chroot
	# Inject the target packages server into the cross feed file
	sed -i -e "s|__TARGET_PACKAGES__|${TARGET_PACKAGES_MIRROR}|g" $(BUILD_DIR)/$(DEBIAN-LIVE_DIR)/config/hooks/0460-install-endor.hook.chroot
	# Temporary hook to pull in demo files!
	cd $(BUILD_DIR)/$(DEBIAN-LIVE_DIR)/config/includes.chroot/etc/skel ; \
		wget -r --no-parent --no-host-directories --cut-dirs=1 --reject "index.html*" \
		http://packages.calnexsol.com/demo_files/ | true; # Don't error out.
	if test "$(BUILD_DIR)/$(DEBIAN-LIVE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DEBIAN-LIVE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	# Live config recipe (no not modify unless you know 									\
	# what you're doing!) 													\
	sudo lb config														\
		--architectures				amd64									\
		--binary-images				iso-hybrid								\
		--distribution				$(TARGET_DISTRO)							\
		--apt-indices				false									\
		--apt-recommends			false									\
		--memtest					memtest86+							\
		--checksums					sha1								\
		--win32-loader				false									\
		--loadlin					false								\
		--backports					true								\
		--mirror-bootstrap			$(TARGET_REPO_MIRROR)/debian						\
		--mirror-chroot				$(TARGET_REPO_MIRROR)/debian						\
		--mirror-chroot-security	$(TARGET_REPO_MIRROR)/security							\
		--mirror-binary				$(TARGET_REPO_MIRROR)/debian						\
		--mirror-binary-security	$(TARGET_REPO_MIRROR)/security							\
		--debootstrap-options           "--no-check-gpg" 								\
		--iso-application			"Springbank demo"							\
		--iso-publisher				"Calnex Solutions"							\
		--iso-volume				"Springbank demo"							\
		;														\
		sudo mkdir -p $(@D)/config/includes.chroot/bin/; 								\
		sudo cp $(BUILD_DIR)/Springbank-bootstrap_1.2-7_x86_64.xsh $(@D)/config/includes.chroot/bin/; 			\
	)
	touch $@

debian-live-unpack: $(DEBIAN-LIVE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DEBIAN-LIVE_BUILD_DIR)/.built: $(DEBIAN-LIVE_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		PRODUCT=$(TARGET_PRODUCT) sudo lb build; \
	)
	touch $@

#
# This is the build convenience target.
#
debian-live: $(DEBIAN-LIVE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DEBIAN-LIVE_BUILD_DIR)/.staged: $(DEBIAN-LIVE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

debian-live-stage: $(DEBIAN-LIVE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/debian-live
#
$(DEBIAN-LIVE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: debian-live" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEBIAN-LIVE_PRIORITY)" >>$@
	@echo "Section: $(DEBIAN-LIVE_SECTION)" >>$@
	@echo "Version: $(DEBIAN-LIVE_VERSION)-$(DEBIAN-LIVE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEBIAN-LIVE_MAINTAINER)" >>$@
	@echo "Source: $(DEBIAN-LIVE_SITE)/$(DEBIAN-LIVE_SOURCE)" >>$@
	@echo "Description: $(DEBIAN-LIVE_DESCRIPTION)" >>$@
	@echo "Depends: $(DEBIAN-LIVE_DEPENDS)" >>$@
	@echo "Suggests: $(DEBIAN-LIVE_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEBIAN-LIVE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEBIAN-LIVE_IPK_DIR)/opt/sbin or $(DEBIAN-LIVE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEBIAN-LIVE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEBIAN-LIVE_IPK_DIR)/opt/etc/debian-live/...
# Documentation files should be installed in $(DEBIAN-LIVE_IPK_DIR)/opt/doc/debian-live/...
# Daemon startup scripts should be installed in $(DEBIAN-LIVE_IPK_DIR)/opt/etc/init.d/S??debian-live
#
# You may need to patch your application to make it use these locations.
#
$(DEBIAN-LIVE_IPK): $(DEBIAN-LIVE_BUILD_DIR)/.built
	rm -rf $(DEBIAN-LIVE_IPK_DIR) $(BUILD_DIR)/DEBIAN-LIVE_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(DEBIAN-LIVE_BUILD_DIR) DESTDIR=$(DEBIAN-LIVE_IPK_DIR) install-strip
	$(MAKE) $(DEBIAN-LIVE_IPK_DIR)/CONTROL/control
	echo $(DEBIAN-LIVE_CONFFILES) | sed -e 's/ /\n/g' > $(DEBIAN-LIVE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEBIAN-LIVE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DEBIAN-LIVE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
debian-live-ipk: $(DEBIAN-LIVE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
debian-live-clean:
	sudo rm -rf $(DEBIAN-LIVE_BUILD_DIR)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
debian-live-dirclean:
	rm -rf $(BUILD_DIR)/$(DEBIAN-LIVE_DIR) $(DEBIAN-LIVE_BUILD_DIR) $(DEBIAN-LIVE_IPK_DIR) $(DEBIAN-LIVE_IPK)
#
#
# Some sanity check for the package.
#
debian-live-check: $(DEBIAN-LIVE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
