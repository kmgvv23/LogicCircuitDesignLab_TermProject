## memory_game_constraints.xdc
## Xilinx Vivado constraints file for COMBO-2 board (Spartan-7 XC7S75-FGG484-1)

## Clock (100 MHz)
set_property PACKAGE_PIN M8 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk -waveform {0 5} [get_ports clk]

## DIP Switches
set_property PACKAGE_PIN Y1 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN W3 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN U2 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN T1 [get_ports {dip_sw[3]}]
set_property PACKAGE_PIN W4 [get_ports {dip_sw[4]}]
set_property PACKAGE_PIN W1 [get_ports {dip_sw[5]}]
set_property PACKAGE_PIN V4 [get_ports {dip_sw[6]}]
set_property PACKAGE_PIN U4 [get_ports {dip_sw[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {dip_sw[*]}]

## Button Switches
set_property PACKAGE_PIN K4 [get_ports {btn[0]}]
set_property PACKAGE_PIN N8 [get_ports {btn[1]}]
set_property PACKAGE_PIN N4 [get_ports {btn[2]}]
set_property PACKAGE_PIN N1 [get_ports {btn[3]}]
set_property PACKAGE_PIN P6 [get_ports {btn[4]}]
set_property PACKAGE_PIN N6 [get_ports {btn[5]}]
set_property PACKAGE_PIN L5 [get_ports {btn[6]}]
set_property PACKAGE_PIN J2 [get_ports {btn[7]}]
set_property PACKAGE_PIN K2 [get_ports {btn[8]}]
set_property PACKAGE_PIN L7 [get_ports {btn[9]}]
set_property PACKAGE_PIN L1 [get_ports {btn[10]}]
set_property PACKAGE_PIN K6 [get_ports {btn[11]}]

set_property IOSTANDARD LVCMOS33 [get_ports {btn[*]}]

## LEDs
set_property PACKAGE_PIN L4 [get_ports {led[0]}]
set_property PACKAGE_PIN M4 [get_ports {led[1]}]
set_property PACKAGE_PIN M2 [get_ports {led[2]}]
set_property PACKAGE_PIN N7 [get_ports {led[3]}]
set_property PACKAGE_PIN M7 [get_ports {led[4]}]
set_property PACKAGE_PIN M3 [get_ports {led[5]}]
set_property PACKAGE_PIN M1 [get_ports {led[6]}]
set_property PACKAGE_PIN N5 [get_ports {led[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## Single 7-Segment Display (Timer)
set_property PACKAGE_PIN P1 [get_ports {seg_timer_data[0]}]
set_property PACKAGE_PIN P3 [get_ports {seg_timer_data[1]}]
set_property PACKAGE_PIN P7 [get_ports {seg_timer_data[2]}]
set_property PACKAGE_PIN N3 [get_ports {seg_timer_data[3]}]
set_property PACKAGE_PIN T5 [get_ports {seg_timer_data[4]}]
set_property PACKAGE_PIN R2 [get_ports {seg_timer_data[5]}]
set_property PACKAGE_PIN R4 [get_ports {seg_timer_data[6]}]
set_property PACKAGE_PIN R6 [get_ports {seg_timer_data[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {seg_timer_data[*]}]

## 8-Array 7-Segment Display (Input View)
set_property PACKAGE_PIN F1 [get_ports {seg_arr_data[0]}]
set_property PACKAGE_PIN F5 [get_ports {seg_arr_data[1]}]
set_property PACKAGE_PIN E2 [get_ports {seg_arr_data[2]}]
set_property PACKAGE_PIN E4 [get_ports {seg_arr_data[3]}]
set_property PACKAGE_PIN J1 [get_ports {seg_arr_data[4]}]
set_property PACKAGE_PIN J3 [get_ports {seg_arr_data[5]}]
set_property PACKAGE_PIN J7 [get_ports {seg_arr_data[6]}]
set_property PACKAGE_PIN H2 [get_ports {seg_arr_data[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {seg_arr_data[*]}]

set_property PACKAGE_PIN H4 [get_ports {seg_arr_sel[0]}]
set_property PACKAGE_PIN H6 [get_ports {seg_arr_sel[1]}]
set_property PACKAGE_PIN G1 [get_ports {seg_arr_sel[2]}]
set_property PACKAGE_PIN G3 [get_ports {seg_arr_sel[3]}]
set_property PACKAGE_PIN L6 [get_ports {seg_arr_sel[4]}]
set_property PACKAGE_PIN K1 [get_ports {seg_arr_sel[5]}]
set_property PACKAGE_PIN K3 [get_ports {seg_arr_sel[6]}]
set_property PACKAGE_PIN K5 [get_ports {seg_arr_sel[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {seg_arr_sel[*]}]

## Text LCD
set_property PACKAGE_PIN A4 [get_ports {lcd_data[0]}]
set_property PACKAGE_PIN B2 [get_ports {lcd_data[1]}]
set_property PACKAGE_PIN C3 [get_ports {lcd_data[2]}]
set_property PACKAGE_PIN D4 [get_ports {lcd_data[3]}]
set_property PACKAGE_PIN A2 [get_ports {lcd_data[4]}]
set_property PACKAGE_PIN C5 [get_ports {lcd_data[5]}]
set_property PACKAGE_PIN C1 [get_ports {lcd_data[6]}]
set_property PACKAGE_PIN D1 [get_ports {lcd_data[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {lcd_data[*]}]

set_property PACKAGE_PIN A6 [get_ports lcd_e]
set_property PACKAGE_PIN G6 [get_ports lcd_rs]
set_property PACKAGE_PIN D6 [get_ports lcd_rw]

set_property IOSTANDARD LVCMOS33 [get_ports lcd_e]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rs]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rw]

## Piezo Buzzer
set_property PACKAGE_PIN Y21 [get_ports piezo]
set_property IOSTANDARD LVCMOS33 [get_ports piezo]

## Full Color LED (RGB LED 1)
set_property PACKAGE_PIN T2 [get_ports rgb_r]
set_property PACKAGE_PIN U5 [get_ports rgb_g]
set_property PACKAGE_PIN U3 [get_ports rgb_b]

set_property IOSTANDARD LVCMOS33 [get_ports rgb_r]
set_property IOSTANDARD LVCMOS33 [get_ports rgb_g]
set_property IOSTANDARD LVCMOS33 [get_ports rgb_b]
