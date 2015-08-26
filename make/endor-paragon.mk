###########################################################
#
# endor-paragon
#
###########################################################

# You must replace "endor-paragon" and "ENDOR_PARAGON" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ENDOR_PARAGON_VERSION, ENDOR_PARAGON_SITE and ENDOR_PARAGON_SOURCE define
# the upstream location of the source code for the package.
# ENDOR_PARAGON_DIR is the directory which is created when the source
# archive is unpacked.
# ENDOR_PARAGON_UNZIP is the command used to unzip the source.
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
BUILD_VERSION_NUMBER?=0.1.0.0
BUILD_NUMBER?=devel
ENDOR_BRANCH_PARAM?=master


ENDOR_PARAGON_REPOSITORY=https://github.com/Calnex/Springbank
ENDOR_PARAGON_DOCUMENTATION_REPOSITORY=https://github.com/Calnex/EndorDocumentation
ENDOR_PARAGON_VERSION=$(shell echo "$(BUILD_VERSION_NUMBER)" | cut --delimiter "." --output-delimiter "." -f2,3,4)
ENDOR_PARAGON_SOURCE=endor-paragon-$(ENDOR_PARAGON_VERSION).tar.gz
ENDOR_PARAGON_DIR=endor-paragon
ENDOR_PARAGON_UNZIP=zcat
ENDOR_PARAGON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENDOR_PARAGON_DESCRIPTION=Describe endor-paragon here.
ENDOR_PARAGON_SECTION=base
ENDOR_PARAGON_PRIORITY=optional
ENDOR_PARAGON_DEPENDS=postgresql, mono, xsp
ENDOR_PARAGON_SUGGESTS=
ENDOR_PARAGON_CONFLICTS=endor-attero

#
# ENDOR_PARAGON_IPK_VERSION should be incremented when the ipk changes.
#
ENDOR_PARAGON_IPK_VERSION=$(BUILD_NUMBER)

#
# ENDOR_PARAGON_CONFFILES should be a list of user-editable files
#ENDOR_PARAGON_CONFFILES=/opt/etc/endor-paragon.conf /opt/etc/init.d/SXXendor-paragon

#
# ENDOR_PARAGON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ENDOR_PARAGON_PATCHES=$(ENDOR_PARAGON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENDOR_PARAGON_CPPFLAGS=
ENDOR_PARAGON_LDFLAGS=

#
# ENDOR_PARAGON_BUILD_DIR is the directory in which the build is done.
# ENDOR_PARAGON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENDOR_PARAGON_IPK_DIR is the directory in which the ipk is built.
# ENDOR_PARAGON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ifdef ENDOR_COMMON_SOURCE_REPOSITORY
ENDOR_PARAGON_SPRINGBANK_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/Springbank
ENDOR_PARAGON_CAT_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/CAT
ENDOR_PARAGON_DATASTORAGE_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/DataStorage
ENDOR_PARAGON_DOCUMENTATION_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/EndorDocumentation
endif
ENDOR_PARAGON_GIT_TAG?=HEAD
ENDOR_PARAGON_GIT_OPTIONS?=
ENDOR_PARAGON_TREEISH=$(ENDOR_PARAGON_GIT_TAG)
ENDOR_PARAGON_BUILD_DIR=$(BUILD_DIR)/endor-paragon

## Source dir is common for now
ENDOR_PARAGON_SOURCE_DIR=$(SOURCE_DIR)/endor
ENDOR_PARAGON_IPK_DIR=$(BUILD_DIR)/endor-paragon-ipk
ENDOR_PARAGON_IPK=$(BUILD_DIR)/endor-paragon_$(ENDOR_PARAGON_VERSION)-$(ENDOR_PARAGON_IPK_VERSION)_$(TARGET_ARCH).ipk
ENDOR_PARAGON_BUILD_UTILITIES_DIR=$(BUILD_DIR)/../BuildUtilities

ENDOR_PARAGON_CAT_BUILD_DIR = $(BUILD_DIR)/cat

