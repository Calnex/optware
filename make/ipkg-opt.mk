###########################################################
#
# ipkg-opt
#
###########################################################

#
# IPKG-OPT_REPOSITORY defines the upstream location of the source code
# for the package.  IPKG-OPT_DIR is the directory which is created when
# this cvs module is checked out.
#
IPKG-OPT_REPOSITORY=https://github.com/Calnex/ipkg-opt
IPKG-OPT_DIR=ipkg-opt
IPKG-OPT_MAINTAINER=Calnex <debian@calnexsol.com>
IPKG-OPT_DESCRIPTION=The Itsy Package Manager
IPKG-OPT_SECTION=base
IPKG-OPT_PRIORITY=optional
IPKG-OPT_DEPENDS=
IPKG-OPT_SUGGESTS=
IPKG-OPT_CONFLICTS=

IPKG-OPT_VERSION=0.99.163
IPKG-OPT_CALNEX_SITE=$(PACKAGES_SERVER)/build_dependencies/1.0/ipkg-opt-$(IPKG-OPT_VERSION).tar.gz
IPKG-OPT_SITE=https://github.com/Calnex/ipkg-opt/archive/refs/tags/v$(IPKG-OPT_VERSION).tar.gz
IPKG-OPT_SOURCE=ipkg-opt-$(IPKG-OPT_VERSION).tar.gz
IPKG-OPT_UNZIP=zcat

#
# IPKG-OPT_IPK_VERSION should be incremented when the ipk changes.
#
IPKG-OPT_IPK_VERSION=11

#
# IPKG-OPT_CONFFILES should be a list of user-editable files
IPKG-OPT_CONFFILES=/opt/etc/ipkg.conf

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPKG-OPT_CPPFLAGS=
IPKG-OPT_LDFLAGS=

#
# IPKG-OPT_BUILD_DIR is the directory in which the build is done.
# IPKG-OPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg-opt control files.
# IPKG-OPT_IPK_DIR is the directory in which the ipk is built.
# IPKG-OPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPKG-OPT_BUILD_DIR=$(BUILD_DIR)/ipkg-opt
IPKG-OPT_SOURCE_DIR=$(SOURCE_DIR)/ipkg-opt
IPKG-OPT_IPK_DIR=$(BUILD_DIR)/ipkg-opt-$(IPKG-OPT_VERSION)-ipk
IPKG-OPT_IPK=$(BUILD_DIR)/ipkg-opt_$(IPKG-OPT_VERSION)-$(IPKG-OPT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ipkg-opt-source ipkg-opt-unpack ipkg-opt ipkg-opt-stage ipkg-opt-ipk ipkg-opt-clean ipkg-opt-dirclean ipkg-opt-check

#
# IPKG-OPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPKG-OPT_PATCHES=$(IPKG-OPT_SOURCE_DIR)/args.h.patch \
	$(IPKG-OPT_SOURCE_DIR)/ipkg_conf.h.patch \
	$(IPKG-OPT_SOURCE_DIR)/ipkg_conf.c.patch \
	$(IPKG-OPT_SOURCE_DIR)/update-alternatives.patch \
	$(IPKG-OPT_SOURCE_DIR)/ipkg-va_start_segfault.diff \
	$(IPKG-OPT_SOURCE_DIR)/list_installed.patch \
	$(IPKG-OPT_SOURCE_DIR)/ipkg_install.c.patch
# atp $(IPKG-OPT_SOURCE_DIR)/pkg_run_script_segfault.patch

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPKG-OPT_SOURCE):
	$(WGET) -P $(@D) $(IPKG-OPT_CALNEX_SITE) -O $@ || \
	$(WGET) -P $(@D) $(IPKG-OPT_SITE) -O $@


