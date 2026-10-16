class sram_monitor_active extends uvm_monitor;
    `uvm_component_utils(sram_monitor_active)
    
    virtual sram_if vif;
    uvm_analysis_port #(sram_item) mon_act_port;
    sram_item mon_act_item;
        
    function new(string name = "sram_monitor_active", uvm_component parent = null);
        super.new(name, parent);
        mon_act_port = new("mon_act_port", this);
        mon_act_item = new();
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual sram_if)::get(this, "", "vif", vif))
        `uvm_fatal(get_type_name(), "No virtual interface set for sram_monitor_active");
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin      
        @(posedge vif.hclk or negedge vif.n_hreset);
        if(!vif.n_hreset || vif.hsel) begin
            mon_act_item.cmd	= {vif.n_hreset, vif.hsel, vif.hwrite};
            mon_act_item.htrans	= vif.htrans;
            mon_act_item.haddr	= vif.haddr;
            mon_act_item.hsize	= vif.hsize;
            mon_act_item.hwdata	= vif.hwdata;
            mon_act_item.hready	= vif.hready;
            mon_act_port.write(mon_act_item);
        end
        end
    endtask
endclass