OPTWARE-BOOTSTRAP_TARGETS=\
	Springbank \

OPTWARE-BOOTSTRAP_REAL_OPT_DIR=$(strip \
	$(if $(filter Sprintbank, $(OPTWARE_TARGET)), /volume1/@optware))

OPTWARE-BOOTSTRAP_RC=$(strip \
	$(if $(filter Springbank, $(OPTWARE_TARGET)), /etc/rc.optware))

OPTWARE-BOOTSTRAP_CONTAINS=$(strip \
	ipkg-opt wget)

OPTWARE-BOOTSTRAP_UPDATE_ALTERNATIVES=$(strip \
	$(if $(filter ipkg-opt, $(OPTWARE-BOOTSTRAP_CONTAINS)),,yes))

define OPTWARE-BOOTSTRAP_RULE_TEMPLATE
$(1)-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=$(1)
$(1)-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=$(1)
endef

$(foreach target,$(OPTWARE-BOOTSTRAP_TARGETS),$(eval $(call OPTWARE-BOOTSTRAP_RULE_TEMPLATE,$(target))))

