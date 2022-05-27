include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts-asus
PKG_VERSION:=0.9
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/ddns-scripts-asus
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for ASUSddns
  DEPENDS:=ddns-scripts +curl +openssl-util
endef

define Package/ddns-scripts-asus/description
  Dynamic DNS Client scripts extension for "asuscomm.com".
  It requires:
  "option username" to be a valid ASUS router MAC address
  "option password" to be the router's WPS pin code
  "option domain" to contain the domain
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ddns-scripts-asus/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_asusddns.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/asuscomm.com.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-asus/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef

$(eval $(call BuildPackage,ddns-scripts-asus))