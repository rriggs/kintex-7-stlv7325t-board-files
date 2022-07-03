########### CLOCKS ##########
#set_property -dict { PACKAGE_PIN AB11 IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_200_p]
#set_property -dict { PACKAGE_PIN AC11 IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_200_n]
#set_property -dict { PACKAGE_PIN F17  IOSTANDARD LVCMOS33    } [get_ports sysclk_100]
#set_property -dict { PACKAGE_PIN F6   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_150_p]
#set_property -dict { PACKAGE_PIN F5   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_150_n]
#set_property -dict { PACKAGE_PIN D6   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_156_p]
#set_property -dict { PACKAGE_PIN D5   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_156_n]

#create_clock -period  5.000 [get_ports sysclk_200_p]
#create_clock -period 10.000 [get_ports sysclk_100]
#create_clock -period  6.667 [get_ports sysclk_150_p]
#create_clock -period  6.400 [get_ports sysclk_156_p]

