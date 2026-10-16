 class sram_agent extends uvm_agent;
    `uvm_component_utils(sram_agent);
    
    sram_driver			drv;
    sram_sequencer		seqr;
    sram_monitor_active	mon_act;
    sram_monitor_passive	mon_pas;
    sram_vip				vip;
    sram_coverage			cov;
    
    function new(string name = "sram_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(get_is_active() == UVM_ACTIVE) begin
        drv	= sram_driver::type_id::create("drv", this);
        seqr	= sram_sequencer::type_id::create("seqr", this);
        vip	= sram_vip::type_id::create("vip", this);
        cov	= sram_coverage::type_id::create("cov", this);
        
        mon_act	= sram_monitor_active::type_id::create("mon_act", this);
        end
        else begin
        mon_pas	= sram_monitor_passive::type_id::create("mon_pas", this);
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(get_is_active() == UVM_ACTIVE) begin
        drv.seq_item_port.connect(seqr.seq_item_export);
        mon_act.mon_act_port.connect(vip.analysis_export);
        vip.cov_port.connect(cov.analysis_export);
        end
    //     else begin
    //       mon_pas.mon_pas_port.connect(vip.analysis_export);
    //     end
    endfunction
endclass