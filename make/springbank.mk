###########################################################
#
# springbank
#
###########################################################

# You must replace "springbank" and "SPRINGBANK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SPRINGBANK_VERSION, SPRINGBANK_SITE and SPRINGBANK_SOURCE define
# the upstream location of the source code for the package.
# SPRINGBANK_DIR is the directory which is created when the source
# archive is unpacked.
# SPRINGBANK_UNZIP is the command used to unzip the source.
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
SPRINGBANK_VERSION=1.0.0
SPRINGBANK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SPRINGBANK_DESCRIPTION=Describe springbank here.
SPRINGBANK_SECTION=base
SPRINGBANK_PRIORITY=optional
SPRINGBANK_DEPENDS=$(PACKAGES)
SPRINGBANK_SUGGESTS=
SPRINGBANK_CONFLICTS=

#
# SPRINGBANK_IPK_VERSION should be incremented when the ipk changes.
#
SPRINGBANK_IPK_VERSION=1

#
# SPRINGBANK_BUILD_DIR is the directory in which the build is done.
# SPRINGBANK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SPRINGBANK_IPK_DIR is the directory in which the ipk is built.
# SPRINGBANK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SPRINGBANK_BUILD_DIR=$(BUILD_DIR)/springbank
SPRINGBANK_SOURCE_DIR=$(SOURCE_DIR)/springbank
SPRINGBANK_IPK_DIR=$(BUILD_DIR)/springbank-$(SPRINGBANK_VERSION)-ipk
SPRINGBANK_IPK=$(BUILD_DIR)/springbank_$(SPRINGBANK_VERSION)-$(SPRINGBANK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: springbank-source springbank-unpack springbank springbank-stage springbank-ipk springbank-clean springbank-dirclean springbank-check

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/springbank
#
$(SPRINGBANK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: springbank" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPRINGBANK_PRIORITY)" >>$@
	@echo "Section: $(SPRINGBANK_SECTION)" >>$@
	@echo "Version: $(SPRINGBANK_VERSION)-$(SPRINGBANK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPRINGBANK_MAINTAINER)" >>$@
	@echo "Source: $(SPRINGBANK_SITE)/$(SPRINGBANK_SOURCE)" >>$@
	@echo "Description: $(SPRINGBANK_DESCRIPTION)" >>$@
	@echo "Depends: $(SPRINGBANK_DEPENDS)" >>$@
	@echo "Suggests: $(SPRINGBANK_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPRINGBANK_CONFLICTS)" >>$@

#
# This is called from the top level makefile to create the IPK file.
#
springbank-ipk: 
	rm -rf $(SPRINGBANK_IPK_DIR)
	$(MAKE) $(SPRINGBANK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPRINGBANK_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SPRINGBANK_IPK_DIR)

#
# This is called from the top level makefile to clean all of the built files.
#
springbank-clean:
	rm -f $(SPRINGBANK_BUILD_DIR)/.built
	-$(MAKE) -C $(SPRINGBANK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
springbank-dirclean:
	rm -rf $(BUILD_DIR)/$(SPRINGBANK_DIR) $(SPRINGBANK_BUILD_DIR) $(SPRINGBANK_IPK_DIR) $(SPRINGBANK_IPK)
#
#
# Some sanity check for the package.
#
springbank-check: $(SPRINGBANK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
