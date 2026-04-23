###########################################################
#
# dotnet-runtimes
#
###########################################################


DOTNET-RUNTIMES_VERSION=8.0.26
DOTNET-RUNTIMES_MAINTAINER=dotnet-foundation <contact@dotnetfoundation.org>
DOTNET-RUNTIMES_DESCRIPTION=.NET and ASP.NET Core runtimes bundled for Optware
DOTNET-RUNTIMES_SECTION=extras
DOTNET-RUNTIMES_PRIORITY=optional
DOTNET-RUNTIMES_DEPENDS=
DOTNET-RUNTIMES_SUGGESTS=
DOTNET-RUNTIMES_CONFLICTS=

DOTNET-RUNTIMES_IPK_VERSION=0

DOTNET-RUNTIMES_CONFFILES=

#
# .NET runtime binary sources.  These are downloaded from the official Microsoft site, but a local mirror is also supported.
#

DOTNET-RUNTIMES_CALNEX_SITE=$(PACKAGES_SERVER)
DOTNET-RUNTIMES_SITE=https://builds.dotnet.microsoft.com/dotnet

DOTNET-RUNTIMES_RUNTIME_BINARIES=dotnet-runtime-$(DOTNET-RUNTIMES_VERSION)-linux-x64.tar.gz
DOTNET-RUNTIMES_RUNTIME_URL_OFFICIAL=$(DOTNET-RUNTIMES_SITE)/Runtime/$(DOTNET-RUNTIMES_VERSION)/$(DOTNET-RUNTIMES_RUNTIME_BINARIES)
DOTNET-RUNTIMES_RUNTIME_URL_CALNEX=$(DOTNET-RUNTIMES_CALNEX_SITE)/$(DOTNET-RUNTIMES_RUNTIME_BINARIES)

DOTNET-RUNTIMES_ASPNETCORE_BINARIES=aspnetcore-runtime-$(DOTNET-RUNTIMES_VERSION)-linux-x64.tar.gz
DOTNET-RUNTIMES_ASPNETCORE_URL_OFFICIAL=$(DOTNET-RUNTIMES_SITE)/aspnetcore/Runtime/$(DOTNET-RUNTIMES_VERSION)/$(DOTNET-RUNTIMES_ASPNETCORE_BINARIES)
DOTNET-RUNTIMES_ASPNETCORE_URL_CALNEX=$(DOTNET-RUNTIMES_CALNEX_SITE)/$(DOTNET-RUNTIMES_ASPNETCORE_BINARIES)

