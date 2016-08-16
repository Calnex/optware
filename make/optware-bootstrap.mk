###########################################################
#
# optware-bootstrap
#
# Creates an ipk for optware-bootstrapping optware.
#
###########################################################

OPTWARE-BOOTSTRAP_VERSION=1.2
OPTWARE-BOOTSTRAP_IPK_VERSION=7

OPTWARE-BOOTSTRAP_DIR=optware-bootstrap-$(OPTWARE-BOOTSTRAP_VERSION)
OPTWARE-BOOTSTRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPTWARE-BOOTSTRAP_DESCRIPTION=Optware bootstrap package
OPTWARE-BOOTSTRAP_SECTION=util
OPTWARE-BOOTSTRAP_PRIORITY=optional
OPTWARE-BOOTSTRAP_DEPENDS=
OPTWARE-BOOTSTRAP_CONFLICTS=

OPTWARE-BOOTSTRAP_SOURCE_DIR=$(SOURCE_DIR)/optware-bootstrap

# This is used when multiple devices shares the same feed, but need different bootstrap.xsh
# For instance, in the case of mssii
# 	OPTWARE_TARGET is set to mssii
# 	OPTWARE-BOOTSTRAP_TARGET can be either mssii, lspro, terapro
OPTWARE-BOOTSTRAP_TARGET ?= $(OPTWARE_TARGET)

# bootstrap target specific options such as
# OPTWARE-BOOTSTRAP_REAL_OPT_DIR and OPTWARE-BOOTSTRAP_RC
# will be set in the .mk included below
include $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/target-specific.mk

ifneq (, $(filter $(OPTWARE-BOOTSTRAP_TARGET), $(OPTWARE-BOOTSTRAP_TARGETS)))

OPTWARE-BOOTSTRAP_CONTAINS ?= ipkg-opt wget debian
OPTWARE-BOOTSTRAP_IPKS_DONE:=$(foreach p, $(OPTWARE-BOOTSTRAP_CONTAINS), $(BUILD_DIR)/$(p)/.ipk)

OPTWARE-BOOTSTRAP_BUILD_DIR=$(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)-optware-bootstrap

OPTWARE-BOOTSTRAP_V=$(OPTWARE-BOOTSTRAP_VERSION)-$(OPTWARE-BOOTSTRAP_IPK_VERSION)
OPTWARE-BOOTSTRAP_IPK_DIR=$(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)-bootstrap-$(OPTWARE-BOOTSTRAP_VERSION)-ipk
OPTWARE-BOOTSTRAP_IPK=$(BUILD_DIR)/optware-bootstrap_$(OPTWARE-BOOTSTRAP_V)_$(TARGET_ARCH).ipk
OPTWARE-BOOTSTRAP_XSH=$(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)-bootstrap_$(OPTWARE-BOOTSTRAP_V)_$(TARGET_ARCH).xsh

$(OPTWARE-BOOTSTRAP_BUILD_DIR)/.configured: $(OPTWARE-BOOTSTRAP_PATCHES) make/optware-bootstrap.mk \
$(OPTWARE-BOOTSTRAP_SOURCE_DIR)/target-specific.mk
	rm -rf $(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_DIR) $(@D)
	mkdir -p $(@D)
	touch $@

optware-bootstrap-unpack: $(OPTWARE-BOOTSTRAP_BUILD_DIR)/.configured

$(OPTWARE-BOOTSTRAP_BUILD_DIR)/.built: $(OPTWARE-BOOTSTRAP_BUILD_DIR)/.configured
	rm -f $@
#	cp -a $(TARGET_LIBDIR)/* $(OPTWARE-BOOTSTRAP_BUILD_DIR)/
#	find $(OPTWARE-BOOTSTRAP_BUILD_DIR)/ -type l | xargs rm -f
#	rm $(OPTWARE-BOOTSTRAP_BUILD_DIR)/libc.so*
	touch $@

optware-bootstrap: $(OPTWARE-BOOTSTRAP_BUILD_DIR)/.built

