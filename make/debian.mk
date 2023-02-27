#########################################################
#
# debian
#
###########################################################

# You must replace "debian" and "DEBIAN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DEBIAN_VERSION, DEBIAN_SITE and DEBIAN_SOURCE define
# the upstream location of the source code for the package.
# DEBIAN_DIR is the directory which is created when the source
# archive is unpacked.
# DEBIAN_UNZIP is the command used to unzip the source.
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
DEBIAN_VERSION?=11.00
DEBIAN_SOURCE=debian-$(DEBIAN_VERSION).tar.gz
DEBIAN_DIR=debian-$(DEBIAN_VERSION)
DEBIAN_UNZIP=zcat
DEBIAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DEBIAN_DESCRIPTION=Minimal install of the Debian GNU/Linux Operating System
DEBIAN_SECTION=kernel
DEBIAN_PRIORITY=optional
DEBIAN_DEPENDS=
DEBIAN_SUGGESTS=
DEBIAN_CONFLICTS=

TARGET_DISTRO?=bullseye

#
# DEBIAN_IPK_VERSION should be incremented when the ipk changes.
#
DEBIAN_BUILD_NO?=DEVEL
DEBIAN_IPK_VERSION=$(DEBIAN_BUILD_NO)
#
# DEBIAN_PARTITION_LABEL CANNOT be longer than 10 Characters, it will cause boot failure. 
#
DEBIAN_PARTITION_LABEL=OS_$(DEBIAN_VERSION).$(DEBIAN_IPK_VERSION)

#
# DEBIAN_CONFFILES should be a list of user-editable files
#DEBIAN_CONFFILES=/opt/etc/debian.conf /opt/etc/init.d/SXXdebian

#
# If not defined, set the default SMD URL
#
TARGET_SMD?=http://packages.calnexsol.com/SMD/

#
# DEBIAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DEBIAN_CONFIG=$(DEBIAN_SRC_DIR)/config

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DEBIAN_CPPFLAGS=
DEBIAN_LDFLAGS=

