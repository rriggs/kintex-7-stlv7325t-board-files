########### HDMI ##########
set_property -dict { PACKAGE_PIN M26  IOSTANDARD LVCMOS33 } [get_ports {hdmi_cec}]
set_property -dict { PACKAGE_PIN N26  IOSTANDARD LVCMOS33 } [get_ports {hdmi_hpd}]
set_property -dict { PACKAGE_PIN K21  IOSTANDARD LVCMOS33 } [get_ports {hdmi_scl}]
set_property -dict { PACKAGE_PIN L23  IOSTANDARD LVCMOS33 } [get_ports {hdmi_sda}]
set_property -dict { PACKAGE_PIN R21  IOSTANDARD TMDS_33 } [get_ports {hdmi_clk_p}]
set_property -dict { PACKAGE_PIN P21  IOSTANDARD TMDS_33 } [get_ports {hdmi_clk_n}]
set_property -dict { PACKAGE_PIN N18  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[0]}]
set_property -dict { PACKAGE_PIN M19  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[0]}]
set_property -dict { PACKAGE_PIN M21  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[1]}]
set_property -dict { PACKAGE_PIN M22  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[1]}]
set_property -dict { PACKAGE_PIN K25  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[2]}]
set_property -dict { PACKAGE_PIN K26  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[2]}]

