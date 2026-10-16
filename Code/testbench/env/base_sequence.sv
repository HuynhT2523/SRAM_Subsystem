class base_sequence extends uvm_sequence #(sram_item);
    `uvm_object_utils(base_sequence)

    sram_sequencer seqr;

    function new(string name = "base_sequence");
    super.new(name);
    endfunction

    task pre_body();
    if(!$cast(seqr, get_sequencer()))
        `uvm_fatal(get_type_name(), "Not cast sequencer");
    seqr.cfg.print();
    endtask

    virtual task body();
    // T.B.D
    endtask

    task ISSUE_CMD(logic [2:0] cmd, logic [1:0] htrans = 0, logic [2:0] hsize = 0, logic [31:0] haddr = 0, logic [31:0] hwdata = 0, bit continuous = 0, int num_clk = 0);
        req = sram_item::type_id::create("req");
        start_item(req);
        req.cmd = cmd;
        req.htrans = htrans;
        req.hsize = hsize;    
        req.haddr = haddr;
        req.hwdata = hwdata;
        req.continuous = continuous;
        req.num_clk = num_clk;
        finish_item(req);
        `uvm_info("[SEQ]", "End of one request", UVM_LOW);
    endtask

    task ISSUE_RESET(int num_clk = 1);
        ISSUE_CMD(3'b000, , , , , , num_clk);
    endtask

    task ISSUE_RESET_WR(logic [1:0] htrans, logic [2:0] hsize, logic [31:0] haddr, logic [31:0] hwdata, bit continuous = 0, int num_clk = 1);
        ISSUE_CMD(3'b011, htrans, hsize, haddr, hwdata, continuous, num_clk);
    endtask

    task ISSUE_RESET_RD(logic [1:0] htrans, logic [2:0] hsize, logic [31:0] haddr, bit continuous = 0, int num_clk = 1);
        ISSUE_CMD(3'b010, htrans, hsize, haddr, , continuous, num_clk);
    endtask

    task ISSUE_WR(logic [1:0] htrans, logic [2:0] hsize, logic [31:0] haddr, logic [31:0] hwdata, bit continuous = 0, int num_clk = 1);
        ISSUE_CMD(3'b111, htrans, hsize, haddr, hwdata, continuous, num_clk);
    endtask

    task ISSUE_RD(logic [1:0] htrans, logic [2:0] hsize, logic [31:0] haddr, bit continuous = 0, int num_clk = 1);
        ISSUE_CMD(3'b110, htrans, hsize, haddr, , continuous , num_clk);
    endtask

    task ISSUE_WR_INVALID(logic [1:0] htrans, logic [2:0] hsize, logic [31:0] haddr, logic [31:0] hwdata, bit continuous = 0, int num_clk = 1);
        ISSUE_CMD(3'b101, htrans, hsize, haddr, hwdata, continuous, num_clk);
    endtask

    task ISSUE_RD_INVALID(logic [1:0] htrans, logic [2:0] hsize, logic [31:0] haddr, bit continuous = 0, int num_clk = 1);
        ISSUE_CMD(3'b100, htrans, hsize, haddr, , continuous , num_clk);
    endtask

endclass