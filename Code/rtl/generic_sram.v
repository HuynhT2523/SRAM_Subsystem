module generic_sram # (
    parameter DW = 140,     // width of data busses
    parameter DD = 1024,    // depth of RAM
    parameter AW = 10       // width of address bus
) (
    input wire          clk,    // posedge clock
    input wire          n_cs,   // RAM select
    input wire          n_we,   // read=1/write=0
    input wire          n_oe,   // output enable
    input wire [DW-1:0] mask,   // if 1 bit not written
    input wire [AW-1:0] ad,     // address
    input wire [DW-1:0] din,    // data in

    output wire [DW-1:0] dout   // data out
);
    // Internal signal
    reg     [DW-1:0] ram_array[DD-1:0];  // RAM array
    reg     [DW-1:0] ram_data;           // RAM output data
    wire    [AW-1:0] ram_addr = ad;      // buffer address

    // Ram access on rising edge of clock
    // RAM does nothing if not selected
    always @ ( posedge clk ) begin : p_array
        if ( n_cs == 1'b0 ) begin
            if ( n_we == 1'b1 ) ram_data <= ram_array[ram_addr];
            else ram_array[ram_addr] <= (din & ~mask) | (ram_array[ram_addr] & mask);
        end else begin
            ram_data <= ram_data;
        end
    end // p_array

    // RAM output disabled if either not selected or not enabled
    assign dout = ram_data;
endmodule // retry_sram_128