class sram_driver extends uvm_driver #(sram_item);
    `uvm_component_utils(sram_driver)

    virtual sram_if vif;
    sram_item temp_queue[$];

    function new(string name = "sram_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual sram_if)::get(this, "", "vif", vif))
        `uvm_fatal("NO VIF", {"VIF must be set for: ", get_full_name(), ".vif"});
    endfunction

    task run_phase(uvm_phase phase);
        INIT();
        forever begin
        seq_item_port.get_next_item(req);
        //       fork
        //         RESET();
        DRIVE();
        //       join
        seq_item_port.item_done();
        end
    endtask

    task INIT();
        vif.n_hreset = 1;
        vif.hsel 	 = 0;
        vif.htrans 	 = 2'b00;
        vif.hsize 	 = 3'b010;
        vif.hwdata 	 = 0;
        vif.hwrite 	 = 0;
        temp_queue.delete();
        #200;
        vif.n_hreset = 0;
        #550;
        vif.n_hreset = 1;
        #100;
    endtask

    task DRIVE();
        fork
        // 	  RESET
        begin
            if(!req.cmd[2]) begin
            vif.n_hreset = req.cmd[2];
            temp_queue.delete();
            #(req.num_clk*100);
            vif.n_hreset = 1;
            end
        end

        begin
            sram_item cloned_item;
            $cast(cloned_item, req.clone());

            // ADDR PHASE
            @(posedge vif.hclk_setup);
            vif.hsel   = cloned_item.cmd[1];
            vif.htrans = cloned_item.htrans;
            vif.haddr  = cloned_item.haddr;
            vif.hwrite = cloned_item.cmd[0];
            vif.hsize  = cloned_item.hsize;
            temp_queue.push_back(cloned_item);

            // DATA PHASE
            if(cloned_item.continuous) begin
            fork
                begin
                sram_item data;
                @(posedge vif.hclk_setup);
                if(temp_queue.size() > 0) begin
                    data = temp_queue.pop_front();
                    if(data.cmd[0] == 1) vif.hwdata = data.hwdata;
                end

                end
            join_none
            
            while(!vif.hready) @(posedge vif.hclk_setup); // Nếu hready = 0 thì chờ 1 clk_setup chờ tới khi hready = 1
            end else begin
            sram_item data;
            wait(vif.hready);
            @(posedge vif.hclk_setup);
            if(temp_queue.size() > 0) begin
                data = temp_queue.pop_front();
                if(data.cmd[0] == 1) vif.hwdata = data.hwdata;
            end
            vif.htrans = 2'b00;
            vif.hwrite = 1'b0;
            end
        end
        join
    endtask

endclass