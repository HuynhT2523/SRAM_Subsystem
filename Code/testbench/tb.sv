`include "sram_pkg.sv"
`include "test_pkg.sv"

module tb;
    import uvm_pkg::*;
    import test_pkg::*;

    sram_if sram_if();

    sram_subsystem DUT (
        .hclk       (sram_if.clk),
        .n_hreset   (sram_if.n_hreset),
        .hsel       (sram_if.hsel),
        .haddr      (sram_if.haddr),
        .htrans     (sram_if.htrans),
        .hsize      (sram_if.hsize),
        .hwrite     (sram_if.hwrite),
        .hwdata     (sram_if.hwdata),
        .hrdata     (sram_if.hrdata),
        .hready     (sram_if.hready),
        .hresp      (sram_if.hresp)
    );

    initial begin
        sram_if.hclk_setup = 0;
        forever #5 sram_if.hclk_setup = ~sram_if.hclk_setup;
    end

    assign #2 sram_if.hclk      = sram_if.hclk_setup;
    assign #1 sram_if.hclk_hold = sram_if.hclk;

    initial begin
        uvm_config_db#(virtual sram_if)::set(uvm_root:get(),"*","vif",sram_if);
        run_test();
    end

    initial begin
        $display("Dumping waveform in TRN format");
        $recordfile("waveform.trn");
        $recordvars();
    end
endmodule