$(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: optware-bootstrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPTWARE-BOOTSTRAP_PRIORITY)" >>$@
	@echo "Section: $(OPTWARE-BOOTSTRAP_SECTION)" >>$@
	@echo "Version: $(OPTWARE-BOOTSTRAP_V)" >>$@
	@echo "Maintainer: $(OPTWARE-BOOTSTRAP_MAINTAINER)" >>$@
	@echo "Source: $(OPTWARE-BOOTSTRAP_SITE)/$(OPTWARE-BOOTSTRAP_SOURCE)" >>$@
	@echo "Description: $(OPTWARE-BOOTSTRAP_DESCRIPTION) for $(OPTWARE-BOOTSTRAP_TARGET)" >>$@
	@echo "Depends: $(OPTWARE-BOOTSTRAP_DEPENDS)" >>$@
	@echo "Conflicts: $(OPTWARE-BOOTSTRAP_CONFLICTS)" >>$@

$(OPTWARE-BOOTSTRAP_XSH): $(OPTWARE-BOOTSTRAP_BUILD_DIR)/.built $(OPTWARE-BOOTSTRAP_IPKS_DONE)
	# build optware-bootstrap.ipk first
	rm -rf $(OPTWARE-BOOTSTRAP_IPK_DIR) $(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)-bootstrap_*_$(TARGET_ARCH).ipk
	install -d -m 755 \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/lib \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/var
ifneq ($(OPTWARE-BOOTSTRAP_LIBS),)
	cp -rip $(OPTWARE-BOOTSTRAP_LIBS) $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/lib
endif
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/var/lib
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/etc/init.d
	install -d -m 1755 $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/tmp
	install -m 755 $(IPKG-OPT_SOURCE_DIR)/rc.optware $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc/
ifneq (, $(filter fsg3 fsg3v4, $(OPTWARE_TARGET)))
	install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE_TARGET)/optware \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)$(OPTWARE-BOOTSTRAP_RC)
else
	install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/optware $(OPTWARE-BOOTSTRAP_IPK_DIR)$(OPTWARE-BOOTSTRAP_RC)
endif
	sed -i -e 's/__TARGET_DISTRO__/$(TARGET_DISTRO)/g' $(OPTWARE-BOOTSTRAP_IPK_DIR)$(OPTWARE-BOOTSTRAP_RC)
	sed -i -e 's/__TARGET_PRODUCT__/$(TARGET_PRODUCT)/g' $(OPTWARE-BOOTSTRAP_IPK_DIR)$(OPTWARE-BOOTSTRAP_RC)
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc/init.d
	if [ -e $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE_TARGET)/S00optware ] ; then \
		install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE_TARGET)/S00optware \
			$(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc/init.d/ ; \
	fi
ifneq (, $(filter yes, $(OPTWARE-BOOTSTRAP_UPDATE_ALTERNATIVES)))
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)$(UPD-ALT_PREFIX)/bin
	install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/update-alternatives \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)$(UPD-ALT_PREFIX)/bin/
endif
	$(MAKE) $(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/control
	install -m 644 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/preinst $(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/
ifneq ($(OPTWARE-BOOTSTRAP_REAL_OPT_DIR),)
	sed -i -e '/^[ 	]*REAL_OPT_DIR=$$/s|=.*|=$(OPTWARE-BOOTSTRAP_REAL_OPT_DIR)|' \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)$(OPTWARE-BOOTSTRAP_RC) \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/preinst
endif
	install -m 644 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)/postinst \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/etc/usbmount/
	install -m 644 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/usbrepo/usbmount.conf \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/etc/usbmount/
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/lib/udev/rules.d
	install -m 644 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/usbrepo/usbmount.rules \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/lib/udev/rules.d/
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/bin
	install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/usbrepo/optwareUSB \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/bin/
	sed -i -e 's/__TARGET_DISTRO__/$(TARGET_DISTRO)/g' $(OPTWARE-BOOTSTRAP_IPK_DIR)/bin/optwareUSB
	sed -i -e 's/__TARGET_PRODUCT__/$(TARGET_PRODUCT)/g' $(OPTWARE-BOOTSTRAP_IPK_DIR)/bin/optwareUSB
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc
	install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE_TARGET)/logrotate.conf $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc/logrotate.conf
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc/cron.daily
	install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE_TARGET)/logrotate.cron $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc/cron.daily/logrotate.optware
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPTWARE-BOOTSTRAP_IPK_DIR)
	# build optware-bootstrap.xsh next
	rm -rf $(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)-bootstrap_*_$(TARGET_ARCH).xsh
