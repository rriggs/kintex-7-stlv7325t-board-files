########### UART ##########
set_property -dict { PACKAGE_PIN M25  IOSTANDARD LVCMOS33 } [get_ports {uart_tx}]
set_property -dict { PACKAGE_PIN L25  IOSTANDARD LVCMOS33 } [get_ports {uart_rx}]

