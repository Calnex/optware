###########################################################
#
# hyperfastcgi
#
###########################################################

# You must replace "hyperfastcgi" and "HYPERFASTCGI" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# HYPERFASTCGI_VERSION, HYPERFASTCGI_SITE and HYPERFASTCGI_SOURCE define
# the upstream location of the source code for the package.
# HYPERFASTCGI_DIR is the directory which is created when the source
# archive is unpacked.
# HYPERFASTCGI_UNZIP is the command used to unzip the source.
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
HYPERFASTCGI_REPOSITORY=https://github.com/xplicit/HyperFastCgi.git
HYPERFASTCGI_VERSION=0.3
HYPERFASTCGI_SOURCE=hyperfastcgi-$(HYPERFASTCGI_VERSION).tar.gz
HYPERFASTCGI_DIR=hyperfastcgi-$(HYPERFASTCGI_VERSION)
HYPERFASTCGI_UNZIP=zcat
HYPERFASTCGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HYPERFASTCGI_DESCRIPTION=HyperFastCgi hosts mono web applications with nginx. It's a primary replacement of mono-server-fastcgi for linux platform.
HYPERFASTCGI_SECTION=net
HYPERFASTCGI_PRIORITY=optional
HYPERFASTCGI_DEPENDS=libevent, libstdc++, mono
HYPERFASTCGI_SUGGESTS=
HYPERFASTCGI_CONFLICTS=

#
# HYPERFASTCGI_IPK_VERSION should be incremented when the ipk changes.
#
HYPERFASTCGI_IPK_VERSION=1

#
# HYPERFASTCGI_CONFFILES should be a list of user-editable files
#HYPERFASTCGI_CONFFILES=/opt/etc/hyperfastcgi.conf /opt/etc/init.d/SXXhyperfastcgi

#
# HYPERFASTCGI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HYPERFASTCGI_PATCHES=$(HYPERFASTCGI_SOURCE_DIR)/Makefile.am.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HYPERFASTCGI_CPPFLAGS=
HYPERFASTCGI_LDFLAGS=

