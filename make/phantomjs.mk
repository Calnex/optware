###########################################################
#
# phantomjs
#
###########################################################

# You must replace "phantomjs" and "PHANTOMJS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PHANTOMJS_VERSION, PHANTOMJS_SITE and PHANTOMJS_SOURCE define
# the upstream location of the source code for the package.
# PHANTOMJS_DIR is the directory which is created when the source
# archive is unpacked.
# PHANTOMJS_UNZIP is the command used to unzip the source.
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
PHANTOMJS_SITE=https://github.com/ariya/phantomjs/archive
PHANTOMJS_VERSION=2.0.0
PHANTOMJS_SOURCE=$(PHANTOMJS_VERSION).tar.gz
PHANTOMJS_DIR=phantomjs-$(PHANTOMJS_VERSION)
PHANTOMJS_UNZIP=zcat
PHANTOMJS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHANTOMJS_DESCRIPTION=Describe phantomjs here.
PHANTOMJS_SECTION=libs
PHANTOMJS_PRIORITY=optional
PHANTOMJS_DEPENDS=
PHANTOMJS_SUGGESTS=
PHANTOMJS_CONFLICTS=

#
# PHANTOMJS_IPK_VERSION should be incremented when the ipk changes.
#
PHANTOMJS_IPK_VERSION=1

#
# PHANTOMJS_CONFFILES should be a list of user-editable files
#PHANTOMJS_CONFFILES=/opt/etc/phantomjs.conf /opt/etc/init.d/SXXphantomjs

#
# PHANTOMJS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PHANTOMJS_PATCHES=$(PHANTOMJS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHANTOMJS_CPPFLAGS=
PHANTOMJS_LDFLAGS=

#
# PHANTOMJS_BUILD_DIR is the directory in which the build is done.
# PHANTOMJS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHANTOMJS_IPK_DIR is the directory in which the ipk is built.
# PHANTOMJS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHANTOMJS_BUILD_DIR=$(BUILD_DIR)/phantomjs
PHANTOMJS_SOURCE_DIR=$(SOURCE_DIR)/phantomjs
PHANTOMJS_IPK_DIR=$(BUILD_DIR)/phantomjs-$(PHANTOMJS_VERSION)-ipk
PHANTOMJS_IPK=$(BUILD_DIR)/phantomjs_$(PHANTOMJS_VERSION)-$(PHANTOMJS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: phantomjs-source phantomjs-unpack phantomjs phantomjs-stage phantomjs-ipk phantomjs-clean phantomjs-dirclean phantomjs-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PHANTOMJS_SOURCE):
	$(WGET) -P $(@D) $(PHANTOMJS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
phantomjs-source: $(DL_DIR)/$(PHANTOMJS_SOURCE) $(PHANTOMJS_PATCHES)

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
$(PHANTOMJS_BUILD_DIR)/.configured: $(DL_DIR)/$(PHANTOMJS_SOURCE) $(PHANTOMJS_PATCHES) make/phantomjs.mk
	rm -rf $(BUILD_DIR)/$(PHANTOMJS_DIR) $(@D)
	$(PHANTOMJS_UNZIP) $(DL_DIR)/$(PHANTOMJS_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(PHANTOMJS_PATCHES)" ; \
		then cat $(PHANTOMJS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PHANTOMJS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PHANTOMJS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PHANTOMJS_DIR) $(@D) ; \
	fi
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

phantomjs-unpack: $(PHANTOMJS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PHANTOMJS_BUILD_DIR)/.built: $(PHANTOMJS_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		./build.sh --confirm --silent --qtdeps=bundled \
        )
	touch $@

#
# This is the build convenience target.
#
phantomjs: $(PHANTOMJS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PHANTOMJS_BUILD_DIR)/.staged: $(PHANTOMJS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

phantomjs-stage: $(PHANTOMJS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/phantomjs
#
$(PHANTOMJS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: phantomjs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHANTOMJS_PRIORITY)" >>$@
	@echo "Section: $(PHANTOMJS_SECTION)" >>$@
	@echo "Version: $(PHANTOMJS_VERSION)-$(PHANTOMJS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHANTOMJS_MAINTAINER)" >>$@
	@echo "Source: $(PHANTOMJS_SITE)/$(PHANTOMJS_SOURCE)" >>$@
	@echo "Description: $(PHANTOMJS_DESCRIPTION)" >>$@
	@echo "Depends: $(PHANTOMJS_DEPENDS)" >>$@
	@echo "Suggests: $(PHANTOMJS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PHANTOMJS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHANTOMJS_IPK_DIR)/opt/sbin or $(PHANTOMJS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHANTOMJS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PHANTOMJS_IPK_DIR)/opt/etc/phantomjs/...
# Documentation files should be installed in $(PHANTOMJS_IPK_DIR)/opt/doc/phantomjs/...
# Daemon startup scripts should be installed in $(PHANTOMJS_IPK_DIR)/opt/etc/init.d/S??phantomjs
#
# You may need to patch your application to make it use these locations.
#
$(PHANTOMJS_IPK): $(PHANTOMJS_BUILD_DIR)/.built
	rm -rf $(PHANTOMJS_IPK_DIR) $(BUILD_DIR)/phantomjs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PHANTOMJS_BUILD_DIR) DESTDIR=$(PHANTOMJS_IPK_DIR)/opt/bin/ TARGET=$(PHANTOMJS_IPK_DIR)/opt/bin/phantomjs install
	install -d $(PHANTOMJS_IPK_DIR)/opt/bin/
	install -m 644 $(PHANTOMJS_BUILD_DIR)/bin/phantomjs $(PHANTOMJS_IPK_DIR)/opt/bin/phantomjs
	$(MAKE) $(PHANTOMJS_IPK_DIR)/CONTROL/control
	echo $(PHANTOMJS_CONFFILES) | sed -e 's/ /\n/g' > $(PHANTOMJS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHANTOMJS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHANTOMJS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
phantomjs-ipk: $(PHANTOMJS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
phantomjs-clean:
	rm -f $(PHANTOMJS_BUILD_DIR)/.built
	$(MAKE) -C $(PHANTOMJS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
phantomjs-dirclean:
	rm -rf $(BUILD_DIR)/$(PHANTOMJS_DIR) $(PHANTOMJS_BUILD_DIR) $(PHANTOMJS_IPK_DIR) $(PHANTOMJS_IPK)
#
#
# Some sanity check for the package.
#
phantomjs-check: $(PHANTOMJS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
