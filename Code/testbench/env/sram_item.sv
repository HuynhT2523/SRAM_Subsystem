class sram_item extends uvm_sequence_item;
    logic [2:0]     cmd;    // {hreset, hsel, hwrite}
    logic [1:0]     htrans;
    logic [2:0]     hsize;
    logic [31:0]    haddr;  // addr[31:20]=0; addr[19:2]=sram_addr; addr[1:0]=address offset
    int num_clk;

    // Data
    logic [31:0] hwdata;
    logic [31:0] hrdata;

    // Continuous
    bit continuous;

    // Output
    bit hready;

    `uvm_object_utils_begin(sram_item)
        `uvm_field_int(cmd			, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(htrans		, UVM_ALL_ON)
        `uvm_field_int(hsize		, UVM_ALL_ON)
        `uvm_field_int(haddr		, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(hwdata		, UVM_NOCOMPARE)
        `uvm_field_int(hrdata		, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(num_clk		, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(continuous	, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(hready	    , UVM_ALL_ON | UVM_BIN)
    `uvm_object_utils_end
endclass