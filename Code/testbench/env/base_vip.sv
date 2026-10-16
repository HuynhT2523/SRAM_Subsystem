class base_vip #(type in_item = uvm_sequence_item, type out_item = uvm_sequence_item) extends uvm_component;
    typedef base_vip#(in_item, out_item) this_type;
    `uvm_component_param_utils(this_type)
    
    uvm_analysis_port   #(out_item)   analysis_port;
    uvm_analysis_export #(in_item)    analysis_export;
    uvm_tlm_analysis_fifo #(in_item)  vip_fifo;
    in_item  ib;  // Handle the input item
    out_item ob;  // Handle the output item
    
    function new(string name = "base_vip", uvm_component parent = null);
        super.new(name, parent);
        analysis_port   = new("analysis_port", this);
        analysis_export = new("analysis_export", this);
        vip_fifo = new("vip_fifo", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        analysis_export.connect(vip_fifo.analysis_export);
    endfunction 
    
    function void start_of_simulation_phase(uvm_phase phase);  
        super.start_of_simulation_phase(phase);
        ib = new("ib");
        ob = new("ob");
    endfunction
        
    task run_phase(uvm_phase phase);
        forever translate();
    endtask
    
    virtual task translate(); // Implement reference model
    endtask
    
    task get_item (output in_item t); //Get item from VIP fifo
        vip_fifo.get(t);
    endtask
    
    task put_item (input out_item t); //Clone item before putting item
        out_item u;
        void'($cast(u, t.clone()));
        analysis_port.write(u);
    endtask
endclass