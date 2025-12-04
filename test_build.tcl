# Use hardware_test as top module
set_property top hardware_test [current_fileset]
update_compile_order -fileset sources_1
