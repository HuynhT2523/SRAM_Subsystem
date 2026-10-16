interface sram_if;
    import uvm_pkg::*;

    // System clock
    logic hclk, hclk_setup, hclk_hold;

    // Control signal
    logic n_hreset;
    logic hsel;
    logic hwrite;
    logic [1:0]     htrans;
    logic [2:0]     hsize;
    logic [31:0]    haddr;

    // Data signal
    logic [31:0]    hwdata;
    logic [31:0]    hrdata;

    // Output signal
    logic hready;
    logic hresp;

    // State VIP
    logic [2:0] phase;

    // `include "sram_assertion.sv"
endinterface