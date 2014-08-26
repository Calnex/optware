###########################################################
#
# debian-root
#
###########################################################

# You must replace "debian-root" and "debian-root" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# debian-root_VERSION, debian-root_SITE and debian-root_SOURCE define
# the upstream location of the source code for the package.
# debian-root_DIR is the directory which is created when the source
# archive is unpacked.
# debian-root_UNZIP is the command used to unzip the source.
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
debian-root_VERSION=0.0.1
debian-root_SOURCE=debian-root-$(debian-root_VERSION).tar.gz
debian-root_DIR=debian-root-$(debian-root_VERSION)
debian-root_UNZIP=zcat
debian-root_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
debian-root_DESCRIPTION=Describe debian-root here.
debian-root_SECTION=
debian-root_PRIORITY=optional
debian-root_DEPENDS=
debian-root_SUGGESTS=
debian-root_CONFLICTS=

#
# debian-root_IPK_VERSION should be incremented when the ipk changes.
#
debian-root_IPK_VERSION=1

#
# debian-root_CONFFILES should be a list of user-editable files
#debian-root_CONFFILES=/opt/etc/debian-root.conf /opt/etc/init.d/SXXdebian-root

#
# debian-root_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
debian-root_CONFIG=$(debian-root_SOURCE_DIR)/config

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
debian-root_CPPFLAGS=
debian-root_LDFLAGS=

#
# debian-root_BUILD_DIR is the directory in which the build is done.
# debian-root_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# debian-root_IPK_DIR is the directory in which the ipk is built.
# debian-root_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
debian-root_BUILD_DIR=$(BUILD_DIR)/debian-root
debian-root_SOURCE_DIR=$(SOURCE_DIR)/debian-root
debian-root_IPK_DIR=$(BUILD_DIR)/debian-root-$(debian-root_VERSION)-ipk
debian-root_IPK=$(BUILD_DIR)/debian-root_$(debian-root_VERSION)-$(debian-root_IPK_VERSION)_$(TARGET_ARCH).ipk

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
$(debian-root_BUILD_DIR)/.configured: $(debian-root_PATCHES) make/debian-root.mk
	$(MAKE) optware-bootstrap-stage
	sudo rm -rf $(BUILD_DIR)/$(debian-root_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(debian-root_DIR)
	cp -ar $(debian-root_CONFIG) $(BUILD_DIR)/$(debian-root_DIR)
	if test "$(BUILD_DIR)/$(debian-root_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(debian-root_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		sudo lb init && \
		# Live config recipe (no not modify unless you know 		\
		# what you're doing!) 						\
		sudo lb config							\
		--architectures		amd64 					\
		--binary-images		iso-hybrid				\
		--memtest		memtest86+				\
		--bootappend-live	"boot=live config username=calnex"	\
		--debootstrap-options	"--variant=minbase"			\
		;								\
		sudo mkdir -p $(@D)/config/includes.chroot/bin/; \
		sudo cp $(STAGING_DIR)/bin/Springbank-bootstrap_1.2-7_x86_64.xsh $(@D)/config/includes.chroot/bin/; \
	)
	touch $@

debian-root-unpack: $(debian-root_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(debian-root_BUILD_DIR)/.built: $(debian-root_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		sudo lb build; \
	)
	touch $@

#
# This is the build convenience target.
#
debian-root: $(debian-root_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(debian-root_BUILD_DIR)/.staged: $(debian-root_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

debian-root-stage: $(debian-root_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/debian-root
#
$(debian-root_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: debian-root" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(debian-root_PRIORITY)" >>$@
	@echo "Section: $(debian-root_SECTION)" >>$@
	@echo "Version: $(debian-root_VERSION)-$(debian-root_IPK_VERSION)" >>$@
	@echo "Maintainer: $(debian-root_MAINTAINER)" >>$@
	@echo "Source: $(debian-root_SITE)/$(debian-root_SOURCE)" >>$@
	@echo "Description: $(debian-root_DESCRIPTION)" >>$@
	@echo "Depends: $(debian-root_DEPENDS)" >>$@
	@echo "Suggests: $(debian-root_SUGGESTS)" >>$@
	@echo "Conflicts: $(debian-root_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(debian-root_IPK_DIR)/opt/sbin or $(debian-root_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(debian-root_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(debian-root_IPK_DIR)/opt/etc/debian-root/...
# Documentation files should be installed in $(debian-root_IPK_DIR)/opt/doc/debian-root/...
# Daemon startup scripts should be installed in $(debian-root_IPK_DIR)/opt/etc/init.d/S??debian-root
#
# You may need to patch your application to make it use these locations.
#
$(debian-root_IPK): $(debian-root_BUILD_DIR)/.built
	rm -rf $(debian-root_IPK_DIR) $(BUILD_DIR)/debian-root_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(debian-root_BUILD_DIR) DESTDIR=$(debian-root_IPK_DIR) install-strip
	$(MAKE) $(debian-root_IPK_DIR)/CONTROL/control
	echo $(debian-root_CONFFILES) | sed -e 's/ /\n/g' > $(debian-root_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(debian-root_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(debian-root_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
debian-root-ipk: $(debian-root_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
debian-root-clean:
	sudo rm -rf $(debian-root_BUILD_DIR)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
debian-root-dirclean:
	rm -rf $(BUILD_DIR)/$(debian-root_DIR) $(debian-root_BUILD_DIR) $(debian-root_IPK_DIR) $(debian-root_IPK)
#
#
# Some sanity check for the package.
#
debian-root-check: $(debian-root_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
