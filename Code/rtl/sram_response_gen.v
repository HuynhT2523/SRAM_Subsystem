module sram_response_gen(
    input wire hclk,         // AHB Clock
    input wire n_hreset,     // AHB reset - Active low
    input wire hsel,         // AHB2APB select
    input wire [1:0] htrans, // Transfer type
    input wire [2:0] hsize,  // AHB Access type - byte, half-word, word
    input wire RWconflict,   // Read coinciding with 2nd stage of write

    output wire hready,       // Ready for new bus cycle from target slave
    output wire hresp,        // Response from the bridge
    output wire valid_access
);
    wire    size_error;
    wire    valid_access;
    wire    hready_RWconflict;    
    wire    sram_subs_access;
    wire    hready_error;
    reg     r_hresp_0;
    reg     r_hready;

    // Lower hready for one cycle of there is a Read's address phase coinciding 
    // with a write's data phase for the same mem group
    assign hready_RWconflict = RWconflict ?  1'b0 : 1'b1;

    // Flag error if access size is 64 bits or more
    // hsize [2:0]
    // 000 - 8 bit
    // 001 - 16 bit
    // 010 - 32 bit
    // 011 - 64 bit
    // 1xx > 64 bit
    // htrans [1:0]
    // 00 = idle
    // 01 = busy
    // 10 = non-seq
    // 11 = seq
    // hresp
    // 00 = OK
    // 01 = Error
    // 10 = Retry
    // 11 = Split

    // Access > 32 bit is error
    assign size_error = ( hsize[2] | (hsize[1] & hsize[0]) ) ? 1'b1 : 1'b0;

    // Sram subsystem access, 
    assign sram_subs_access = ( (htrans[1] & hsel) & (hready))? 1'b1 : 1'b0;

    // valid access: sram sub system is access and there is not size error
    assign valid_access = sram_subs_access & ~size_error;

    // Pull hready low only if there is an access has a size error 
    assign hready_error = sram_subs_access & size_error;

    // Flag error or ignore access that occurs when hready output is low
    always @(posedge hclk or negedge n_hreset)
    begin
        if (~n_hreset)
        begin
            r_hready  <= 1'b1;
            r_hresp_0 <= 1'b0;
        end // if (!n_hreset)
        else
        begin
            r_hready  <= (~hready_error & hready_RWconflict);
            if(hready_error) 
                r_hresp_0 <= 1'b1;
            //else if (hready_in)
            else if (hready)
                r_hresp_0 <= 1'b0;
        end
    end // always @(posedge hclk ..

    assign hready   = r_hready;
    assign hresp    = r_hresp_0;
endmodule // module sram_response_gen