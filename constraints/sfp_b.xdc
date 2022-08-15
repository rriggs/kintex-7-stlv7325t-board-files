########### SFP+ B ##########
set_property -dict { PACKAGE_PIN C22  IOSTANDARD LVCMOS25 } [get_ports {sfp_b_scl}]
set_property -dict { PACKAGE_PIN D21  IOSTANDARD LVCMOS25 } [get_ports {sfp_b_sda}]
set_property -dict { PACKAGE_PIN K1   IOSTANDARD LVDS } [get_ports {sfp_b_txn}]
set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVDS } [get_ports {sfp_b_txp}]
set_property -dict { PACKAGE_PIN L3   IOSTANDARD LVDS } [get_ports {sfp_b_rxn}]
set_property -dict { PACKAGE_PIN L4   IOSTANDARD LVDS } [get_ports {sfp_b_rxp}]

