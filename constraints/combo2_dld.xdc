################################################################################
## Constraints File for Combo 2 DLD Board (Correct Pinout)
## Spartan-7 xc7s75fgga484-1
## Based on actual Combo II-DLD-Base pinout
################################################################################

## Clock Signal (using USER_Clock1)
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Reset Button (KEY01)
set_property -dict { PACKAGE_PIN K4 IOSTANDARD LVCMOS33 } [get_ports rst]

## Button Inputs
## Start Button (KEY02)
set_property -dict { PACKAGE_PIN N8 IOSTANDARD LVCMOS33 } [get_ports btn_start]
## Confirm Button (KEY03)
set_property -dict { PACKAGE_PIN N4 IOSTANDARD LVCMOS33 } [get_ports btn_confirm]
## Back Button (KEY04)
set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS33 } [get_ports btn_back]

## Number Buttons 1-8 (KEY05-KEY12)
set_property -dict { PACKAGE_PIN P6 IOSTANDARD LVCMOS33 } [get_ports {btn_num[0]}]
set_property -dict { PACKAGE_PIN N6 IOSTANDARD LVCMOS33 } [get_ports {btn_num[1]}]
set_property -dict { PACKAGE_PIN L5 IOSTANDARD LVCMOS33 } [get_ports {btn_num[2]}]
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports {btn_num[3]}]
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports {btn_num[4]}]
set_property -dict { PACKAGE_PIN L7 IOSTANDARD LVCMOS33 } [get_ports {btn_num[5]}]
set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports {btn_num[6]}]
set_property -dict { PACKAGE_PIN K6 IOSTANDARD LVCMOS33 } [get_ports {btn_num[7]}]

## DIP Switch
## DIP_SW1 for reset
set_property -dict { PACKAGE_PIN Y1 IOSTANDARD LVCMOS33 } [get_ports dip_reset]

## Speed Select Switch (DIP_SW2, DIP_SW3)
set_property -dict { PACKAGE_PIN W3 IOSTANDARD LVCMOS33 } [get_ports {speed_select[0]}]
set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports {speed_select[1]}]

## LED Array (8 LEDs - LED_D1 to LED_D8)
set_property -dict { PACKAGE_PIN L4 IOSTANDARD LVCMOS33 } [get_ports {led_array[0]}]
set_property -dict { PACKAGE_PIN M4 IOSTANDARD LVCMOS33 } [get_ports {led_array[1]}]
set_property -dict { PACKAGE_PIN M2 IOSTANDARD LVCMOS33 } [get_ports {led_array[2]}]
set_property -dict { PACKAGE_PIN N7 IOSTANDARD LVCMOS33 } [get_ports {led_array[3]}]
set_property -dict { PACKAGE_PIN M7 IOSTANDARD LVCMOS33 } [get_ports {led_array[4]}]
set_property -dict { PACKAGE_PIN M3 IOSTANDARD LVCMOS33 } [get_ports {led_array[5]}]
set_property -dict { PACKAGE_PIN M1 IOSTANDARD LVCMOS33 } [get_ports {led_array[6]}]
set_property -dict { PACKAGE_PIN N5 IOSTANDARD LVCMOS33 } [get_ports {led_array[7]}]

## RGB LED (F_LED1)
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 } [get_ports rgb_r]
set_property -dict { PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports rgb_g]
set_property -dict { PACKAGE_PIN U3 IOSTANDARD LVCMOS33 } [get_ports rgb_b]

## LCD 16x2 Interface (4-bit mode using D4-D7)
set_property -dict { PACKAGE_PIN G6 IOSTANDARD LVCMOS33 } [get_ports lcd_rs]
set_property -dict { PACKAGE_PIN D6 IOSTANDARD LVCMOS33 } [get_ports lcd_rw]
set_property -dict { PACKAGE_PIN A6 IOSTANDARD LVCMOS33 } [get_ports lcd_e]
## LCD Data pins (using upper 4 bits: TLCD_D4-D7)
set_property -dict { PACKAGE_PIN A2 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[0]}]
set_property -dict { PACKAGE_PIN C5 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[1]}]
set_property -dict { PACKAGE_PIN C1 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[2]}]
set_property -dict { PACKAGE_PIN D1 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[3]}]

## 8-Array 7-Segment Display
## Cathodes (segments a-g + dp)
set_property -dict { PACKAGE_PIN F1 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[0]}]
set_property -dict { PACKAGE_PIN F5 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[1]}]
set_property -dict { PACKAGE_PIN E2 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[2]}]
set_property -dict { PACKAGE_PIN E4 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[3]}]
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[4]}]
set_property -dict { PACKAGE_PIN J3 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[5]}]
set_property -dict { PACKAGE_PIN J7 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[6]}]
set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 } [get_ports {seg_array_cathode[7]}]

## Anodes (digit select 0-7)
set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[0]}]
set_property -dict { PACKAGE_PIN H6 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[1]}]
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[2]}]
set_property -dict { PACKAGE_PIN G3 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[3]}]
set_property -dict { PACKAGE_PIN L6 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[4]}]
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[5]}]
set_property -dict { PACKAGE_PIN K3 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[6]}]
set_property -dict { PACKAGE_PIN K5 IOSTANDARD LVCMOS33 } [get_ports {seg_array_anode[7]}]

## 2-Digit 7-Segment Display (Timer)
## Cathodes (segments a-g + dp) - Using remaining free pins
## TODO: Verify these pins match your board's 2-digit 7-segment connections
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_cathode[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_cathode[1]}]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_cathode[2]}]
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_cathode[3]}]
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_cathode[4]}]
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_cathode[5]}]
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_cathode[6]}]
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_cathode[7]}]

## Anodes (digit select 0-1)
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_anode[0]}]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports {seg_timer_anode[1]}]

## Piezo Buzzer
set_property -dict { PACKAGE_PIN Y21 IOSTANDARD LVCMOS33 } [get_ports piezo]

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
