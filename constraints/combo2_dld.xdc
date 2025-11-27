################################################################################
## Constraints File for Combo 2 DLD Board
## Spartan-7 xc7s75fgga484-1
## Generated from board pinout specification
################################################################################

## Clock Signal (100MHz)
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Reset Button (using BTNC as reset)
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 } [get_ports rst]

## Button Inputs
## Start Button (BTNU)
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports btn_start]
## Confirm Button (BTNR)
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports btn_confirm]
## Back Button (BTNL)
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports btn_back]

## Number Buttons 1-8 (BTN0-BTN7)
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports {btn_num[0]}]
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports {btn_num[1]}]
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports {btn_num[2]}]
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports {btn_num[3]}]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {btn_num[4]}]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports {btn_num[5]}]
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports {btn_num[6]}]
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {btn_num[7]}]

## DIP Switch (using SW0 for reset)
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports dip_reset]

## Speed Select Switch (using SW1-SW2)
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {speed_select[0]}]
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {speed_select[1]}]

## LED Array (8 LEDs - LED0 to LED7)
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {led_array[0]}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {led_array[1]}]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {led_array[2]}]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {led_array[3]}]
set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports {led_array[4]}]
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports {led_array[5]}]
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {led_array[6]}]
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports {led_array[7]}]

## RGB LED (LED16)
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports rgb_r]
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 } [get_ports rgb_g]
set_property -dict { PACKAGE_PIN F6 IOSTANDARD LVCMOS33 } [get_ports rgb_b]

## LCD 16x2 Interface (4-bit mode)
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports lcd_rs]
set_property -dict { PACKAGE_PIN L17 IOSTANDARD LVCMOS33 } [get_ports lcd_rw]
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports lcd_e]
## LCD Data pins (using upper 4 bits: DB4-DB7)
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[0]}]
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[1]}]
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[2]}]
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[3]}]

## 8-Array 7-Segment Display
## Cathodes (segments a-g + dp)
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[0]}]
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[1]}]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[2]}]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[3]}]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[4]}]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[5]}]
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[6]}]
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[7]}]

## Anodes (digit select 0-7)
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[0]}]
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[1]}]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[2]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[3]}]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[4]}]
set_property -dict { PACKAGE_PIN T9 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[5]}]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[6]}]
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[7]}]

## Timer 7-Segment Display (using same 7-seg, controlled by different anodes)
## Cathodes (segments) - shared with main 7-seg
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {seg_timer[0]}]
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports {seg_timer[1]}]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {seg_timer[2]}]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {seg_timer[3]}]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {seg_timer[4]}]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports {seg_timer[5]}]
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {seg_timer[6]}]

## Timer Anodes (using last 2 digits of 7-seg array)
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_anode[0]}]
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_anode[1]}]

## Piezo Buzzer
set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVCMOS33 } [get_ports piezo]

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
