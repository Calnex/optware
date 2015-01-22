###########################################################
#
# CAT
#
###########################################################

# You must replace "cat" and "CAT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ENDOR_VERSION, ENDOR_SITE and ENDOR_SOURCE define
# the upstream location of the source code for the package.
# ENDOR_DIR is the directory which is created when the source
# archive is unpacked.
# ENDOR_UNZIP is the command used to unzip the source.
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
CAT_REPOSITORY=git@github.com:Calnex/CAT.git
CAT_VERSION=1.0
CAT_SOURCE=cat-$(CAT_VERSION).tar.gz
CAT_DIR=cat-$(CAT_VERSION)
CAT_UNZIP=zcat
CAT_MAINTAINER=NSLU2 Linux <alan.potter@calnexsol.com>
CAT_DESCRIPTION=Embedded CAT for Endor
CAT_SECTION=base
CAT_PRIORITY=optional
CAT_DEPENDS=mono
CAT_SUGGESTS=
CAT_CONFLICTS=
CAT_GIT_BRANCH=WebService-EndorRelease

#
# CAT_IPK_VERSION should be incremented when the ipk changes.
#
CAT_IPK_VERSION=git

#
# CAT_CONFFILES should be a list of user-editable files
#

#
# CAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CAT_PATCHES=$(CAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CAT_CPPFLAGS=
CAT_LDFLAGS=

