create_clock -period 41.667 -name sys_clk [get_ports clk]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk]

set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports data_out]

set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS33} [get_ports data_in[3]]
set_property -dict {PACKAGE_PIN B9  IOSTANDARD LVCMOS33} [get_ports data_in[2]]
set_property -dict {PACKAGE_PIN G5  IOSTANDARD LVCMOS33} [get_ports data_in[1]]
set_property -dict {PACKAGE_PIN A7  IOSTANDARD LVCMOS33} [get_ports data_in[0]]

set_property -dict {PACKAGE_PIN A13  IOSTANDARD LVCMOS33} [get_ports rst] 
set_property -dict {PACKAGE_PIN F5  IOSTANDARD LVCMOS33} [get_ports load]  
set_property -dict {PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports shift]




