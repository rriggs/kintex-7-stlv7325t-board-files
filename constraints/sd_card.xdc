########### SD CARD ##########
# SDIO Interface
#set_property -dict { PACKAGE_PIN N16  IOSTANDARD LVCMOS33 } [get_ports {sd_d0}]
#set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {sd_d1}]
#set_property -dict { PACKAGE_PIN N22  IOSTANDARD LVCMOS33 } [get_ports {sd_d2}]
#set_property -dict { PACKAGE_PIN P19  IOSTANDARD LVCMOS33 } [get_ports {sd_d3}]
#set_property -dict { PACKAGE_PIN U21  IOSTANDARD LVCMOS33 } [get_ports {sd_cmd}]
#set_property -dict { PACKAGE_PIN N21  IOSTANDARD LVCMOS33 } [get_ports {sd_clk}]

# SPI Interface
#set_property -dict { PACKAGE_PIN N16  IOSTANDARD LVCMOS33 } [get_ports {sd_do}]
#set_property -dict { PACKAGE_PIN P19  IOSTANDARD LVCMOS33 } [get_ports {sd_cs}]
#set_property -dict { PACKAGE_PIN U21  IOSTANDARD LVCMOS33 } [get_ports {sd_di}]
#set_property -dict { PACKAGE_PIN N21  IOSTANDARD LVCMOS33 } [get_ports {sd_clk}]

