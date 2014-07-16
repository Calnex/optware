###########################################################
#
# xsp
#
###########################################################

# You must replace "xsp" and "XSP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# XSP_VERSION, XSP_SITE and XSP_SOURCE define
# the upstream location of the source code for the package.
# XSP_DIR is the directory which is created when the source
# archive is unpacked.
# XSP_UNZIP is the command used to unzip the source.
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
XSP_REPOSITORY=https://github.com/mono/xsp.git
XSP_VERSION=3.2.1
XSP_SOURCE=xsp-$(XSP_VERSION).tar.gz
XSP_DIR=xsp-$(XSP_VERSION)
XSP_UNZIP=zcat
XSP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XSP_DESCRIPTION=Describe xsp here.
XSP_SECTION=net
XSP_PRIORITY=optional
XSP_DEPENDS=
XSP_SUGGESTS=
XSP_CONFLICTS=

#
# XSP_IPK_VERSION should be incremented when the ipk changes.
#
XSP_IPK_VERSION=1

#
# XSP_CONFFILES should be a list of user-editable files
#XSP_CONFFILES=/opt/etc/xsp.conf /opt/etc/init.d/SXXxsp

#
# XSP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XSP_PATCHES=$(XSP_SOURCE_DIR)/configure.patch
XSP_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XSP_CPPFLAGS=
XSP_LDFLAGS=

#
# XSP_BUILD_DIR is the directory in which the build is done.
# XSP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XSP_IPK_DIR is the directory in which the ipk is built.
# XSP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XSP_GIT_TAG=HEAD
XSP_TREEISH=$(XSP_GIT_TAG)
XSP_BUILD_DIR=$(BUILD_DIR)/xsp
XSP_SOURCE_DIR=$(SOURCE_DIR)/xsp
XSP_IPK_DIR=$(BUILD_DIR)/xsp-$(XSP_VERSION)-ipk
XSP_IPK=$(BUILD_DIR)/xsp_$(XSP_VERSION)-$(XSP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xsp-source xsp-unpack xsp xsp-stage xsp-ipk xsp-clean xsp-dirclean xsp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XSP_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf xsp && \
		git clone --bare $(XSP_REPOSITORY) xsp && \
		cd xsp && \
		(git archive --format=tar --prefix=$(XSP_DIR)/ $(XSP_TREEISH) | gzip > $@) && \
		rm -rf xsp ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xsp-source: $(DL_DIR)/$(XSP_SOURCE) $(XSP_PATCHES)

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
$(XSP_BUILD_DIR)/.configured: $(DL_DIR)/$(XSP_SOURCE) $(XSP_PATCHES) make/xsp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(XSP_DIR) $(@D)
	$(XSP_UNZIP) $(DL_DIR)/$(XSP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XSP_PATCHES)" ; \
		then cat $(XSP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XSP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XSP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XSP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XSP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XSP_LDFLAGS)" \
		./autogen.sh \
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

xsp-unpack: $(XSP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XSP_BUILD_DIR)/.built: $(XSP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xsp: $(XSP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XSP_BUILD_DIR)/.staged: $(XSP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

xsp-stage: $(XSP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xsp
#
$(XSP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: xsp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XSP_PRIORITY)" >>$@
	@echo "Section: $(XSP_SECTION)" >>$@
	@echo "Version: $(XSP_VERSION)-$(XSP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XSP_MAINTAINER)" >>$@
	@echo "Source: $(XSP_SITE)/$(XSP_SOURCE)" >>$@
	@echo "Description: $(XSP_DESCRIPTION)" >>$@
	@echo "Depends: $(XSP_DEPENDS)" >>$@
	@echo "Suggests: $(XSP_SUGGESTS)" >>$@
	@echo "Conflicts: $(XSP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XSP_IPK_DIR)/opt/sbin or $(XSP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XSP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XSP_IPK_DIR)/opt/etc/xsp/...
# Documentation files should be installed in $(XSP_IPK_DIR)/opt/doc/xsp/...
# Daemon startup scripts should be installed in $(XSP_IPK_DIR)/opt/etc/init.d/S??xsp
#
# You may need to patch your application to make it use these locations.
#
$(XSP_IPK): $(XSP_BUILD_DIR)/.built
	rm -rf $(XSP_IPK_DIR) $(BUILD_DIR)/xsp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XSP_BUILD_DIR) DESTDIR=$(XSP_IPK_DIR) install-strip
	$(MAKE) $(XSP_IPK_DIR)/CONTROL/control
	echo $(XSP_CONFFILES) | sed -e 's/ /\n/g' > $(XSP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XSP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(XSP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xsp-ipk: $(XSP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xsp-clean:
	rm -f $(XSP_BUILD_DIR)/.built
	-$(MAKE) -C $(XSP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xsp-dirclean:
	rm -rf $(BUILD_DIR)/$(XSP_DIR) $(XSP_BUILD_DIR) $(XSP_IPK_DIR) $(XSP_IPK)
#
#
# Some sanity check for the package.
#
xsp-check: $(XSP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
