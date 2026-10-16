class sram_env extends uvm_env;
    `uvm_component_utils(sram_env)
    
    sram_agent		agt_act;
    sram_agent		agt_pas;
    sram_scoreboard	scb;
    
    function new(string name = "sram_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt_act	= sram_agent::type_id::create("agt_act", this);
        agt_pas	= sram_agent::type_id::create("agt_pas", this);
        scb	= sram_scoreboard::type_id::create("scb", this);
        
        set_config_int("agt_act", "is_active", UVM_ACTIVE);
        set_config_int("agt_pas", "is_active", UVM_PASSIVE);
    endfunction

    function void connect_phase(uvm_phase phase);
        agt_act.vip.analysis_port.connect(scb.exp_fifo.analysis_export);
        agt_pas.mon_pas.mon_pas_port.connect(scb.act_fifo.analysis_export);	
    endfunction
endclass