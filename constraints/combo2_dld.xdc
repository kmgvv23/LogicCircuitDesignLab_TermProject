################################################################################
## Constraints File Template for Combo 2 DLD Board
## Spartan-7 xc7s75fgga484-1
##
## IMPORTANT: This is a TEMPLATE file. You must modify the pin assignments
## according to your actual Combo 2 DLD board pinout.
## Refer to your board's user manual for correct pin locations.
################################################################################

## Clock Signal (assumed 100MHz)
## TODO: Update with actual clock pin
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Reset Button
## TODO: Update with actual reset button pin
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports rst]

## Button Inputs
## Start Button
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports btn_start]
## Confirm Button
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports btn_confirm]
## Back Button
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports btn_back]

## Number Buttons (1-8)
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {btn_num[0]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {btn_num[1]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {btn_num[2]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {btn_num[3]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {btn_num[4]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {btn_num[5]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {btn_num[6]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {btn_num[7]}]

## DIP Switch
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports dip_reset]

## Speed Select Switch (2 bits)
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {speed_select[0]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {speed_select[1]}]

## LED Array (8 LEDs)
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {led_array[0]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {led_array[1]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {led_array[2]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {led_array[3]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {led_array[4]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {led_array[5]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {led_array[6]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {led_array[7]}]

## RGB LED
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports rgb_r]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports rgb_g]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports rgb_b]

## LCD 16x2 Interface (4-bit mode)
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports lcd_rs]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports lcd_rw]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports lcd_e]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {lcd_data[0]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {lcd_data[1]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {lcd_data[2]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {lcd_data[3]}]

## 8-Array 7-Segment Display
## Cathodes (segments)
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[0]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[1]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[2]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[3]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[4]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[5]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[6]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[7]}]

## Anodes (digit select)
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[0]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[1]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[2]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[3]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[4]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[5]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[6]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[7]}]

## Timer 7-Segment Display (2 digits)
## Cathodes (segments)
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer[0]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer[1]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer[2]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer[3]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer[4]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer[5]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer[6]}]

## Anodes (digit select)
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer_anode[0]}]
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports {seg_timer_anode[1]}]

## Piezo Buzzer
set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS33 } [get_ports piezo]

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
