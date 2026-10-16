class sram_coverage extends uvm_subscriber #(sram_item);
    `uvm_component_utils(sram_coverage)

    sram_item cov_item;

    covergroup cg;
        option.per_instance = 1;
        option.name = "sram_coverage";

        // {hreset, hsel, hwrite}
        cp_cmd: coverpoint cov_item.cmd {
        bins reset	= {3'b000};
        bins read		= {3'b110};
        bins write	= {3'b111};
        }

        cp_htrans: coverpoint cov_item.htrans {
        bins idle		= {2'b00};
    //       bins busy		= {2'b01};
        bins nonseq	= {2'b10};
    //       bins seq		= {2'b11};
        }

        cp_hsize: coverpoint cov_item.hsize {
        bins bytes	= {3'b000};
        bins halfword = {3'b001};
        bins word		= {3'b010};
        }

        cp_haddr: coverpoint cov_item.haddr[19:2] {
        bins low	= {[0:1023]};
        bins mid	= {[1024:65535]};
        bins high = {[65536:(1<<18)-1]};
        }
        
        cp_hwdata: coverpoint cov_item.hwdata {
        bins min    = {32'h0000_0000};
        bins low    = {[32'h0000_0001:32'h0000_FFFF]};
        bins mid[3] = {[32'h0001_0000:32'h7FFF_FFFF]};
        bins high   = {[32'h8000_0000:32'hFFFE_FFFF]};
        bins max    = {32'hFFFF_FFFF};
        }

        // Cross coverage
        cr_cmd_hsize: cross cp_cmd, cp_hsize {
        ignore_bins hsize = binsof(cp_cmd.reset);
        }
        cr_cmd_htrans: cross cp_cmd, cp_htrans {
        ignore_bins htrans = binsof(cp_cmd.reset);
        }
        
        cr_cmd_hwdata: cross cp_cmd, cp_htrans, cp_hwdata {
        ignore_bins no_wr     = !binsof(cp_cmd.write);
        ignore_bins no_nonseq = !binsof(cp_htrans.nonseq);
        }
    endgroup

    function new(string name = "sram_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg = new();
    endfunction

    virtual function void write(sram_item t);
        cov_item = t;
        cg.sample();
    endfunction
endclass