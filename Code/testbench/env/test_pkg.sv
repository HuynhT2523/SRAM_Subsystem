package test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import sram_pkg::*;
    `include "base_test.sv"

    // Testcases
    `include "single_wr_rd_test.sv"
    `include "single_wr_then_rd_test.sv"
    `include "single_wr_multiple_test.sv"
    `include "single_rd_multiple_test.sv"
    `include "single_wr_invalid_test.sv"
    `include "single_rd_invalid_test.sv"
    `include "single_over_wr_rd_test.sv"

    `include "conti_wr_rd_test.sv"
    `include "conti_wr_then_rd_test.sv"
    `include "conti_wr_multi_test.sv"
    `include "conti_rd_multi_test.sv"
    `include "conti_over_wr_rd_test.sv"

    `include "single_conti_combine_test.sv"

    `include "htrans_idle_test.sv"

    `include "hsize_byte_test.sv"
    `include "hsize_halfword_test.sv"
    `include "hsize_word_test.sv"
    `include "hsize_combine_test.sv"
    `include "hsize_invalid_test.sv"

    `include "reset_wr_test.sv"
    `include "reset_rd_test.sv"
    `include "reset_while_wr_test.sv"
    `include "reset_while_rd_test.sv"
endpackage