#
# HYPERFASTCGI_BUILD_DIR is the directory in which the build is done.
# HYPERFASTCGI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HYPERFASTCGI_IPK_DIR is the directory in which the ipk is built.
# HYPERFASTCGI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HYPERFASTCGI_GIT_TAG=HEAD
HYPERFASTCGI_TREEISH=$(HYPERFASTCGI_GIT_TAG)
HYPERFASTCGI_BUILD_DIR=$(BUILD_DIR)/hyperfastcgi
HYPERFASTCGI_SOURCE_DIR=$(SOURCE_DIR)/hyperfastcgi
HYPERFASTCGI_IPK_DIR=$(BUILD_DIR)/hyperfastcgi-$(HYPERFASTCGI_VERSION)-ipk
HYPERFASTCGI_IPK=$(BUILD_DIR)/hyperfastcgi_$(HYPERFASTCGI_VERSION)-$(HYPERFASTCGI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hyperfastcgi-source hyperfastcgi-unpack hyperfastcgi hyperfastcgi-stage hyperfastcgi-ipk hyperfastcgi-clean hyperfastcgi-dirclean hyperfastcgi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HYPERFASTCGI_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf hyperfastcgi && \
		git clone --bare $(HYPERFASTCGI_REPOSITORY) hyperfastcgi && \
		cd hyperfastcgi && \
		(git archive --format=tar --prefix=$(HYPERFASTCGI_DIR)/ $(HYPERFASTCGI_TREEISH) | gzip > $@) && \
		rm -rf hyperfastcgi ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hyperfastcgi-source: $(DL_DIR)/$(HYPERFASTCGI_SOURCE) $(HYPERFASTCGI_PATCHES)

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
$(HYPERFASTCGI_BUILD_DIR)/.configured: $(DL_DIR)/$(HYPERFASTCGI_SOURCE) $(HYPERFASTCGI_PATCHES) make/hyperfastcgi.mk
	$(MAKE) libtool-stage libevent-stage libstdc++-stage mono-stage
	rm -rf $(BUILD_DIR)/$(HYPERFASTCGI_DIR) $(@D)
	$(HYPERFASTCGI_UNZIP) $(DL_DIR)/$(HYPERFASTCGI_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(HYPERFASTCGI_PATCHES)" ; \
		then cat $(HYPERFASTCGI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HYPERFASTCGI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HYPERFASTCGI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HYPERFASTCGI_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		DMCS="$(STAGING_DIR)/opt/bin/dmcs" \
		MONO="$(STAGING_DIR)/opt/bin/mono" \
		MDOC="$(STAGING_DIR)/opt/bin/mdoc" \
		GACUTIL="$(STAGING_DIR)/opt/bin/gacutil" \
		SN="$(STAGING_DIR)/opt/bin/sn" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HYPERFASTCGI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HYPERFASTCGI_LDFLAGS)" \
		PATH="/opt/bin:/opt/sbin:$(PATH)" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--program-prefix="" \
		--prefix=/opt \
		--with-sysroot=/opt \
		--with-runtime=/opt/bin/mono \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

hyperfastcgi-unpack: $(HYPERFASTCGI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HYPERFASTCGI_BUILD_DIR)/.built: $(HYPERFASTCGI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
hyperfastcgi: $(HYPERFASTCGI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HYPERFASTCGI_BUILD_DIR)/.staged: $(HYPERFASTCGI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e "s|/opt|${STAGING_DIR}/opt|g" $(STAGING_DIR)/opt/bin/hyperfastcgi*
	touch $@

hyperfastcgi-stage: $(HYPERFASTCGI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hyperfastcgi
#
$(HYPERFASTCGI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: hyperfastcgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HYPERFASTCGI_PRIORITY)" >>$@
	@echo "Section: $(HYPERFASTCGI_SECTION)" >>$@
	@echo "Version: $(HYPERFASTCGI_VERSION)-$(HYPERFASTCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HYPERFASTCGI_MAINTAINER)" >>$@
	@echo "Source: $(HYPERFASTCGI_SITE)/$(HYPERFASTCGI_SOURCE)" >>$@
	@echo "Description: $(HYPERFASTCGI_DESCRIPTION)" >>$@
	@echo "Depends: $(HYPERFASTCGI_DEPENDS)" >>$@
	@echo "Suggests: $(HYPERFASTCGI_SUGGESTS)" >>$@
	@echo "Conflicts: $(HYPERFASTCGI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HYPERFASTCGI_IPK_DIR)/opt/sbin or $(HYPERFASTCGI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HYPERFASTCGI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HYPERFASTCGI_IPK_DIR)/opt/etc/hyperfastcgi/...
# Documentation files should be installed in $(HYPERFASTCGI_IPK_DIR)/opt/doc/hyperfastcgi/...
# Daemon startup scripts should be installed in $(HYPERFASTCGI_IPK_DIR)/opt/etc/init.d/S??hyperfastcgi
#
# You may need to patch your application to make it use these locations.
#
$(HYPERFASTCGI_IPK): $(HYPERFASTCGI_BUILD_DIR)/.built
	rm -rf $(HYPERFASTCGI_IPK_DIR) $(BUILD_DIR)/hyperfastcgi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HYPERFASTCGI_BUILD_DIR) DESTDIR=$(HYPERFASTCGI_IPK_DIR) install-strip
	rm -rf $(HYPERFASTCGI_IPK_DIR)/usr
	sed -i -e 's|exec \S* |exec /opt/bin/mono |g' $(HYPERFASTCGI_IPK_DIR)/opt/bin/hyperfastcgi4
	$(MAKE) $(HYPERFASTCGI_IPK_DIR)/CONTROL/control
	echo $(HYPERFASTCGI_CONFFILES) | sed -e 's/ /\n/g' > $(HYPERFASTCGI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HYPERFASTCGI_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(HYPERFASTCGI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hyperfastcgi-ipk: $(HYPERFASTCGI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hyperfastcgi-clean:
	rm -f $(HYPERFASTCGI_BUILD_DIR)/.built
	$(MAKE) -C $(HYPERFASTCGI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hyperfastcgi-dirclean:
	rm -rf $(BUILD_DIR)/$(HYPERFASTCGI_DIR) $(HYPERFASTCGI_BUILD_DIR) $(HYPERFASTCGI_IPK_DIR) $(HYPERFASTCGI_IPK)
#
#
# Some sanity check for the package.
#
hyperfastcgi-check: $(HYPERFASTCGI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
