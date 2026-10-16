class sram_monitor_passive extends uvm_monitor;
    `uvm_component_utils(sram_monitor_passive)

    virtual sram_if vif;
    uvm_analysis_port #(sram_item) mon_pas_port;
    sram_item mon_pas_item;
    
    bit rd_en;	// enable for transfer

    function new(string name = "sram_monitor_passive", uvm_component parent = null);
        super.new(name, parent);
        mon_pas_port = new("mon_pas_port", this);
        mon_pas_item = new();
        
        rd_en = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual sram_if)::get(this, "", "vif", vif))
        `uvm_fatal(get_type_name(), "No virtual interface set for sram_monitor_passive");
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
        @(posedge vif.hclk or negedge vif.n_hreset);
        if(!vif.n_hreset) begin
            rd_en = 0;
        end
        else begin
            if(vif.hsel && rd_en && vif.hready) begin
            mon_pas_item.hrdata	= vif.hrdata;
            mon_pas_port.write(mon_pas_item);
            
            rd_en = 0;
            end
            
            if(vif.hsel && !vif.hwrite && (vif.htrans == 2'b10) && (vif.hsize < 3) && !rd_en) begin
            mon_pas_item.cmd		= {vif.n_hreset, vif.hsel, vif.hwrite};
            mon_pas_item.htrans	= vif.htrans;
            mon_pas_item.hsize	= vif.hsize;
            mon_pas_item.haddr	= vif.haddr;
            
            rd_en = 1;
            end
        end
        end
    endtask
endclass