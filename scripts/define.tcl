set_property verilog_define {
    FPGA
} [current_fileset]
# <!-- current_fileset 一般是source_1即设计源文件, 需要对仿真区域也使用相同的宏定义可以将current_fileset改为get_filesets sim_1 -->