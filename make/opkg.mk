###########################################################
#
# opkg
#
###########################################################

#
# OPKG_REPOSITORY defines the upstream location of the source code
# for the package.  OPKG_DIR is the directory which is created when
# this cvs module is checked out.
#
OPKG_REPOSITORY=https://git.yoctoproject.org/opkg/
OPKG_DIR=opkg
OPKG_MAINTAINER=Calnex <debian@calnexsol.com>
OPKG_DESCRIPTION=The Open-Embedded Package Manager
OPKG_SECTION=base
OPKG_PRIORITY=optional
OPKG_DEPENDS=
OPKG_SUGGESTS=
OPKG_CONFLICTS=

OPKG_VERSION=0.9.0
OPKG_CALNEX_SITE=$(PACKAGES_SERVER)/build_dependencies/1.0/opkg-$(OPKG_VERSION).tar.gz
OPKG_SITE=https://git.yoctoproject.org/opkg/snapshot/
OPKG_SOURCE=opkg-$(OPKG_VERSION).tar.gz
OPKG_UNZIP=zcat

#
# OPKG_IPK_VERSION should be incremented when the ipk changes.
#
OPKG_IPK_VERSION=0

#
# OPKG_CONFFILES should be a list of user-editable files
OPKG_CONFFILES=/opt/etc/opkg.conf

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPKG_CPPFLAGS=
OPKG_LDFLAGS=

#
# OPKG_BUILD_DIR is the directory in which the build is done.
# OPKG_SOURCE_DIR is the directory which holds all the
# patches and ipkg-opt control files.
# OPKG_IPK_DIR is the directory in which the ipk is built.
# OPKG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPKG_BUILD_DIR=$(BUILD_DIR)/opkg
OPKG_SOURCE_DIR=$(SOURCE_DIR)/opkg
OPKG_IPK_DIR=$(BUILD_DIR)/opkg-$(OPKG_VERSION)-ipk
OPKG_IPK=$(BUILD_DIR)/opkg_$(OPKG_VERSION)-$(OPKG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: opkg-source opkg-unpack opkg opkg-stage opkg-ipk opkg-clean opkg-dirclean opkg-check

#
# OPKG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
OPKG_PATCHES=

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPKG_SOURCE):
	$(WGET) -P $(@D) $(OPKG_CALNEX_SITE) -O $@ || \
	$(WGET) -P $(@D) $(OPKG_SITE) -O $@


opkg-source: $(DL_DIR)/$(OPKG_SOURCE)

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) ipkg-opt-stage <baz>-stage").
#
$(OPKG_BUILD_DIR)/.configured: $(DL_DIR)/$(OPKG_SOURCE)
	rm -rf $(BUILD_DIR)/$(OPKG_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(OPKG_SOURCE)
	if test -d "$(BUILD_DIR)/opkg-$(OPKG_VERSION)" ; \
		then mv $(BUILD_DIR)/opkg-$(OPKG_VERSION) $(BUILD_DIR)/$(OPKG_DIR) ; \
	fi
	if test -n "$(OPKG_PATCHES)" ; \
		then cat $(OPKG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPKG_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(OPKG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(OPKG_DIR) $(@D) ; \
	fi
	rm -f $(@D)/etc/Makefile aclocal.m4
#	autoreconf -vif $(@D)
	(cd $(@D); \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPKG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPKG_LDFLAGS)" \
		cmake \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_INSTALL_PREFIX=/opt \
			-DWITH_CURL=OFF \
			-DWITH_GPGME=OFF \
			-DUSE_SOLVER_LIBSOLV=OFF \
			-DUSE_ACL=OFF \
			-DUSE_XATTR=OFF \
			-DCMAKE_C_FLAGS="$(STAGING_CFLAGS) $(OPKG_CPPFLAGS)" \
			-DCMAKE_EXE_LINKER_FLAGS="$(STAGING_LDFLAGS) $(OPKG_LDFLAGS)" \
			-DCMAKE_SHARED_LINKER_FLAGS="$(STAGING_LDFLAGS) $(OPKG_LDFLAGS)" \
			-DCMAKE_MODULE_LINKER_FLAGS="$(STAGING_LDFLAGS) $(OPKG_LDFLAGS)" \
			. ; \
	)
	touch $@


opkg-unpack: $(OPKG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPKG_BUILD_DIR)/.built: $(OPKG_BUILD_DIR)/.configured
	rm -f $@
	\
	$(MAKE) -j -C $(@D)
	touch $@

#
# This is the build convenience target.
#
opkg: $(OPKG_BUILD_DIR)/.built

#
# This rule creates a control file for opkg.  It is no longer
# necessary to create a seperate control file under sources/opkg
#
$(OPKG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: opkg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPKG_PRIORITY)" >>$@
	@echo "Section: $(OPKG_SECTION)" >>$@
	@echo "Version: $(OPKG_VERSION)-$(OPKG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPKG_MAINTAINER)" >>$@
	@echo "Source: $(OPKG_REPOSITORY)" >>$@
	@echo "Description: $(OPKG_DESCRIPTION)" >>$@
	@echo "Depends: $(OPKG_DEPENDS)" >>$@
	@echo "Suggests: $(OPKG_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPKG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPKG_IPK_DIR)/opt/sbin or $(OPKG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPKG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPKG_IPK_DIR)/opt/etc/ipkg/...
# Documentation files should be installed in $(OPKG_IPK_DIR)/opt/doc/ipkg-opt/...
# Daemon startup scripts should be installed in $(OPKG_IPK_DIR)/opt/etc/init.d/S??ipkg
#
# You may need to patch your application to make it use these locations.
#

$(OPKG_IPK): $(OPKG_BUILD_DIR)/.built
	rm -rf $(OPKG_IPK_DIR) $(BUILD_DIR)/opkg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OPKG_BUILD_DIR) DESTDIR=$(OPKG_IPK_DIR) install
	install -d $(OPKG_IPK_DIR)/opt/etc/
	install -m 644 $(OPKG_SOURCE_DIR)/opkg.conf \
		$(OPKG_IPK_DIR)/opt/etc/opkg.conf
	rm -f $(OPKG_IPK_DIR)/opt/lib/*.a
	rm -f $(OPKG_IPK_DIR)/opt/lib/*.la
	rm -rf $(OPKG_IPK_DIR)/opt/include
#	ln -s ipkg $(OPKG_IPK_DIR)/opt/bin/opkg
	$(MAKE) $(OPKG_IPK_DIR)/CONTROL/control
	echo $(OPKG_CONFFILES) | sed -e 's/ /\n/g' > $(OPKG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPKG_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPKG_IPK_DIR)

$(OPKG_BUILD_DIR)/.ipk: $(OPKG_IPK)
	rm -f $@
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
opkg-ipk: $(OPKG_BUILD_DIR)/.ipk

#
# This is called from the top level makefile to clean all of the built files.
#
opkg-clean:
	rm -f $(OPKG_BUILD_DIR)/.built
	$(MAKE) -C $(OPKG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
opkg-dirclean:
	rm -rf $(BUILD_DIR)/$(OPKG_DIR) $(OPKG_BUILD_DIR) $(OPKG_IPK_DIR) $(OPKG_IPK)

#
#
# Some sanity check for the package.
#
opkg-check: $(OPKG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPKG_IPK)