#
# DEBIAN_BUILD_DIR is the directory in which the build is done.
# DEBIAN_SRC_DIR is the directory which holds all the
# patches and ipkg control files.
# DEBIAN_IPK_DIR is the directory in which the ipk is built.
# DEBIAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEBIAN_BUILD_DIR=$(BUILD_DIR)/debian
DEBIAN_SRC_DIR=$(SOURCE_DIR)/debian
DEBIAN_IPK_DIR=$(BUILD_DIR)/debian-$(DEBIAN_VERSION)-ipk
DEBIAN_IPK=$(BUILD_DIR)/debian_$(DEBIAN_VERSION).$(DEBIAN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: debian-source debian-unpack debian debian-stage debian-ipk debian-clean debian-dirclean debian-check

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
$(DEBIAN_BUILD_DIR)/.configured: $(DEBIAN_PATCHES) make/debian.mk
#	$(MAKE) packages
	$(MAKE) optware-bootstrap-ipk
	sudo rm -rf $(BUILD_DIR)/$(DEBIAN_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(DEBIAN_DIR)
	cp -ar $(DEBIAN_CONFIG) $(BUILD_DIR)/$(DEBIAN_DIR)
	if test "$(BUILD_DIR)/$(DEBIAN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DEBIAN_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	# Live config recipe (no not modify unless you know what you're doing!)		\
	# /usr/lib/live/build/config --help						\
	sudo lb config noauto								\
		--architecture				amd64				\
		--binary-image				hdd				\
		--binary-filesystem			ext4				\
		--distribution				$(TARGET_DISTRO)		\
		--apt-indices				false				\
		--apt-recommends			false				\
		--ignore-system-defaults	true				\
		--memtest					memtest86+			\
		--checksums					sha1				\
		--win32-loader				false				\
		--loadlin					false				\
		--backports					true				\
		--mirror-bootstrap			$(TARGET_REPO_MIRROR)/debian	\
		--mirror-chroot				$(TARGET_REPO_MIRROR)/debian	\
		--mirror-chroot-security	$(TARGET_REPO_MIRROR)/debian-security	\
		--mirror-binary				$(TARGET_REPO_MIRROR)/debian	\
		--mirror-binary-security	$(TARGET_REPO_MIRROR)/debian-security	\
		#--debootstrap-options		"--keyring=/root/.gnupg/pubring.kbx"		\
		--hdd-label					"$(DEBIAN_PARTITION_LABEL)"	\
		--hdd-size					320				\
		--bootloader				syslinux			\
		;									\
		sudo mkdir -p $(@D)/config/includes.chroot/bin/;			\
		sudo cp $(BUILD_DIR)/Springbank-bootstrap_1.2-7_x86_64.xsh $(@D)/config/includes.chroot/bin/; \
		#sudo cp -ar $(PACKAGE_DIR) $(@D)/config/includes.binary/optware; \
		sudo sed -i -e 's/__LIVE_MEDIA__/$(DEBIAN_PARTITION_LABEL)/g' $(@D)/config/includes.binary/boot/extlinux/live.cfg; \
		sudo mkdir -p $(@D)/config/packages.chroot;\
		cd $(@D)/config/packages.chroot;	\
		sudo wget -r -l1 -nd --no-parent -A 'SysMgmtDaemon_*.deb' $(TARGET_SMD);\
		sudo dpkg-name SysMgmtDaemon_*.deb;	\
	)
	touch $@

debian-unpack: $(DEBIAN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DEBIAN_BUILD_DIR)/.built: $(DEBIAN_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		sudo lb build; \
		dd \
			if=live-image-amd64.img \
			of=root.img \
			skip=`/sbin/fdisk -l live-image-amd64.img | awk '/Device/ {getline; print $$3}'` \
			count=`/sbin/fdisk -l live-image-amd64.img | awk '/Device/{getline; print $$5}'`; \
		dd \
			if=live-image-amd64.img \
			of=boot.img \
			bs=512 count=1; \
#		gpg --local-user 64F48DD3 --armour --detach-sign root.img; \
#		md5sum root.img > root.img.md5; \
	)
	touch $@

#
# This is the build convenience target.
#
debian: $(DEBIAN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DEBIAN_BUILD_DIR)/.staged: $(DEBIAN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

debian-stage: $(DEBIAN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/debian
#
$(DEBIAN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: debian" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEBIAN_PRIORITY)" >>$@
	@echo "Section: $(DEBIAN_SECTION)" >>$@
	@echo "Version: $(DEBIAN_VERSION).$(DEBIAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEBIAN_MAINTAINER)" >>$@
	@echo "Source: $(DEBIAN_SITE)/$(DEBIAN_SOURCE)" >>$@
	@echo "Description: $(DEBIAN_DESCRIPTION)" >>$@
	@echo "Depends: $(DEBIAN_DEPENDS)" >>$@
	@echo "Suggests: $(DEBIAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEBIAN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEBIAN_IPK_DIR)/opt/sbin or $(DEBIAN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEBIAN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEBIAN_IPK_DIR)/opt/etc/debian/...
# Documentation files should be installed in $(DEBIAN_IPK_DIR)/opt/doc/debian/...
# Daemon startup scripts should be installed in $(DEBIAN_IPK_DIR)/opt/etc/init.d/S??debian
#
# You may need to patch your application to make it use these locations.
#
$(DEBIAN_IPK): $(DEBIAN_BUILD_DIR)/.built
	rm -rf $(DEBIAN_IPK_DIR) $(BUILD_DIR)/debian_*_$(TARGET_ARCH).ipk
	$(MAKE) $(DEBIAN_IPK_DIR)/CONTROL/control
	echo $(DEBIAN_CONFFILES) | sed -e 's/ /\n/g' > $(DEBIAN_IPK_DIR)/CONTROL/conffiles
	install -d $(DEBIAN_IPK_DIR)/opt/var/lib/debian
	# Newly created boot paritions
	install -m 755 $(DEBIAN_BUILD_DIR)/boot.img	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/
	install -m 755 $(DEBIAN_BUILD_DIR)/root.img	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/
	install -m 755 $(DEBIAN_BUILD_DIR)/root.img.asc	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/
	install -m 755 $(DEBIAN_BUILD_DIR)/root.img.md5	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/
	# EFI created boot partitions
	if test -d $(DEBIAN-EFI_BUILD_DIR); then \
		install -m 755 $(DEBIAN-EFI_BUILD_DIR)/boot.iso	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/; \
		install -m 755 $(DEBIAN-EFI_BUILD_DIR)/root.iso	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/; \
		install -m 755 $(DEBIAN-EFI_BUILD_DIR)/root.iso.asc	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/; \
		install -m 755 $(DEBIAN-EFI_BUILD_DIR)/root.iso.md5	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/; \
		install -m 755 $(DEBIAN-EFI_BUILD_DIR)/bootable.iso	$(DEBIAN_IPK_DIR)/opt/var/lib/debian/; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEBIAN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DEBIAN_IPK_DIR)

$(DEBIAN_BUILD_DIR)/.ipk: $(DEBIAN_IPK)
	touch $@

debian-ipk: $(DEBIAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
debian-clean:
	sudo rm -rf $(DEBIAN_BUILD_DIR)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
debian-dirclean:
	rm -rf $(BUILD_DIR)/$(DEBIAN_DIR) $(DEBIAN_BUILD_DIR) $(DEBIAN_IPK_DIR) $(DEBIAN_IPK)
#
#
# Some sanity check for the package.
#
debian-check: $(DEBIAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
