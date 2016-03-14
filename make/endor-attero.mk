###########################################################
#
# endor-attero
#
###########################################################

# You must replace "endor-attero" and "ENDOR_ATTERO" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ENDOR_ATTERO_VERSION, ENDOR_ATTERO_SITE and ENDOR_ATTERO_SOURCE define
# the upstream location of the source code for the package.
# ENDOR_ATTERO_DIR is the directory which is created when the source
# archive is unpacked.
# ENDOR_ATTERO_UNZIP is the command used to unzip the source.
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


ENDOR_ATTERO_REPOSITORY=https://github.com/Calnex/Springbank
ENDOR_ATTERO_DOCUMENTATION_REPOSITORY=https://github.com/Calnex/EndorDocumentation
ENDOR_ATTERO_VERSION=$(shell echo "$(BUILD_VERSION_NUMBER)" | cut --delimiter "." --output-delimiter "." -f2,3,4)
ENDOR_ATTERO_SOURCE=endor-attero-$(ENDOR_ATTERO_VERSION).tar.gz
ENDOR_ATTERO_DIR=endor-attero
ENDOR_ATTERO_UNZIP=zcat
ENDOR_ATTERO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENDOR_ATTERO_DESCRIPTION=Describe endor-attero here.
ENDOR_ATTERO_SECTION=base
ENDOR_ATTERO_PRIORITY=optional
ENDOR_ATTERO_DEPENDS=postgresql, mono, xsp, nginx
ENDOR_ATTERO_SUGGESTS=
ENDOR_ATTERO_CONFLICTS=endor-paragon

#
# ENDOR_ATTERO_IPK_VERSION should be incremented when the ipk changes.
#
ENDOR_ATTERO_IPK_VERSION=$(BUILD_NUMBER)

#
# ENDOR_ATTERO_CONFFILES should be a list of user-editable files
#ENDOR_ATTERO_CONFFILES=/opt/etc/endor-attero.conf /opt/etc/init.d/SXXendor-attero

#
# ENDOR_ATTERO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ENDOR_ATTERO_PATCHES=$(ENDOR_ATTERO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENDOR_ATTERO_CPPFLAGS=
ENDOR_ATTERO_LDFLAGS=

#
# ENDOR_ATTERO_BUILD_DIR is the directory in which the build is done.
# ENDOR_ATTERO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENDOR_ATTERO_IPK_DIR is the directory in which the ipk is built.
# ENDOR_ATTERO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ifdef ENDOR_COMMON_SOURCE_REPOSITORY
ENDOR_ATTERO_SPRINGBANK_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/Springbank
ENDOR_ATTERO_CAT_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/CAT
ENDOR_ATTERO_DATASTORAGE_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/DataStorage
ENDOR_ATTERO_DOCUMENTATION_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/EndorDocumentation
ENDOR_ATTERO_CALNEXCOMMON_GIT_REFERENCE=--reference $(ENDOR_COMMON_SOURCE_REPOSITORY)/CalnexCommon
endif
ENDOR_ATTERO_GIT_TAG?=HEAD
ENDOR_ATTERO_GIT_OPTIONS?=
ENDOR_ATTERO_TREEISH=$(ENDOR_ATTERO_GIT_TAG)
ENDOR_ATTERO_BUILD_DIR=$(BUILD_DIR)/endor-attero

## Source dir is common for now
ENDOR_ATTERO_SOURCE_DIR=$(SOURCE_DIR)/endor
ENDOR_ATTERO_IPK_DIR=$(BUILD_DIR)/endor-attero-ipk
ENDOR_ATTERO_IPK=$(BUILD_DIR)/endor-attero_$(ENDOR_ATTERO_IPK_VERSION)-$(ENDOR_ATTERO_VERSION)_$(TARGET_ARCH).ipk
ENDOR_ATTERO_BUILD_UTILITIES_DIR=$(BUILD_DIR)/../BuildUtilities

