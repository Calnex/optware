###########################################################
#
# tshark-$(TSHARK_1.4.9_VERSION)
#
###########################################################

# You must replace "tshark-$(TSHARK_1.4.9_VERSION)" and "TSHARK_1.4.9" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TSHARK_1.4.9_VERSION, TSHARK_1.4.9_SITE and TSHARK_1.4.9_SOURCE define
# the upstream location of the source code for the package.
# TSHARK_1.4.9_DIR is the directory which is created when the source
# archive is unpacked.
# TSHARK_1.4.9_UNZIP is the command used to unzip the source.
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
TSHARK_1.4.9_SITE=http://www.wireshark.org/download/src/all-versions
TSHARK_1.4.9_VERSION = 1.4.9
TSHARK_1.4.9_SOURCE=wireshark-$(TSHARK_1.4.9_VERSION).tar.bz2
TSHARK_1.4.9_DIR=wireshark-$(TSHARK_1.4.9_VERSION)
TSHARK_1.4.9_UNZIP=bzcat
TSHARK_1.4.9_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TSHARK_1.4.9_DESCRIPTION=Terminal based wireshark to dump and analyze network traffic
TSHARK_1.4.9_SECTION=net
TSHARK_1.4.9_PRIORITY=optional
TSHARK_1.4.9_DEPENDS=c-ares, glib, libpcap, pcre, zlib, geoip
TSHARK_1.4.9_SUGGESTS=
TSHARK_1.4.9_CONFLICTS=

#
# TSHARK_1.4.9_IPK_VERSION should be incremented when the ipk changes.
#
TSHARK_1.4.9_IPK_VERSION ?= 1

#
# TSHARK_1.4.9_CONFFILES should be a list of user-editable files
#TSHARK_1.4.9_CONFFILES=/opt/etc/tshark-$(TSHARK_1.4.9_VERSION).conf /opt/etc/init.d/SXXtshark-$(TSHARK_1.4.9_VERSION)

#
# TSHARK_1.4.9_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#TSHARK_1.4.9_PATCHES=$(TSHARK_1.4.9_SOURCE_DIR)/doc/Makefile.am.patch
TSHARK_1.4.9_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TSHARK_1.4.9_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include
TSHARK_1.4.9_LDFLAGS=-lglib-2.0 -lgmodule-2.0 -L/$(TSHARK_1.4.9_BUILD_DIR)/wiretap/.libs

