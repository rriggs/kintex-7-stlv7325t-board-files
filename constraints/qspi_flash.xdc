########### QSPI FLASH ##########
set_property -dict { PACKAGE_PIN B24  IOSTANDARD LVCMOS33 } [get_ports {qspi_d0}]
set_property -dict { PACKAGE_PIN A25  IOSTANDARD LVCMOS33 } [get_ports {qspi_d1}]
set_property -dict { PACKAGE_PIN B22  IOSTANDARD LVCMOS33 } [get_ports {qspi_d2}]
set_property -dict { PACKAGE_PIN A22  IOSTANDARD LVCMOS33 } [get_ports {qspi_d3}]
set_property -dict { PACKAGE_PIN C23  IOSTANDARD LVCMOS33 } [get_ports {qspi_cs}]
set_property -dict { PACKAGE_PIN C8   IOSTANDARD LVCMOS33 } [get_ports {qspi_clk}]