.PHONY: endor-paragon-source endor-paragon-unpack endor-paragon endor-paragon-stage endor-paragon-ipk endor-paragon-clean endor-paragon-dirclean endor-paragon-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ENDOR_PARAGON_SOURCE):
	([ -z "${BUILD_VERSION_NUMBER}" ] && { echo "ERROR: Need to set BUILD_VERSION_NUMBER"; exit 1; }; \
		cd $(BUILD_DIR) ; \
		rm -rf endor-paragon && \
		git clone $(ENDOR_PARAGON_REPOSITORY) endor-paragon $(ENDOR_PARAGON_GIT_OPTIONS) $(ENDOR_PARAGON_SPRINGBANK_GIT_REFERENCE) --branch $(ENDOR_BRANCH_PARAM) && \
		cd endor-paragon && \
		if [ ! -z "${ENDOR_PARAGON_COMMIT_ID}" ] ; \
			then /usr/bin/git checkout ${ENDOR_PARAGON_COMMIT_ID} ; \
		fi ; \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			    echo "Checking out TAG: ${TAG_NAME} "  ;  \
			    /usr/bin/git checkout -b br_${TAG_NAME} ${TAG_NAME} ; \
		fi; \
		git submodule sync --recursive && \
		cd Server/Software/Libs/CAT && \
		git submodule update --init --remote $(ENDOR_PARAGON_CAT_GIT_REFERENCE) && \
		cd Calnex.Endor.DataStorage && \
		git submodule update --init --remote $(ENDOR_PARAGON_DATASTORAGE_GIT_REFERENCE) && \
		cd .. && \
		if [ ! -z "${CAT_TAG}" ] ; \
			then \
			    echo "Checking out a drop of the cat"             && \
				/usr/bin/git checkout -b br_${CAT_TAG} ${CAT_TAG} && \
				/usr/bin/git submodule update --recursive;           \
		fi; \
		cd $(BUILD_DIR) && \
		echo "using System.Reflection;" > endor-paragon/Server/Software/Endor/BuildInformation/Version.cs ; \
		echo "[assembly: AssemblyVersion(\"${BUILD_VERSION_NUMBER}\")]" >> endor-paragon/Server/Software/Endor/BuildInformation/Version.cs ; \
		echo "[assembly: AssemblyFileVersion(\"${BUILD_VERSION_NUMBER}\")]" >> endor-paragon/Server/Software/Endor/BuildInformation/Version.cs ; \
		git show-ref --heads > endor-paragon/Server/Software/Endor/BuildInformation/GitCommitIds.txt; \
		# \
		# Check out EndorDocumentation \
		# \
		cd $(BUILD_DIR)/endor-paragon/Server/Software ; \
		/usr/bin/git clone $(ENDOR_PARAGON_DOCUMENTATION_REPOSITORY) EndorDocumentation --branch $(ENDOR_BRANCH_PARAM)  $(ENDOR_PARAGON_DOCUMENTATION_GIT_REFERENCE) ; \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			cd $(BUILD_DIR)/endor-paragon/Server/Software/EndorDocumentation ; \
			echo "Checking out Documentation at TAG: ${TAG_NAME} "  ;  \
			/usr/bin/git checkout -b br_doc_${TAG_NAME} ${TAG_NAME} ; \
		fi; \
		# Minify the Paragon Javascript \
		python3 $(BUILD_DIR)/endor-paragon/Server/Software/Endor/BuildUtilities/minify2.py \
			--type="js" \
			--output="${BUILD_DIR}/endor-paragon/Server/Software/Endor/Web/WebApp/wwwroot/ngApps/Paragon/paragonApp.min.js" \
			--folder-exclusions="\\test \\Vendor \\img \\css" \
			--file-inclusions="*.js" \
			--file-exclusions="-spec.js" \
			--folder-source="${BUILD_DIR}/endor-paragon/Server/Software/Endor/Web/WebApp/wwwroot/ngApps/Paragon" \
			--java-interpreter="/usr/bin/java" \
			--jar-file="$(BUILD_DIR)/endor-paragon/Server/Software/Endor/BuildUtilities/yuicompressor-2.4.7.jar" ; \
		# Minify the ngUtils Javascript \
		python3 $(BUILD_DIR)/endor-paragon/Server/Software/Endor/BuildUtilities/minify2.py \
			--type="js" \
			--output="${BUILD_DIR}/endor-paragon/Server/Software/Endor/Web/WebApp/wwwroot/ngUtils/ngUtils.min.js" \
			--folder-exclusions="\\test \\Vendor \\img \\css" \
			--file-inclusions="*.js" \
			--file-exclusions="-spec.js" \
			--folder-source="${BUILD_DIR}/endor-paragon/Server/Software/Endor/Web/WebApp/wwwroot/ngUtils" \
			--java-interpreter="/usr/bin/java" \
			--jar-file="$(BUILD_DIR)/endor-paragon/Server/Software/Endor/BuildUtilities/yuicompressor-2.4.7.jar" ; \
		cd $(BUILD_DIR)/endor-paragon/Server/Software && \
		tar --transform  "s,^,endor-paragon/,S" -cz -f $@ --exclude=.git* * && \
		# Cleanup any branches we created \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			cd $(BUILD_DIR)/endor-paragon/Server/Software/EndorDocumentation ; \
			/usr/bin/git checkout master ; \
			/usr/bin/git branch -d br_doc_${TAG_NAME} ; \
			cd $(BUILD_DIR)/endor-paragon ; \
			/usr/bin/git checkout master ; \
			/usr/bin/git branch -d br_${TAG_NAME} ; \
		fi; \
		cd $(BUILD_DIR) ;\
		rm -rf endor-paragon ;\
	)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
