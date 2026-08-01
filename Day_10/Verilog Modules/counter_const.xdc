create_clock -period 41.667 -name sys_clk [get_ports clk]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk]


set_property -dict {PACKAGE_PIN A13  IOSTANDARD LVCMOS33} [get_ports rst]

set_property -dict {PACKAGE_PIN T2  IOSTANDARD LVCMOS33} [get_ports count[0]]
set_property -dict {PACKAGE_PIN T3  IOSTANDARD LVCMOS33} [get_ports count[1]]
set_property -dict {PACKAGE_PIN M1  IOSTANDARD LVCMOS33} [get_ports count[2]]
set_property -dict {PACKAGE_PIN P1  IOSTANDARD LVCMOS33} [get_ports count[3]]