#	rm -rf $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap
	install -d $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap
	#	move the ipk, so it will not be in the feed
	mv $(OPTWARE-BOOTSTRAP_IPK) $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/optware-bootstrap.ipk
	#	additional ipk's we require
	for i in $(OPTWARE-BOOTSTRAP_CONTAINS); do \
		I_IPK=`grep -i ^$${i}_IPK= make/*.mk | sed 's/^.*://;s/=.*//'`; \
		ipkfile=`MAKEFLAGS=-s $(MAKE) query-$${I_IPK}`; \
		cp $$ipkfile $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/$${i}.ipk; \
	done
	#	bootstrap scripts
	install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)/bootstrap.sh \
	   $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)/S00SystemConfiguration \
	   $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)/S00SystemLoading \
	   $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)/loading_server \
	   $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)/loading_server.py \
	   $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)/ip_fallback \
	   $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/ipkg.sh \
	   $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/
	   
	# Fixup distro
	sed -i -e 's/__TARGET_DISTRO__/$(TARGET_DISTRO)/g' $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/bootstrap.sh
	sed -i -e 's/__TARGET_PRODUCT__/$(TARGET_PRODUCT)/g' $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/bootstrap.sh
	sed -i -e 's/__TARGET_PRODUCT__/$(TARGET_PRODUCT_LOWER)/g' $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/S00SystemConfiguration
ifneq (OPTWARE-BOOTSTRAP_REAL_OPT_DIR,)
	sed -i -e '/^[ 	]*REAL_OPT_DIR=.*/s|=.*|=$(OPTWARE-BOOTSTRAP_REAL_OPT_DIR)|' \
	       -e 's/$${OPTWARE_TARGET}/$(OPTWARE_TARGET)/g' \
	   $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/bootstrap.sh
endif
	#	NNN is the number of bytes to skip, adjust if not 3 digits
	echo "#!/bin/sh" >$@
	echo 'echo "Optware Bootstrap for $(OPTWARE-BOOTSTRAP_TARGET)."' >>$@
	echo 'echo "Extracting archive to $PWD... please wait"' >>$@
	echo 'dd if=$$0 bs=NNN skip=1 | tar xzv' >>$@
	echo "cd bootstrap && sh bootstrap.sh && mv S00SystemConfiguration /etc/init.d && mv S00SystemLoading /etc/init.d && mv loading_server /sbin &&  mv loading_server.py /sbin && mv ip_fallback /sbin && cd .. && rm -r bootstrap && exit 0" >>$@
#	echo 'exec /bin/sh -l' >>$@ # No logon shell after install
	sed -i -e "s/NNN/`wc -c $@ | awk '{print $$1}'`/" $@
	tar -C $(OPTWARE-BOOTSTRAP_BUILD_DIR) -czf - bootstrap >>$@
	chmod 755 $@
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPTWARE-BOOTSTRAP_IPK_DIR)

optware-bootstrap-ipk: $(OPTWARE-BOOTSTRAP_XSH)
optware-bootstrap-xsh: $(OPTWARE-BOOTSTRAP_XSH)

optware-bootstrap-stage: optware-bootstrap-ipk
	cp $(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_TARGET)-bootstrap_*_$(TARGET_ARCH).xsh $(STAGING_DIR)/bin/

optware-bootstrap-clean:
	rm -rf $(OPTWARE-BOOTSTRAP_BUILD_DIR)/*

optware-bootstrap-dirclean:
	rm -rf $(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_DIR) $(OPTWARE-BOOTSTRAP_BUILD_DIR) $(OPTWARE-BOOTSTRAP_IPK_DIR) $(OPTWARE-BOOTSTRAP_IPK)
	rm -rf $(OPTWARE-BOOTSTRAP_XSH)

endif