#
# TSHARK_1.4.9_BUILD_DIR is the directory in which the build is done.
# TSHARK_1.4.9_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TSHARK_1.4.9_IPK_DIR is the directory in which the ipk is built.
# TSHARK_1.4.9_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TSHARK_1.4.9_BUILD_DIR=$(BUILD_DIR)/tshark-$(TSHARK_1.4.9_VERSION)
TSHARK_1.4.9_SOURCE_DIR=$(SOURCE_DIR)/tshark-$(TSHARK_1.4.9_VERSION)
TSHARK_1.4.9_IPK_DIR=$(BUILD_DIR)/tshark-$(TSHARK_1.4.9_VERSION)-ipk
TSHARK_1.4.9_IPK=$(BUILD_DIR)/tshark_$(TSHARK_1.4.9_VERSION)-$(TSHARK_1.4.9_IPK_VERSION)_$(TARGET_ARCH).ipk
TSHARK_1.4.9_LIB_DIR=/opt/lib/wireshark/$(TSHARK_1.4.9_VERSION)

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TSHARK_1.4.9_SOURCE):
	$(WGET) -P $(@D) $(TSHARK_1.4.9_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tshark-$(TSHARK_1.4.9_VERSION)-source: $(DL_DIR)/$(TSHARK_1.4.9_SOURCE) $(TSHARK_1.4.9_PATCHES)

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
$(TSHARK_1.4.9_BUILD_DIR)/.configured: $(DL_DIR)/$(TSHARK_1.4.9_SOURCE) $(TSHARK_1.4.9_PATCHES) make/tshark-$(TSHARK_1.4.9_VERSION).mk
	$(MAKE) c-ares-stage geoip-stage glib-stage libpcap-stage pcre-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(TSHARK_1.4.9_DIR) $(@D)
	$(TSHARK_1.4.9_UNZIP) $(DL_DIR)/$(TSHARK_1.4.9_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TSHARK_1.4.9_PATCHES)" ; \
		then cat $(TSHARK_1.4.9_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(TSHARK_1.4.9_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TSHARK_1.4.9_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TSHARK_1.4.9_DIR) $(@D) ; \
	fi
	sed -i 's/^have_inet_pton=no], \[AC_MSG_RESULT(cross compiling, assume it is broken);$$/have_inet_pton=no], \[AC_MSG_RESULT(cross compiling, assume it is ok);/' $(@D)/configure.in
	sed -i 's/^have_inet_pton=no])],$$/have_inet_pton=yes])],/' $(@D)/configure.in
	sed -i -e '/^INCLUDES/s|-I$$(includedir)|-I$(STAGING_INCLUDE_DIR)|' $(@D)/plugins/*/Makefile.am
	#Disable documentation as it fails the build :(
	sed -i -e '/doc\/Makefile/d' $(@D)/configure.in 
	sed -i -e 's/ doc\b//g' $(@D)/Makefile.am 
	sed -i -e 's/ doc\b//g' $(@D)/Makefile.in 
#	rm -rf $(@D)/doc
	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TSHARK_1.4.9_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TSHARK_1.4.9_LDFLAGS)" \
		LIBRARY_PATH="$(STAGING_LIB_DIR):$(TARGET_LIB_DIR)" \
		LD_LIBRARY_PATH="$(STAGING_LIB_DIR):$(TARGET_LIB_DIR)" \
		PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" \
		ac_wireshark_inttypes_h_defines_formats=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--libdir=$(TSHARK_1.4.9_LIB_DIR) \
		--program-suffix=-$(TSHARK_1.4.9_VERSION) \
		--disable-wireshark \
		--enable-extra-gcc-checks \
		--with-gtk2=no \
		--with-gtk3=no \
		--with-gnutls=no \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

tshark-$(TSHARK_1.4.9_VERSION)-unpack: $(TSHARK_1.4.9_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TSHARK_1.4.9_BUILD_DIR)/.built: $(TSHARK_1.4.9_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) CC_FOR_BUILD=$(HOSTCC) CC=$(HOSTCC) -C $(@D)/tools/lemon lemon
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
tshark-$(TSHARK_1.4.9_VERSION): $(TSHARK_1.4.9_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TSHARK_1.4.9_BUILD_DIR)/.staged: $(TSHARK_1.4.9_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tshark-$(TSHARK_1.4.9_VERSION)-stage: $(TSHARK_1.4.9_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tshark-$(TSHARK_1.4.9_VERSION)
#
$(TSHARK_1.4.9_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tshark-$(TSHARK_1.4.9_VERSION)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TSHARK_1.4.9_PRIORITY)" >>$@
	@echo "Section: $(TSHARK_1.4.9_SECTION)" >>$@
	@echo "Version: $(TSHARK_1.4.9_VERSION)-$(TSHARK_1.4.9_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TSHARK_1.4.9_MAINTAINER)" >>$@
	@echo "Source: $(TSHARK_1.4.9_SITE)/$(TSHARK_1.4.9_SOURCE)" >>$@
	@echo "Description: $(TSHARK_1.4.9_DESCRIPTION)" >>$@
	@echo "Depends: $(TSHARK_1.4.9_DEPENDS)" >>$@
	@echo "Suggests: $(TSHARK_1.4.9_SUGGESTS)" >>$@
	@echo "Conflicts: $(TSHARK_1.4.9_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TSHARK_1.4.9_IPK_DIR)/opt/sbin or $(TSHARK_1.4.9_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TSHARK_1.4.9_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TSHARK_1.4.9_IPK_DIR)/opt/etc/wireshark/...
# Documentation files should be installed in $(TSHARK_1.4.9_IPK_DIR)/opt/doc/wireshark/...
# Daemon startup scripts should be installed in $(TSHARK_1.4.9_IPK_DIR)/opt/etc/init.d/S??wireshark
#
# You may need to patch your application to make it use these locations.
#
$(TSHARK_1.4.9_IPK): $(TSHARK_1.4.9_BUILD_DIR)/.built
	rm -rf $(TSHARK_1.4.9_IPK_DIR) $(BUILD_DIR)/tshark-$(TSHARK_1.4.9_VERSION)_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TSHARK_1.4.9_BUILD_DIR) \
		DESTDIR=$(TSHARK_1.4.9_IPK_DIR) \
		install
	rm -f $(TSHARK_1.4.9_IPK_DIR)/$(TSHARK_1.4.9_LIB_DIR)/*.la
	rm -f $(TSHARK_1.4.9_IPK_DIR)/$(TSHARK_1.4.9_LIB_DIR)/wireshark/plugins/*/*.la
	$(STRIP_COMMAND) \
		$(TSHARK_1.4.9_IPK_DIR)/opt/bin/[a-em-z]* \
		$(TSHARK_1.4.9_IPK_DIR)/$(TSHARK_1.4.9_LIB_DIR)/lib* \
		$(TSHARK_1.4.9_IPK_DIR)/$(TSHARK_1.4.9_LIB_DIR)/wireshark/plugins/*/*.so
	install -d $(TSHARK_1.4.9_IPK_DIR)/opt/etc/
	$(MAKE) $(TSHARK_1.4.9_IPK_DIR)/CONTROL/control
	echo $(TSHARK_1.4.9_CONFFILES) | sed -e 's/ /\n/g' > $(TSHARK_1.4.9_IPK_DIR)/CONTROL/conffiles
	cd $(TSHARK_1.4.9_IPK_DIR)/opt/share; mv wireshark $(TSHARK_1.4.9_VERSION); mkdir wireshark; mv $(TSHARK_1.4.9_VERSION) wireshark/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TSHARK_1.4.9_IPK_DIR)
	cd $(BUILD_DIR); mv tshark-$(TSHARK_1.4.9_VERSION)*.ipk $(TSHARK_1.4.9_IPK)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(TSHARK_1.4.9_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tshark-$(TSHARK_1.4.9_VERSION)-ipk: $(TSHARK_1.4.9_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tshark-$(TSHARK_1.4.9_VERSION)-clean:
	rm -f $(TSHARK_1.4.9_BUILD_DIR)/.built
	-$(MAKE) -C $(TSHARK_1.4.9_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tshark-$(TSHARK_1.4.9_VERSION)-dirclean:
	rm -rf $(BUILD_DIR)/$(TSHARK_1.4.9_DIR) $(TSHARK_1.4.9_BUILD_DIR) $(TSHARK_1.4.9_IPK_DIR) $(TSHARK_1.4.9_IPK)

#
# Some sanity check for the package.
#
tshark-$(TSHARK_1.4.9_VERSION)-check: $(TSHARK_1.4.9_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