#
# CAT_BUILD_DIR is the directory in which the build is done.
# CAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CAT_IPK_DIR is the directory in which the ipk is built.
# CAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CAT_GIT_TAG?=HEAD
CAT_GIT_OPTIONS?=--depth 1
CAT_TREEISH=$(CAT_GIT_TAG)
CAT_BUILD_DIR=$(BUILD_DIR)/cat
CAT_SOURCE_DIR=$(SOURCE_DIR)/cat
CAT_IPK_DIR=$(BUILD_DIR)/cat-$(CAT_VERSION)-ipk
CAT_IPK=$(BUILD_DIR)/cat_$(CAT_VERSION)-$(CAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cat-source cat-unpack cat cat-stage cat-ipk cat-clean cat-dirclean cat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
# Pull the Release version of the CAT
#
$(DL_DIR)/$(CAT_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf cat && \
		git clone $(CAT_REPOSITORY) cat && \
		cd cat && \
		git checkout $(CAT_GIT_BRANCH) && \
		(git archive \
			--format=tar \
			--prefix=$(CAT_DIR)/ \
			$(CAT_TREEISH) | \
		gzip > $@) && \
		rm -rf cat ;\
	)

# atp temporary fix - pull main line cat (1.0.4)
#$(DL_DIR)/$(CAT_SOURCE):
#	(cd $(BUILD_DIR) ; \
#		rm -rf cat && \
#        mkdir cat && \
#        cd cat && \
#        git init && \
#        git pull $(CAT_REPOSITORY) && \
#		cd cat && \
#		(git archive \
#			--format=tar \
#			--prefix=$(CAT_DIR)/ \
#			$(CAT_TREEISH) | \
#		gzip > $@) && \
#		rm -rf cat ;\
#	)




#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cat-source: $(DL_DIR)/$(CAT_SOURCE) $(CAT_PATCHES)

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
$(CAT_BUILD_DIR)/.configured: $(DL_DIR)/$(CAT_SOURCE) $(CAT_PATCHES) make/cat.mk
	rm -rf $(BUILD_DIR)/$(CAT_DIR) $(@D)
	$(CAT_UNZIP) $(DL_DIR)/$(CAT_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(CAT_PATCHES)" ; \
		then cat $(CAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CAT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CAT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		mdtool generate-makefiles Calnex.CAT.Build.sln -d:Release && \
		sed -i -e 's/PROGRAMFILES = \\/PROGRAMFILES = \\\n\t$$(ASSEMBLY) \\/g' `find $(CAT_BUILD_DIR) -name Makefile.am` && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CAT_LDFLAGS)" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

cat-unpack: $(CAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CAT_BUILD_DIR)/.built: $(CAT_BUILD_DIR)/.configured
	echo "Making the CAT in $(@D)"
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cat: $(CAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CAT_BUILD_DIR)/.staged: $(CAT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

cat-stage: $(CAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/endor
#
$(CAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CAT_PRIORITY)" >>$@
	@echo "Section: $(CAT_SECTION)" >>$@
	@echo "Version: $(CAT_VERSION)-$(CAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CAT_MAINTAINER)" >>$@
	@echo "Source: $(CAT_SITE)/$(CAT_SOURCE)" >>$@
	@echo "Description: $(CAT_DESCRIPTION)" >>$@
	@echo "Depends: $(CAT_DEPENDS)" >>$@
	@echo "Suggests: $(CAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(CAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ENDOR_IPK_DIR)/opt/sbin or $(ENDOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENDOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ENDOR_IPK_DIR)/opt/etc/endor/...
# Documentation files should be installed in $(ENDOR_IPK_DIR)/opt/doc/endor/...
# Daemon startup scripts should be installed in $(ENDOR_IPK_DIR)/opt/etc/init.d/S??endor
#
# You may need to patch your application to make it use these locations.
#
$(CAT_IPK): $(CAT_BUILD_DIR)/.built
	rm -rf $(CAT_IPK_DIR) $(BUILD_DIR)/cat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CAT_BUILD_DIR) DESTDIR=$(CAT_IPK_DIR) install-strip
	cd $(CAT_IPK_DIR)/opt/lib/calnex-cat-build && \
	tar --remove-files -cvzf long-filepaths.tar.gz \
		`find . -type f -ls | awk '{ if (length($$$$13) > 80) { print $$11}}'`
#	install -d $(ENDOR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ENDOR_SOURCE_DIR)/instrumentcontroller-supervisor $(ENDOR_IPK_DIR)/opt/bin/instrumentcontroller-supervisor
#	install -m 755 $(ENDOR_SOURCE_DIR)/curiosity $(ENDOR_IPK_DIR)/opt/bin/curiosity
#	install -m 755 $(ENDOR_SOURCE_DIR)/cat-redirect $(ENDOR_IPK_DIR)/opt/bin/cat-redirect
#	install -m 755 $(ENDOR_SOURCE_DIR)/rc.endor-virtualinstrument $(ENDOR_IPK_DIR)/opt/etc/init.d/S96endor-virtualinstrument
#	install -m 755 $(ENDOR_SOURCE_DIR)/rc.endor-instrumentcontroller $(ENDOR_IPK_DIR)/opt/etc/init.d/S97endor-instrumentcontroller
#	install -m 755 $(ENDOR_SOURCE_DIR)/rc.cat-remotingserver $(ENDOR_IPK_DIR)/opt/etc/init.d/S98cat-remotingserver
#	install -m 755 $(ENDOR_SOURCE_DIR)/rc.endor-webapp $(ENDOR_IPK_DIR)/opt/etc/init.d/S99endor-webapp
#	install -m 755 $(ENDOR_IPK_DIR)/opt/lib/endor/WebApp.dll $(ENDOR_IPK_DIR)/opt/lib/endor/bin/WebApp.dll
#	install -d $(ENDOR_IPK_DIR)/opt/share/endor
#	install -m 755 $(ENDOR_BUILD_DIR)/Endor/Instrument/VirtualInstrument/Files/V0.05SyncEthernetDemowander_V4_NEW.cpd $(ENDOR_IPK_DIR)/opt/share/endor/V0.05SyncEthernetDemowander_V4_NEW.cpd
#	cp -r $(ENDOR_BUILD_DIR)/Endor/Data/Schema $(ENDOR_IPK_DIR)/opt/lib/endor/schema
	$(MAKE) $(CAT_IPK_DIR)/CONTROL/control
	install -m 755 $(CAT_SOURCE_DIR)/postinst $(CAT_IPK_DIR)/CONTROL/postinst
	install -m 755 $(CAT_SOURCE_DIR)/prerm $(CAT_IPK_DIR)/CONTROL/prerm
	echo $(CAT_CONFFILES) | sed -e 's/ /\n/g' > $(CAT_IPK_DIR)/CONTROL/conffiles
	echo "Building CAT IPK"
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CAT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(CAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cat-ipk: $(CAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cat-clean:
	rm -f $(CAT_BUILD_DIR)/.built
	$(MAKE) -C $(CAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cat-dirclean:
	rm -rf $(BUILD_DIR)/$(CAT_DIR) $(CAT_BUILD_DIR) $(CAT_IPK_DIR) $(CAT_IPK)
#
#
# Some sanity check for the package.
#
cat-check: $(CAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
