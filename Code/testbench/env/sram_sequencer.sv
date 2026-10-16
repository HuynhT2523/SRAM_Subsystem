class sram_sequencer extends uvm_sequencer #(sram_item);
    `uvm_component_utils(sram_sequencer)

    sram_config cfg;

    function new(string name = "sram_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(sram_config)::get(this,"", "m_cfg", cfg))
            `uvm_fatal(get_type_name(), "Not get sram_config");
    endfunction
  
endclass