ipkg-opt-source: $(DL_DIR)/$(IPKG-OPT_SOURCE)

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
$(IPKG-OPT_BUILD_DIR)/.configured: $(DL_DIR)/$(IPKG-OPT_SOURCE)
	rm -rf $(BUILD_DIR)/$(IPKG-OPT_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(IPKG-OPT_SOURCE)
	mv $(BUILD_DIR)/ipkg-opt-0.99.163 $(BUILD_DIR)/$(IPKG-OPT_DIR) # Rename extracted directory
	if test -n "$(IPKG-OPT_PATCHES)" ; \
		then cat $(IPKG-OPT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IPKG-OPT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IPKG-OPT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(IPKG-OPT_DIR) $(@D) ; \
	fi
	rm -f $(@D)/etc/Makefile aclocal.m4
	autoreconf -vif $(@D)
	(cd $(@D); \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPKG-OPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPKG-OPT_LDFLAGS)" \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ipkglibdir=/opt/lib \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@


ipkg-opt-unpack: $(IPKG-OPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPKG-OPT_BUILD_DIR)/.built: $(IPKG-OPT_BUILD_DIR)/.configured
	rm -f $@
	\
	$(MAKE) -j -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ipkg-opt: $(IPKG-OPT_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg-opt.  It is no longer
# necessary to create a seperate control file under sources/ipkg-opt
#
$(IPKG-OPT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ipkg-opt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPKG-OPT_PRIORITY)" >>$@
	@echo "Section: $(IPKG-OPT_SECTION)" >>$@
	@echo "Version: $(IPKG-OPT_VERSION)-$(IPKG-OPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPKG-OPT_MAINTAINER)" >>$@
	@echo "Source: $(IPKG-OPT_REPOSITORY)" >>$@
	@echo "Description: $(IPKG-OPT_DESCRIPTION)" >>$@
	@echo "Depends: $(IPKG-OPT_DEPENDS)" >>$@
	@echo "Suggests: $(IPKG-OPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPKG-OPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPKG-OPT_IPK_DIR)/opt/sbin or $(IPKG-OPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPKG-OPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPKG-OPT_IPK_DIR)/opt/etc/ipkg/...
# Documentation files should be installed in $(IPKG-OPT_IPK_DIR)/opt/doc/ipkg-opt/...
# Daemon startup scripts should be installed in $(IPKG-OPT_IPK_DIR)/opt/etc/init.d/S??ipkg
#
# You may need to patch your application to make it use these locations.
#

$(IPKG-OPT_IPK): $(IPKG-OPT_BUILD_DIR)/.built
	rm -rf $(IPKG-OPT_IPK_DIR) $(BUILD_DIR)/ipkg-opt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IPKG-OPT_BUILD_DIR) DESTDIR=$(IPKG-OPT_IPK_DIR) install-strip
	install -d $(IPKG-OPT_IPK_DIR)/opt/etc/
	install -m 644 $(IPKG-OPT_SOURCE_DIR)/ipkg.conf \
		$(IPKG-OPT_IPK_DIR)/opt/etc/ipkg.conf
	rm $(IPKG-OPT_IPK_DIR)/opt/lib/*.a
	rm $(IPKG-OPT_IPK_DIR)/opt/lib/*.la
	rm -rf $(IPKG-OPT_IPK_DIR)/opt/include
	mv $(IPKG-OPT_IPK_DIR)/opt/bin/ipkg-cl $(IPKG-OPT_IPK_DIR)/opt/bin/ipkg
	ln -s ipkg $(IPKG-OPT_IPK_DIR)/opt/bin/ipkg-opt
	$(MAKE) $(IPKG-OPT_IPK_DIR)/CONTROL/control
	echo $(IPKG-OPT_CONFFILES) | sed -e 's/ /\n/g' > $(IPKG-OPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPKG-OPT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(IPKG-OPT_IPK_DIR)

$(IPKG-OPT_BUILD_DIR)/.ipk: $(IPKG-OPT_IPK)
	rm -f $@
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
ipkg-opt-ipk: $(IPKG-OPT_BUILD_DIR)/.ipk

#
# This is called from the top level makefile to clean all of the built files.
#
ipkg-opt-clean:
	rm -f $(IPKG-OPT_BUILD_DIR)/.built
	$(MAKE) -C $(IPKG-OPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipkg-opt-dirclean:
	rm -rf $(BUILD_DIR)/$(IPKG-OPT_DIR) $(IPKG-OPT_BUILD_DIR) $(IPKG-OPT_IPK_DIR) $(IPKG-OPT_IPK)

#
#
# Some sanity check for the package.
#
ipkg-opt-check: $(IPKG-OPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPKG-OPT_IPK)
