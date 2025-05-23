#########################################################
#
# debian-efi
#
###########################################################

# You must replace "debian" and "DEBIAN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DEBIAN_VERSION, DEBIAN-EFI_SITE and DEBIAN-EFI_SOURCE define
# the upstream location of the source code for the package.
# DEBIAN-EFI_DIR is the directory which is created when the source
# archive is unpacked.
# DEBIAN-EFI_UNZIP is the command used to unzip the source.
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
DEBIAN_VERSION?=11.xx
DEBIAN-EFI_SOURCE=debian-$(DEBIAN_VERSION).tar.gz
DEBIAN-EFI_DIR=debian-efi-$(DEBIAN_VERSION)
DEBIAN-EFI_UNZIP=zcat
DEBIAN-EFI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DEBIAN-EFI_DESCRIPTION=Minimal install of the Debian GNU/Linux Operating System
DEBIAN-EFI_SECTION=kernel
DEBIAN-EFI_PRIORITY=optional
DEBIAN-EFI_DEPENDS=
DEBIAN-EFI_SUGGESTS=
DEBIAN-EFI_CONFLICTS=

#
# DEBIAN_IPK_VERSION should be incremented when the ipk changes.
#
DEBIAN_BUILD_NO?=DEVEL
DEBIAN_IPK_VERSION=$(DEBIAN_BUILD_NO)
#
# DEBIAN-EFI_PARTITION_LABEL CANNOT be longer than 10 Characters, it will cause boot failure. 
#
DEBIAN-EFI_PARTITION_LABEL=OS_$(DEBIAN_VERSION).$(DEBIAN_IPK_VERSION)

#
# DEBIAN-EFI_CONFFILES should be a list of user-editable files
#DEBIAN-EFI_CONFFILES=/opt/etc/debian.conf /opt/etc/init.d/SXXdebian

#
# If not defined, set the default SMD URL
#
TARGET_SMD?=http://packages.calnexsol.com/SMD/

#
# DEBIAN-EFI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DEBIAN-EFI_CONFIG=$(DEBIAN-EFI_SRC_DIR)/config

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DEBIAN-EFI_CPPFLAGS=
DEBIAN-EFI_LDFLAGS=

#
# DEBIAN-EFI_BUILD_DIR is the directory in which the build is done.
# DEBIAN-EFI_SRC_DIR is the directory which holds all the
# patches and ipkg control files.
# DEBIAN-EFI_IPK_DIR is the directory in which the ipk is built.
# DEBIAN-EFI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEBIAN-EFI_BUILD_DIR=$(BUILD_DIR)/debian-efi
DEBIAN-EFI_SRC_DIR=$(SOURCE_DIR)/debian
DEBIAN-EFI_IPK_DIR=$(BUILD_DIR)/debian-efi-$(DEBIAN_VERSION)-ipk
DEBIAN-EFI_IPK=$(BUILD_DIR)/debian_$(DEBIAN_VERSION).$(DEBIAN_IPK_VERSION)-efi_$(TARGET_ARCH).ipk

