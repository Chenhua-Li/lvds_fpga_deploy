# 为综合文件集 sources_1 设置宏定义
set_property verilog_define {FPGA} [get_filesets sources_1]

# 为仿真文件集 sim_1 设置宏定义
set_property verilog_define {FPGA} [get_filesets sim_1]