endor-paragon-source: $(DL_DIR)/$(ENDOR_PARAGON_SOURCE) $(ENDOR_PARAGON_PATCHES) 

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
$(ENDOR_PARAGON_BUILD_DIR)/.configured: $(DL_DIR)/$(ENDOR_PARAGON_SOURCE) $(ENDOR_PARAGON_PATCHES)  make/endor-paragon.mk
	rm -rf $(BUILD_DIR)/$(ENDOR_PARAGON_DIR) $(@D)
	$(ENDOR_PARAGON_UNZIP) $(DL_DIR)/$(ENDOR_PARAGON_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(ENDOR_PARAGON_PATCHES)" ; \
		then cat $(ENDOR_PARAGON_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ENDOR_PARAGON_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ENDOR_PARAGON_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ENDOR_PARAGON_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		mdtool generate-makefiles EndorParagon.sln -d:release && \
		sed -i -e 's/PROGRAMFILES = \\/PROGRAMFILES = \\\n\t$$(ASSEMBLY) \\/g' `find $(ENDOR_PARAGON_BUILD_DIR) -name Makefile.am` && \
		sed -i -e 's/EndorParagon/Endor/g' autogen.sh configure.ac && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ENDOR_PARAGON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENDOR_PARAGON_LDFLAGS)" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

endor-paragon-unpack: $(ENDOR_PARAGON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ENDOR_PARAGON_BUILD_DIR)/.built: $(ENDOR_PARAGON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@


#
# You should change the dependency to refer directly to the main binary
# which is built.
#
endor-paragon: $(ENDOR_PARAGON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ENDOR_PARAGON_BUILD_DIR)/.staged-paragon: $(ENDOR_PARAGON_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

endor-paragon-stage: $(ENDOR_PARAGON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/endor
#
$(ENDOR_PARAGON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: endor-paragon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENDOR_PARAGON_PRIORITY)" >>$@
	@echo "Section: $(ENDOR_PARAGON_SECTION)" >>$@
	@echo "Version: $(ENDOR_PARAGON_VERSION)-$(ENDOR_PARAGON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ENDOR_PARAGON_MAINTAINER)" >>$@
	@echo "Source: $(ENDOR_PARAGON_SITE)/$(ENDOR_PARAGON_SOURCE)" >>$@
	@echo "Description: $(ENDOR_PARAGON_DESCRIPTION)" >>$@
	@echo "Depends: $(ENDOR_PARAGON_DEPENDS)" >>$@
	@echo "Suggests: $(ENDOR_PARAGON_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENDOR_PARAGON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ENDOR_PARAGON_IPK_DIR)/opt/sbin or $(ENDOR_PARAGON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENDOR_PARAGON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ENDOR_PARAGON_IPK_DIR)/opt/etc/endor-paragon/...
# Documentation files should be installed in $(ENDOR_PARAGON_IPK_DIR)/opt/doc/endor-paragon/...
# Daemon startup scripts should be installed in $(ENDOR_PARAGON_IPK_DIR)/opt/etc/init.d/S??endor-paragon
#
# You may need to patch your application to make it use these locations.
# 
$(ENDOR_PARAGON_IPK): $(ENDOR_PARAGON_BUILD_DIR)/.built
	rm -rf $(ENDOR_PARAGON_IPK_DIR) $(BUILD_DIR)/endor-paragon_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ENDOR_PARAGON_BUILD_DIR) DESTDIR=$(ENDOR_PARAGON_IPK_DIR) install-strip
	
	# Configuration files
	#
	install -d $(ENDOR_PARAGON_IPK_DIR)/opt/etc/init.d
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/instrumentcontroller-supervisor	$(ENDOR_PARAGON_IPK_DIR)/opt/bin/instrumentcontroller-supervisor
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/cat-supervisor				    $(ENDOR_PARAGON_IPK_DIR)/opt/bin/cat-supervisor
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/calnex.endor.webapp				$(ENDOR_PARAGON_IPK_DIR)/opt/bin/calnex.endor.webapp
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/calnex.endor.translatorclui		$(ENDOR_PARAGON_IPK_DIR)/opt/bin/calnex.endor.translatorclui 
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/curiosity					    $(ENDOR_PARAGON_IPK_DIR)/opt/bin/curiosity
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/cat-redirect					    $(ENDOR_PARAGON_IPK_DIR)/opt/bin/cat-redirect
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/instrument.controller.virtual	$(ENDOR_PARAGON_IPK_DIR)/opt/bin/calnex.endor.instrument.controller.virtualinstrument
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/instrument.controller.physical	$(ENDOR_PARAGON_IPK_DIR)/opt/bin/calnex.endor.instrument.controller.physicalinstrument
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/rc.endor-wait-for-database		$(ENDOR_PARAGON_IPK_DIR)/opt/etc/init.d/S96_pre_endor-waitfordatabase
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/rc.endor-instrumentcontroller	$(ENDOR_PARAGON_IPK_DIR)/opt/etc/init.d/S97endor-instrumentcontroller
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/rc.cat-remotingserver			$(ENDOR_PARAGON_IPK_DIR)/opt/etc/init.d/S98cat-remotingserver
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/rc.endor-webapp				    $(ENDOR_PARAGON_IPK_DIR)/opt/etc/init.d/S99endor-webapp
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/rc.endor-translatorclui			$(ENDOR_PARAGON_IPK_DIR)/opt/etc/init.d/S99endor-translator
	install -m 755 $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/WebApp.dll			$(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/bin/WebApp.dll
	mkdir $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/utility
	install -m 644 $(ENDOR_PARAGON_SOURCE_DIR)/save_persistent_data.py          $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/utility/save_persistent_data.py
	install -m 644 $(ENDOR_PARAGON_SOURCE_DIR)/restore_persistent_data.py       $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/utility/restore_persistent_data.py
    
	
	# Shell scripts
	#
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/set_ifconfig_DHCP.sh   $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/set_ifconfig_DHCP.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/set_ifconfig_static.sh $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/set_ifconfig_static.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/get_gateway.sh         $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/get_gateway.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/get_ip.sh              $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/get_ip.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/get_subnet_mask.sh     $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/get_subnet_mask.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/poweroff.sh            $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/poweroff.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/reboot.sh              $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/reboot.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Web/WebApp/Shell/update_software.sh                                        $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/update_software.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Web/WebApp/Shell/update_software_worker.sh                                 $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/update_software_worker.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Web/WebApp/Shell/set_time.sh                                               $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/set_time.sh
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Web/WebApp/Shell/set_date.sh                                               $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/set_date.sh
	
	# CAT HTML and Javascript
	#
	install -d $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/CAT
	cp -rv $(ENDOR_PARAGON_BUILD_DIR)/Libs/CAT/Release/html/* $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/CAT/

	# CAT's Mask_XML files
	#
	install -d $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/bin/Mask_XML
	install -m 755 -t $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/bin/Mask_XML $(ENDOR_PARAGON_BUILD_DIR)/Libs/CAT/WanderAnalysisTool/Mask_XML/*
	
	# Various other required files
	#
	install -d $(ENDOR_PARAGON_IPK_DIR)/opt/share/endor
	install -m 755 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Virtual/Files/V0.05SyncEthernetDemowander_V4_NEW.cpd $(ENDOR_PARAGON_IPK_DIR)/opt/share/endor/V0.05SyncEthernetDemowander_V4_NEW.cpd
	cp -r $(ENDOR_PARAGON_BUILD_DIR)/Endor/Data/Schema $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/schema
	install -m 444 $(ENDOR_PARAGON_BUILD_DIR)/Endor/Data/Schema/Baseline/RebuildDb_Paragon.py $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/schema/Baseline/RebuildDb.py
		$(MAKE) $(ENDOR_PARAGON_IPK_DIR)/CONTROL/control
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/postinst $(ENDOR_PARAGON_IPK_DIR)/CONTROL/postinst
	install -m 755 $(ENDOR_PARAGON_SOURCE_DIR)/prerm $(ENDOR_PARAGON_IPK_DIR)/CONTROL/prerm
	echo $(ENDOR_PARAGON_CONFFILES) | sed -e 's/ /\n/g' > $(ENDOR_PARAGON_IPK_DIR)/CONTROL/conffiles

	# Provide PhantomJS from the packages server
	#
	if [ -e "$(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/phantomJs" ]; \
		then rm -rf $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/phantomJs; \
	fi
	mkdir $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/phantomJs/
	wget http://packages.calnexsol.com/build_dependencies/1.0/binary_dependencies/phantomjs    \
			-O $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/phantomJs/phantomjs
	chmod 555 $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/phantomJs/phantomjs
	install -m 644 $(ENDOR_PARAGON_BUILD_DIR)/Libs/CAT/Release/phantomJs/RenderService.js    $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/phantomJs/RenderService.js
	install -m 644 $(ENDOR_PARAGON_BUILD_DIR)/Libs/CAT/Release/phantomJs/Render.js           $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/phantomJs/Render.js
	 
	
	# Help documentation
	#
	install -d $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/Help/Documents
	install -m 444 $(ENDOR_PARAGON_BUILD_DIR)/Endor/BuildInformation/GitCommitIds.txt                 $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/Help/GitCommitIds.txt

	cd $(ENDOR_PARAGON_BUILD_DIR)/EndorDocumentation/DocumentationShippedWithParagon && \
	find . -name *.xml | cpio -pdm --verbose $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/Help/ && \
	find . -name *.pdf | cpio -pdm --verbose $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/Help/
	
	# Embedded firmware
	#
	if [ ${ENDOR_PARAGON_FIRMWARE_VERSION} ]; then \
        if [ "$ENDOR_PARAGON_FIRMWARE_VERSION" -ne "(none)" ] ; then \
            install -d $(ENDOR_PARAGON_IPK_DIR)/opt/var/lib/embedded; \
            cd $(ENDOR_PARAGON_IPK_DIR)/opt/var/lib/embedded; \
            wget http://packages.calnexsol.com/firmware/fw-update-$(ENDOR_PARAGON_FIRMWARE_VERSION).tar.gz; \
            wget http://packages.calnexsol.com/firmware/fw-update-$(ENDOR_PARAGON_FIRMWARE_VERSION).tar.gz.md5; \
            cat $(ENDOR_PARAGON_SOURCE_DIR)/postinst.firmware >> $(ENDOR_PARAGON_IPK_DIR)/CONTROL/postinst; \
            sed -i -e 's/__FIRMWARE_VERSION__/${ENDOR_PARAGON_FIRMWARE_VERSION}/g' $(ENDOR_PARAGON_IPK_DIR)/CONTROL/postinst; \
        fi; \
	fi
	
	# The version of tar used in ipkg_build chokes at file name lengths > 100 characters.
	# Build any such files into a tarball that can later be purged.
	#
	cd $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor && \
	tar --remove-files -czf long-filepaths.tar.gz \
		`find . -type f -ls | awk '{ if (length($$$$13) > 80) { print $$11}}'`
	
	# Now go and build the package
	#
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENDOR_PARAGON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ENDOR_PARAGON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
endor-paragon-ipk: $(ENDOR_PARAGON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
endor-paragon-clean:
	rm -f $(ENDOR_PARAGON_BUILD_DIR)/.built
	$(MAKE) -C $(ENDOR_PARAGON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
endor-paragon-dirclean:
	rm -rf $(BUILD_DIR)/$(ENDOR_PARAGON_DIR) $(ENDOR_PARAGON_BUILD_DIR) $(ENDOR_PARAGON_IPK_DIR) $(ENDOR_PARAGON_IPK)
#
#
# Some sanity check for the package.
#
endor-paragon-check: $(ENDOR_PARAGON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
