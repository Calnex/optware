###########################################################
#
# libevent
#
###########################################################

# You must replace "libevent" and "LIBEVENT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBEVENT_VERSION, LIBEVENT_SITE and LIBEVENT_SOURCE define
# the upstream location of the source code for the package.
# LIBEVENT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBEVENT_UNZIP is the command used to unzip the source.
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
LIBEVENT_VERSION=2.0.22-stable
LIBEVENT_SITE=https://github.com/libevent/libevent/releases/download/release-$(LIBEVENT_VERSION)/
LIBEVENT_SOURCE=libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_DIR=libevent-$(LIBEVENT_VERSION)
LIBEVENT_UNZIP=zcat
LIBEVENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBEVENT_DESCRIPTION=Describe libevent here.
LIBEVENT_SECTION=libs
LIBEVENT_PRIORITY=optional
LIBEVENT_DEPENDS=
LIBEVENT_SUGGESTS=
LIBEVENT_CONFLICTS=

#
# LIBEVENT_IPK_VERSION should be incremented when the ipk changes.
#
LIBEVENT_IPK_VERSION=1

#
# LIBEVENT_CONFFILES should be a list of user-editable files
#LIBEVENT_CONFFILES=/opt/etc/libevent.conf /opt/etc/init.d/SXXlibevent

#
# LIBEVENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBEVENT_PATCHES=$(LIBEVENT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBEVENT_CPPFLAGS=
LIBEVENT_LDFLAGS=

# Options to pass to the make that is performed when building the code
LIBEVENT_MAKE_OPTIONS=-j



#
# LIBEVENT_BUILD_DIR is the directory in which the build is done.
# LIBEVENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBEVENT_IPK_DIR is the directory in which the ipk is built.
# LIBEVENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBEVENT_BUILD_DIR=$(BUILD_DIR)/libevent
LIBEVENT_SOURCE_DIR=$(SOURCE_DIR)/libevent
LIBEVENT_IPK_DIR=$(BUILD_DIR)/libevent-$(LIBEVENT_VERSION)-ipk
LIBEVENT_IPK=$(BUILD_DIR)/libevent_$(LIBEVENT_VERSION)-$(LIBEVENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libevent-source libevent-unpack libevent libevent-stage libevent-ipk libevent-clean libevent-dirclean libevent-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBEVENT_SOURCE):
	$(WGET) -P $(@D) $(LIBEVENT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libevent-source: $(DL_DIR)/$(LIBEVENT_SOURCE) $(LIBEVENT_PATCHES)

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
$(LIBEVENT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEVENT_SOURCE) $(LIBEVENT_PATCHES) make/libevent.mk
	rm -rf $(BUILD_DIR)/$(LIBEVENT_DIR) $(@D)
	$(LIBEVENT_UNZIP) $(DL_DIR)/$(LIBEVENT_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(LIBEVENT_PATCHES)" ; \
		then cat $(LIBEVENT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBEVENT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBEVENT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBEVENT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEVENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEVENT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libevent-unpack: $(LIBEVENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBEVENT_BUILD_DIR)/.built: $(LIBEVENT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) $(LIBEVENT_MAKE_OPTIONS) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libevent: $(LIBEVENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBEVENT_BUILD_DIR)/.staged: $(LIBEVENT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e "s|^libdir=.*|libdir='$(STAGING_DIR)/opt/lib'|" $(STAGING_DIR)/opt/lib/libevent.la
	touch $@

libevent-stage: $(LIBEVENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libevent
#
$(LIBEVENT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libevent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBEVENT_PRIORITY)" >>$@
	@echo "Section: $(LIBEVENT_SECTION)" >>$@
	@echo "Version: $(LIBEVENT_VERSION)-$(LIBEVENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBEVENT_MAINTAINER)" >>$@
	@echo "Source: $(LIBEVENT_SITE)/$(LIBEVENT_SOURCE)" >>$@
	@echo "Description: $(LIBEVENT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBEVENT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBEVENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBEVENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBEVENT_IPK_DIR)/opt/sbin or $(LIBEVENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBEVENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBEVENT_IPK_DIR)/opt/etc/libevent/...
# Documentation files should be installed in $(LIBEVENT_IPK_DIR)/opt/doc/libevent/...
# Daemon startup scripts should be installed in $(LIBEVENT_IPK_DIR)/opt/etc/init.d/S??libevent
#
# You may need to patch your application to make it use these locations.
#
$(LIBEVENT_IPK): $(LIBEVENT_BUILD_DIR)/.built
	rm -rf $(LIBEVENT_IPK_DIR) $(BUILD_DIR)/libevent_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBEVENT_BUILD_DIR) DESTDIR=$(LIBEVENT_IPK_DIR) install-strip
#	install -d $(LIBEVENT_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBEVENT_SOURCE_DIR)/libevent.conf $(LIBEVENT_IPK_DIR)/opt/etc/libevent.conf
#	install -d $(LIBEVENT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBEVENT_SOURCE_DIR)/rc.libevent $(LIBEVENT_IPK_DIR)/opt/etc/init.d/SXXlibevent
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBEVENT_IPK_DIR)/opt/etc/init.d/SXXlibevent
	$(MAKE) $(LIBEVENT_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBEVENT_SOURCE_DIR)/postinst $(LIBEVENT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBEVENT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBEVENT_SOURCE_DIR)/prerm $(LIBEVENT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBEVENT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBEVENT_IPK_DIR)/CONTROL/postinst $(LIBEVENT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBEVENT_CONFFILES) | sed -e 's/ /\n/g' > $(LIBEVENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEVENT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBEVENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libevent-ipk: $(LIBEVENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libevent-clean:
	rm -f $(LIBEVENT_BUILD_DIR)/.built
	$(MAKE) -C $(LIBEVENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libevent-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEVENT_DIR) $(LIBEVENT_BUILD_DIR) $(LIBEVENT_IPK_DIR) $(LIBEVENT_IPK)
#
#
# Some sanity check for the package.
#
libevent-check: $(LIBEVENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
