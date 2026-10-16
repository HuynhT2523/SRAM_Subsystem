class sram_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(sram_scoreboard)

    uvm_tlm_analysis_fifo #(sram_item) exp_fifo; // agent active	(VIP, expected)
    uvm_tlm_analysis_fifo #(sram_item) act_fifo; // agent passive (DUT, actual)

    function new(string name = "sram_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        exp_fifo = new("exp_fifo", this);
        act_fifo = new("act_fifo", this);
    endfunction

    task run_phase(uvm_phase phase);
        sram_item exp_item, act_item;

        forever begin
        fork
            begin
            exp_fifo.get(exp_item);
            act_fifo.get(act_item);
            end
        join
        
        if(act_item.cmd == 3'b110) begin
            case(act_item.hsize)
            3'b000: begin
                case(act_item.haddr[1:0])
                2'b00: begin
                    if(exp_item.hrdata[7:0] !== act_item.hrdata[7:0]) begin
                    `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h: exp=0x%0h act=0x%0h", act_item.haddr, exp_item.hrdata[7:0], act_item.hrdata[7:0]))
                    end
                    else begin
                    `uvm_info("[SCB]", $sformatf("PASS: addr=0x%0h data=0x%0h", exp_item.haddr, act_item.hrdata[7:0]), UVM_LOW)
                    end
                end
                2'b01: begin
                    if(exp_item.hrdata[15:8] !== act_item.hrdata[15:8]) begin
                    `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h: exp=0x%0h act=0x%0h", act_item.haddr, exp_item.hrdata[15:8], act_item.hrdata[15:8]))
                    end
                    else begin
                    `uvm_info("[SCB]", $sformatf("PASS: addr=0x%0h data=0x%0h", exp_item.haddr, act_item.hrdata[15:8]), UVM_LOW)
                    end
                end
                2'b10: begin
                    if(exp_item.hrdata[23:16] !== act_item.hrdata[23:16]) begin
                    `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h: exp=0x%0h act=0x%0h", act_item.haddr, exp_item.hrdata[23:16], act_item.hrdata[23:16]))
                    end
                    else begin
                    `uvm_info("[SCB]", $sformatf("PASS: addr=0x%0h data=0x%0h", exp_item.haddr, act_item.hrdata[23:16]), UVM_LOW)
                    end
                end
                2'b11: begin
                    if(exp_item.hrdata[31:24] !== act_item.hrdata[31:24]) begin
                    `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h: exp=0x%0h act=0x%0h", act_item.haddr, exp_item.hrdata[31:24], act_item.hrdata[31:24]))
                    end
                    else begin
                    `uvm_info("[SCB]", $sformatf("PASS: addr=0x%0h data=0x%0h", exp_item.haddr, act_item.hrdata[31:24]), UVM_LOW)
                    end
                end
                endcase
            end
            3'b001: begin
                if(act_item.haddr[1]) begin
                if(exp_item.hrdata[15:0] !== act_item.hrdata[15:0]) begin
                    `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h: exp=0x%0h act=0x%0h", act_item.haddr, exp_item.hrdata[15:0], act_item.hrdata[15:0]))
                end
                else begin
                    `uvm_info("[SCB]", $sformatf("PASS: addr=0x%0h data=0x%0h", exp_item.haddr, act_item.hrdata[15:0]), UVM_LOW)
                end
                end
                else begin
                if(exp_item.hrdata[31:16] !== act_item.hrdata[31:16]) begin
                    `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h: exp=0x%0h act=0x%0h", act_item.haddr, exp_item.hrdata[31:16], act_item.hrdata[31:16]))
                end
                else begin
                    `uvm_info("[SCB]", $sformatf("PASS: addr=0x%0h data=0x%0h", exp_item.haddr, act_item.hrdata[31:16]), UVM_LOW)
                end
                end
            end
            3'b010: begin
                if(exp_item.hrdata[31:0] !== act_item.hrdata[31:0]) begin
                `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h: exp=0x%0h act=0x%0h", act_item.haddr, exp_item.hrdata[31:0], act_item.hrdata[31:0]))
                end
                else begin
                `uvm_info("[SCB]", $sformatf("PASS: addr=0x%0h data=0x%0h", exp_item.haddr, act_item.hrdata[31:0]), UVM_LOW)
                end
            end
            endcase
        end
        end
    endtask
endclass