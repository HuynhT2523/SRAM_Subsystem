class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    sram_env        env;
    sram_config		cfg;
    base_sequence   seq;

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = sram_env::type_id::create("env", this);
        cfg = sram_config::type_id::create("cfg");
        seq = base_sequence::type_id::create("seq");

        assert(cfg.randomize());
        cfg.print();
        uvm_config_db#(sram_config)::set(null, "*", "m_cfg", cfg);
    endfunction

    virtual function void end_of_elaboration_phase (uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.agt_act.seqr);
        phase.drop_objection(this);
        phase.phase_done.set_drain_time(this, 5000);
    endtask

    function void report_phase(uvm_phase phase);
        uvm_report_server svr;
        super.report_phase(phase);
        svr = uvm_report_server::get_server();
        if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
        `uvm_info(get_type_name(), "=======================================", UVM_NONE)
        `uvm_info(get_type_name(), "====           TEST FAIL           ====", UVM_NONE)
        `uvm_info(get_type_name(), "=======================================", UVM_NONE)
        end else begin
        `uvm_info(get_type_name(), "=======================================", UVM_NONE)
        `uvm_info(get_type_name(), "====           TEST PASS           ====", UVM_NONE)
        `uvm_info(get_type_name(), "=======================================", UVM_NONE)
        end
    endfunction
  
endclass