ENDOR_ATTERO_CAT_BUILD_DIR = $(BUILD_DIR)/cat


.PHONY: endor-attero-source endor-attero-unpack endor-attero endor-attero-stage endor-attero-ipk endor-attero-clean endor-attero-dirclean endor-attero-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ENDOR_ATTERO_SOURCE):
	([ -z "${BUILD_VERSION_NUMBER}" ] && { echo "ERROR: Need to set BUILD_VERSION_NUMBER"; exit 1; }; \
		cd $(BUILD_DIR) ; \
		rm -rf endor-attero && \
		git clone $(ENDOR_ATTERO_REPOSITORY) endor-attero $(ENDOR_ATTERO_GIT_OPTIONS) $(ENDOR_ATTERO_SPRINGBANK_GIT_REFERENCE) --branch $(ENDOR_BRANCH_PARAM)  && \
		cd endor-attero && \
		if [ ! -z "${ENDOR_ATTERO_COMMIT_ID}" ] ; \
			then /usr/bin/git checkout ${ENDOR_ATTERO_COMMIT_ID} ; \
		fi ; \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			    echo "Checking out TAG: ${TAG_NAME} "  ;  \
			    /usr/bin/git checkout -b br_${TAG_NAME} ${TAG_NAME} ; \
		fi; \
		git submodule sync --recursive && \
		cd Server/Software/Libs/CAT && \
		git submodule update --init $(ENDOR_ATTERO_CAT_GIT_REFERENCE) && \
		cd Calnex.Endor.DataStorage && \
		git submodule update --init $(ENDOR_ATTERO_DATASTORAGE_GIT_REFERENCE) && \
        cd Calnex.Common && \
        git submodule update --init $(ENDOR_ATTERO_CALNEXCOMMON_GIT_REFERENCE) && \
		cd .. && \
		if [ ! -z "${CAT_TAG}" ] ; \
			then \
			    echo "Checking out a drop of the cat"             && \
				/usr/bin/git checkout -b br_${CAT_TAG} ${CAT_TAG} && \
				/usr/bin/git submodule update --recursive;           \
		fi; \
		cd $(BUILD_DIR) && \
		echo "using System.Reflection;" > endor-attero/Server/Software/Endor/BuildInformation/Version.cs ; \
		echo "[assembly: AssemblyVersion(\"${BUILD_VERSION_NUMBER}\")]" >> endor-attero/Server/Software/Endor/BuildInformation/Version.cs ; \
		echo "[assembly: AssemblyFileVersion(\"${BUILD_VERSION_NUMBER}\")]" >> endor-attero/Server/Software/Endor/BuildInformation/Version.cs ; \
		git show-ref --heads > endor-attero/Server/Software/Endor/BuildInformation/GitCommitIds.txt; \
		# \
		# Check out EndorDocumentation \
		# \
		cd $(BUILD_DIR)/endor-attero/Server/Software ; \
		/usr/bin/git clone $(ENDOR_ATTERO_DOCUMENTATION_REPOSITORY) EndorDocumentation --branch $(ENDOR_BRANCH_PARAM) $(ENDOR_ATTERO_DOCUMENTATION_GIT_REFERENCE) ; \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			cd $(BUILD_DIR)/endor-attero/Server/Software/EndorDocumentation ; \
			echo "Checking out Documentation at TAG: ${TAG_NAME} "  ;  \
			/usr/bin/git checkout -b br_doc_${TAG_NAME} ${TAG_NAME} ; \
		fi; \
		# Minify the Attero Javascript \
		python3 $(BUILD_DIR)/endor-attero/Server/Software/Endor/BuildUtilities/minify2.py \
			--type="js" \
			--output="${BUILD_DIR}/endor-attero/Server/Software/Endor/Web/WebApp/wwwroot/ngApps/Attero/atteroApp.min.js" \
			--folder-exclusions="\\test \\Vendor \\img \\css" \
			--file-inclusions="*.js" \
			--file-exclusions="-spec.js" \
			--folder-source="${BUILD_DIR}/endor-attero/Server/Software/Endor/Web/WebApp/wwwroot/ngApps/Attero" \
			--java-interpreter="/usr/bin/java" \
			--jar-file="$(BUILD_DIR)/endor-attero/Server/Software/Endor/BuildUtilities/yuicompressor-2.4.7.jar" ; \
		# Minify the ngUtils Javascript \
		python3 $(BUILD_DIR)/endor-attero/Server/Software/Endor/BuildUtilities/minify2.py \
			--type="js" \
			--output="${BUILD_DIR}/endor-attero/Server/Software/Endor/Web/WebApp/wwwroot/ngUtils/ngUtils.min.js" \
			--folder-exclusions="\\test \\Vendor \\img \\css" \
			--file-inclusions="*.js" \
			--file-exclusions="-spec.js" \
			--folder-source="${BUILD_DIR}/endor-attero/Server/Software/Endor/Web/WebApp/wwwroot/ngUtils" \
			--java-interpreter="/usr/bin/java" \
			--jar-file="$(BUILD_DIR)/endor-attero/Server/Software/Endor/BuildUtilities/yuicompressor-2.4.7.jar" ; \
		cd $(BUILD_DIR)/endor-attero/Server/Software && \
		tar --transform  "s,^,endor-attero/,S" -cz -f $@ --exclude=.git* * && \
		# Cleanup any branches we created \
		if [ ! -z "${TAG_NAME}" ] ; \
			then \
			cd $(BUILD_DIR)/endor-attero/Server/Software/EndorDocumentation ; \
			/usr/bin/git checkout master ; \
			/usr/bin/git branch -d br_doc_${TAG_NAME} ; \
			cd $(BUILD_DIR)/endor-attero ; \
			/usr/bin/git checkout master ; \
			/usr/bin/git branch -d br_${TAG_NAME} ; \
		fi; \
		cd $(BUILD_DIR) ;\
		rm -rf endor-attero ;\
	)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