DOTNET-RUNTIMES_BUILD_DIR=$(BUILD_DIR)/dotnet-runtimes
DOTNET-RUNTIMES_SOURCE_DIR=$(SOURCE_DIR)/dotnet-runtimes
DOTNET-RUNTIMES_IPK_DIR=$(BUILD_DIR)/dotnet-runtimes-$(DOTNET-RUNTIMES_VERSION)-ipk
DOTNET-RUNTIMES_IPK=$(BUILD_DIR)/dotnet-runtimes_$(DOTNET-RUNTIMES_VERSION)-$(DOTNET-RUNTIMES_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dotnet-runtimes-source dotnet-runtimes-unpack dotnet-runtimes dotnet-runtimes-stage dotnet-runtimes-ipk dotnet-runtimes-clean dotnet-runtimes-dirclean dotnet-runtimes-check

$(DL_DIR)/$(DOTNET-RUNTIMES_RUNTIME_BINARIES):
	$(WGET) -P $(@D) $(DOTNET-RUNTIMES_RUNTIME_URL_CALNEX) -O $@ || \
	$(WGET) -P $(@D) $(DOTNET-RUNTIMES_RUNTIME_URL_OFFICIAL) -O $@

$(DL_DIR)/$(DOTNET-RUNTIMES_ASPNETCORE_BINARIES):
	$(WGET) -P $(@D) $(DOTNET-RUNTIMES_ASPNETCORE_URL_CALNEX) -O $@ || \
	$(WGET) -P $(@D) $(DOTNET-RUNTIMES_ASPNETCORE_URL_OFFICIAL) -O $@

dotnet-runtimes-source: $(DL_DIR)/$(DOTNET-RUNTIMES_RUNTIME_BINARIES) $(DL_DIR)/$(DOTNET-RUNTIMES_ASPNETCORE_BINARIES) \
	$(DOTNET-RUNTIMES_SOURCE_DIR)/postinst \
	$(DOTNET-RUNTIMES_SOURCE_DIR)/prerm \
	$(DOTNET-RUNTIMES_SOURCE_DIR)/postrm

$(DOTNET-RUNTIMES_BUILD_DIR)/.configured: dotnet-runtimes-source make/dotnet-runtimes.mk
	rm -rf $(@D)
	mkdir -p $(@D)
	touch $@

#
# This is called from the top level makefile to unpack the .NET runtimes and apply any patches.
#
dotnet-runtimes-unpack: $(DOTNET-RUNTIMES_BUILD_DIR)/.configured

$(DOTNET-RUNTIMES_BUILD_DIR)/.built: $(DOTNET-RUNTIMES_BUILD_DIR)/.configured
	rm -f $@
	rm -rf $(@D)/data
	install -d \
		$(@D)/data/opt/usr/share/dotnet \
		$(@D)/data/opt/bin
	tar -xzf $(DL_DIR)/$(DOTNET-RUNTIMES_RUNTIME_BINARIES) -C $(@D)/data/opt/usr/share/dotnet
	tar -xzf $(DL_DIR)/$(DOTNET-RUNTIMES_ASPNETCORE_BINARIES) -C $(@D)/data/opt/usr/share/dotnet
	(cd $(@D)/data/opt/usr/share/dotnet; \
		LONG_PATH_FILES=`find . -type f | awk '{ if (length($$0) >= 70) { print $$0 }}'`; \
		if test -n "$$LONG_PATH_FILES" ; then \
			tar --remove-files -czf long-filepaths.tar.gz $$LONG_PATH_FILES; \
		else \
			tar -czf long-filepaths.tar.gz --files-from /dev/null; \
		fi)
	ln -sf /opt/usr/share/dotnet/dotnet $(@D)/data/opt/bin/dotnet
	touch $@


#
# This is the build convenience target.
#
dotnet-runtimes: $(DOTNET-RUNTIMES_BUILD_DIR)/.built

$(DOTNET-RUNTIMES_BUILD_DIR)/.staged: $(DOTNET-RUNTIMES_BUILD_DIR)/.built
	rm -f $@
	touch $@

dotnet-runtimes-stage: $(DOTNET-RUNTIMES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lua
#
$(DOTNET-RUNTIMES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dotnet-runtimes" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DOTNET-RUNTIMES_PRIORITY)" >>$@
	@echo "Section: $(DOTNET-RUNTIMES_SECTION)" >>$@
	@echo "Version: $(DOTNET-RUNTIMES_VERSION)-$(DOTNET-RUNTIMES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DOTNET-RUNTIMES_MAINTAINER)" >>$@
	@echo "Source: $(DOTNET-RUNTIMES_SITE)/$(DOTNET-RUNTIMES_RUNTIME_BINARIES)" >>$@
	@echo "Description: $(DOTNET-RUNTIMES_DESCRIPTION)" >>$@
	@echo "Depends: $(DOTNET-RUNTIMES_DEPENDS)" >>$@
	@echo "Suggests: $(DOTNET-RUNTIMES_SUGGESTS)" >>$@
	@echo "Conflicts: $(DOTNET-RUNTIMES_CONFLICTS)" >>$@

#
# This is called from the top level makefile to create the IPK file.
#
$(DOTNET-RUNTIMES_IPK): $(DOTNET-RUNTIMES_BUILD_DIR)/.built
	rm -rf $(DOTNET-RUNTIMES_IPK_DIR) $(BUILD_DIR)/dotnet-runtimes_*_$(TARGET_ARCH).ipk
	cp -a $(DOTNET-RUNTIMES_BUILD_DIR)/data $(DOTNET-RUNTIMES_IPK_DIR)
	$(MAKE) $(DOTNET-RUNTIMES_IPK_DIR)/CONTROL/control
	install -m 755 $(DOTNET-RUNTIMES_SOURCE_DIR)/postinst $(DOTNET-RUNTIMES_IPK_DIR)/CONTROL/postinst
	install -m 755 $(DOTNET-RUNTIMES_SOURCE_DIR)/prerm $(DOTNET-RUNTIMES_IPK_DIR)/CONTROL/prerm
	install -m 755 $(DOTNET-RUNTIMES_SOURCE_DIR)/postrm $(DOTNET-RUNTIMES_IPK_DIR)/CONTROL/postrm
	echo $(DOTNET-RUNTIMES_CONFFILES) | sed -e 's/ /\n/g' > $(DOTNET-RUNTIMES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DOTNET-RUNTIMES_IPK_DIR)
	@if ! test -f $(DOTNET-RUNTIMES_IPK); then \
		echo "Expected ipk not found at $(DOTNET-RUNTIMES_IPK)"; \
		echo "Available dotnet-runtimes ipk files:"; \
		ls -1 $(BUILD_DIR)/dotnet-runtimes*_$(TARGET_ARCH).ipk 2>/dev/null || true; \
		exit 1; \
	fi
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DOTNET-RUNTIMES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dotnet-runtimes-ipk: $(DOTNET-RUNTIMES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dotnet-runtimes-clean:
	rm -f $(DOTNET-RUNTIMES_BUILD_DIR)/.built $(DOTNET-RUNTIMES_BUILD_DIR)/.staged
	rm -rf $(DOTNET-RUNTIMES_BUILD_DIR)/data

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dotnet-runtimes-dirclean:
	rm -rf $(DOTNET-RUNTIMES_BUILD_DIR) $(DOTNET-RUNTIMES_IPK_DIR) $(DOTNET-RUNTIMES_IPK)

#
# Some sanity check for the package.
#
dotnet-runtimes-check: $(DOTNET-RUNTIMES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
