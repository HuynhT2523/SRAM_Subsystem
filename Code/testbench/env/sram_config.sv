class sram_config extends uvm_object;

    rand logic [2:0] cmd[];		// cmd = {n_hreset, hsel, hwrite}
    rand logic [1:0] htrans[];
    rand logic [2:0] hsize[];
    rand logic [31:0] haddr[];
    rand logic [31:0] hwdata[];
    rand bit continuous[];
    rand int num_clk[]; 

    `uvm_object_utils_begin(sram_config)
        `uvm_field_array_int(cmd        , UVM_ALL_ON | UVM_BIN)
        `uvm_field_array_int(htrans     , UVM_ALL_ON)
        `uvm_field_array_int(hsize      , UVM_ALL_ON)
        `uvm_field_array_int(haddr      , UVM_ALL_ON)
        `uvm_field_array_int(hwdata     , UVM_ALL_ON)
        `uvm_field_array_int(continuous , UVM_ALL_ON | UVM_BIN)
        `uvm_field_array_int(num_clk    , UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "sram_config");
        super.new(name);
    endfunction

    constraint cmd_c {
        soft cmd.size() inside {[2:5]};
        foreach(cmd[i]) soft cmd[i] inside {3'b100, 3'b011, 3'b010};
    }

    constraint htrans_c {
        solve cmd before htrans;
        htrans.size() == cmd.size();
        foreach(htrans[i]) soft htrans[i] == 2'b10;
    }

    constraint hsize_c {
        solve cmd before hsize;
        solve haddr before hsize;
        hsize.size() == cmd.size();
        
        foreach(hsize[i]) { 
            if(hsize[i] == 3'b000) {
                if(haddr[i][1:0] == 2'b00) {
                    hwdata[i][31:8] == 24'h0;
                } else if(haddr[i][1:0] == 2'b01) {
                    hwdata[i][31:16] == 16'h0;
                    hwdata[i][7:0] == 8'h0;
                } else if(haddr[i][1:0] == 2'b10) {
                    hwdata[i][31:24] == 8'h0;
                    hwdata[i][15:0] == 16'h0;
                } else {
                    hwdata[i][23:0] == 24'h0;
                }
            }
                
            else if(hsize[i] == 3'b001) {
                if(haddr[i][1:0] == 2'b00) {
                    hwdata[i][31:16] == 16'h0;
                } else if(haddr[i][1:0] == 2'b10) {
                    hwdata[i][15:0] == 16'h0;
                }
            }
                
            else {
                soft hsize[i] inside {3'b000, 3'b001, 3'b010};
            }
        }
    }

    constraint haddr_c {
        solve cmd before haddr;
        haddr.size() == cmd.size();
        foreach(haddr[i]) {
            soft haddr[i][31:20] == 12'h00;
            soft haddr[i][1:0] inside {2'b00, 2'b01, 2'b10, 2'b11};
            if(hsize[i] == 3'b001) {
                haddr[i][1:0] inside {2'b00, 2'b10};
            }
        }
    }
        
    //   constraint haddr_hsize_c {
    //     foreach(hsize[i]) {
    //       if(hsize[i] == 3'b001) {
    //         haddr[i][1:0] inside {2'b00, 2'b10};
    //       }
    //     }
    //   }

    constraint hwdata_c {
        solve cmd before hwdata;
        solve haddr before hwdata;
        solve hsize before hwdata;
        hwdata.size() == cmd.size();
    }

    constraint continuous_c {
        solve cmd before continuous;
        continuous.size() == cmd.size();
    }

    constraint numclk_c {
        solve cmd before num_clk;
        num_clk.size() == cmd.size();
        foreach(num_clk[i]) num_clk[i] == 1;
    }
      
endclass