endor-attero-source: $(DL_DIR)/$(ENDOR_ATTERO_SOURCE) $(ENDOR_ATTERO_PATCHES) 

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
$(ENDOR_ATTERO_BUILD_DIR)/.configured: $(DL_DIR)/$(ENDOR_ATTERO_SOURCE) $(ENDOR_ATTERO_PATCHES)  make/endor-attero.mk
	rm -rf $(BUILD_DIR)/$(ENDOR_ATTERO_DIR) $(@D)
	$(ENDOR_ATTERO_UNZIP) $(DL_DIR)/$(ENDOR_ATTERO_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(ENDOR_ATTERO_PATCHES)" ; \
		then cat $(ENDOR_ATTERO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ENDOR_ATTERO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ENDOR_ATTERO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ENDOR_ATTERO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		mdtool generate-makefiles Endor.sln -d:release && \
		sed -i -e 's/PROGRAMFILES = \\/PROGRAMFILES = \\\n\t$$(ASSEMBLY) \\/g' `find $(ENDOR_ATTERO_BUILD_DIR) -name Makefile.am` && \
		sed -i -e 's/Endor/Endor/g' autogen.sh configure.ac && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ENDOR_ATTERO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENDOR_ATTERO_LDFLAGS)" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

endor-attero-unpack: $(ENDOR_ATTERO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ENDOR_ATTERO_BUILD_DIR)/.built: $(ENDOR_ATTERO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@


#
# You should change the dependency to refer directly to the main binary
# which is built.
#
endor-attero: $(ENDOR_ATTERO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ENDOR_ATTERO_BUILD_DIR)/.staged-attero: $(ENDOR_ATTERO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

endor-attero-stage: $(ENDOR_ATTERO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/endor
#
$(ENDOR_ATTERO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: endor-attero" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENDOR_ATTERO_PRIORITY)" >>$@
	@echo "Section: $(ENDOR_ATTERO_SECTION)" >>$@
	@echo "Version: $(ENDOR_ATTERO_VERSION)-$(ENDOR_ATTERO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ENDOR_ATTERO_MAINTAINER)" >>$@
	@echo "Source: $(ENDOR_ATTERO_SITE)/$(ENDOR_ATTERO_SOURCE)" >>$@
	@echo "Description: $(ENDOR_ATTERO_DESCRIPTION)" >>$@
	@echo "Depends: $(ENDOR_ATTERO_DEPENDS)" >>$@
	@echo "Suggests: $(ENDOR_ATTERO_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENDOR_ATTERO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ENDOR_ATTERO_IPK_DIR)/opt/sbin or $(ENDOR_ATTERO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENDOR_ATTERO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ENDOR_ATTERO_IPK_DIR)/opt/etc/endor-attero/...
# Documentation files should be installed in $(ENDOR_ATTERO_IPK_DIR)/opt/doc/endor-attero/...
# Daemon startup scripts should be installed in $(ENDOR_ATTERO_IPK_DIR)/opt/etc/init.d/S??endor-attero
#
# You may need to patch your application to make it use these locations.
# 
$(ENDOR_ATTERO_IPK): $(ENDOR_ATTERO_BUILD_DIR)/.built
	rm -rf $(ENDOR_ATTERO_IPK_DIR) $(BUILD_DIR)/endor-attero_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ENDOR_ATTERO_BUILD_DIR) DESTDIR=$(ENDOR_ATTERO_IPK_DIR) install-strip
	
	# Configuration files
	#
	install -d $(ENDOR_ATTERO_IPK_DIR)/opt/etc/init.d
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/instrumentcontroller-supervisor	$(ENDOR_ATTERO_IPK_DIR)/opt/bin/instrumentcontroller-supervisor
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/cat-supervisor-cat				    $(ENDOR_ATTERO_IPK_DIR)/opt/bin/cat-supervisor-cat
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/calnex.endor.webapp				$(ENDOR_ATTERO_IPK_DIR)/opt/bin/calnex.endor.webapp
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/calnex.endor.translatorclui		$(ENDOR_ATTERO_IPK_DIR)/opt/bin/calnex.endor.translatorclui 
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/curiosity					        $(ENDOR_ATTERO_IPK_DIR)/opt/bin/curiosity
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/cat-redirect					    $(ENDOR_ATTERO_IPK_DIR)/opt/bin/cat-redirect
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/instrument.controller.virtual		$(ENDOR_ATTERO_IPK_DIR)/opt/bin/calnex.endor.instrument.controller.virtualinstrument
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/instrument.controller.physical	$(ENDOR_ATTERO_IPK_DIR)/opt/bin/calnex.endor.instrument.controller.physicalinstrument
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/rc.endor-wait-for-database		$(ENDOR_ATTERO_IPK_DIR)/opt/etc/init.d/S96_pre_endor-waitfordatabase
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/rc.endor-instrumentcontroller		$(ENDOR_ATTERO_IPK_DIR)/opt/etc/init.d/S97endor-instrumentcontroller
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/rc.cat-remotingserver-cat		    $(ENDOR_ATTERO_IPK_DIR)/opt/etc/init.d/S98cat-remotingserver-cat
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/rc.endor-webapp				    $(ENDOR_ATTERO_IPK_DIR)/opt/etc/init.d/S99endor-webapp
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/rc.endor-translatorclui			$(ENDOR_ATTERO_IPK_DIR)/opt/etc/init.d/S99endor-translator
	install -m 755 $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/WebApp.dll			    $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/bin/WebApp.dll
	mkdir $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/utility
	install -m 644 $(ENDOR_ATTERO_SOURCE_DIR)/save_persistent_data.py           $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/utility/save_persistent_data.py
	install -m 644 $(ENDOR_ATTERO_SOURCE_DIR)/restore_persistent_data.py        $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/utility/restore_persistent_data.py
	
	# Shell scripts
	#
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/set_ifconfig_DHCP.sh   $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/set_ifconfig_DHCP.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/set_ifconfig_static.sh $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/set_ifconfig_static.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/get_gateway.sh         $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/get_gateway.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/get_ip.sh              $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/get_ip.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/get_subnet_mask.sh     $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/get_subnet_mask.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/poweroff.sh            $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/poweroff.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Shell/reboot.sh              $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/reboot.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Controller/Sql/attero_updates.sql       $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/attero_updates.sql
	
#	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Web/WebApp/Shell/update_software.sh                                        $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/update_instrument.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Web/WebApp/Shell/set_time.sh                                               $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/set_time.sh
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Web/WebApp/Shell/set_date.sh                                               $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/set_date.sh
	
	# CAT HTML and Javascript
	#
	install -d $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/CAT
	cp -rv $(ENDOR_ATTERO_BUILD_DIR)/Libs/CAT/Release/html/* $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/CAT/
	cp -rv $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/CAT/index.cat.html $(ENDOR_PARAGON_IPK_DIR)/opt/lib/endor/CAT/index.html

	
	# CAT's Mask_XML files
	#
	install -d $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/bin/Mask_XML
	install -m 755 -t $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/bin/Mask_XML $(ENDOR_ATTERO_BUILD_DIR)/Libs/CAT/WanderAnalysisTool/Mask_XML/*

        # Application JavaScript
        #
	install -m 644 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Web/WebApp/wwwroot/ngApps/Attero/atteroApp.min.js          $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/wwwroot/ngApps/Attero/atteroApp.min.js
	install -m 644 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Web/WebApp/wwwroot/ngUtils/ngUtils.min.js                  $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/wwwroot/ngUtils/ngUtils.min.js


	
	# Various other required files
	#
	install -d $(ENDOR_ATTERO_IPK_DIR)/opt/share/endor
	install -m 755 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Instrument/Calnex.Endor.Instrument.Virtual/Files/V0.05SyncEthernetDemowander_V4_NEW.cpd $(ENDOR_ATTERO_IPK_DIR)/opt/share/endor/V0.05SyncEthernetDemowander_V4_NEW.cpd
	cp -r $(ENDOR_ATTERO_BUILD_DIR)/Endor/Data/Schema $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/schema
	install -m 444 $(ENDOR_ATTERO_BUILD_DIR)/Endor/Data/Schema/Baseline/RebuildDb.py $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/schema/Baseline/RebuildDb.py
		$(MAKE) $(ENDOR_ATTERO_IPK_DIR)/CONTROL/control
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/preinst  $(ENDOR_ATTERO_IPK_DIR)/CONTROL/preinst
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/postinst $(ENDOR_ATTERO_IPK_DIR)/CONTROL/postinst
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/prerm    $(ENDOR_ATTERO_IPK_DIR)/CONTROL/prerm
	install -m 755 $(ENDOR_ATTERO_SOURCE_DIR)/postrm   $(ENDOR_ATTERO_IPK_DIR)/CONTROL/postrm
	echo $(ENDOR_ATTERO_CONFFILES) | sed -e 's/ /\n/g' > $(ENDOR_ATTERO_IPK_DIR)/CONTROL/conffiles

	# Some tidy-ups
	#
	rm -rf $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/bin/phantomJs/phantomjs.exe
	
	# Provide PhantomJS from the packages server
	#
	if [ -e "$(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/phantomJs" ]; \
		then rm -rf $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/phantomJs; \
	fi
	mkdir $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/phantomJs/
	wget http://packages.calnexsol.com/build_dependencies/1.0/binary_dependencies/phantomjs    \
			-O $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/phantomJs/phantomjs
	chmod 555 $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/phantomJs/phantomjs
	install -m 644 $(ENDOR_ATTERO_BUILD_DIR)/Libs/CAT/Release/phantomJs/RenderService.js    $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/phantomJs/RenderService.js
	# install -m 644 $(ENDOR_ATTERO_BUILD_DIR)/Libs/CAT/Release/phantomJs/Render.js           $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/phantomJs/Render.js
	
	# Swagger files
	#
	install -m 644 ${ENDOR_ATTERO_BUILD_DIR}/Endor/Web/WebApp/doc/images/Favicon_Spirent.png   $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/doc/images/Favicon_Spirent.png
	install -m 644 ${ENDOR_ATTERO_BUILD_DIR}/Endor/Web/WebApp/doc/images/Favicon_calnex.png    $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/doc/images/Favicon_calnex.png

	# Help documentation
	#
	install -d $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/Help/Documents
	install -m 444 $(ENDOR_ATTERO_BUILD_DIR)/Endor/BuildInformation/GitCommitIds.txt                 $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/Help/GitCommitIds.txt

	# NGINX config
	#
	install -d $(ENDOR_ATTERO_IPK_DIR)/opt/etc/nginx/sites-available
	install -d $(ENDOR_ATTERO_IPK_DIR)/opt/etc/nginx/sites-enabled
	install -m 644 $(ENDOR_ATTERO_SOURCE_DIR)/endor.nginx  $(ENDOR_ATTERO_IPK_DIR)/opt/etc/nginx/sites-available/endor

	# Embedded firmware
	#
	if [ ! -z "${ENDOR_ATTERO_FIRMWARE_VERSION}" ]; then \
        if [ "${ENDOR_ATTERO_FIRMWARE_VERSION}" != "(none)" ] ; then \
            install -d $(ENDOR_ATTERO_IPK_DIR)/opt/var/lib/embedded; \
            cd $(ENDOR_ATTERO_IPK_DIR)/opt/var/lib/embedded; \
            wget "http://packages.calnexsol.com/firmware/fw-update-$(ENDOR_ATTERO_FIRMWARE_VERSION).tar.gz"; \
            wget "http://packages.calnexsol.com/firmware/fw-update-$(ENDOR_ATTERO_FIRMWARE_VERSION).tar.gz.md5"; \
            cat $(ENDOR_ATTERO_SOURCE_DIR)/postinst.firmware >> $(ENDOR_ATTERO_IPK_DIR)/CONTROL/postinst; \
            sed -i -e 's/__FIRMWARE_VERSION__/${ENDOR_ATTERO_FIRMWARE_VERSION}/g' $(ENDOR_ATTERO_IPK_DIR)/CONTROL/postinst; \
        fi; \
	fi
	
	cd $(ENDOR_ATTERO_BUILD_DIR)/EndorDocumentation/DocumentationShippedWithAttero && \
	find . -name *.xml | cpio -pdm --verbose $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/Help/ && \
	find . -name *.pdf | cpio -pdm --verbose $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor/Help/
	
	# The version of tar used in ipkg_build chokes at file name lengths > 100 characters.
	# Build any such files into a tarball that can later be purged.
	#
	cd $(ENDOR_ATTERO_IPK_DIR)/opt/lib/endor && \
	tar --remove-files -czf long-filepaths.tar.gz \
		`find . -type f -ls | awk '{ if (length($$$$13) > 80) { print $$11}}'`
	
	# Now go and build the package
	#
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENDOR_ATTERO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ENDOR_ATTERO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
endor-attero-ipk: $(ENDOR_ATTERO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
endor-attero-clean:
	rm -f $(ENDOR_ATTERO_BUILD_DIR)/.built
	$(MAKE) -C $(ENDOR_ATTERO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
endor-attero-dirclean:
	rm -rf $(BUILD_DIR)/$(ENDOR_ATTERO_DIR) $(ENDOR_ATTERO_BUILD_DIR) $(ENDOR_ATTERO_IPK_DIR) $(ENDOR_ATTERO_IPK)
#
#
# Some sanity check for the package.
#
endor-attero-check: $(ENDOR_ATTERO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
