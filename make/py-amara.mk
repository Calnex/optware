###########################################################
#
# py-amara
#
###########################################################

#
# PY-AMARA_VERSION, PY-AMARA_SITE and PY-AMARA_SOURCE define
# the upstream location of the source code for the package.
# PY-AMARA_DIR is the directory which is created when the source
# archive is unpacked.
# PY-AMARA_UNZIP is the command used to unzip the source.
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
PY-AMARA_SITE=http://cheeseshop.python.org/packages/source/A/Amara
PY-AMARA_VERSION=1.1.8b2
PY-AMARA_SOURCE=Amara-$(PY-AMARA_VERSION).tar.gz
PY-AMARA_DIR=Amara-$(PY-AMARA_VERSION)
PY-AMARA_UNZIP=zcat
PY-AMARA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-AMARA_DESCRIPTION=A collection of Python/XML processing tools to complement 4Suite.
PY-AMARA_SECTION=misc
PY-AMARA_PRIORITY=optional
PY-AMARA_DEPENDS=py-4suite
PY-AMARA_CONFLICTS=

#
# PY-AMARA_IPK_VERSION should be incremented when the ipk changes.
#
PY-AMARA_IPK_VERSION=2

#
# PY-AMARA_CONFFILES should be a list of user-editable files
#PY-AMARA_CONFFILES=/opt/etc/py-amara.conf /opt/etc/init.d/SXXpy-amara

#
# PY-AMARA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-AMARA_PATCHES=$(PY-AMARA_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-AMARA_CPPFLAGS=
PY-AMARA_LDFLAGS=

#
# PY-AMARA_BUILD_DIR is the directory in which the build is done.
# PY-AMARA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-AMARA_IPK_DIR is the directory in which the ipk is built.
# PY-AMARA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-AMARA_BUILD_DIR=$(BUILD_DIR)/py-amara
PY-AMARA_SOURCE_DIR=$(SOURCE_DIR)/py-amara
PY-AMARA_IPK_DIR=$(BUILD_DIR)/py-amara-$(PY-AMARA_VERSION)-ipk
PY-AMARA_IPK=$(BUILD_DIR)/py-amara_$(PY-AMARA_VERSION)-$(PY-AMARA_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-AMARA_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-AMARA_SITE)/$(PY-AMARA_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-amara-source: $(DL_DIR)/$(PY-AMARA_SOURCE) $(PY-AMARA_PATCHES)

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
$(PY-AMARA_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-AMARA_SOURCE) $(PY-AMARA_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-AMARA_DIR) $(PY-AMARA_BUILD_DIR)
	$(PY-AMARA_UNZIP) $(DL_DIR)/$(PY-AMARA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-AMARA_PATCHES)"; then \
	    cat $(PY-AMARA_PATCHES) | patch -d $(BUILD_DIR)/$(PY-AMARA_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-AMARA_DIR) $(PY-AMARA_BUILD_DIR)
	(cd $(PY-AMARA_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	touch $(PY-AMARA_BUILD_DIR)/.configured

py-amara-unpack: $(PY-AMARA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-AMARA_BUILD_DIR)/.built: $(PY-AMARA_BUILD_DIR)/.configured
	rm -f $(PY-AMARA_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-AMARA_BUILD_DIR)
	(cd $(PY-AMARA_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	python2.4 setup.py build)
	touch $(PY-AMARA_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-amara: $(PY-AMARA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-AMARA_BUILD_DIR)/.staged: $(PY-AMARA_BUILD_DIR)/.built
	rm -f $(PY-AMARA_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-AMARA_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-AMARA_BUILD_DIR)/.staged

py-amara-stage: $(PY-AMARA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-amara
#
$(PY-AMARA_IPK_DIR)/CONTROL/control:
	@install -d $(PY-AMARA_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-amara" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-AMARA_PRIORITY)" >>$@
	@echo "Section: $(PY-AMARA_SECTION)" >>$@
	@echo "Version: $(PY-AMARA_VERSION)-$(PY-AMARA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-AMARA_MAINTAINER)" >>$@
	@echo "Source: $(PY-AMARA_SITE)/$(PY-AMARA_SOURCE)" >>$@
	@echo "Description: $(PY-AMARA_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-AMARA_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-AMARA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-AMARA_IPK_DIR)/opt/sbin or $(PY-AMARA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-AMARA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-AMARA_IPK_DIR)/opt/etc/py-amara/...
# Documentation files should be installed in $(PY-AMARA_IPK_DIR)/opt/doc/py-amara/...
# Daemon startup scripts should be installed in $(PY-AMARA_IPK_DIR)/opt/etc/init.d/S??py-amara
#
# You may need to patch your application to make it use these locations.
#
$(PY-AMARA_IPK): $(PY-AMARA_BUILD_DIR)/.built
	rm -rf $(PY-AMARA_IPK_DIR) $(BUILD_DIR)/py-amara_*_$(TARGET_ARCH).ipk
	(cd $(PY-AMARA_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py install --root=$(PY-AMARA_IPK_DIR) --prefix=/opt)
#	$(STRIP_COMMAND) `find $(PY-AMARA_IPK_DIR)/opt/lib/ -name '*.so'`
	$(MAKE) $(PY-AMARA_IPK_DIR)/CONTROL/control
#	echo $(PY-AMARA_CONFFILES) | sed -e 's/ /\n/g' > $(PY-AMARA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-AMARA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-amara-ipk: $(PY-AMARA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-amara-clean:
	-$(MAKE) -C $(PY-AMARA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-amara-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-AMARA_DIR) $(PY-AMARA_BUILD_DIR) $(PY-AMARA_IPK_DIR) $(PY-AMARA_IPK)
