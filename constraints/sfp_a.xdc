########### SFP+ A ##########
set_property -dict { PACKAGE_PIN C21  IOSTANDARD LVCMOS25 } [get_ports {sfp_a_scl}]
set_property -dict { PACKAGE_PIN B21  IOSTANDARD LVCMOS25 } [get_ports {sfp_a_sda}]
set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVDS } [get_ports {sfp_a_txn}]
set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVDS } [get_ports {sfp_a_txp}]
set_property -dict { PACKAGE_PIN J3   IOSTANDARD LVDS } [get_ports {sfp_a_rxn}]
set_property -dict { PACKAGE_PIN J4   IOSTANDARD LVDS } [get_ports {sfp_a_rxp}]

