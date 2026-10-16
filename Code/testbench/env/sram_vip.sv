class sram_vip extends base_vip #(sram_item, sram_item);
    `uvm_component_utils(sram_vip)
    
    virtual sram_if vif;
    
    uvm_analysis_port #(sram_item) cov_port;
    
    logic [31:0] sram_mem [0:(1<<18)-1];
    
    logic [31:0] buff_addr;
    logic [2:0] buff_hsize;
    
    typedef enum logic [2:0] {
        RESET,
        ADDR_PHASE,
        WR_DATA_PHASE,
        RD_DATA_PHASE
    } fsm_state;
    
    fsm_state phase, next_phase;
    
    function new(string name = "sram_vip", uvm_component parent = null);
        super.new(name, parent);
        cov_port = new("cov_port", this);

        buff_addr   = 0;
        buff_hsize  = 0;

        phase       = ADDR_PHASE;
        next_phase	= ADDR_PHASE;
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual sram_if) :: get(this, "", "vif", vif))
        `uvm_fatal(get_type_name(), "Not set vif at top level");
    endfunction
    
    task translate();
        get_item(ib);
        
        if(!ib.cmd[2]) begin
        phase	= RESET;
        end
        else begin
        phase = next_phase;
        end
        
        case(phase)
        RESET: begin
            foreach(sram_mem[i]) sram_mem[i] = 'x;
            next_phase = ADDR_PHASE;
        end
        
        ADDR_PHASE: begin
            if(ib.htrans == 2'b10 && ib.hsize < 3) begin	// nonseq
            case(ib.cmd)					// {hreset, hsel, hwrite}
                3'b110: begin // read
                ob.copy(ib);
                next_phase	= RD_DATA_PHASE;
                end
                3'b111: begin // write
                buff_addr		= ib.haddr;
                buff_hsize	= ib.hsize;
                next_phase	= WR_DATA_PHASE;
                end
                default: next_phase = ADDR_PHASE;
            endcase
            end
            else begin
            next_phase = ADDR_PHASE;
            end
        end
        
        WR_DATA_PHASE: begin
            if(ib.cmd[1] && ib.hready) begin
            SRAM_WRITE(buff_addr[19:2], buff_addr[1:0], buff_hsize, ib.hwdata);
            `uvm_info("VIP", $sformatf("WRITE: addr=0x%0h, hwdata=0x%0h", ib.haddr, ib.hwdata), UVM_LOW)
            if(ib.htrans == 2'b10 && ib.hsize < 3) begin
                case(ib.cmd)
                3'b110: begin // read
                    ob.copy(ib);
                    next_phase	= RD_DATA_PHASE;
                end
                3'b111: begin // write
                    buff_addr	= ib.haddr;
                    buff_hsize	= ib.hsize;
                    next_phase	= WR_DATA_PHASE;
                end
                default: next_phase = ADDR_PHASE;
                endcase
            end
            else begin
                next_phase = ADDR_PHASE;
            end
            end
        end
        
        RD_DATA_PHASE: begin
            if(ib.cmd[1] && ib.hready) begin
            ob.hrdata = sram_mem[ob.haddr[19:2]];
            put_item(ob);
            `uvm_info("VIP", $sformatf("READ: addr=0x%0h, hrdata=0x%0h", ob.haddr, ob.hrdata), UVM_LOW)
            
            if(ib.htrans == 2'b10 && ib.hsize < 3) begin
                case(ib.cmd)
                    3'b110: begin // read
                    ob.copy(ib);
                    next_phase	= RD_DATA_PHASE;
                    end
                    3'b111: begin // write
                    buff_addr	= ib.haddr;
                    buff_hsize	= ib.hsize;
                    next_phase	= WR_DATA_PHASE;
                    end
                    default: next_phase = ADDR_PHASE;
                endcase
                end
                else begin
                next_phase = ADDR_PHASE;
                end
            end
            else begin
            next_phase = RD_DATA_PHASE;
            end
        end
        endcase
        
        vif.phase = phase;
        
        case(phase)
        RESET: begin
            cov_port.write(ib);
        end
        ADDR_PHASE: begin
            if(ib.htrans == 2'b10 && ib.hsize < 3) begin
            cov_port.write(ib);
            end
        end
        WR_DATA_PHASE: begin
            if(ib.hready) cov_port.write(ib);
        end
        RD_DATA_PHASE: begin
            if(ib.cmd[1] && ib.hready) cov_port.write(ob);
        end
        endcase
    endtask
    
    //=== SRAM MEMORY ======
    task SRAM_WRITE(
        input logic [17:0]	addr,
        input logic [1:0]	offset,
        input logic [2:0]	hsize,
        input logic [31:0]	wdata
    );
        case(hsize)
        3'b000: begin	// byte
            case(offset)
            2'b00: sram_mem[addr][7:0]   = wdata[7:0];
            2'b01: sram_mem[addr][15:8]  = wdata[15:8];
            2'b10: sram_mem[addr][23:16] = wdata[23:16];
            2'b11: sram_mem[addr][31:24] = wdata[31:24];
            endcase
        end
        
        3'b001: begin	// halfword
            if(offset[1] == 1'b0) begin
            sram_mem[addr][15:0]  = wdata[15:0];
            end
            else begin
            sram_mem[addr][31:16] = wdata[31:16];
            end
        end
        
        3'b010: begin // word
            sram_mem[addr] = wdata;
        end
        endcase
    endtask
endclass