.PHONY: debian-efi-source debian-efi-unpack debian-efi debian-efi-stage debian-efi-ipk debian-efi-clean debian-efi-dirclean debian-efi-check

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
$(DEBIAN-EFI_BUILD_DIR)/.configured: $(DEBIAN-EFI_PATCHES) make/debian-efi.mk
#	$(MAKE) packages
	$(MAKE) optware-bootstrap-ipk
	sudo rm -rf $(BUILD_DIR)/$(DEBIAN-EFI_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(DEBIAN-EFI_DIR)
	cp -ar $(DEBIAN-EFI_CONFIG) $(BUILD_DIR)/$(DEBIAN-EFI_DIR)
	if test "$(BUILD_DIR)/$(DEBIAN-EFI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DEBIAN-EFI_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	# Live config recipe (no not modify unless you know what you're doing!)		\
	# /usr/lib/live/build/config --help						\
	sudo lb config noauto								\
		--architecture				amd64				\
		--binary-image				iso-hybrid			\
		--binary-filesystem			ext4				\
		--distribution				$(TARGET_DISTRO)	\
		--apt-indices				false				\
		--apt-recommends			false				\
		--apt-source-archives		false 				\
		--ignore-system-defaults	true				\
		--memtest					none				\
		--checksums					sha1				\
		--win32-loader				false				\
		--loadlin					false				\
		--backports					true				\
		--updates					true				\
		--security					true				\
		--archive-areas 			"main,updates/main"	\
		--mirror-bootstrap			$(TARGET_REPO_MIRROR)/debian	\
		--mirror-chroot				$(TARGET_REPO_MIRROR)/debian	\
		--mirror-chroot-security	$(TARGET_REPO_MIRROR)/debian-security	\
		--mirror-binary				$(TARGET_REPO_MIRROR)/debian	\
		--mirror-binary-security	$(TARGET_REPO_MIRROR)/debian-security	\
		--debootstrap-options		"--keyring=/root/.gnupg/pubring.kbx"		\
		--hdd-label					"$(DEBIAN-EFI_PARTITION_LABEL)"	\
		--hdd-size					320						\
		--bootloader				grub-efi				\
		--linux-packages			"linux-image-5.10.0-32" \
		;									\
		sudo mkdir -p $(@D)/config/includes.chroot/bin/;			\
		sudo cp $(BUILD_DIR)/Springbank-bootstrap_1.2-7_x86_64.xsh $(@D)/config/includes.chroot/bin/; \
		#sudo cp -ar $(PACKAGE_DIR) $(@D)/config/includes.binary/optware; \
		sudo sed -i -e 's/__LIVE_MEDIA__/$(DEBIAN-EFI_PARTITION_LABEL)/g' $(@D)/config/includes.binary/boot/extlinux/live.cfg; \
		sudo sed -i -e 's/__LIVE_MEDIA__/$(DEBIAN-EFI_PARTITION_LABEL)/g' $(@D)/config/includes.binary/boot/grub/grub.cfg; \
		sudo mkdir -p $(@D)/config/packages.chroot;\
		cd $(@D)/config/packages.chroot; \
		sudo wget -nv -r -l1 -nd --no-parent -A 'SysMgmtDaemon_*.deb' $(TARGET_SMD);\
		sudo dpkg-name SysMgmtDaemon_*.deb;	\
	)
	touch $@

debian-efi-unpack: $(DEBIAN-EFI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DEBIAN-EFI_BUILD_DIR)/.built: $(DEBIAN-EFI_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		# Add a custom MKSQUASHFS_OPTION to prevent exports, resolves an issue with overlayFS during downgrades \
		export MKSQUASHFS_OPTIONS="-no-exports"; \
		sudo lb build; \
		\
		# Extract EFI partition that is 'embedded' into rootfs partition and place at the end where it can easily be extracted \
		mkdir tmp; \
		fuseiso live-image-amd64.hybrid.iso tmp; \
		cp tmp/boot/grub/efi.img ./efi.img; \
		xorriso -as genisoimage \
			-r -V '$(DEBIAN-EFI_PARTITION_LABEL)' \
			-o bootable.iso \
			-J -joliet-long -cache-inodes \
			-append_partition 2 0xef ./efi.img \
			-appended_part_as_gpt \
			-e --interval:appended_partition_2:all:: \
			-no-emul-boot \
			-partition_offset 16 \
			-no-pad \
			tmp; \
		fusermount -u tmp; \
		rm -rf tmp; \
		\
		# Extract EFI (boot) and rootfs (root) partitions into individual images \
		dd \
			if=bootable.iso \
			of=root.iso \
			skip=`/sbin/fdisk -l bootable.iso | awk '/basic data/ {print $$2}'` \
			count=`/sbin/fdisk -l bootable.iso | awk '/basic data/ {print $$4}'`; \
		dd \
			if=bootable.iso \
			of=boot.iso \
			skip=`/sbin/fdisk -l bootable.iso | awk '/EFI/ {print $$2}'` \
			count=`/sbin/fdisk -l bootable.iso | awk '/EFI/ {print $$4}'`; \
		gpg --local-user 64F48DD3 --armour --detach-sign root.iso; \
		\
		md5sum root.iso > root.iso.md5; \
	)
	touch $@

#
# This is the build convenience target.
#
debian-efi: $(DEBIAN-EFI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DEBIAN-EFI_BUILD_DIR)/.staged: $(DEBIAN-EFI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

debian-efi-stage: $(DEBIAN-EFI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/debian
#
$(DEBIAN-EFI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: debian" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEBIAN-EFI_PRIORITY)" >>$@
	@echo "Section: $(DEBIAN-EFI_SECTION)" >>$@
	@echo "Version: $(DEBIAN_VERSION).$(DEBIAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEBIAN-EFI_MAINTAINER)" >>$@
	@echo "Source: $(DEBIAN-EFI_SITE)/$(DEBIAN-EFI_SOURCE)" >>$@
	@echo "Description: $(DEBIAN-EFI_DESCRIPTION)" >>$@
	@echo "Depends: $(DEBIAN-EFI_DEPENDS)" >>$@
	@echo "Suggests: $(DEBIAN-EFI_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEBIAN-EFI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEBIAN-EFI_IPK_DIR)/opt/sbin or $(DEBIAN-EFI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEBIAN-EFI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEBIAN-EFI_IPK_DIR)/opt/etc/debian/...
# Documentation files should be installed in $(DEBIAN-EFI_IPK_DIR)/opt/doc/debian/...
# Daemon startup scripts should be installed in $(DEBIAN-EFI_IPK_DIR)/opt/etc/init.d/S??debian
#
# You may need to patch your application to make it use these locations.
#
$(DEBIAN-EFI_IPK): $(DEBIAN-EFI_BUILD_DIR)/.built
	rm -rf $(DEBIAN-EFI_IPK_DIR) $(BUILD_DIR)/debian_*_$(TARGET_ARCH).ipk
	$(MAKE) $(DEBIAN-EFI_IPK_DIR)/CONTROL/control
	echo $(DEBIAN-EFI_CONFFILES) | sed -e 's/ /\n/g' > $(DEBIAN-EFI_IPK_DIR)/CONTROL/conffiles
	install -d $(DEBIAN-EFI_IPK_DIR)/opt/var/lib/debian
	install -m 755 $(DEBIAN-EFI_BUILD_DIR)/boot.iso	$(DEBIAN-EFI_IPK_DIR)/opt/var/lib/debian/
	install -m 755 $(DEBIAN-EFI_BUILD_DIR)/root.iso	$(DEBIAN-EFI_IPK_DIR)/opt/var/lib/debian/
	install -m 755 $(DEBIAN-EFI_BUILD_DIR)/root.iso.asc	$(DEBIAN-EFI_IPK_DIR)/opt/var/lib/debian/
	install -m 755 $(DEBIAN-EFI_BUILD_DIR)/root.iso.md5	$(DEBIAN-EFI_IPK_DIR)/opt/var/lib/debian/
	install -m 755  $(DEBIAN-EFI_BUILD_DIR)/bootable.iso $(DEBIAN-EFI_IPK_DIR)/opt/var/lib/debian/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEBIAN-EFI_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DEBIAN-EFI_IPK_DIR)

$(DEBIAN-EFI_BUILD_DIR)/.ipk: $(DEBIAN-EFI_IPK)
	touch $@

debian-efi-ipk: $(DEBIAN-EFI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
debian-efi-clean:
	sudo rm -rf $(DEBIAN-EFI_BUILD_DIR)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
debian-efi-dirclean:
	rm -rf $(BUILD_DIR)/$(DEBIAN-EFI_DIR) $(DEBIAN-EFI_BUILD_DIR) $(DEBIAN-EFI_IPK_DIR) $(DEBIAN-EFI_IPK)
#
#
# Some sanity check for the package.
#
debian-efi-check: $(DEBIAN-EFI_IPK)

